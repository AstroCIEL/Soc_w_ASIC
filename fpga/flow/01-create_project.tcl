# Create Vivado project for ariane_soc_top on AXU15EG

create_project ariane_soc_top -force

set_property part xczu15eg-ffvb1156-2-i [current_project]

set_property verilog_define {FPGA_XILINX=1 SYNTHESIS=1 FPGA_SYNTHESIS=1 FPGA_AXU15EG=1} [get_filesets sources_1]

# -------------------------------------------------------
# Source files 
# -------------------------------------------------------
source {sources.tcl}

# -------------------------------------------------------
# Clock wizard IP generation (200MHz diff → sys_clk)
# -------------------------------------------------------
source {../constraints/xilinx_generate_clk_wizard.tcl}

# -------------------------------------------------------
# XDC Constraints
# -------------------------------------------------------
read_xdc {../constraints/pin_assign.xdc}
read_xdc {../constraints/constraints.xdc}
read_xdc {../constraints/cdc_timing.xdc}
read_xdc {../constraints/sync.xdc}
read_xdc {../constraints/dsp_force.xdc}

set_property top ariane_soc_top_wrapper [current_fileset]
set_property source_mgmt_mode None [current_project]
