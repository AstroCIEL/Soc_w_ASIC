###############################################################################
# syn/scripts/synth.tcl
# Flat DC NXT synthesis driver.
#
# INCR_CHECKPOINT:
#   NONE             — full compile from RTL
#   post_constraints — resume after constraints, then compile + report
#   post_compile     — restore compiled DDC and regenerate outputs/reports
###############################################################################

# ===========================================================================
# Intercept Makefile variables → internal Tcl variables
# ===========================================================================

proc capture_var {name args} {
    upvar 1 $name var
    if {[info exists var]} { return }                          ;# already set by -x
    if {[info exists ::env($name)]} {
        set var $::env($name)
        return
    }
    if {[llength $args] == 0} {
        error "$name is required but was not passed by the Makefile or environment."
    }
    set var [lindex $args 0]
}

capture_var PDK_ROOT                                           ;# required
capture_var SYN_ROOT                                           ;# required
capture_var BUILD_DIR                                          ;# required
capture_var SYN_MODE              flat                         ;# retained for compatibility; must be flat
capture_var SYN_TARGET            axu                          ;# mxu, axu, top, custom
capture_var TOP_MODULE_OVERRIDE   ""                           ;# optional override
capture_var NETLIST_NAMESPACE_PREFIX_OVERRIDE ""               ;# optional override
capture_var NETLIST_UNIQUIFY_ENABLE auto                       ;# auto, 0, 1
capture_var NETLIST_CHANGE_NAMES_ENABLE auto                   ;# auto, 0, 1
capture_var INCR_CHECKPOINT       NONE                         ;# NONE, post_constraints, post_compile

set env(PDK_ROOT) $PDK_ROOT   ;# keep env in sync for child scripts

# Derived directory layout
set SETUP_DIR   "${SYN_ROOT}/setup"
set SCRIPTS_DIR "${SYN_ROOT}/scripts"
set REPORT_DIR  "${BUILD_DIR}/reports"
set OUTPUT_DIR  "${BUILD_DIR}/outputs"

# ===========================================================================
# Step 0: Project configuration + environment check
# ===========================================================================
source ${SCRIPTS_DIR}/tools.tcl
source ${SETUP_DIR}/setup.tcl
source ${SCRIPTS_DIR}/check-env.tcl

file mkdir ${BUILD_DIR} ${REPORT_DIR} ${OUTPUT_DIR}

# ===========================================================================
# 0529： 添加SVF文件的生成命令
# ===========================================================================
set SVF_FILE ${OUTPUT_DIR}/${TOP_MODULE}.svf
file delete -force $SVF_FILE
puts "== \[svf\] writing Formality guidance: $SVF_FILE"
set_svf $SVF_FILE

# ===========================================================================
# Step 1: Load generic scripts (defines procs only, no side effects yet)
# ===========================================================================
source ${SCRIPTS_DIR}/mmmc.tcl
source ${SCRIPTS_DIR}/physical.tcl
source ${SCRIPTS_DIR}/output.tcl

puts "=================================================================="
puts "  SYN_ROOT   : $SYN_ROOT"
puts "  BUILD_DIR  : $BUILD_DIR"
puts "  SYN_TARGET : $SYN_TARGET"
puts "  TOP_MODULE : $TOP_MODULE"
puts "  SYN_MODE   : $SYN_MODE"
if {$INCR_CHECKPOINT ne "NONE"} {
    puts "  CHECKPOINT : $INCR_CHECKPOINT"
}
puts "=================================================================="

timer_mark "Step 0-1: Setup & config"

# ===========================================================================
# Step 2: Clean slate
# ===========================================================================
remove_design -all

# ===========================================================================
# Step 3: Global timing-library setup (must precede elaborate / read_ddc)
# ===========================================================================
define_design_lib WORK -path ${BUILD_DIR}/WORK

mmmc_setup_global_libs $SRAM_MACROS

timer_mark "Step 3: Timing library setup"

# ===========================================================================
# Step 4: Physical library setup
# ===========================================================================
physical_open_mw_lib

timer_mark "Step 4: Physical library setup"

# ===========================================================================
# Incremental resume: determine which steps to skip.
# ===========================================================================

if {$INCR_CHECKPOINT eq "NONE"} {
    set _skip_elab        0
    set _skip_constraints 0
    set _skip_compile     0
} elseif {$INCR_CHECKPOINT eq "post_constraints"} {
    set _skip_elab        1
    set _skip_constraints 1
    set _skip_compile     0
} elseif {$INCR_CHECKPOINT eq "post_compile"} {
    set _skip_elab        1
    set _skip_constraints 1
    set _skip_compile     1
}

