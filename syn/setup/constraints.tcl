###############################################################################
# syn/setup/constraints.tcl
###############################################################################

# ---------------------------------------------------------------------------
# System clock  (600 MHz → period = 1.667 ns)
# ---------------------------------------------------------------------------
set CLK_PERIOD 1.667  
set CLK_NAME   SYS_CLK

create_clock -name ${CLK_NAME} -period ${CLK_PERIOD} [get_ports clk_i]

# ---------------------------------------------------------------------------
# RTC clock  (32.768 kHz → period ≈ 30517 ns)
# ---------------------------------------------------------------------------
set RTC_PERIOD 30517.578
set RTC_NAME   RTC_CLK

create_clock -name ${RTC_NAME} -period ${RTC_PERIOD} [get_ports rtc_i]
set_clock_groups -asynchronous \
    -group [get_clocks ${CLK_NAME}] \
    -group [get_clocks ${RTC_NAME}]

# ---------------------------------------------------------------------------
# JTAG TCK  (≤ 10 MHz → period = 100 ns)
# ---------------------------------------------------------------------------
set TCK_PERIOD 100.0
set TCK_NAME   JTAG_TCK

create_clock -name ${TCK_NAME} -period ${TCK_PERIOD} [get_ports jtag_tck_i]
set_clock_groups -asynchronous \
    -group [get_clocks ${CLK_NAME}] \
    -group [get_clocks ${TCK_NAME}]

# ---------------------------------------------------------------------------
# Clock quality (SYS_CLK only)
# ---------------------------------------------------------------------------
set_clock_uncertainty -setup 0.20 [get_clocks ${CLK_NAME}]
set_clock_uncertainty -hold  0.05 [get_clocks ${CLK_NAME}]
set_clock_transition   0.10       [get_clocks ${CLK_NAME}]

# ---------------------------------------------------------------------------
# I/O delays
# ---------------------------------------------------------------------------
set SYNC_INS [remove_from_collection \
    [remove_from_collection \
        [remove_from_collection [all_inputs] [get_ports clk_i]] \
        [get_ports rtc_i]] \
    [get_ports {jtag_tck_i jtag_tms_i jtag_tdi_i jtag_trst_ni}]]

set ALL_OUTS [all_outputs]

set_input_delay  -clock ${CLK_NAME} [expr ${CLK_PERIOD} * 0.3] ${SYNC_INS}
set_output_delay -clock ${CLK_NAME} [expr ${CLK_PERIOD} * 0.3] ${ALL_OUTS}

set_input_delay  -clock ${TCK_NAME} [expr ${TCK_PERIOD} * 0.3] \
    [get_ports {jtag_tms_i jtag_tdi_i jtag_trst_ni}]
set_output_delay -clock ${TCK_NAME} [expr ${TCK_PERIOD} * 0.3] \
    [get_ports {jtag_tdo_o jtag_tdo_driven_o}]

# ---------------------------------------------------------------------------
# Output loads
# ---------------------------------------------------------------------------
set_load 0.01 ${ALL_OUTS}

# ---------------------------------------------------------------------------
# Design-rule constraints
# ---------------------------------------------------------------------------
set_max_fanout    32  [current_design]
set_max_transition 0.3 [current_design]

# ---------------------------------------------------------------------------
# False / multicycle paths
# ---------------------------------------------------------------------------
set_false_path -from [get_ports rst_ni]
set_false_path -from [get_ports jtag_trst_ni]
set_false_path -from [get_ports debug_enable_i]

# ---------------------------------------------------------------------------
# SRAM macro static pin constraints
# ---------------------------------------------------------------------------
set RF_MACROS [list rf_dcache_half_64x128 rf_icache_64x128 \
                    rf_vrf_64x64 \
                    rf_icache_tag_64x48 rf_dcache_tag_64x46]

foreach macro $RF_MACROS {
    foreach_in_collection inst \
            [get_cells -hierarchical -filter "ref_name == $macro" -quiet] {
        set iname [get_object_name $inst]
        set_case_analysis 0 [get_pins ${iname}/rawl]
        set_case_analysis 1 [get_pins ${iname}/wabl]
        set_case_analysis 1 [get_pins ${iname}/ret1n]
    }
}

foreach_in_collection inst \
        [get_cells -hierarchical -filter "ref_name == sram_l2_16384x64" -quiet] {
    set iname [get_object_name $inst]
    set_case_analysis 0 [get_pins ${iname}/RAWL]
    set_case_analysis 1 [get_pins ${iname}/WABL]
    set_case_analysis 1 [get_pins ${iname}/RET1N]
    set_case_analysis 0 [get_pins ${iname}/STOV]
}

# 把rf2p的一些配置端口锁定成valid的常量 与wrapper中端口接的常量一致
foreach_in_collection inst \
        [get_cells -hier -filter "ref_name == rf2p_256_128" -quiet] {
    set iname [get_object_name $inst]
    set_case_analysis 0 [get_pins ${iname}/stov]
    set_case_analysis 1 [get_pins ${iname}/ret1n]
    set_case_analysis 0 [get_pins ${iname}/emasa]
    set_case_analysis 0 [get_pins ${iname}/emaa\[2\]]
    set_case_analysis 1 [get_pins ${iname}/emaa\[1\]]
    set_case_analysis 1 [get_pins ${iname}/emaa\[0\]]
    set_case_analysis 1 [get_pins ${iname}/emab\[2\]]
    set_case_analysis 0 [get_pins ${iname}/emab\[1\]]
    set_case_analysis 0 [get_pins ${iname}/emab\[0\]]
}

# ---------------------------------------------------------------------------
# 0525: Add Clock gating (before compile_ultra -gate_clock)
# ---------------------------------------------------------------------------
set_clock_gating_style -sequential_cell latch
set_clock_gating_check -setup 0.15 -hold 0.02
