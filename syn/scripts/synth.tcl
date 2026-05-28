###############################################################################
# syn/scripts/synth.tcl
# Unified DC NXT synthesis driver.
#
# SYN_MODE (string):
#   "flat" — Flat synthesis.
#              INCR_CHECKPOINT=NONE → full compile from RTL
#              INCR_CHECKPOINT=<phase> → resume from that checkpoint DDC
#   "hier" — Hierarchical block-level synthesis.
#              HIER_COMPILE_BLOCKS non-empty → recompile those blocks + assemble top
#              HIER_COMPILE_BLOCKS empty     → assemble top from cached block DDCs only
###############################################################################

# ===========================================================================
# Intercept Makefile variables → internal Tcl variables
# ===========================================================================

proc capture_var {name args} {
    upvar 1 $name var
    if {[info exists var]} { return }
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
capture_var SYN_MODE              flat                         ;# "flat" or "hier"
capture_var INCR_CHECKPOINT       NONE                         ;# flat: NONE=full, or phase name
capture_var HIER_COMPILE_BLOCKS   {}                           ;# hier: blocks to recompile

set env(PDK_ROOT) $PDK_ROOT   ;# keep env in sync for child scripts

# Derived directory layout
set SETUP_DIR   "${SYN_ROOT}/setup"
set SCRIPTS_DIR "${SYN_ROOT}/scripts"
set REPORT_DIR  "${BUILD_DIR}/reports"
set OUTPUT_DIR  "${BUILD_DIR}/outputs"
set BLOCKS_DIR  "${BUILD_DIR}/blocks"

# ===========================================================================
# Step 0: Project configuration + environment check
# ===========================================================================
source ${SCRIPTS_DIR}/tools.tcl
source ${SETUP_DIR}/setup.tcl
source ${SCRIPTS_DIR}/check-env.tcl

file mkdir ${BUILD_DIR} ${REPORT_DIR} ${OUTPUT_DIR}

# Load block definitions and helper procs for hier mode
if {$SYN_MODE eq "hier"} {
    source ${SETUP_DIR}/blocks.tcl
    source ${SCRIPTS_DIR}/hier.tcl
    file mkdir ${BLOCKS_DIR}
}

# ===========================================================================
# Step 1: Load generic scripts (defines procs only, no side effects yet)
# ===========================================================================
source ${SCRIPTS_DIR}/mmmc.tcl
source ${SCRIPTS_DIR}/physical.tcl
source ${SCRIPTS_DIR}/output.tcl

puts "=================================================================="
puts "  SYN_ROOT   : $SYN_ROOT"
puts "  BUILD_DIR  : $BUILD_DIR"
puts "  TOP_MODULE : $TOP_MODULE"
puts "  SYN_MODE   : $SYN_MODE"
if {$INCR_CHECKPOINT ne "NONE"} {
    puts "  CHECKPOINT : $INCR_CHECKPOINT"
}
if {$SYN_MODE eq "hier"} {
    if {$HIER_COMPILE_BLOCKS eq ""} {
        puts "  ACTION     : assemble top from cached block DDCs"
    } else {
        puts "  BLOCKS     : $HIER_COMPILE_BLOCKS"
    }
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
# Works with both flat and hier modes.
#
#   INCR_CHECKPOINT       | skip_elab | skip_constraints | skip_assemble | skip_compile
#   ----------------------+-----------+------------------+---------------+-------------
#   NONE (full)           |    no     |       no         |      no       |     no
#   post_constraints      |    yes    |      yes         |      no       |     no
#   post_assemble (hier)  |    yes    |      yes         |     yes       |     no
#   post_compile          |    yes    |      yes         |     yes       |    yes
#
# ===========================================================================

if {$INCR_CHECKPOINT eq "NONE"} {
    set _skip_elab        0
    set _skip_constraints 0
    set _skip_assemble    0
    set _skip_compile     0
} elseif {$INCR_CHECKPOINT eq "post_constraints"} {
    set _skip_elab        1
    set _skip_constraints 1
    set _skip_assemble    0
    set _skip_compile     0
} elseif {$INCR_CHECKPOINT eq "post_assemble"} {
    set _skip_elab        1
    set _skip_constraints 1
    set _skip_assemble    1
    set _skip_compile     0
} elseif {$INCR_CHECKPOINT eq "post_compile"} {
    set _skip_elab        1
    set _skip_constraints 1
    set _skip_assemble    1
    set _skip_compile     1
}

# ===========================================================================
# Step 5: Restore checkpoint DDC
# ===========================================================================

if {$_skip_elab} {
    set _ddc [checkpoint_ddc $INCR_CHECKPOINT $OUTPUT_DIR $TOP_MODULE]
    if {![file exists $_ddc]} {
        error "Checkpoint DDC not found: $_ddc\nRun full flow first (make flat / make hier)."
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
        error "build/input.tcl not found. Run 'make gen_filelist' first."
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

    if {$SYN_MODE eq "flat"} {
        # ==============================================================
        # FLAT: single compile_ultra pass on entire design
        # ==============================================================
        set _compile_cmd "compile_ultra"
        foreach opt $COMPILE_OPTIONS {
            append _compile_cmd " $opt"
        }
        # Append -incremental when resuming from post_constraints checkpoint
        if {$INCR_CHECKPOINT eq "post_constraints"} {
            append _compile_cmd " -incremental"
        }

        puts "== \[flat\] $_compile_cmd"
        eval $_compile_cmd

        save_checkpoint post_compile $ENABLE_CHECKPOINTS $OUTPUT_DIR $TOP_MODULE

    } else {
        # ==============================================================
        # HIER: block-level compile + assemble top
        # ==============================================================
        if {!$_skip_assemble} {
            hier_blocks_report

            set _compile_list [hier_build_compile_list $HIER_COMPILE_BLOCKS]

            if {[llength $_compile_list] > 0} {
                puts "== \[hier\] Compile order: $_compile_list"
                foreach hp $_compile_list {
                    # For parent blocks: read cached child DDCs first
                    if {[hier_block_has_children $hp]} {
                        foreach child [hier_block_children $hp] {
                            if {[hier_block_compiled $child]} {
                                _read_hier_block $child
                            }
                        }
                    }
                    _compile_hier_block $hp
                }
            } else {
                puts "== \[hier\] All blocks have cached DDCs, assemble-only"
            }

            # Assemble top: batch remove + read DDCs + link once
            puts "== \[hier\] Assembling top ..."
            _assemble_hier_roots
            _check_unmapped_cells

            save_checkpoint post_assemble $ENABLE_CHECKPOINTS $OUTPUT_DIR $TOP_MODULE
        } else {
            puts "== \[hier\] skipping assemble (resuming from $INCR_CHECKPOINT)"
        }

        _compile_top_shell

        save_checkpoint post_compile $ENABLE_CHECKPOINTS $OUTPUT_DIR $TOP_MODULE
    }

} else {
    puts "== \[incr\] skipping compile (resuming from $INCR_CHECKPOINT)"
}

timer_mark "Step 8: Compile"

# ===========================================================================
# Step 9: Post-compile outputs
# ===========================================================================
output_post_compile $TOP_MODULE $ELAB_NAME $OUTPUT_DIR $ACTIVE_SCENARIOS

timer_mark "Step 9: Post-compile outputs"

# ===========================================================================
# Step 10: Reports
# ===========================================================================
output_reports $REPORT_DIR $ACTIVE_SCENARIOS $MAX_PATHS

timer_mark "Step 10: Reports"

puts "=================================================================="
puts "  Synthesis complete.  (SYN_MODE=$SYN_MODE)"
puts "  Outputs : $OUTPUT_DIR"
puts "  Reports : $REPORT_DIR"
if {$SYN_MODE eq "hier"} {
    puts "  Blocks  : $BLOCKS_DIR"
}
puts "=================================================================="

timer_report

exit