# ===========================================================================
# Step 5: Restore checkpoint DDC
# ===========================================================================

if {$_skip_elab} {
    set _ddc [checkpoint_ddc $INCR_CHECKPOINT $OUTPUT_DIR $TOP_MODULE]
    if {![file exists $_ddc]} {
        error "Checkpoint DDC not found: $_ddc\nRun full flow first (make flat SYN_TARGET=$SYN_TARGET)."
    }
    puts "== \[step 5\] reading checkpoint: $_ddc"
    read_ddc $_ddc
    set ELAB_NAME [get_object_name [current_design]]
    puts "   restored design: $ELAB_NAME"
    link
}

timer_mark "Step 5: Restore checkpoint"

# ===========================================================================
# Step 6: Elaborate
# ===========================================================================

if {!$_skip_elab} {
    set _input_tcl ${BUILD_DIR}/input.tcl
    if {![file exists $_input_tcl]} {
        error "build input.tcl not found: $_input_tcl. Run 'make gen_filelist' first."
    }
    source $_input_tcl

    elaborate ${TOP_MODULE} -library WORK
    set ELAB_NAME [get_object_name [current_design]]
    puts "== \[step 6\] elaborated design: $ELAB_NAME"
    link

    # Mark SRAM macros dont_touch
    foreach macro $SRAM_MACROS {
        set cells [get_cells -hier -filter "ref_name == $macro" -quiet]
        if {[sizeof_collection $cells] > 0} {
            set_dont_touch $cells
            puts "   dont_touch: [sizeof_collection $cells]x $macro"
        }
    }

    write -f verilog -hierarchy -output ${OUTPUT_DIR}/${ELAB_NAME}_unmapped.v
    report_resources          > ${REPORT_DIR}/resources_precompile.rpt
}

timer_mark "Step 6: Elaborate"

# ===========================================================================
# Step 7: MCMM scenarios + constraints
# ===========================================================================

if {!$_skip_constraints} {
    mmmc_create_scenarios ${SETUP_DIR}/constraints.tcl $SRAM_MACROS
    physical_set_tluplus $ACTIVE_SCENARIOS
    check_design > ${REPORT_DIR}/check_design.rpt
    save_checkpoint post_constraints $ENABLE_CHECKPOINTS $OUTPUT_DIR $TOP_MODULE
} else {
    puts "== \[incr\] skipping constraint setup (resuming from $INCR_CHECKPOINT)"
    mmmc_set_active_scenarios $ACTIVE_SCENARIOS
}

timer_mark "Step 7: MCMM constraints"

# ===========================================================================
# Step 8: Compile
# ===========================================================================

if {!$_skip_compile} {
    set_host_options -max_cores $COMPILE_MAX_CORES

    if {[netlist_namespace_enabled]} {
        global uniquify_naming_style
        set uniquify_naming_style "${NETLIST_NAMESPACE_PREFIX}%s_%d"
        puts "== \[namespace\] pre-compile style = $uniquify_naming_style"
    }

    set _compile_cmd "compile_ultra"
    foreach opt $COMPILE_OPTIONS {
        append _compile_cmd " $opt"
    }
    if {$INCR_CHECKPOINT eq "post_constraints"} {
        append _compile_cmd " -incremental"
    }

    puts "== \[flat\] $_compile_cmd"
    eval $_compile_cmd

    apply_netlist_namespace "post-compile"
    save_checkpoint post_compile $ENABLE_CHECKPOINTS $OUTPUT_DIR $TOP_MODULE
} else {
    puts "== \[incr\] skipping compile (resuming from $INCR_CHECKPOINT)"
}

timer_mark "Step 8: Compile"

# ===========================================================================
# Step 9: Post-compile outputs
# ===========================================================================
output_post_compile $TOP_MODULE $ELAB_NAME $OUTPUT_DIR $ACTIVE_SCENARIOS

# ===========================================================================
# Close SVF file
# ===========================================================================
puts "== \[svf\] closing Formality guidance: $SVF_FILE"
set_svf -off

timer_mark "Step 9: Post-compile outputs"

# ===========================================================================
# Step 10: Reports
# ===========================================================================
output_reports $REPORT_DIR $ACTIVE_SCENARIOS $MAX_PATHS

timer_mark "Step 10: Reports"

puts "=================================================================="
puts "  Synthesis complete."
puts "  Target  : $SYN_TARGET"
puts "  Top     : $TOP_MODULE"
puts "  Outputs : $OUTPUT_DIR"
puts "  Reports : $REPORT_DIR"
puts "=================================================================="

timer_report

exit
