###############################################################################
# Timing Constraints for ariane_soc_top
###############################################################################

# --------------------------------------------------------------------------
# System clock  (250 MHz → period = 4.0 ns)
# --------------------------------------------------------------------------
set CLK_PERIOD 4.0
set CLK_NAME   SYS_CLK

create_clock -name ${CLK_NAME} -period ${CLK_PERIOD} [get_ports clk_i]

# --------------------------------------------------------------------------
# RTC clock  (32.768 kHz → period ≈ 30517 ns)
# Used only by CLINT; set as independent, no MMMC needed.
# --------------------------------------------------------------------------
set RTC_PERIOD 30517.578
set RTC_NAME   RTC_CLK

create_clock -name ${RTC_NAME} -period ${RTC_PERIOD} [get_ports rtc_i]
set_clock_groups -asynchronous -group [get_clocks ${CLK_NAME}] \
                               -group [get_clocks ${RTC_NAME}]

# --------------------------------------------------------------------------
# JTAG TCK  (≤ 10 MHz → period = 100 ns; driven by SimJTAG in sim,
#            by a real debugger on silicon)
# --------------------------------------------------------------------------
set TCK_PERIOD 100.0
set TCK_NAME   JTAG_TCK

create_clock -name ${TCK_NAME} -period ${TCK_PERIOD} [get_ports jtag_tck_i]
set_clock_groups -asynchronous -group [get_clocks ${CLK_NAME}] \
                               -group [get_clocks ${TCK_NAME}]

# --------------------------------------------------------------------------
# Clock uncertainty & transition for SYS_CLK
# --------------------------------------------------------------------------
set_clock_uncertainty -setup 0.20 [get_clocks ${CLK_NAME}]
set_clock_uncertainty -hold  0.05 [get_clocks ${CLK_NAME}]
set_clock_transition   0.10  [get_clocks ${CLK_NAME}]

# --------------------------------------------------------------------------
# Input / Output delays  (relative to SYS_CLK only)
# Exclude async clock ports and JTAG ports (covered by TCK domain).
# --------------------------------------------------------------------------
set SYNC_INS [remove_from_collection \
    [remove_from_collection \
        [remove_from_collection [all_inputs] [get_ports clk_i]] \
        [get_ports rtc_i]] \
    [get_ports {jtag_tck_i jtag_tms_i jtag_tdi_i jtag_trst_ni}]]

set ALL_OUTS [all_outputs]

set_input_delay  -clock ${CLK_NAME} [expr ${CLK_PERIOD} * 0.3] ${SYNC_INS}
set_output_delay -clock ${CLK_NAME} [expr ${CLK_PERIOD} * 0.3] ${ALL_OUTS}

# JTAG I/O relative to TCK
set_input_delay  -clock ${TCK_NAME} [expr ${TCK_PERIOD} * 0.3] \
    [get_ports {jtag_tms_i jtag_tdi_i jtag_trst_ni}]
set_output_delay -clock ${TCK_NAME} [expr ${TCK_PERIOD} * 0.3] \
    [get_ports {jtag_tdo_o jtag_tdo_driven_o}]

# --------------------------------------------------------------------------
# Output loads
# --------------------------------------------------------------------------
set_load 0.01 ${ALL_OUTS}

# --------------------------------------------------------------------------
# Design rule constraints
# --------------------------------------------------------------------------
set_max_fanout    32  [current_design]
set_max_transition 0.3 [current_design]

# --------------------------------------------------------------------------
# False / multicycle paths
# --------------------------------------------------------------------------
# Async reset is false path from a timing perspective
set_false_path -from [get_ports rst_ni]

# JTAG reset is async
set_false_path -from [get_ports jtag_trst_ni]

# debug_enable_i is quasi-static
set_false_path -from [get_ports debug_enable_i]
