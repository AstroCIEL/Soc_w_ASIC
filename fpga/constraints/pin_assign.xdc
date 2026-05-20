# CLOCK - 200MHz Differential Clock
set_property -dict {PACKAGE_PIN AL8 IOSTANDARD DIFF_SSTL12} [get_ports clk_200mhz_p]
set_property -dict {PACKAGE_PIN AL7 IOSTANDARD DIFF_SSTL12} [get_ports clk_200mhz_n]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets jtag_tck_i]

# RESET
# PL_KEY button: pressed = low (0, reset), released = high (1, normal operation) or floating
# rst_ni port is low-active: 0 = reset, 1 = normal operation
# Add PULLUP to ensure rst_ni = 1 when button is released (not pressed)
set_property -dict {PACKAGE_PIN AN12 IOSTANDARD LVCMOS33} [get_ports rst_ni] ; # PL_KEY button
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets rst_ni]

# LEDS
set_property -dict {PACKAGE_PIN AM13 IOSTANDARD LVCMOS33} [get_ports rst_exit_led_o] ; # PL_LED1
set_property -dict {PACKAGE_PIN AP12 IOSTANDARD LVCMOS33} [get_ports clk_led_o]      ; # PL_LED2

# UART
# PL_UART (J14 connector)
set_property -dict {PACKAGE_PIN D10 IOSTANDARD LVCMOS33} [get_ports uart_tx_o]
set_property -dict {PACKAGE_PIN D11 IOSTANDARD LVCMOS33} [get_ports uart_rx_i]

# JTAG
# J50 connector pins
set_property -dict {PACKAGE_PIN C19 IOSTANDARD LVCMOS33} [get_ports jtag_tck_i] ; # J50[7]
set_property -dict {PACKAGE_PIN A13 IOSTANDARD LVCMOS33} [get_ports jtag_tms_i] ; # J50[10]
# jtag_trst_ni connected to rst_ni internally in wrapper
set_property -dict {PACKAGE_PIN C18 IOSTANDARD LVCMOS33} [get_ports jtag_tdi_i] ; # J50[8]
set_property -dict {PACKAGE_PIN A12 IOSTANDARD LVCMOS33} [get_ports jtag_tdo_o] ; # J50[9]

