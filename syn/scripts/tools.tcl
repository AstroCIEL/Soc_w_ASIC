###############################################################################
# syn/scripts/tools.tcl
# Generic utility procs for synthesis scripts.
###############################################################################

# ===========================================================================
# Step timing
# ===========================================================================

set _timer_steps {}
set _timer_t0 [clock seconds]
set _timer_last $_timer_t0

proc timer_mark {step_name} {
    global _timer_steps _timer_last
    set now [clock seconds]
    set elapsed [expr {$now - $_timer_last}]
    lappend _timer_steps [list $step_name $elapsed]
    set _timer_last $now
}

proc timer_report {} {
    global _timer_steps _timer_t0
    set total [expr {[clock seconds] - $_timer_t0}]
    puts ""
    puts "=================================================================="
    puts "  Step Timing Report"
    puts "=================================================================="
    puts [format "  %-45s %10s %8s" "STEP" "ELAPSED(s)" "  %"]
    puts "  [string repeat - 70]"
    foreach entry $_timer_steps {
        set name [lindex $entry 0]
        set secs [lindex $entry 1]
        if {$total > 0} {
            set pct [format "%5.1f%%" [expr {100.0 * $secs / $total}]]
        } else {
            set pct "  -  "
        }
        puts [format "  %-45s %10d %8s" $name $secs $pct]
    }
    puts "  [string repeat - 70]"
    puts [format "  %-45s %10d %8s" "TOTAL" $total "100.0%"]
    puts "=================================================================="
}

# ===========================================================================
# Checkpoint helpers
# ===========================================================================

proc checkpoint_ddc {phase output_dir top_module} {
    return ${output_dir}/${top_module}_${phase}.ddc
}

proc save_checkpoint {phase enable output_dir top_module} {
    if {!$enable} { return }
    set path [checkpoint_ddc $phase $output_dir $top_module]
    puts "== \[checkpoint\] saving $phase -> $path"
    write -f ddc -hierarchy -output $path
}

# ===========================================================================
# Netlist namespace helpers
# ===========================================================================

proc netlist_namespace_enabled {} {
    if {![info exists ::NETLIST_UNIQUIFY_ENABLE]} { return 0 }
    if {$::NETLIST_UNIQUIFY_ENABLE eq "0"} { return 0 }
    if {$::NETLIST_UNIQUIFY_ENABLE eq "1"} { return 1 }
    if {$::NETLIST_UNIQUIFY_ENABLE eq "auto"} {
        return [expr {[info exists ::NETLIST_NAMESPACE_PREFIX] && $::NETLIST_NAMESPACE_PREFIX ne ""}]
    }
    error "NETLIST_UNIQUIFY_ENABLE must be 0, 1, or auto; got '$::NETLIST_UNIQUIFY_ENABLE'."
}

proc apply_netlist_namespace {stage} {
    global uniquify_naming_style

    if {![netlist_namespace_enabled]} {
        puts "== \[namespace\] disabled at $stage"
        return
    }
    if {![info exists ::NETLIST_NAMESPACE_PREFIX] || $::NETLIST_NAMESPACE_PREFIX eq ""} {
        error "NETLIST_NAMESPACE_PREFIX must be non-empty when namespace uniquify is enabled."
    }

    set uniquify_naming_style "${::NETLIST_NAMESPACE_PREFIX}%s_%d"
    puts "== \[namespace\] $stage: uniquify_naming_style = $uniquify_naming_style"
    uniquify -force
    link
}
