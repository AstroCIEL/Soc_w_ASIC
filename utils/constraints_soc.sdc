#############################################################################
# Description:  Synopsys Design Constraints
# Modifier:     Siris Li <mingxuanli_siris@163.com> [Peking University]
# Acknowledge:  Columbia University, System Level Design Group
#############################################################################

set_units -time ns -capacitance pF

# -------------------------------------------
# Timing Constraints
# -------------------------------------------
# set $rm_clock_pin to name "clk", no need to be the same
# "clk" will be referred as clock pin by tools
# "get_ports" is aliased as "get_port", return full path to specified port
create_clock -period ${rm_clock_period} -name clk  [get_ports $rm_clock_pin] 
create_clock -period 100                -name tclk [get_ports tck]

# Genus doesn't support this syntax, but Innovus does
# cause all clock endpoints in the fanout of the specified object to receive propagated clock timing unless there is a set_clock_latency with higher precedence
set_propagated_clock [list clk tclk]

# set virtual clk for I/O port
# to model IO delays relative to a top level clk
create_clock -period ${rm_clock_period} -name vclk

# apply to all clocks in the fanout and corresponding sequential logic of the port
# "get_clocks" is aliased as "get_clock", return full path of clock name defined of "create_clock"
set_clock_uncertainty -setup    [expr ${rm_pre_cts_clock_uncertainty} + ${rm_setup_margin} + ${rm_period_jitter}] [get_clocks clk]
set_clock_uncertainty -hold     [expr ${rm_hold_margin}] [get_clocks clk]
set_clock_uncertainty -setup    [expr ${rm_pre_cts_clock_uncertainty} + ${rm_setup_margin} + ${rm_period_jitter}] [get_clocks tclk]
set_clock_uncertainty -hold     [expr ${rm_hold_margin}] [get_clocks tclk]
set_clock_uncertainty -setup    [expr ${rm_pre_cts_clock_uncertainty} + ${rm_period_jitter}] [get_clocks vclk]
set_clock_uncertainty -hold     [expr ${rm_pre_cts_clock_uncertainty} + ${rm_period_jitter}] [get_clocks vclk]

# define IO constraints using virtual clock
set_input_delay  [expr 0.6*${rm_clock_period}] -clock vclk [remove_from_collection [all_inputs] [get_ports ${rm_clock_pin}]] 
set_output_delay [expr 0.6*${rm_clock_period}] -clock vclk [all_outputs]

# define asynchronous clock groups, i.e. "set_false_path" to clock 
set_clock_groups -asynchronous -group {clk vclk} -group {tclk}

# exclude path for timing analysis
set_false_path -from [get_ports rst_n]

# -------------------------------------------
# Design Rule Constraints
# -------------------------------------------
# specify capacitance on specified ports 
set_load ${rm_load_value} [all_outputs]

# set maximum fanout load limit constraints on whole design
set_max_fanout ${rm_max_fanout} ${rm_core_top}

# specify maximum transition for whole design
# override clock maximum transition
set_max_transition ${rm_max_transition} ${rm_core_top}
set_max_transition ${rm_max_clock_transition} [get_clocks] -clock_path

