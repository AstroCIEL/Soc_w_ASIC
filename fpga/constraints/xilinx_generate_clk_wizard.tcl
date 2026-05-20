# Copyright 2022 EPFL
# Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
# Define design macros

set design_name xilinx_clk_wizard

# Create block design
create_bd_design $design_name

# Create instance and set properties
create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0

# Clock configuration for AXU15EG: 200 MHz differential input -> 15 MHz output
# Vivado auto-calculates MMCM_DIVCLK_DIVIDE / MMCM_CLKFBOUT_MULT_F / MMCM_CLKOUT0_DIVIDE_F
# from PRIM_IN_FREQ and CLKOUT1_REQUESTED_OUT_FREQ; do NOT set them manually (disabled params).

set_property -dict [list \
  CONFIG.PRIMITIVE {MMCM} \
  CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} \
  CONFIG.PRIM_IN_FREQ {200} \
  CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {40} \
  CONFIG.CLKOUT1_DRIVES {Buffer} \
  CONFIG.CLKOUT2_DRIVES {Buffer} \
  CONFIG.CLKOUT3_DRIVES {Buffer} \
  CONFIG.CLKOUT4_DRIVES {Buffer} \
  CONFIG.CLKOUT5_DRIVES {Buffer} \
  CONFIG.CLKOUT6_DRIVES {Buffer} \
  CONFIG.CLKOUT7_DRIVES {Buffer} \
  CONFIG.RESET_TYPE {ACTIVE_HIGH} \
  CONFIG.USE_LOCKED {false} \
  CONFIG.USE_RESET {true} \
] [get_bd_cells clk_wiz_0]

# Create ports
make_bd_pins_external [get_bd_cells clk_wiz_0]
make_bd_intf_pins_external [get_bd_cells clk_wiz_0]

# Save and close block design
save_bd_design
close_bd_design $design_name

# Create wrapper
set wrapper_path [ make_wrapper -fileset sources_1 -files [ get_files -norecurse xilinx_clk_wizard.bd ] -top ]
add_files -norecurse -fileset sources_1 $wrapper_path

