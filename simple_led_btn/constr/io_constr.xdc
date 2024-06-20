# -----------------------------------------------------------------------------
# ZCU102 IO Constraint
# Originator: S. Janamian
# Date: 6/16/2024
# -----------------------------------------------------------------------------

set_property -dict {PACKAGE_PIN AG14 IOSTANDARD LVCMOS33} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN AF13 IOSTANDARD LVCMOS33} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN AE13 IOSTANDARD LVCMOS33} [get_ports {led[2]}]
set_property -dict {PACKAGE_PIN AJ14 IOSTANDARD LVCMOS33} [get_ports {led[3]}]
set_property -dict {PACKAGE_PIN AJ15 IOSTANDARD LVCMOS33} [get_ports {led[4]}]
set_property -dict {PACKAGE_PIN AH13 IOSTANDARD LVCMOS33} [get_ports {led[5]}]
set_property -dict {PACKAGE_PIN AH14 IOSTANDARD LVCMOS33} [get_ports {led[6]}]
set_property -dict {PACKAGE_PIN AL12 IOSTANDARD LVCMOS33} [get_ports {led[7]}]

set_property -dict {PACKAGE_PIN AN14 IOSTANDARD LVCMOS33} [get_ports {btn[0]}]
set_property -dict {PACKAGE_PIN AP14 IOSTANDARD LVCMOS33} [get_ports {btn[1]}]
set_property -dict {PACKAGE_PIN AM14 IOSTANDARD LVCMOS33} [get_ports {btn[2]}]
set_property -dict {PACKAGE_PIN AN13 IOSTANDARD LVCMOS33} [get_ports {btn[3]}]
set_property -dict {PACKAGE_PIN AN12 IOSTANDARD LVCMOS33} [get_ports {btn[4]}]
set_property -dict {PACKAGE_PIN AP12 IOSTANDARD LVCMOS33} [get_ports {btn[5]}]
set_property -dict {PACKAGE_PIN AL13 IOSTANDARD LVCMOS33} [get_ports {btn[6]}]
set_property -dict {PACKAGE_PIN AK13 IOSTANDARD LVCMOS33} [get_ports {btn[7]}]

