# Create a bin file which can be used to program the flash on the FPGA
set_property STEPS.WRITE_BITSTREAM.ARGS.BIN_FILE true [get_runs impl_1]

# --------------------------------------------------------------------------
# Incremental Implementation: use previous impl checkpoint as reference
# --------------------------------------------------------------------------
set IMPL_REF_DCP "checkpoints/impl_reference.dcp"

# Vivado will raise an error if impl_1 is launched when it is already done. So
# check the progress first and only launch if its not complete.
if { [get_property PROGRESS [get_runs impl_1]] != "100%"} {
  # If a reference checkpoint exists, enable incremental implementation
  if {[file exists $IMPL_REF_DCP]} {
      puts "INFO: Using incremental implementation with reference: $IMPL_REF_DCP"
      set_property INCREMENTAL_CHECKPOINT $IMPL_REF_DCP [get_runs impl_1]
  } else {
      puts "INFO: No reference checkpoint found — running full implementation"
  }

  launch_runs impl_1 -to_step write_bitstream -jobs [expr {[info exists ::env(JOBS)] ? $::env(JOBS) : 4}]
  wait_on_run impl_1
  puts "Bitstream generation completed"
} else {
  puts "Bitstream generation already complete"
}

# Generate implementation reports unconditionally
file mkdir reports
catch { open_run impl_1 }

report_utilization    -file reports/impl_utilization.rpt
report_timing_summary -file reports/impl_timing.rpt -warn_on_violation
report_drc            -file reports/impl_drc.rpt
report_power          -file reports/impl_power.rpt


puts "Implementation reports written to reports/"

if { [get_property PROGRESS [get_runs impl_1]] != "100%"} {
   puts "ERROR: Implementation and bitstream generation step failed. See reports/impl_errors.rpt"
   exit 1
}

# By default, Vivado writes the bitstream to a file named after the toplevel and
# put into the *.runs/impl_1 folder.
# fusesoc/edalize historically used a bitstream name based on the project name,
# and puts it into the top-level project workroot.
# To keep backwards-compat, copy the Vivado default bitstream file to the
# traditional edalize location.
# The Vivado default name is beneficial when using the GUI, as it is set as
# default bitstream in the "Program Device" dialog; non-standard names need to
# be selected from a file picker first.
set vivadoDefaultBitstreamFile [ get_property DIRECTORY [current_run] ]/[ get_property top [current_fileset] ].bit
file copy -force $vivadoDefaultBitstreamFile [pwd]/[current_project].bit

# Save current impl checkpoint as reference for next incremental run
file mkdir checkpoints
set impl_dcp [get_property DIRECTORY [get_runs impl_1]]/[get_property top [current_fileset]]_routed.dcp
if {[file exists $impl_dcp]} {
    file copy -force $impl_dcp $IMPL_REF_DCP
    puts "INFO: Saved impl reference checkpoint: $IMPL_REF_DCP"
}
