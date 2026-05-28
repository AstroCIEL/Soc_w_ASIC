###############################################################################
# syn/scripts/hier.tcl
# Helper procs for hierarchical block-based synthesis.
#
# This script provides:
#   - Query/utility procs for HIER_BLOCKS data (defined in setup/blocks.tcl)
#   - Compilation procs: _compile_hier_block, _read_hier_block, _compile_top_shell
#
# Sourced by synth.tcl when SYN_MODE=hier.
# Requires: HIER_BLOCKS (global), BUILD_DIR, TOP_MODULE, ACTIVE_SCENARIOS
###############################################################################

# ===========================================================================
# Query / utility procs
# ===========================================================================

# Return all hier_paths
proc hier_block_paths {} {
    global HIER_BLOCKS
    set paths {}
    foreach entry $HIER_BLOCKS {
        lappend paths [lindex $entry 0]
    }
    return $paths
}

# Return ref_name for a hier_path
proc hier_block_ref {hier_path} {
    global HIER_BLOCKS
    foreach entry $HIER_BLOCKS {
        if {[lindex $entry 0] eq $hier_path} {
            return [lindex $entry 1]
        }
    }
    error "Hier path '$hier_path' not found in HIER_BLOCKS"
}

# Return description for a hier_path
proc hier_block_desc {hier_path} {
    global HIER_BLOCKS
    foreach entry $HIER_BLOCKS {
        if {[lindex $entry 0] eq $hier_path} {
            return [lindex $entry 2]
        }
    }
    return ""
}

# Convert hier_path to a safe filename (replace / with __)
proc hier_path_to_filename {hier_path} {
    return [string map {/ __} $hier_path]
}

# Return DDC path for a compiled block
proc hier_block_ddc {hier_path} {
    global BUILD_DIR
    set fname [hier_path_to_filename $hier_path]
    return ${BUILD_DIR}/blocks/${fname}.ddc
}

# Check if a block DDC exists
proc hier_block_compiled {hier_path} {
    return [file exists [hier_block_ddc $hier_path]]
}

# Return list of blocks with valid DDC files
proc hier_blocks_available {} {
    set avail {}
    foreach hp [hier_block_paths] {
        if {[hier_block_compiled $hp]} {
            lappend avail $hp
        }
    }
    return $avail
}

# Return list of blocks missing DDC files
proc hier_blocks_missing {} {
    set missing {}
    foreach hp [hier_block_paths] {
        if {![hier_block_compiled $hp]} {
            lappend missing $hp
        }
    }
    return $missing
}

# Check if hier_path is an ancestor of another block
# (i.e., another block's path starts with "$hier_path/")
proc hier_block_has_children {hier_path} {
    global HIER_BLOCKS
    foreach entry $HIER_BLOCKS {
        set ep [lindex $entry 0]
        if {$ep ne $hier_path && [string match "${hier_path}/*" $ep]} {
            return 1
        }
    }
    return 0
}

# Return children of a given hier_path
proc hier_block_children {hier_path} {
    global HIER_BLOCKS
    set children {}
    foreach entry $HIER_BLOCKS {
        set ep [lindex $entry 0]
        if {$ep ne $hier_path && [string match "${hier_path}/*" $ep]} {
            lappend children $ep
        }
    }
    return $children
}

# Return the parent block of a given hier_path (if any; "" if none)
proc hier_block_parent {hier_path} {
    global HIER_BLOCKS
    set best_parent ""
    set best_len 0
    foreach entry $HIER_BLOCKS {
        set ep [lindex $entry 0]
        if {$ep ne $hier_path && [string match "${ep}/*" $hier_path]} {
            if {[string length $ep] > $best_len} {
                set best_parent $ep
                set best_len [string length $ep]
            }
        }
    }
    return $best_parent
}

# Return only "leaf" blocks (no children in HIER_BLOCKS)
proc hier_blocks_leaves {} {
    set leaves {}
    foreach hp [hier_block_paths] {
        if {![hier_block_has_children $hp]} {
            lappend leaves $hp
        }
    }
    return $leaves
}

# Return only "root" blocks (no parent in HIER_BLOCKS)
proc hier_blocks_roots {} {
    set roots {}
    foreach hp [hier_block_paths] {
        if {[hier_block_parent $hp] eq ""} {
            lappend roots $hp
        }
    }
    return $roots
}

# Pretty-print block hierarchy with compile status
proc hier_blocks_report {} {
    global HIER_BLOCKS
    puts "== \[hier\] Block partition ============================================"
    puts [format "  %-4s %-45s %-22s %s" "" "HIER_PATH" "REF_NAME" "STATUS"]
    puts "  [string repeat - 95]"
    foreach entry $HIER_BLOCKS {
        set hp [lindex $entry 0]
        set rn [lindex $entry 1]
        set desc [lindex $entry 2]

        # Indentation based on depth (number of / separators)
        set depth [llength [split $hp /]]
        set indent [string repeat "  " [expr {$depth - 1}]]

        if {[hier_block_compiled $hp]} {
            set st "CACHED"
        } else {
            set st "NEEDS COMPILE"
        }
        puts [format "  %-4s %-45s %-22s %s" $indent${depth}. $hp $rn $st]
    }
    puts "======================================================================"
}

