# Suppress known-false combinatorial loop warnings from AXI valid/ready handshake logic.
# Synth 8-295: Vivado flags AXI READY-depends-on-VALID paths as timing loops; this is a
# known pattern in common_cells / iDMA / axi_xbar. Vivado automatically infers
# set_disable_timing to handle these paths; downgrading to WARNING is safe.
set_msg_config -id {Synth 8-295} -new_severity WARNING

# Area-oriented synthesis hints:
# -resource_sharing encourages common arithmetic sharing
# -flatten_hierarchy rebuilt gives Vivado more global optimization freedom
set_property STEPS.SYNTH_DESIGN.ARGS.DIRECTIVE AreaOptimized_high [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.ARGS.RESOURCE_SHARING auto [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY rebuilt [get_runs synth_1]

# --------------------------------------------------------------------------
# Incremental Synthesis: use previous synth checkpoint as reference
# --------------------------------------------------------------------------
set SYNTH_REF_DCP "checkpoints/synth_reference.dcp"

set outdated [get_property NEEDS_REFRESH [get_runs synth_1]]
set progress [get_property PROGRESS [get_runs synth_1]]

if {$outdated || $progress != "100%"} {
    # If a reference checkpoint exists, enable incremental synthesis
    if {[file exists $SYNTH_REF_DCP]} {
        puts "INFO: Using incremental synthesis with reference: $SYNTH_REF_DCP"
        set_property INCREMENTAL_CHECKPOINT $SYNTH_REF_DCP [get_runs synth_1]
    } else {
        puts "INFO: No reference checkpoint found — running full synthesis"
    }

    reset_runs synth_1
    launch_runs synth_1 -jobs [expr {[info exists ::env(JOBS)] ? $::env(JOBS) : 4}]
    wait_on_run synth_1
}

# Generate reports unconditionally (even on failure, partial reports are useful)
file mkdir reports
catch { open_run synth_1 }

report_utilization    -file reports/synth_utilization.rpt
report_timing_summary -file reports/synth_timing.rpt -warn_on_violation
report_drc            -file reports/synth_drc.rpt


# Fail after reports if synthesis did not complete
if {[get_property STATUS [get_runs synth_1]] ne "synth_design Complete!"} {
    puts "ERROR: Synthesis failed. See reports/synth_messages.rpt"
    exit 1
}

# Save current synth checkpoint as reference for next incremental run
file mkdir checkpoints
set synth_dcp [get_property DIRECTORY [get_runs synth_1]]/[get_property top [current_fileset]].dcp
if {[file exists $synth_dcp]} {
    file copy -force $synth_dcp $SYNTH_REF_DCP
    puts "INFO: Saved synth reference checkpoint: $SYNTH_REF_DCP"
}
