### CDC Timing Constraints
# Applied during synthesis and implementation.
# Design uses cdc_2phase_clearable (dmi_cdc.sv) for JTAG DMI handshake.

# 2-phase CDC: constrain async handshake nets through cdc_2phase_src_clearable
# Module name in RTL: cdc_2phase_src_clearable (hardware/ip/common_cells/src/cdc_2phase_clearable.sv)
set_max_delay -through [get_nets -filter {NAME=~"*async*"} -of_objects [get_cells -hier -filter {REF_NAME =~ cdc_2phase_src_clearable* || ORIG_REF_NAME =~ cdc_2phase_src_clearable*}]] 20.000
set_false_path -hold -through [get_nets -filter {NAME=~"*async*"} -of_objects [get_cells -hier -filter {REF_NAME =~ cdc_2phase_src_clearable* || ORIG_REF_NAME =~ cdc_2phase_src_clearable*}]]

# 4-phase CDC: not used in this design
# set_max_delay -through [get_nets -hierarchical -filter {NAME=~"*cdc_4phase_src*/*data_src_q*"}] 20.000
# set_false_path -hold -through [get_nets -hierarchical -filter {NAME=~"*cdc_4phase_src*/*data_src_q*"}]
# set_max_delay -through [get_nets -hierarchical -filter {NAME=~"*cdc_4phase_src*/*req_src_q*"}] 20.000
# set_false_path -hold -through [get_nets -hierarchical -filter {NAME=~"*cdc_4phase_src*/*req_src_q*"}]