# ---------------------------------------------------------------------------
# hier_build_compile_list
#   Build the ordered compile list: explicit blocks + any with missing DDCs.
#   Returns a flat list sorted bottom-up (leaves first, then parents).
#
#   Args:
#     explicit_blocks - user-specified blocks to (re)compile
# ---------------------------------------------------------------------------
proc hier_build_compile_list {explicit_blocks} {
    # Start with explicit list
    set to_compile $explicit_blocks

    # Auto-add any blocks without a cached DDC
    foreach hp [hier_block_paths] {
        if {![hier_block_compiled $hp] && [lsearch -exact $to_compile $hp] < 0} {
            puts "   AUTO-ADD: $hp (no cached DDC)"
            lappend to_compile $hp
        }
    }

    if {[llength $to_compile] == 0} {
        return {}
    }

    # Sort bottom-up: leaves first, then parents
    set leaves {}
    set parents {}
    foreach hp $to_compile {
        if {[hier_block_has_children $hp]} {
            lappend parents $hp
        } else {
            lappend leaves $hp
        }
    }

    # Return leaves followed by parents (deeper parents first would be ideal
    # for multi-level nesting, but current hierarchy is max 2 levels)
    return [concat $leaves $parents]
}

# ===========================================================================
# Physical environment setup
# ===========================================================================
proc _apply_mcmm_physical_env {} {
    set _design [current_design .]
    puts "   \[env\] Applying OC + TLU+ to design: $_design"
    foreach _s $::ACTIVE_SCENARIOS {
        mmmc_current_scenario $_s
        set _corner [lindex $::_mmmc_SCENARIO_DEF($_s) 0]
        mmmc_set_operating_conditions $_corner $::SRAM_MACROS
    }
    physical_set_tluplus $::ACTIVE_SCENARIOS
}

# ===========================================================================
# Compilation procs
# ===========================================================================

# Compile a single hierarchical block: characterize from top, compile in
# sub-design context, save DDC.
proc _compile_hier_block {hier_path} {
    global TOP_MODULE BLOCKS_DIR REPORT_DIR COMPILE_OPTIONS COMPILE_MAX_CORES

    set ref_name [hier_block_ref $hier_path]
    set ddc_path [hier_block_ddc $hier_path]
    set fname    [hier_path_to_filename $hier_path]

    puts ""
    puts "== \[hier\] Compiling block: $hier_path ($ref_name)"
    puts "         DDC target: $ddc_path"

    current_design $TOP_MODULE

    set cell_obj [get_cells $hier_path -quiet]
    if {[sizeof_collection $cell_obj] == 0} {
        error "Cannot find cell '$hier_path' under $TOP_MODULE"
    }

    puts "   characterizing $hier_path ..."
    characterize -constraints $cell_obj

    set sub_design [get_attribute $cell_obj ref_name]
    current_design $sub_design
    link

    # Sub-design needs explicit OC + TLU+ (characterize does not propagate these)
    _apply_mcmm_physical_env

    set _compile_cmd "compile_ultra"
    foreach opt $COMPILE_OPTIONS {
        append _compile_cmd " $opt"
    }
    puts "   \[compile\] $_compile_cmd"
    eval $_compile_cmd

    set _blk_rpt_dir ${REPORT_DIR}/blocks/${fname}
    file mkdir ${_blk_rpt_dir}
    report_area   -nosplit                                      > ${_blk_rpt_dir}/area.rpt
    report_qor                                                  > ${_blk_rpt_dir}/qor.rpt
    report_timing -delay max -nosplit -max_paths 10             > ${_blk_rpt_dir}/timing_max.rpt
    report_timing -delay min -nosplit -max_paths 10             > ${_blk_rpt_dir}/timing_min.rpt

    write -f ddc -hierarchy -output $ddc_path
    puts "   \[saved\] $ddc_path"

    current_design $TOP_MODULE
    link

    puts "== \[hier\] Block $hier_path DONE"
    puts ""
    timer_mark "  block: $hier_path"
}

# Read a single block DDC and link (used for reading child DDCs before parent compile).
proc _read_hier_block {hier_path} {
    global TOP_MODULE

    set ddc_path [hier_block_ddc $hier_path]
    if {![file exists $ddc_path]} {
        error "Block DDC not found: $ddc_path\n  Run: make hier BLOCK=\"$hier_path\""
    }

    puts "   \[read\] $hier_path <- $ddc_path"
    read_ddc $ddc_path
    current_design $TOP_MODULE
    link
}

