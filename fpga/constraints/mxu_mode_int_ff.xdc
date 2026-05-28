# -----------------------------------------------------------------------------
# MXU mode pruning for synthesis resource closure
# -----------------------------------------------------------------------------
# Purpose:
#   Keep MXU in a fixed runtime mode during synthesis so Vivado can prune the
#   unused mode logic cone (INT/POSIT + FF/BP mux networks).
#
# Fixed mode in this file:
#   - data_type_mode_i = 1  (INT mode)
#   - data_flow_mode_i = 0  (FF mode)
#
# Note:
#   This does not change array size or arithmetic algorithm, but it does
#   remove unused runtime-selectable mode paths from the compiled netlist.

# Top-level mode pins inside MXU datapath wrapper
set_case_analysis 1 [get_pins -quiet -hier -filter {NAME =~ "*i_mxu_top_wrapper/i_mxu_top/u_mxu_top_no_ctrl/sa_top_data_type_mode_i"}]
set_case_analysis 0 [get_pins -quiet -hier -filter {NAME =~ "*i_mxu_top_wrapper/i_mxu_top/u_mxu_top_no_ctrl/sa_top_data_flow_mode_i"}]

# Internal replicated mode controls (allow deeper pruning)
set_case_analysis 1 [get_pins -quiet -hier -filter {NAME =~ "*i_mxu_top_wrapper/i_mxu_top/u_mxu_top_no_ctrl/*/data_type_mode_i"}]
set_case_analysis 0 [get_pins -quiet -hier -filter {NAME =~ "*i_mxu_top_wrapper/i_mxu_top/u_mxu_top_no_ctrl/*/data_flow_mode_i"}]
set_case_analysis 1 [get_pins -quiet -hier -filter {NAME =~ "*i_mxu_top_wrapper/i_mxu_top/u_mxu_top_no_ctrl/*/data_mode_i"}]
