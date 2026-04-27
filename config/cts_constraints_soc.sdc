#############################################################################
# Description:  Synopsys Design Constraints
# Modifier:     Mingxuan Li <mingxuanli_siris@163.com> [Peking University]
# Acknowledge:  Columbia University, System Level Design Group
#############################################################################
reset_clock_uncertainty -from [all_clocks] -to [all_clocks]

set_clock_uncertainty -setup [expr ${rm_post_cts_clock_uncertainty} + ${rm_setup_margin} + ${rm_period_jitter}] [get_clocks clk]
set_clock_uncertainty -hold [expr  ${rm_hold_margin}] [get_clocks clk]

set_clock_uncertainty -setup [expr ${rm_post_cts_clock_uncertainty} + ${rm_setup_margin} + ${rm_period_jitter}] [get_clocks tclk]
set_clock_uncertainty -hold [expr  ${rm_hold_margin}] [get_clocks tclk]

set_clock_uncertainty -setup [expr ${rm_post_cts_clock_uncertainty} + ${rm_setup_margin} + ${rm_period_jitter}] [get_clocks vclk]
set_clock_uncertainty -hold [expr ${rm_hold_margin}] [get_clocks vclk]