# ---------------------------------------------------------------------------
# _assemble_hier_roots
#   Three-phase assembly to avoid shared-design conflicts:
#     1) Remove all root block hierarchies from memory (batch)
#     2) Read all root block DDCs into memory (batch)
#     3) Link once
# ---------------------------------------------------------------------------
proc _assemble_hier_roots {} {
    global TOP_MODULE

    current_design $TOP_MODULE

    # Phase 1: remove all stale elaborated root block hierarchies
    puts "== \[hier\] Phase: remove stale block hierarchies"
    foreach hp [hier_blocks_roots] {
        set cell_obj [get_cells $hp -quiet]
        if {[sizeof_collection $cell_obj] == 0} { continue }
        set rn [get_attribute $cell_obj ref_name]
        if {$rn eq $TOP_MODULE} {
            error "Refusing to remove TOP_MODULE itself: $rn"
        }
        if {[sizeof_collection [get_designs $rn -quiet]] > 0} {
            puts "   \[cleanup\] remove_design -hierarchy $rn"
            remove_design -hierarchy $rn
        }
    }

    # Phase 2: read all root block DDCs into memory
    puts "== \[hier\] Phase: read compiled block DDCs"
    foreach hp [hier_blocks_roots] {
        set ddc_path [hier_block_ddc $hp]
        if {![file exists $ddc_path]} {
            error "Block DDC not found: $ddc_path\n  Run: make hier BLOCK=\"$hp\""
        }
        puts "   \[read\] $hp <- $ddc_path"
        read_ddc $ddc_path
    }

    # Phase 3: single link
    current_design $TOP_MODULE
    link
    puts "== \[hier\] Assembly link complete"
}

# ---------------------------------------------------------------------------
# _check_unmapped_cells
#   Check that no unmapped cells remain INSIDE declared blocks.
#   Top-level glue being unmapped is expected (compiled by _compile_top_shell).
# ---------------------------------------------------------------------------
proc _check_unmapped_cells {} {
    global TOP_MODULE HIER_BLOCKS
    current_design $TOP_MODULE

    set block_unmapped 0
    set examples {}
    foreach entry $HIER_BLOCKS {
        set hp [lindex $entry 0]
        set cells [get_cells ${hp}/* -hierarchical -filter "is_mapped == false" -quiet]
        if {[sizeof_collection $cells] > 0} {
            set n [sizeof_collection $cells]
            incr block_unmapped $n
            if {[llength $examples] < 5} {
                foreach_in_collection c $cells {
                    if {[llength $examples] >= 5} { break }
                    lappend examples "[get_object_name $c] ([get_attribute $c ref_name])"
                }
            }
        }
    }

    if {$block_unmapped > 0} {
        foreach e $examples {
            puts "   UNMAPPED (block): $e"
        }
        error "Blocks contain $block_unmapped unmapped cells after assembly. DDC read failed."
    }
    puts "   \[check\] no unmapped cells inside blocks — assembly OK"
}

# Compile top-level shell in two phases:
#   1) Freeze pre-compiled blocks and optimize the top-level glue logic.
#   2) Release the blocks and run an incremental timing-repair pass in the
#      final top-level physical context.  This is required in topo mode because
#      block standalone placement/RC can differ from the assembled top placement/RC.
proc _compile_top_shell {} {
    global TOP_MODULE COMPILE_OPTIONS COMPILE_MAX_CORES HIER_BLOCKS

    current_design $TOP_MODULE

    puts "== \[hier\] Phase 1: compile top shell with blocks frozen"
    foreach entry $HIER_BLOCKS {
        set hp [lindex $entry 0]
        set cell_obj [get_cells $hp -quiet]
        if {[sizeof_collection $cell_obj] > 0} {
            set_dont_touch $cell_obj
            puts "   dont_touch (block): $hp"
        }
    }

    set _compile_cmd "compile_ultra"
    foreach opt $COMPILE_OPTIONS {
        append _compile_cmd " $opt"
    }
    puts "   \[compile\] $_compile_cmd"
    eval $_compile_cmd
    timer_mark "  top-shell phase 1: glue compile"

    puts "== \[hier\] Phase 2: release blocks and repair timing incrementally"
    foreach entry $HIER_BLOCKS {
        set hp [lindex $entry 0]
        set cell_obj [get_cells $hp -quiet]
        if {[sizeof_collection $cell_obj] > 0} {
            remove_attribute $cell_obj dont_touch
            puts "   released (block): $hp"
        }
    }

    # Run incremental optimization after block release so DC can fix internal
    # timing violations exposed by the final top-level physical placement.
    set _repair_cmd "compile_ultra -incremental"
    foreach opt $COMPILE_OPTIONS {
        append _repair_cmd " $opt"
    }
    puts "   \[compile\] $_repair_cmd"
    eval $_repair_cmd
    timer_mark "  top-shell phase 2: incremental timing repair"
}
