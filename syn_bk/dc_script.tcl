###############################################################################
# Ara SoC DC Synthesis Script
###############################################################################

# --------------------------------------------------------------------------
# Directory & variable setup (can be overridden by Makefile)
# --------------------------------------------------------------------------
if {![info exists SCRIPT_DIR]}  { set SCRIPT_DIR  [file dirname [file normalize [info script]]] }
if {![info exists PROJ_ROOT]}   { set PROJ_ROOT   [file normalize "${SCRIPT_DIR}/.."] }
if {![info exists TOP_MODULE]}  { set TOP_MODULE   ariane_soc_top }
if {![info exists REPORT_DIR]}  { set REPORT_DIR   ${SCRIPT_DIR}/reports }
if {![info exists OUTPUT_DIR]}  { set OUTPUT_DIR   ${SCRIPT_DIR}/outputs }

file mkdir ${REPORT_DIR}
file mkdir ${OUTPUT_DIR}

puts "=================================================================="
puts "  PROJ_ROOT  : ${PROJ_ROOT}"
puts "  SCRIPT_DIR : ${SCRIPT_DIR}"
puts "  TOP_MODULE : ${TOP_MODULE}"
puts "  REPORT_DIR : ${REPORT_DIR}"
puts "  OUTPUT_DIR : ${OUTPUT_DIR}"
puts "=================================================================="

# --------------------------------------------------------------------------
# Step 1: Clean slate
# --------------------------------------------------------------------------
remove_design -all

# --------------------------------------------------------------------------
# Step 2: Library setup
# --------------------------------------------------------------------------
source ${SCRIPT_DIR}/set_libs.tcl

define_design_lib WORK -path ${SCRIPT_DIR}/WORK

# --------------------------------------------------------------------------
# Step 3: Read RTL
# --------------------------------------------------------------------------
source ${SCRIPT_DIR}/read_design.tcl

# --------------------------------------------------------------------------
# Step 4: Elaborate & Link
# --------------------------------------------------------------------------
elaborate ${TOP_MODULE} -library WORK
# After parametric elaborate DC renames the design to e.g. ara_soc_NrLanes4_VLEN4096.
# Record the actual name for reference; downstream commands use [current_design].
set ELAB_NAME [get_object_name [current_design]]
puts "Elaborated design name: ${ELAB_NAME}"
link

# <TODO> Mark SRAM wrappers as dont_touch so DC treats them as black boxes.
# ariane_soc_top contains:
#   i_sram             — main DRAM (tc_sram via paired_sram_wrapper)
#   i_ariane_peripherals / bootrom / cache srams — via tc_sram_wrapper → tc_sram_syn
# Uncomment and adjust cell names when real macro libraries are wired in.
# if {[sizeof_collection [get_cells -hier -filter "ref_name =~ tc_sram_syn" -quiet]] > 0} {
#     set_dont_touch [get_cells -hier -filter "ref_name =~ tc_sram_syn"]
# }

write -f ddc -hierarchy -output ${OUTPUT_DIR}/${ELAB_NAME}_precompile.ddc

# --------------------------------------------------------------------------
# Step 5: Load UPF (power intent) — uncomment when UPF is ready
# --------------------------------------------------------------------------
# load_upf ${PROJ_ROOT}/pnr/ara_soc.upf

# --------------------------------------------------------------------------
# Step 6: Constraints
# --------------------------------------------------------------------------
source ${SCRIPT_DIR}/set_constraints.tcl

# --------------------------------------------------------------------------
# Step 7: Pre-compile reports
# --------------------------------------------------------------------------
check_design > ${REPORT_DIR}/check_design.rpt
report_clocks > ${REPORT_DIR}/clocks.rpt
report_timing -loop -max_paths 10 > ${REPORT_DIR}/timing_loop.rpt

# --------------------------------------------------------------------------
# Step 8: Compile
# --------------------------------------------------------------------------
set_host_options -max_cores 8
compile_ultra -no_autoungroup -no_boundary_optimization -timing -gate_clock

# --------------------------------------------------------------------------
# Step 9: Post-compile outputs
# --------------------------------------------------------------------------
change_names -rules verilog -hier

write -f ddc     -hierarchy -output ${OUTPUT_DIR}/${ELAB_NAME}_compiled.ddc
write -f verilog -hierarchy -output ${OUTPUT_DIR}/${ELAB_NAME}_netlist.v
write_sdc ${OUTPUT_DIR}/${ELAB_NAME}.sdc

# --------------------------------------------------------------------------
# Step 10: Reports (max = setup, min = hold)
# --------------------------------------------------------------------------
report_timing -delay max -nosplit -max_paths 20  > ${REPORT_DIR}/timing_max.rpt
report_timing -delay min -nosplit -max_paths 20  > ${REPORT_DIR}/timing_min.rpt
report_area   -hier -nosplit                     > ${REPORT_DIR}/area.rpt
report_power  -nosplit                           > ${REPORT_DIR}/power.rpt
report_resources -hierarchy                      > ${REPORT_DIR}/resources.rpt
report_qor                                       > ${REPORT_DIR}/qor.rpt
report_constraint -all_violators -nosplit        > ${REPORT_DIR}/violations.rpt

puts "=================================================================="
puts "  Synthesis complete. Results in:"
puts "    ${OUTPUT_DIR}/"
puts "    ${REPORT_DIR}/"
puts "=================================================================="

exit
