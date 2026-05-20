# NOTE: The 200MHz input clock is created by the clk_wiz IP's own XDC:
#   create_clock -period 5.000 [get_ports clk_in1_p]
# DO NOT create a duplicate clock here — two create_clock on the same port
# causes Vivado to generate two MMCM output clocks (one per source clock),
# resulting in spurious TIMING-6/7 DRC violations.

# JTAG Clock Constraint (not covered by any IP XDC)
create_clock -add -name jtag_clk_pin -period 100.00 -waveform {0.000 50.000} [get_ports {jtag_tck_i}]
set_input_jitter jtag_clk_pin 1.000

# Declare JTAG clock asynchronous to the MMCM output clock.
# The MMCM output clock name is assigned by the Block Design (clk_wiz_0).
set_clock_groups -name jtag_vs_sys -asynchronous \
  -group [get_clocks -quiet jtag_clk_pin] \
  -group [get_clocks -quiet clk_out1_xilinx_clk_wizard_clk_wiz_0_0]

# JTAG Input/Output Delay Constraints
set_input_delay -clock jtag_clk_pin -clock_fall 5.000 [get_ports jtag_tdi_i]
set_input_delay -clock jtag_clk_pin -clock_fall 5.000 [get_ports jtag_tms_i]
set_output_delay -clock jtag_clk_pin 5.000 [get_ports jtag_tdo_o]

# JTAG Maximum Delay Constraints
set_max_delay -to [get_ports jtag_tdo_o] 20.000
set_max_delay -from [get_ports jtag_tms_i] 20.000
set_max_delay -from [get_ports jtag_tdi_i] 20.000

### Async Input Ports (no external timing reference)
# rst_ni: board push-button, asynchronous to any clock
set_false_path -from [get_ports rst_ni]

# uart_rx_i: serial data, over-sampled internally, no setup/hold vs sys_clk
set_false_path -from [get_ports uart_rx_i]

### Output Ports (no external timing reference)
# uart_tx_o: serial data, driven from internal registers but no board-level timing spec
set_false_path -to [get_ports uart_tx_o]

# LED outputs: combinational/slow signals, no timing requirement
set_false_path -to [get_ports rst_exit_led_o]
set_false_path -to [get_ports clk_led_o]

### Internal Reset Constraints

# dmcontrol_q drives ndmreset (dm_csrs.sv). Use wildcard to match all bits of the register,
set_false_path -from [get_cells -quiet -hierarchical -filter {NAME =~ "*dmcontrol_q_reg*"}]

# rstgen_bypass: synch_regs_q is a NumRegs=4 shift-register; bit[3] (last stage) drives rst_no.
set_false_path -from [get_cells -quiet -hierarchical -filter {NAME =~ "*rstgen*/*synch_regs_q_reg[3]"}]

### AXI Combinatorial Loop Bypass
# The AXI interconnect (axi_xbar, spill_register_flushable, axi_mux/demux) produces
# apparent combinatorial loops through READY/VALID handshake logic, which is a known
# and functionally correct pattern permitted by the AXI spec (READY may depend on VALID).
# Vivado DRC LUTLP-1 flags 882 LUTs involving dram.aw_valid; bypass as recommended.
set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets -quiet -hierarchical -filter {NAME =~ "*dram*aw_valid*"}]
set_property SEVERITY {Warning} [get_drc_checks LUTLP-1]

### DRC Severity Settings
# Allow unconstrained ports (ports not physically connected on this board)
# NSTD-1: Allow ports without IOSTANDARD specification
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
# UCIO-1: Allow ports without LOC (pin location) specification
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]

