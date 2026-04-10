###############################################################################
# Timing Constraints for Ara SoC
###############################################################################

# --------------------------------------------------------------------------
# Clock definition  (250 MHz, period = 4.0 ns)
# --------------------------------------------------------------------------
set CLK_PERIOD 4.0
set CLK_NAME   SYS_CLK

create_clock -name ${CLK_NAME} -period ${CLK_PERIOD} [get_ports clk_i]

# --------------------------------------------------------------------------
# Clock uncertainty & latency
# --------------------------------------------------------------------------
set_clock_uncertainty -setup 0.20 [get_clocks ${CLK_NAME}]
set_clock_uncertainty -hold  0.05 [get_clocks ${CLK_NAME}]

set_clock_transition   0.1 [get_clocks ${CLK_NAME}]

# --------------------------------------------------------------------------
# Input / Output delays
# --------------------------------------------------------------------------
set ALL_INS  [remove_from_collection [all_inputs] [get_ports clk_i]]
set ALL_OUTS [all_outputs]

set_input_delay  -clock ${CLK_NAME} [expr ${CLK_PERIOD} * 0.3] ${ALL_INS}
set_output_delay -clock ${CLK_NAME} [expr ${CLK_PERIOD} * 0.3] ${ALL_OUTS}

# --------------------------------------------------------------------------
# Output loads (UART APB + misc)
# --------------------------------------------------------------------------
set_load 0.01 ${ALL_OUTS}

# --------------------------------------------------------------------------
# Design rule constraints
# --------------------------------------------------------------------------
set_max_fanout 32 [current_design]
set_max_transition 0.3 [current_design]

# --------------------------------------------------------------------------
# False paths on reset & scan
# --------------------------------------------------------------------------
set_false_path -from [get_ports rst_ni]
set_false_path -from [get_ports scan_enable_i]
