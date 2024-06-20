# -----------------------------------------------------------------------------
# ZCU102 IO Constraint
# Originator: S. Janamian
# Date: 6/16/2024
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Clock 125MHz Differential
# -----------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN G21 IOSTANDARD LVDS_25 } [get_ports clk_125mhz_p]
set_property -dict { PACKAGE_PIN F21 IOSTANDARD LVDS_25 } [get_ports clk_125mhz_n]
create_clock -add -name clk_125mhz -period 8.00 -waveform {0 4} [get_nets clk_125mhz]

# -----------------------------------------------------------------------------
# GPIOs
# -----------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN AG14 IOSTANDARD LVCMOS33} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN AF13 IOSTANDARD LVCMOS33} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN AE13 IOSTANDARD LVCMOS33} [get_ports {led[2]}]
set_property -dict {PACKAGE_PIN AJ14 IOSTANDARD LVCMOS33} [get_ports {led[3]}]
set_property -dict {PACKAGE_PIN AJ15 IOSTANDARD LVCMOS33} [get_ports {led[4]}]
set_property -dict {PACKAGE_PIN AH13 IOSTANDARD LVCMOS33} [get_ports {led[5]}]
set_property -dict {PACKAGE_PIN AH14 IOSTANDARD LVCMOS33} [get_ports {led[6]}]
set_property -dict {PACKAGE_PIN AL12 IOSTANDARD LVCMOS33} [get_ports {led[7]}]

set_property -dict {PACKAGE_PIN AN14 IOSTANDARD LVCMOS33} [get_ports {btn}]


