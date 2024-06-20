
##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set gt_rtl [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 gt_rtl ]

  set gt_ref [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 gt_ref ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {156250000} \
   ] $gt_ref


  # Create ports
  set sfp_tx_dis [ create_bd_port -dir O -from 0 -to 0 sfp_tx_dis ]

  # Create instance: zynq_ultra_ps_e, and set properties
  set zynq_ultra_ps_e [ create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e:3.5 zynq_ultra_ps_e ]
  set_property -dict [list \
    CONFIG.PSU_BANK_0_IO_STANDARD {LVCMOS18} \
    CONFIG.PSU_BANK_1_IO_STANDARD {LVCMOS18} \
    CONFIG.PSU_BANK_2_IO_STANDARD {LVCMOS18} \
    CONFIG.PSU_BANK_3_IO_STANDARD {LVCMOS18} \
    CONFIG.PSU_DDR_RAM_HIGHADDR {0xFFFFFFFF} \
    CONFIG.PSU_DDR_RAM_HIGHADDR_OFFSET {0x800000000} \
    CONFIG.PSU_DDR_RAM_LOWADDR_OFFSET {0x80000000} \
    CONFIG.PSU_DYNAMIC_DDR_CONFIG_EN {1} \
    CONFIG.PSU_MIO_13_POLARITY {Default} \
    CONFIG.PSU_MIO_22_POLARITY {Default} \
    CONFIG.PSU_MIO_23_POLARITY {Default} \
    CONFIG.PSU_MIO_26_POLARITY {Default} \
    CONFIG.PSU_MIO_32_POLARITY {Default} \
    CONFIG.PSU_MIO_33_POLARITY {Default} \
    CONFIG.PSU_MIO_35_POLARITY {Default} \
    CONFIG.PSU_MIO_36_POLARITY {Default} \
    CONFIG.PSU_MIO_37_POLARITY {Default} \
    CONFIG.PSU_MIO_38_POLARITY {Default} \
    CONFIG.PSU_MIO_43_POLARITY {Default} \
    CONFIG.PSU_MIO_TREE_PERIPHERALS {Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Feedback Clk#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad\
SPI Flash#Quad SPI Flash#GPIO0 MIO#I2C 0#I2C 0#I2C 1#I2C 1#UART 0#UART 0#UART 1#UART 1#GPIO0 MIO#GPIO0 MIO#CAN 1#CAN 1#GPIO1 MIO#DPAUX#DPAUX#DPAUX#DPAUX#PCIE#GPIO1 MIO#GPIO1 MIO#PMU GPO 2#GPIO1 MIO#GPIO1\
MIO#GPIO1 MIO#GPIO1 MIO#SD 1#SD 1#SD 1#SD 1#GPIO1 MIO#SD 1#SD 1#SD 1#SD 1#SD 1#SD 1#SD 1#SD 1#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem\
3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#MDIO 3#MDIO 3} \
    CONFIG.PSU_MIO_TREE_SIGNALS {sclk_out#miso_mo1#mo2#mo3#mosi_mi0#n_ss_out#clk_for_lpbk#n_ss_out_upper#mo_upper[0]#mo_upper[1]#mo_upper[2]#mo_upper[3]#sclk_out_upper#gpio0[13]#scl_out#sda_out#scl_out#sda_out#rxd#txd#txd#rxd#gpio0[22]#gpio0[23]#phy_tx#phy_rx#gpio1[26]#dp_aux_data_out#dp_hot_plug_detect#dp_aux_data_oe#dp_aux_data_in#reset_n#gpio1[32]#gpio1[33]#gpo[2]#gpio1[35]#gpio1[36]#gpio1[37]#gpio1[38]#sdio1_data_out[4]#sdio1_data_out[5]#sdio1_data_out[6]#sdio1_data_out[7]#gpio1[43]#sdio1_wp#sdio1_cd_n#sdio1_data_out[0]#sdio1_data_out[1]#sdio1_data_out[2]#sdio1_data_out[3]#sdio1_cmd_out#sdio1_clk_out#ulpi_clk_in#ulpi_dir#ulpi_tx_data[2]#ulpi_nxt#ulpi_tx_data[0]#ulpi_tx_data[1]#ulpi_stp#ulpi_tx_data[3]#ulpi_tx_data[4]#ulpi_tx_data[5]#ulpi_tx_data[6]#ulpi_tx_data[7]#rgmii_tx_clk#rgmii_txd[0]#rgmii_txd[1]#rgmii_txd[2]#rgmii_txd[3]#rgmii_tx_ctl#rgmii_rx_clk#rgmii_rxd[0]#rgmii_rxd[1]#rgmii_rxd[2]#rgmii_rxd[3]#rgmii_rx_ctl#gem3_mdc#gem3_mdio_out}\
\
    CONFIG.PSU_SD1_INTERNAL_BUS_WIDTH {8} \
    CONFIG.PSU_USB3__DUAL_CLOCK_ENABLE {1} \
    CONFIG.PSU__ACT_DDR_FREQ_MHZ {1066.560059} \
    CONFIG.PSU__CAN1__GRP_CLK__ENABLE {0} \
    CONFIG.PSU__CAN1__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__CAN1__PERIPHERAL__IO {MIO 24 .. 25} \
    CONFIG.PSU__CRF_APB__ACPU_CTRL__ACT_FREQMHZ {1199.880127} \
    CONFIG.PSU__CRF_APB__ACPU_CTRL__FREQMHZ {1200} \
    CONFIG.PSU__CRF_APB__ACPU_CTRL__SRCSEL {APLL} \
    CONFIG.PSU__CRF_APB__APLL_CTRL__SRCSEL {PSS_REF_CLK} \
    CONFIG.PSU__CRF_APB__DBG_FPD_CTRL__ACT_FREQMHZ {249.975021} \
    CONFIG.PSU__CRF_APB__DBG_FPD_CTRL__FREQMHZ {250} \
    CONFIG.PSU__CRF_APB__DBG_FPD_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRF_APB__DBG_TRACE_CTRL__FREQMHZ {250} \
    CONFIG.PSU__CRF_APB__DBG_TRACE_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRF_APB__DBG_TSTMP_CTRL__ACT_FREQMHZ {249.975021} \
    CONFIG.PSU__CRF_APB__DBG_TSTMP_CTRL__FREQMHZ {250} \
    CONFIG.PSU__CRF_APB__DBG_TSTMP_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRF_APB__DDR_CTRL__ACT_FREQMHZ {533.280029} \
    CONFIG.PSU__CRF_APB__DDR_CTRL__FREQMHZ {1067} \
    CONFIG.PSU__CRF_APB__DDR_CTRL__SRCSEL {DPLL} \
    CONFIG.PSU__CRF_APB__DPDMA_REF_CTRL__ACT_FREQMHZ {599.940063} \
    CONFIG.PSU__CRF_APB__DPDMA_REF_CTRL__FREQMHZ {600} \
    CONFIG.PSU__CRF_APB__DPDMA_REF_CTRL__SRCSEL {APLL} \
    CONFIG.PSU__CRF_APB__DPLL_CTRL__SRCSEL {PSS_REF_CLK} \
    CONFIG.PSU__CRF_APB__DP_AUDIO_REF_CTRL__ACT_FREQMHZ {24.997501} \
    CONFIG.PSU__CRF_APB__DP_AUDIO_REF_CTRL__SRCSEL {RPLL} \
    CONFIG.PSU__CRF_APB__DP_AUDIO__FRAC_ENABLED {0} \
    CONFIG.PSU__CRF_APB__DP_STC_REF_CTRL__ACT_FREQMHZ {26.783037} \
    CONFIG.PSU__CRF_APB__DP_STC_REF_CTRL__SRCSEL {RPLL} \
    CONFIG.PSU__CRF_APB__DP_VIDEO_REF_CTRL__ACT_FREQMHZ {299.970032} \
    CONFIG.PSU__CRF_APB__DP_VIDEO_REF_CTRL__SRCSEL {VPLL} \
    CONFIG.PSU__CRF_APB__DP_VIDEO__FRAC_ENABLED {0} \
    CONFIG.PSU__CRF_APB__GDMA_REF_CTRL__ACT_FREQMHZ {599.940063} \
    CONFIG.PSU__CRF_APB__GDMA_REF_CTRL__FREQMHZ {600} \
    CONFIG.PSU__CRF_APB__GDMA_REF_CTRL__SRCSEL {APLL} \
    CONFIG.PSU__CRF_APB__GPU_REF_CTRL__ACT_FREQMHZ {499.950043} \
    CONFIG.PSU__CRF_APB__GPU_REF_CTRL__FREQMHZ {500} \
    CONFIG.PSU__CRF_APB__GPU_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRF_APB__PCIE_REF_CTRL__ACT_FREQMHZ {249.975021} \
    CONFIG.PSU__CRF_APB__PCIE_REF_CTRL__FREQMHZ {250} \
    CONFIG.PSU__CRF_APB__PCIE_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRF_APB__SATA_REF_CTRL__ACT_FREQMHZ {249.975021} \
    CONFIG.PSU__CRF_APB__SATA_REF_CTRL__FREQMHZ {250} \
    CONFIG.PSU__CRF_APB__SATA_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRF_APB__TOPSW_LSBUS_CTRL__ACT_FREQMHZ {99.990005} \
    CONFIG.PSU__CRF_APB__TOPSW_LSBUS_CTRL__FREQMHZ {100} \
    CONFIG.PSU__CRF_APB__TOPSW_LSBUS_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRF_APB__TOPSW_MAIN_CTRL__ACT_FREQMHZ {533.280029} \
    CONFIG.PSU__CRF_APB__TOPSW_MAIN_CTRL__FREQMHZ {533.33} \
    CONFIG.PSU__CRF_APB__TOPSW_MAIN_CTRL__SRCSEL {DPLL} \
    CONFIG.PSU__CRF_APB__VPLL_CTRL__SRCSEL {PSS_REF_CLK} \
    CONFIG.PSU__CRL_APB__ADMA_REF_CTRL__ACT_FREQMHZ {499.950043} \
    CONFIG.PSU__CRL_APB__ADMA_REF_CTRL__FREQMHZ {500} \
    CONFIG.PSU__CRL_APB__ADMA_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__AMS_REF_CTRL__ACT_FREQMHZ {49.995003} \
    CONFIG.PSU__CRL_APB__CAN1_REF_CTRL__ACT_FREQMHZ {99.990005} \
    CONFIG.PSU__CRL_APB__CAN1_REF_CTRL__FREQMHZ {100} \
    CONFIG.PSU__CRL_APB__CAN1_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__CPU_R5_CTRL__ACT_FREQMHZ {499.950043} \
    CONFIG.PSU__CRL_APB__CPU_R5_CTRL__FREQMHZ {500} \
    CONFIG.PSU__CRL_APB__CPU_R5_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__DBG_LPD_CTRL__ACT_FREQMHZ {249.975021} \
    CONFIG.PSU__CRL_APB__DBG_LPD_CTRL__FREQMHZ {250} \
    CONFIG.PSU__CRL_APB__DBG_LPD_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__DLL_REF_CTRL__ACT_FREQMHZ {1499.850098} \
    CONFIG.PSU__CRL_APB__GEM3_REF_CTRL__ACT_FREQMHZ {124.987511} \
    CONFIG.PSU__CRL_APB__GEM3_REF_CTRL__FREQMHZ {125} \
    CONFIG.PSU__CRL_APB__GEM3_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__GEM_TSU_REF_CTRL__ACT_FREQMHZ {249.975021} \
    CONFIG.PSU__CRL_APB__GEM_TSU_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__I2C0_REF_CTRL__ACT_FREQMHZ {99.990005} \
    CONFIG.PSU__CRL_APB__I2C0_REF_CTRL__FREQMHZ {100} \
    CONFIG.PSU__CRL_APB__I2C0_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__I2C1_REF_CTRL__ACT_FREQMHZ {99.990005} \
    CONFIG.PSU__CRL_APB__I2C1_REF_CTRL__FREQMHZ {100} \
    CONFIG.PSU__CRL_APB__I2C1_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__IOPLL_CTRL__SRCSEL {PSS_REF_CLK} \
    CONFIG.PSU__CRL_APB__IOU_SWITCH_CTRL__ACT_FREQMHZ {249.975021} \
    CONFIG.PSU__CRL_APB__IOU_SWITCH_CTRL__FREQMHZ {250} \
    CONFIG.PSU__CRL_APB__IOU_SWITCH_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__LPD_LSBUS_CTRL__ACT_FREQMHZ {99.990005} \
    CONFIG.PSU__CRL_APB__LPD_LSBUS_CTRL__FREQMHZ {100} \
    CONFIG.PSU__CRL_APB__LPD_LSBUS_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__LPD_SWITCH_CTRL__ACT_FREQMHZ {499.950043} \
    CONFIG.PSU__CRL_APB__LPD_SWITCH_CTRL__FREQMHZ {500} \
    CONFIG.PSU__CRL_APB__LPD_SWITCH_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__PCAP_CTRL__ACT_FREQMHZ {187.481262} \
    CONFIG.PSU__CRL_APB__PCAP_CTRL__FREQMHZ {200} \
    CONFIG.PSU__CRL_APB__PCAP_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__PL0_REF_CTRL__ACT_FREQMHZ {99.990005} \
    CONFIG.PSU__CRL_APB__PL0_REF_CTRL__FREQMHZ {100} \
    CONFIG.PSU__CRL_APB__PL0_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__ACT_FREQMHZ {124.987511} \
    CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__FREQMHZ {125} \
    CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__RPLL_CTRL__SRCSEL {PSS_REF_CLK} \
    CONFIG.PSU__CRL_APB__SDIO1_REF_CTRL__ACT_FREQMHZ {187.481262} \
    CONFIG.PSU__CRL_APB__SDIO1_REF_CTRL__FREQMHZ {200} \
    CONFIG.PSU__CRL_APB__SDIO1_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__TIMESTAMP_REF_CTRL__ACT_FREQMHZ {99.990005} \
    CONFIG.PSU__CRL_APB__TIMESTAMP_REF_CTRL__FREQMHZ {100} \
    CONFIG.PSU__CRL_APB__TIMESTAMP_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__UART0_REF_CTRL__ACT_FREQMHZ {99.990005} \
    CONFIG.PSU__CRL_APB__UART0_REF_CTRL__FREQMHZ {100} \
    CONFIG.PSU__CRL_APB__UART0_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__UART1_REF_CTRL__ACT_FREQMHZ {99.990005} \
    CONFIG.PSU__CRL_APB__UART1_REF_CTRL__FREQMHZ {100} \
    CONFIG.PSU__CRL_APB__UART1_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__USB0_BUS_REF_CTRL__ACT_FREQMHZ {249.975021} \
    CONFIG.PSU__CRL_APB__USB0_BUS_REF_CTRL__FREQMHZ {250} \
    CONFIG.PSU__CRL_APB__USB0_BUS_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__USB3_DUAL_REF_CTRL__ACT_FREQMHZ {19.998001} \
    CONFIG.PSU__CRL_APB__USB3_DUAL_REF_CTRL__FREQMHZ {20} \
    CONFIG.PSU__CRL_APB__USB3_DUAL_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__USB3__ENABLE {1} \
    CONFIG.PSU__CSUPMU__PERIPHERAL__VALID {1} \
    CONFIG.PSU__DDRC__BG_ADDR_COUNT {2} \
    CONFIG.PSU__DDRC__BRC_MAPPING {ROW_BANK_COL} \
    CONFIG.PSU__DDRC__BUS_WIDTH {64 Bit} \
    CONFIG.PSU__DDRC__CL {15} \
    CONFIG.PSU__DDRC__CLOCK_STOP_EN {0} \
    CONFIG.PSU__DDRC__COMPONENTS {UDIMM} \
    CONFIG.PSU__DDRC__CWL {14} \
    CONFIG.PSU__DDRC__DDR4_ADDR_MAPPING {0} \
    CONFIG.PSU__DDRC__DDR4_CAL_MODE_ENABLE {0} \
    CONFIG.PSU__DDRC__DDR4_CRC_CONTROL {0} \
    CONFIG.PSU__DDRC__DDR4_T_REF_MODE {0} \
    CONFIG.PSU__DDRC__DDR4_T_REF_RANGE {Normal (0-85)} \
    CONFIG.PSU__DDRC__DEVICE_CAPACITY {4096 MBits} \
    CONFIG.PSU__DDRC__DM_DBI {DM_NO_DBI} \
    CONFIG.PSU__DDRC__DRAM_WIDTH {8 Bits} \
    CONFIG.PSU__DDRC__ECC {Disabled} \
    CONFIG.PSU__DDRC__FGRM {1X} \
    CONFIG.PSU__DDRC__LP_ASR {manual normal} \
    CONFIG.PSU__DDRC__MEMORY_TYPE {DDR 4} \
    CONFIG.PSU__DDRC__PARITY_ENABLE {0} \
    CONFIG.PSU__DDRC__PER_BANK_REFRESH {0} \
    CONFIG.PSU__DDRC__PHY_DBI_MODE {0} \
    CONFIG.PSU__DDRC__RANK_ADDR_COUNT {0} \
    CONFIG.PSU__DDRC__ROW_ADDR_COUNT {15} \
    CONFIG.PSU__DDRC__SELF_REF_ABORT {0} \
    CONFIG.PSU__DDRC__SPEED_BIN {DDR4_2133P} \
    CONFIG.PSU__DDRC__STATIC_RD_MODE {0} \
    CONFIG.PSU__DDRC__TRAIN_DATA_EYE {1} \
    CONFIG.PSU__DDRC__TRAIN_READ_GATE {1} \
    CONFIG.PSU__DDRC__TRAIN_WRITE_LEVEL {1} \
    CONFIG.PSU__DDRC__T_FAW {30.0} \
    CONFIG.PSU__DDRC__T_RAS_MIN {33} \
    CONFIG.PSU__DDRC__T_RC {47.06} \
    CONFIG.PSU__DDRC__T_RCD {15} \
    CONFIG.PSU__DDRC__T_RP {15} \
    CONFIG.PSU__DDRC__VREF {1} \
    CONFIG.PSU__DDR_HIGH_ADDRESS_GUI_ENABLE {1} \
    CONFIG.PSU__DDR__INTERFACE__FREQMHZ {533.500} \
    CONFIG.PSU__DISPLAYPORT__LANE0__ENABLE {1} \
    CONFIG.PSU__DISPLAYPORT__LANE0__IO {GT Lane1} \
    CONFIG.PSU__DISPLAYPORT__LANE1__ENABLE {0} \
    CONFIG.PSU__DISPLAYPORT__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__DLL__ISUSED {1} \
    CONFIG.PSU__DPAUX__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__DPAUX__PERIPHERAL__IO {MIO 27 .. 30} \
    CONFIG.PSU__DP__LANE_SEL {Single Lower} \
    CONFIG.PSU__DP__REF_CLK_FREQ {27} \
    CONFIG.PSU__DP__REF_CLK_SEL {Ref Clk3} \
    CONFIG.PSU__ENET3__FIFO__ENABLE {0} \
    CONFIG.PSU__ENET3__GRP_MDIO__ENABLE {1} \
    CONFIG.PSU__ENET3__GRP_MDIO__IO {MIO 76 .. 77} \
    CONFIG.PSU__ENET3__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__ENET3__PERIPHERAL__IO {MIO 64 .. 75} \
    CONFIG.PSU__ENET3__PTP__ENABLE {0} \
    CONFIG.PSU__ENET3__TSU__ENABLE {0} \
    CONFIG.PSU__FPDMASTERS_COHERENCY {0} \
    CONFIG.PSU__FPD_SLCR__WDT1__ACT_FREQMHZ {99.990005} \
    CONFIG.PSU__FPGA_PL0_ENABLE {1} \
    CONFIG.PSU__GEM3_COHERENCY {0} \
    CONFIG.PSU__GEM3_ROUTE_THROUGH_FPD {0} \
    CONFIG.PSU__GEM__TSU__ENABLE {0} \
    CONFIG.PSU__GPIO0_MIO__IO {MIO 0 .. 25} \
    CONFIG.PSU__GPIO0_MIO__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__GPIO1_MIO__IO {MIO 26 .. 51} \
    CONFIG.PSU__GPIO1_MIO__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__GT__LINK_SPEED {HBR} \
    CONFIG.PSU__GT__PRE_EMPH_LVL_4 {0} \
    CONFIG.PSU__GT__VLT_SWNG_LVL_4 {0} \
    CONFIG.PSU__I2C0__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__I2C0__PERIPHERAL__IO {MIO 14 .. 15} \
    CONFIG.PSU__I2C1__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__I2C1__PERIPHERAL__IO {MIO 16 .. 17} \
    CONFIG.PSU__IOU_SLCR__IOU_TTC_APB_CLK__TTC0_SEL {APB} \
    CONFIG.PSU__IOU_SLCR__IOU_TTC_APB_CLK__TTC1_SEL {APB} \
    CONFIG.PSU__IOU_SLCR__IOU_TTC_APB_CLK__TTC2_SEL {APB} \
    CONFIG.PSU__IOU_SLCR__IOU_TTC_APB_CLK__TTC3_SEL {APB} \
    CONFIG.PSU__IOU_SLCR__TTC0__ACT_FREQMHZ {100.000000} \
    CONFIG.PSU__IOU_SLCR__TTC1__ACT_FREQMHZ {100.000000} \
    CONFIG.PSU__IOU_SLCR__TTC2__ACT_FREQMHZ {100.000000} \
    CONFIG.PSU__IOU_SLCR__TTC3__ACT_FREQMHZ {100.000000} \
    CONFIG.PSU__IOU_SLCR__WDT0__ACT_FREQMHZ {99.990005} \
    CONFIG.PSU__LPD_SLCR__CSUPMU__ACT_FREQMHZ {100.000000} \
    CONFIG.PSU__MAXIGP0__DATA_WIDTH {128} \
    CONFIG.PSU__MAXIGP1__DATA_WIDTH {128} \
    CONFIG.PSU__OVERRIDE__BASIC_CLOCK {0} \
    CONFIG.PSU__PCIE__BAR0_ENABLE {0} \
    CONFIG.PSU__PCIE__BAR0_VAL {0x0} \
    CONFIG.PSU__PCIE__BAR1_ENABLE {0} \
    CONFIG.PSU__PCIE__BAR1_VAL {0x0} \
    CONFIG.PSU__PCIE__BAR2_VAL {0x0} \
    CONFIG.PSU__PCIE__BAR3_VAL {0x0} \
    CONFIG.PSU__PCIE__BAR4_VAL {0x0} \
    CONFIG.PSU__PCIE__BAR5_VAL {0x0} \
    CONFIG.PSU__PCIE__CLASS_CODE_BASE {0x06} \
    CONFIG.PSU__PCIE__CLASS_CODE_INTERFACE {0x0} \
    CONFIG.PSU__PCIE__CLASS_CODE_SUB {0x4} \
    CONFIG.PSU__PCIE__CLASS_CODE_VALUE {0x60400} \
    CONFIG.PSU__PCIE__CRS_SW_VISIBILITY {1} \
    CONFIG.PSU__PCIE__DEVICE_ID {0xD021} \
    CONFIG.PSU__PCIE__DEVICE_PORT_TYPE {Root Port} \
    CONFIG.PSU__PCIE__EROM_ENABLE {0} \
    CONFIG.PSU__PCIE__EROM_VAL {0x0} \
    CONFIG.PSU__PCIE__LANE0__ENABLE {1} \
    CONFIG.PSU__PCIE__LANE0__IO {GT Lane0} \
    CONFIG.PSU__PCIE__LANE1__ENABLE {0} \
    CONFIG.PSU__PCIE__LANE2__ENABLE {0} \
    CONFIG.PSU__PCIE__LANE3__ENABLE {0} \
    CONFIG.PSU__PCIE__LINK_SPEED {5.0 Gb/s} \
    CONFIG.PSU__PCIE__MAXIMUM_LINK_WIDTH {x1} \
    CONFIG.PSU__PCIE__MAX_PAYLOAD_SIZE {256 bytes} \
    CONFIG.PSU__PCIE__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__PCIE__PERIPHERAL__ENDPOINT_ENABLE {0} \
    CONFIG.PSU__PCIE__PERIPHERAL__ROOTPORT_ENABLE {1} \
    CONFIG.PSU__PCIE__PERIPHERAL__ROOTPORT_IO {MIO 31} \
    CONFIG.PSU__PCIE__REF_CLK_FREQ {100} \
    CONFIG.PSU__PCIE__REF_CLK_SEL {Ref Clk0} \
    CONFIG.PSU__PCIE__RESET__POLARITY {Active Low} \
    CONFIG.PSU__PCIE__REVISION_ID {0x0} \
    CONFIG.PSU__PCIE__SUBSYSTEM_ID {0x7} \
    CONFIG.PSU__PCIE__SUBSYSTEM_VENDOR_ID {0x10EE} \
    CONFIG.PSU__PCIE__VENDOR_ID {0x10EE} \
    CONFIG.PSU__PL_CLK0_BUF {TRUE} \
    CONFIG.PSU__PMU_COHERENCY {0} \
    CONFIG.PSU__PMU__AIBACK__ENABLE {0} \
    CONFIG.PSU__PMU__EMIO_GPI__ENABLE {0} \
    CONFIG.PSU__PMU__EMIO_GPO__ENABLE {0} \
    CONFIG.PSU__PMU__GPI0__ENABLE {0} \
    CONFIG.PSU__PMU__GPI1__ENABLE {0} \
    CONFIG.PSU__PMU__GPI2__ENABLE {0} \
    CONFIG.PSU__PMU__GPI3__ENABLE {0} \
    CONFIG.PSU__PMU__GPI4__ENABLE {0} \
    CONFIG.PSU__PMU__GPI5__ENABLE {0} \
    CONFIG.PSU__PMU__GPO0__ENABLE {0} \
    CONFIG.PSU__PMU__GPO1__ENABLE {0} \
    CONFIG.PSU__PMU__GPO2__ENABLE {1} \
    CONFIG.PSU__PMU__GPO2__IO {MIO 34} \
    CONFIG.PSU__PMU__GPO2__POLARITY {high} \
    CONFIG.PSU__PMU__GPO3__ENABLE {0} \
    CONFIG.PSU__PMU__GPO4__ENABLE {0} \
    CONFIG.PSU__PMU__GPO5__ENABLE {0} \
    CONFIG.PSU__PMU__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__PMU__PLERROR__ENABLE {0} \
    CONFIG.PSU__PRESET_APPLIED {1} \
    CONFIG.PSU__PROTECTION__MASTERS {USB1:NonSecure;0|USB0:NonSecure;1|S_AXI_LPD:NA;0|S_AXI_HPC1_FPD:NA;0|S_AXI_HPC0_FPD:NA;0|S_AXI_HP3_FPD:NA;0|S_AXI_HP2_FPD:NA;0|S_AXI_HP1_FPD:NA;0|S_AXI_HP0_FPD:NA;1|S_AXI_ACP:NA;0|S_AXI_ACE:NA;0|SD1:NonSecure;1|SD0:NonSecure;0|SATA1:NonSecure;1|SATA0:NonSecure;1|RPU1:Secure;1|RPU0:Secure;1|QSPI:NonSecure;1|PMU:NA;1|PCIe:NonSecure;1|NAND:NonSecure;0|LDMA:NonSecure;1|GPU:NonSecure;1|GEM3:NonSecure;1|GEM2:NonSecure;0|GEM1:NonSecure;0|GEM0:NonSecure;0|FDMA:NonSecure;1|DP:NonSecure;1|DAP:NA;1|Coresight:NA;1|CSU:NA;1|APU:NA;1}\
\
    CONFIG.PSU__PROTECTION__SLAVES {LPD;USB3_1_XHCI;FE300000;FE3FFFFF;0|LPD;USB3_1;FF9E0000;FF9EFFFF;0|LPD;USB3_0_XHCI;FE200000;FE2FFFFF;1|LPD;USB3_0;FF9D0000;FF9DFFFF;1|LPD;UART1;FF010000;FF01FFFF;1|LPD;UART0;FF000000;FF00FFFF;1|LPD;TTC3;FF140000;FF14FFFF;1|LPD;TTC2;FF130000;FF13FFFF;1|LPD;TTC1;FF120000;FF12FFFF;1|LPD;TTC0;FF110000;FF11FFFF;1|FPD;SWDT1;FD4D0000;FD4DFFFF;1|LPD;SWDT0;FF150000;FF15FFFF;1|LPD;SPI1;FF050000;FF05FFFF;0|LPD;SPI0;FF040000;FF04FFFF;0|FPD;SMMU_REG;FD5F0000;FD5FFFFF;1|FPD;SMMU;FD800000;FDFFFFFF;1|FPD;SIOU;FD3D0000;FD3DFFFF;1|FPD;SERDES;FD400000;FD47FFFF;1|LPD;SD1;FF170000;FF17FFFF;1|LPD;SD0;FF160000;FF16FFFF;0|FPD;SATA;FD0C0000;FD0CFFFF;1|LPD;RTC;FFA60000;FFA6FFFF;1|LPD;RSA_CORE;FFCE0000;FFCEFFFF;1|LPD;RPU;FF9A0000;FF9AFFFF;1|LPD;R5_TCM_RAM_GLOBAL;FFE00000;FFE3FFFF;1|LPD;R5_1_Instruction_Cache;FFEC0000;FFECFFFF;1|LPD;R5_1_Data_Cache;FFED0000;FFEDFFFF;1|LPD;R5_1_BTCM_GLOBAL;FFEB0000;FFEBFFFF;1|LPD;R5_1_ATCM_GLOBAL;FFE90000;FFE9FFFF;1|LPD;R5_0_Instruction_Cache;FFE40000;FFE4FFFF;1|LPD;R5_0_Data_Cache;FFE50000;FFE5FFFF;1|LPD;R5_0_BTCM_GLOBAL;FFE20000;FFE2FFFF;1|LPD;R5_0_ATCM_GLOBAL;FFE00000;FFE0FFFF;1|LPD;QSPI_Linear_Address;C0000000;DFFFFFFF;1|LPD;QSPI;FF0F0000;FF0FFFFF;1|LPD;PMU_RAM;FFDC0000;FFDDFFFF;1|LPD;PMU_GLOBAL;FFD80000;FFDBFFFF;1|FPD;PCIE_MAIN;FD0E0000;FD0EFFFF;1|FPD;PCIE_LOW;E0000000;EFFFFFFF;1|FPD;PCIE_HIGH2;8000000000;BFFFFFFFFF;1|FPD;PCIE_HIGH1;600000000;7FFFFFFFF;1|FPD;PCIE_DMA;FD0F0000;FD0FFFFF;1|FPD;PCIE_ATTRIB;FD480000;FD48FFFF;1|LPD;OCM_XMPU_CFG;FFA70000;FFA7FFFF;1|LPD;OCM_SLCR;FF960000;FF96FFFF;1|OCM;OCM;FFFC0000;FFFFFFFF;1|LPD;NAND;FF100000;FF10FFFF;0|LPD;MBISTJTAG;FFCF0000;FFCFFFFF;1|LPD;LPD_XPPU_SINK;FF9C0000;FF9CFFFF;1|LPD;LPD_XPPU;FF980000;FF98FFFF;1|LPD;LPD_SLCR_SECURE;FF4B0000;FF4DFFFF;1|LPD;LPD_SLCR;FF410000;FF4AFFFF;1|LPD;LPD_GPV;FE100000;FE1FFFFF;1|LPD;LPD_DMA_7;FFAF0000;FFAFFFFF;1|LPD;LPD_DMA_6;FFAE0000;FFAEFFFF;1|LPD;LPD_DMA_5;FFAD0000;FFADFFFF;1|LPD;LPD_DMA_4;FFAC0000;FFACFFFF;1|LPD;LPD_DMA_3;FFAB0000;FFABFFFF;1|LPD;LPD_DMA_2;FFAA0000;FFAAFFFF;1|LPD;LPD_DMA_1;FFA90000;FFA9FFFF;1|LPD;LPD_DMA_0;FFA80000;FFA8FFFF;1|LPD;IPI_CTRL;FF380000;FF3FFFFF;1|LPD;IOU_SLCR;FF180000;FF23FFFF;1|LPD;IOU_SECURE_SLCR;FF240000;FF24FFFF;1|LPD;IOU_SCNTRS;FF260000;FF26FFFF;1|LPD;IOU_SCNTR;FF250000;FF25FFFF;1|LPD;IOU_GPV;FE000000;FE0FFFFF;1|LPD;I2C1;FF030000;FF03FFFF;1|LPD;I2C0;FF020000;FF02FFFF;1|FPD;GPU;FD4B0000;FD4BFFFF;1|LPD;GPIO;FF0A0000;FF0AFFFF;1|LPD;GEM3;FF0E0000;FF0EFFFF;1|LPD;GEM2;FF0D0000;FF0DFFFF;0|LPD;GEM1;FF0C0000;FF0CFFFF;0|LPD;GEM0;FF0B0000;FF0BFFFF;0|FPD;FPD_XMPU_SINK;FD4F0000;FD4FFFFF;1|FPD;FPD_XMPU_CFG;FD5D0000;FD5DFFFF;1|FPD;FPD_SLCR_SECURE;FD690000;FD6CFFFF;1|FPD;FPD_SLCR;FD610000;FD68FFFF;1|FPD;FPD_DMA_CH7;FD570000;FD57FFFF;1|FPD;FPD_DMA_CH6;FD560000;FD56FFFF;1|FPD;FPD_DMA_CH5;FD550000;FD55FFFF;1|FPD;FPD_DMA_CH4;FD540000;FD54FFFF;1|FPD;FPD_DMA_CH3;FD530000;FD53FFFF;1|FPD;FPD_DMA_CH2;FD520000;FD52FFFF;1|FPD;FPD_DMA_CH1;FD510000;FD51FFFF;1|FPD;FPD_DMA_CH0;FD500000;FD50FFFF;1|LPD;EFUSE;FFCC0000;FFCCFFFF;1|FPD;Display\
Port;FD4A0000;FD4AFFFF;1|FPD;DPDMA;FD4C0000;FD4CFFFF;1|FPD;DDR_XMPU5_CFG;FD050000;FD05FFFF;1|FPD;DDR_XMPU4_CFG;FD040000;FD04FFFF;1|FPD;DDR_XMPU3_CFG;FD030000;FD03FFFF;1|FPD;DDR_XMPU2_CFG;FD020000;FD02FFFF;1|FPD;DDR_XMPU1_CFG;FD010000;FD01FFFF;1|FPD;DDR_XMPU0_CFG;FD000000;FD00FFFF;1|FPD;DDR_QOS_CTRL;FD090000;FD09FFFF;1|FPD;DDR_PHY;FD080000;FD08FFFF;1|DDR;DDR_LOW;0;7FFFFFFF;1|DDR;DDR_HIGH;800000000;87FFFFFFF;1|FPD;DDDR_CTRL;FD070000;FD070FFF;1|LPD;Coresight;FE800000;FEFFFFFF;1|LPD;CSU_DMA;FFC80000;FFC9FFFF;1|LPD;CSU;FFCA0000;FFCAFFFF;1|LPD;CRL_APB;FF5E0000;FF85FFFF;1|FPD;CRF_APB;FD1A0000;FD2DFFFF;1|FPD;CCI_REG;FD5E0000;FD5EFFFF;1|LPD;CAN1;FF070000;FF07FFFF;1|LPD;CAN0;FF060000;FF06FFFF;0|FPD;APU;FD5C0000;FD5CFFFF;1|LPD;APM_INTC_IOU;FFA20000;FFA2FFFF;1|LPD;APM_FPD_LPD;FFA30000;FFA3FFFF;1|FPD;APM_5;FD490000;FD49FFFF;1|FPD;APM_0;FD0B0000;FD0BFFFF;1|LPD;APM2;FFA10000;FFA1FFFF;1|LPD;APM1;FFA00000;FFA0FFFF;1|LPD;AMS;FFA50000;FFA5FFFF;1|FPD;AFI_5;FD3B0000;FD3BFFFF;1|FPD;AFI_4;FD3A0000;FD3AFFFF;1|FPD;AFI_3;FD390000;FD39FFFF;1|FPD;AFI_2;FD380000;FD38FFFF;1|FPD;AFI_1;FD370000;FD37FFFF;1|FPD;AFI_0;FD360000;FD36FFFF;1|LPD;AFIFM6;FF9B0000;FF9BFFFF;1|FPD;ACPU_GIC;F9010000;F907FFFF;1}\
\
    CONFIG.PSU__PSS_REF_CLK__FREQMHZ {33.330} \
    CONFIG.PSU__QSPI_COHERENCY {0} \
    CONFIG.PSU__QSPI_ROUTE_THROUGH_FPD {0} \
    CONFIG.PSU__QSPI__GRP_FBCLK__ENABLE {1} \
    CONFIG.PSU__QSPI__GRP_FBCLK__IO {MIO 6} \
    CONFIG.PSU__QSPI__PERIPHERAL__DATA_MODE {x4} \
    CONFIG.PSU__QSPI__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__QSPI__PERIPHERAL__IO {MIO 0 .. 12} \
    CONFIG.PSU__QSPI__PERIPHERAL__MODE {Dual Parallel} \
    CONFIG.PSU__SATA__LANE0__ENABLE {0} \
    CONFIG.PSU__SATA__LANE1__IO {GT Lane3} \
    CONFIG.PSU__SATA__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__SATA__REF_CLK_FREQ {125} \
    CONFIG.PSU__SATA__REF_CLK_SEL {Ref Clk1} \
    CONFIG.PSU__SAXIGP2__DATA_WIDTH {128} \
    CONFIG.PSU__SD1_COHERENCY {0} \
    CONFIG.PSU__SD1_ROUTE_THROUGH_FPD {0} \
    CONFIG.PSU__SD1__CLK_100_SDR_OTAP_DLY {0x3} \
    CONFIG.PSU__SD1__CLK_200_SDR_OTAP_DLY {0x3} \
    CONFIG.PSU__SD1__CLK_50_DDR_ITAP_DLY {0x3D} \
    CONFIG.PSU__SD1__CLK_50_DDR_OTAP_DLY {0x4} \
    CONFIG.PSU__SD1__CLK_50_SDR_ITAP_DLY {0x15} \
    CONFIG.PSU__SD1__CLK_50_SDR_OTAP_DLY {0x5} \
    CONFIG.PSU__SD1__DATA_TRANSFER_MODE {8Bit} \
    CONFIG.PSU__SD1__GRP_CD__ENABLE {1} \
    CONFIG.PSU__SD1__GRP_CD__IO {MIO 45} \
    CONFIG.PSU__SD1__GRP_POW__ENABLE {0} \
    CONFIG.PSU__SD1__GRP_WP__ENABLE {1} \
    CONFIG.PSU__SD1__GRP_WP__IO {MIO 44} \
    CONFIG.PSU__SD1__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__SD1__PERIPHERAL__IO {MIO 39 .. 51} \
    CONFIG.PSU__SD1__SLOT_TYPE {SD 3.0} \
    CONFIG.PSU__SWDT0__CLOCK__ENABLE {0} \
    CONFIG.PSU__SWDT0__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__SWDT0__RESET__ENABLE {0} \
    CONFIG.PSU__SWDT1__CLOCK__ENABLE {0} \
    CONFIG.PSU__SWDT1__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__SWDT1__RESET__ENABLE {0} \
    CONFIG.PSU__TSU__BUFG_PORT_PAIR {0} \
    CONFIG.PSU__TTC0__CLOCK__ENABLE {0} \
    CONFIG.PSU__TTC0__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__TTC0__WAVEOUT__ENABLE {0} \
    CONFIG.PSU__TTC1__CLOCK__ENABLE {0} \
    CONFIG.PSU__TTC1__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__TTC1__WAVEOUT__ENABLE {0} \
    CONFIG.PSU__TTC2__CLOCK__ENABLE {0} \
    CONFIG.PSU__TTC2__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__TTC2__WAVEOUT__ENABLE {0} \
    CONFIG.PSU__TTC3__CLOCK__ENABLE {0} \
    CONFIG.PSU__TTC3__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__TTC3__WAVEOUT__ENABLE {0} \
    CONFIG.PSU__UART0__BAUD_RATE {115200} \
    CONFIG.PSU__UART0__MODEM__ENABLE {0} \
    CONFIG.PSU__UART0__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__UART0__PERIPHERAL__IO {MIO 18 .. 19} \
    CONFIG.PSU__UART1__BAUD_RATE {115200} \
    CONFIG.PSU__UART1__MODEM__ENABLE {0} \
    CONFIG.PSU__UART1__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__UART1__PERIPHERAL__IO {MIO 20 .. 21} \
    CONFIG.PSU__USB0_COHERENCY {0} \
    CONFIG.PSU__USB0__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__USB0__PERIPHERAL__IO {MIO 52 .. 63} \
    CONFIG.PSU__USB0__REF_CLK_FREQ {26} \
    CONFIG.PSU__USB0__REF_CLK_SEL {Ref Clk2} \
    CONFIG.PSU__USB2_0__EMIO__ENABLE {0} \
    CONFIG.PSU__USB3_0__EMIO__ENABLE {0} \
    CONFIG.PSU__USB3_0__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__USB3_0__PERIPHERAL__IO {GT Lane2} \
    CONFIG.PSU__USB__RESET__MODE {Boot Pin} \
    CONFIG.PSU__USB__RESET__POLARITY {Active Low} \
    CONFIG.PSU__USE__IRQ0 {1} \
    CONFIG.PSU__USE__M_AXI_GP0 {1} \
    CONFIG.PSU__USE__M_AXI_GP1 {1} \
    CONFIG.PSU__USE__M_AXI_GP2 {0} \
    CONFIG.PSU__USE__S_AXI_GP2 {1} \
  ] $zynq_ultra_ps_e


  # Create instance: xxv_ethernet, and set properties
  set xxv_ethernet [ create_bd_cell -type ip -vlnv xilinx.com:ip:xxv_ethernet:4.1 xxv_ethernet ]
  set_property -dict [list \
    CONFIG.BASE_R_KR {BASE-KR} \
    CONFIG.DIFFCLK_BOARD_INTERFACE {Custom} \
    CONFIG.GT_GROUP_SELECT {Quad_X1Y3} \
    CONFIG.INCLUDE_AUTO_NEG_LT_LOGIC {None} \
    CONFIG.INCLUDE_FEC_LOGIC {0} \
    CONFIG.LANE1_GT_LOC {X1Y14} \
    CONFIG.USE_BOARD_FLOW {true} \
  ] $xxv_ethernet


  # Create instance: ps8_axi_intercon, and set properties
  set ps8_axi_intercon [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 ps8_axi_intercon ]
  set_property -dict [list \
    CONFIG.NUM_MI {2} \
    CONFIG.NUM_SI {2} \
  ] $ps8_axi_intercon


  # Create instance: rst_ps8_99M, and set properties
  set rst_ps8_99M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_ps8_99M ]

  # Create instance: axi_dma, and set properties
  set axi_dma [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma ]
  set_property -dict [list \
    CONFIG.c_include_mm2s_dre {1} \
    CONFIG.c_include_s2mm_dre {1} \
    CONFIG.c_m_axi_mm2s_data_width {64} \
    CONFIG.c_m_axis_mm2s_tdata_width {64} \
    CONFIG.c_mm2s_burst_size {64} \
    CONFIG.c_s2mm_burst_size {8} \
    CONFIG.c_sg_include_stscntrl_strm {0} \
    CONFIG.c_sg_length_width {16} \
  ] $axi_dma


  # Create instance: tx_data_fifo, and set properties
  set tx_data_fifo [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 tx_data_fifo ]
  set_property -dict [list \
    CONFIG.FIFO_DEPTH {32768} \
    CONFIG.FIFO_MODE {2} \
    CONFIG.HAS_RD_DATA_COUNT {1} \
    CONFIG.HAS_WR_DATA_COUNT {1} \
  ] $tx_data_fifo


  # Create instance: rx_data_fifo, and set properties
  set rx_data_fifo [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 rx_data_fifo ]
  set_property -dict [list \
    CONFIG.FIFO_DEPTH {32768} \
    CONFIG.FIFO_MODE {2} \
    CONFIG.HAS_RD_DATA_COUNT {1} \
    CONFIG.HAS_WR_DATA_COUNT {1} \
  ] $rx_data_fifo


  # Create instance: pl_ps_axi_intercon, and set properties
  set pl_ps_axi_intercon [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 pl_ps_axi_intercon ]
  set_property -dict [list \
    CONFIG.NUM_MI {1} \
    CONFIG.NUM_SI {3} \
  ] $pl_ps_axi_intercon


  # Create instance: rst_xxv_ethernet_156M_rx, and set properties
  set rst_xxv_ethernet_156M_rx [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_xxv_ethernet_156M_rx ]

  # Create instance: rst_xxv_ethernet_156M_tx, and set properties
  set rst_xxv_ethernet_156M_tx [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_xxv_ethernet_156M_tx ]

  # Create instance: xlconcat, and set properties
  set xlconcat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat ]

  # Create instance: rst_dma_tx, and set properties
  set rst_dma_tx [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_dma_tx ]

  # Create instance: rst_dma_rx, and set properties
  set rst_dma_rx [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_dma_rx ]

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]
  set_property -dict [list \
    CONFIG.CONST_VAL {5} \
    CONFIG.CONST_WIDTH {3} \
  ] $xlconstant_0


  # Create instance: xlconstant_1, and set properties
  set xlconstant_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_1 ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0} \
    CONFIG.CONST_WIDTH {56} \
  ] $xlconstant_1


  # Create instance: xlconstant_2, and set properties
  set xlconstant_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_2 ]

  # Create instance: ila_0, and set properties
  set ila_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ila:6.2 ila_0 ]
  set_property -dict [list \
    CONFIG.C_MONITOR_TYPE {Native} \
    CONFIG.C_NUM_OF_PROBES {11} \
  ] $ila_0


  # Create instance: ila_1, and set properties
  set ila_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ila:6.2 ila_1 ]
  set_property -dict [list \
    CONFIG.C_MONITOR_TYPE {Native} \
    CONFIG.C_NUM_OF_PROBES {35} \
    CONFIG.C_PROBE1_WIDTH {2} \
    CONFIG.C_PROBE22_WIDTH {2} \
    CONFIG.C_PROBE25_WIDTH {4} \
    CONFIG.C_PROBE26_WIDTH {14} \
    CONFIG.C_PROBE28_WIDTH {2} \
  ] $ila_1


  # Create instance: ila_2, and set properties
  set ila_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ila:6.2 ila_2 ]
  set_property -dict [list \
    CONFIG.C_MONITOR_TYPE {Native} \
    CONFIG.C_NUM_OF_PROBES {1} \
  ] $ila_2


  # Create interface connections
  connect_bd_intf_net -intf_net axi_dma_0_M_AXIS_MM2S [get_bd_intf_pins axi_dma/M_AXIS_MM2S] [get_bd_intf_pins tx_data_fifo/S_AXIS]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_MM2S [get_bd_intf_pins axi_dma/M_AXI_MM2S] [get_bd_intf_pins pl_ps_axi_intercon/S01_AXI]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_S2MM [get_bd_intf_pins axi_dma/M_AXI_S2MM] [get_bd_intf_pins pl_ps_axi_intercon/S02_AXI]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_SG [get_bd_intf_pins axi_dma/M_AXI_SG] [get_bd_intf_pins pl_ps_axi_intercon/S00_AXI]
  connect_bd_intf_net -intf_net diff_clock_rtl_1 [get_bd_intf_ports gt_ref] [get_bd_intf_pins xxv_ethernet/gt_ref_clk]
  connect_bd_intf_net -intf_net pl_ps_axi_interconnect_M00_AXI [get_bd_intf_pins zynq_ultra_ps_e/S_AXI_HP0_FPD] [get_bd_intf_pins pl_ps_axi_intercon/M00_AXI]
  connect_bd_intf_net -intf_net ps8_0_axi_periph_M00_AXI [get_bd_intf_pins ps8_axi_intercon/M00_AXI] [get_bd_intf_pins xxv_ethernet/s_axi_0]
  connect_bd_intf_net -intf_net ps8_0_axi_periph_M01_AXI [get_bd_intf_pins axi_dma/S_AXI_LITE] [get_bd_intf_pins ps8_axi_intercon/M01_AXI]
  connect_bd_intf_net -intf_net rx_data_fifo_M_AXIS [get_bd_intf_pins rx_data_fifo/M_AXIS] [get_bd_intf_pins axi_dma/S_AXIS_S2MM]
  connect_bd_intf_net -intf_net tx_data_fifo_M_AXIS [get_bd_intf_pins tx_data_fifo/M_AXIS] [get_bd_intf_pins xxv_ethernet/axis_tx_0]
  connect_bd_intf_net -intf_net xxv_ethernet_0_axis_rx_0 [get_bd_intf_pins rx_data_fifo/S_AXIS] [get_bd_intf_pins xxv_ethernet/axis_rx_0]
  connect_bd_intf_net -intf_net xxv_ethernet_0_gt_serial_port [get_bd_intf_ports gt_rtl] [get_bd_intf_pins xxv_ethernet/gt_serial_port]
  connect_bd_intf_net -intf_net zynq_ultra_ps_e_0_M_AXI_HPM0_FPD [get_bd_intf_pins zynq_ultra_ps_e/M_AXI_HPM0_FPD] [get_bd_intf_pins ps8_axi_intercon/S00_AXI]
  connect_bd_intf_net -intf_net zynq_ultra_ps_e_0_M_AXI_HPM1_FPD [get_bd_intf_pins zynq_ultra_ps_e/M_AXI_HPM1_FPD] [get_bd_intf_pins ps8_axi_intercon/S01_AXI]

  # Create port connections
  connect_bd_net -net axi_dma_0_mm2s_introut [get_bd_pins axi_dma/mm2s_introut] [get_bd_pins xlconcat/In0]
  connect_bd_net -net axi_dma_0_s2mm_introut [get_bd_pins axi_dma/s2mm_introut] [get_bd_pins xlconcat/In1]
  connect_bd_net -net axi_dma_mm2s_prmry_reset_out_n [get_bd_pins axi_dma/mm2s_prmry_reset_out_n] [get_bd_pins rst_dma_tx/ext_reset_in]
  connect_bd_net -net axi_dma_s2mm_prmry_reset_out_n [get_bd_pins axi_dma/s2mm_prmry_reset_out_n] [get_bd_pins rst_dma_rx/ext_reset_in]
  connect_bd_net -net proc_sys_reset_0_peripheral_reset [get_bd_pins rst_dma_tx/peripheral_reset] [get_bd_pins xxv_ethernet/tx_reset_0]
  connect_bd_net -net rst_dma_rx_peripheral_reset [get_bd_pins rst_dma_rx/peripheral_reset] [get_bd_pins xxv_ethernet/rx_reset_0]
  connect_bd_net -net rst_ps8_0_99M_peripheral_aresetn [get_bd_pins rst_ps8_99M/peripheral_aresetn] [get_bd_pins ps8_axi_intercon/S00_ARESETN] [get_bd_pins xxv_ethernet/s_axi_aresetn_0] [get_bd_pins ps8_axi_intercon/M00_ARESETN] [get_bd_pins ps8_axi_intercon/ARESETN] [get_bd_pins ps8_axi_intercon/S01_ARESETN] [get_bd_pins pl_ps_axi_intercon/M00_ARESETN] [get_bd_pins pl_ps_axi_intercon/ARESETN] [get_bd_pins ps8_axi_intercon/M01_ARESETN] [get_bd_pins axi_dma/axi_resetn] [get_bd_pins pl_ps_axi_intercon/S00_ARESETN]
  connect_bd_net -net rst_ps8_0_99M_peripheral_reset [get_bd_pins rst_ps8_99M/peripheral_reset] [get_bd_pins xxv_ethernet/sys_reset] [get_bd_pins xxv_ethernet/gtwiz_reset_rx_datapath_0] [get_bd_pins xxv_ethernet/gtwiz_reset_tx_datapath_0]
  connect_bd_net -net rst_xxv_ethernet_0_156M_1_peripheral_aresetn [get_bd_pins rst_xxv_ethernet_156M_tx/peripheral_aresetn] [get_bd_pins pl_ps_axi_intercon/S01_ARESETN] [get_bd_pins tx_data_fifo/s_axis_aresetn]
  connect_bd_net -net rst_xxv_ethernet_0_156M_peripheral_aresetn [get_bd_pins rst_xxv_ethernet_156M_rx/peripheral_aresetn] [get_bd_pins pl_ps_axi_intercon/S02_ARESETN] [get_bd_pins rx_data_fifo/s_axis_aresetn]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins xlconcat/dout] [get_bd_pins zynq_ultra_ps_e/pl_ps_irq0]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins xlconstant_0/dout] [get_bd_pins xxv_ethernet/txoutclksel_in_0] [get_bd_pins xxv_ethernet/rxoutclksel_in_0]
  connect_bd_net -net xlconstant_1_dout [get_bd_pins xlconstant_1/dout] [get_bd_pins xxv_ethernet/tx_preamblein_0]
  connect_bd_net -net xlconstant_2_dout [get_bd_pins xlconstant_2/dout] [get_bd_ports sfp_tx_dis]
  connect_bd_net -net xxv_ethernet_0_rx_clk_out_0 [get_bd_pins xxv_ethernet/rx_clk_out_0] [get_bd_pins xxv_ethernet/rx_core_clk_0] [get_bd_pins rst_xxv_ethernet_156M_rx/slowest_sync_clk] [get_bd_pins axi_dma/m_axi_s2mm_aclk] [get_bd_pins rx_data_fifo/s_axis_aclk] [get_bd_pins pl_ps_axi_intercon/S02_ACLK] [get_bd_pins rst_dma_rx/slowest_sync_clk] [get_bd_pins ila_1/clk]
  connect_bd_net -net xxv_ethernet_0_tx_clk_out_0 [get_bd_pins xxv_ethernet/tx_clk_out_0] [get_bd_pins rst_xxv_ethernet_156M_tx/slowest_sync_clk] [get_bd_pins axi_dma/m_axi_mm2s_aclk] [get_bd_pins tx_data_fifo/s_axis_aclk] [get_bd_pins pl_ps_axi_intercon/S01_ACLK] [get_bd_pins rst_dma_tx/slowest_sync_clk] [get_bd_pins ila_0/clk]
  connect_bd_net -net xxv_ethernet_0_user_rx_reset_0 [get_bd_pins xxv_ethernet/user_rx_reset_0] [get_bd_pins rst_xxv_ethernet_156M_rx/ext_reset_in]
  connect_bd_net -net xxv_ethernet_0_user_tx_reset_0 [get_bd_pins xxv_ethernet/user_tx_reset_0] [get_bd_pins rst_xxv_ethernet_156M_tx/ext_reset_in]
  connect_bd_net -net xxv_ethernet_gt_refclk_out [get_bd_pins xxv_ethernet/gt_refclk_out] [get_bd_pins ila_2/clk]
  connect_bd_net -net xxv_ethernet_gtpowergood_out_0 [get_bd_pins xxv_ethernet/gtpowergood_out_0] [get_bd_pins ila_2/probe0]
  connect_bd_net -net xxv_ethernet_stat_rx_bad_code_0 [get_bd_pins xxv_ethernet/stat_rx_bad_code_0] [get_bd_pins ila_1/probe0]
  connect_bd_net -net xxv_ethernet_stat_rx_bad_fcs_0 [get_bd_pins xxv_ethernet/stat_rx_bad_fcs_0] [get_bd_pins ila_1/probe1]
  connect_bd_net -net xxv_ethernet_stat_rx_bad_preamble_0 [get_bd_pins xxv_ethernet/stat_rx_bad_preamble_0] [get_bd_pins ila_1/probe2]
  connect_bd_net -net xxv_ethernet_stat_rx_bad_sfd_0 [get_bd_pins xxv_ethernet/stat_rx_bad_sfd_0] [get_bd_pins ila_1/probe3]
  connect_bd_net -net xxv_ethernet_stat_rx_block_lock_0 [get_bd_pins xxv_ethernet/stat_rx_block_lock_0] [get_bd_pins ila_1/probe4]
  connect_bd_net -net xxv_ethernet_stat_rx_broadcast_0 [get_bd_pins xxv_ethernet/stat_rx_broadcast_0] [get_bd_pins ila_1/probe5]
  connect_bd_net -net xxv_ethernet_stat_rx_fragment_0 [get_bd_pins xxv_ethernet/stat_rx_fragment_0] [get_bd_pins ila_1/probe6]
  connect_bd_net -net xxv_ethernet_stat_rx_framing_err_0 [get_bd_pins xxv_ethernet/stat_rx_framing_err_0] [get_bd_pins ila_1/probe7]
  connect_bd_net -net xxv_ethernet_stat_rx_framing_err_valid_0 [get_bd_pins xxv_ethernet/stat_rx_framing_err_valid_0] [get_bd_pins ila_1/probe8]
  connect_bd_net -net xxv_ethernet_stat_rx_got_signal_os_0 [get_bd_pins xxv_ethernet/stat_rx_got_signal_os_0] [get_bd_pins ila_1/probe9]
  connect_bd_net -net xxv_ethernet_stat_rx_hi_ber_0 [get_bd_pins xxv_ethernet/stat_rx_hi_ber_0] [get_bd_pins ila_1/probe10]
  connect_bd_net -net xxv_ethernet_stat_rx_inrangeerr_0 [get_bd_pins xxv_ethernet/stat_rx_inrangeerr_0] [get_bd_pins ila_1/probe11]
  connect_bd_net -net xxv_ethernet_stat_rx_internal_local_fault_0 [get_bd_pins xxv_ethernet/stat_rx_internal_local_fault_0] [get_bd_pins ila_1/probe12]
  connect_bd_net -net xxv_ethernet_stat_rx_jabber_0 [get_bd_pins xxv_ethernet/stat_rx_jabber_0] [get_bd_pins ila_1/probe13]
  connect_bd_net -net xxv_ethernet_stat_rx_local_fault_0 [get_bd_pins xxv_ethernet/stat_rx_local_fault_0] [get_bd_pins ila_1/probe14]
  connect_bd_net -net xxv_ethernet_stat_rx_multicast_0 [get_bd_pins xxv_ethernet/stat_rx_multicast_0] [get_bd_pins ila_1/probe15]
  connect_bd_net -net xxv_ethernet_stat_rx_oversize_0 [get_bd_pins xxv_ethernet/stat_rx_oversize_0] [get_bd_pins ila_1/probe16]
  connect_bd_net -net xxv_ethernet_stat_rx_packet_bad_fcs_0 [get_bd_pins xxv_ethernet/stat_rx_packet_bad_fcs_0] [get_bd_pins ila_1/probe17]
  connect_bd_net -net xxv_ethernet_stat_rx_packet_large_0 [get_bd_pins xxv_ethernet/stat_rx_packet_large_0] [get_bd_pins ila_1/probe18]
  connect_bd_net -net xxv_ethernet_stat_rx_packet_small_0 [get_bd_pins xxv_ethernet/stat_rx_packet_small_0] [get_bd_pins ila_1/probe19]
  connect_bd_net -net xxv_ethernet_stat_rx_received_local_fault_0 [get_bd_pins xxv_ethernet/stat_rx_received_local_fault_0] [get_bd_pins ila_1/probe20]
  connect_bd_net -net xxv_ethernet_stat_rx_remote_fault_0 [get_bd_pins xxv_ethernet/stat_rx_remote_fault_0] [get_bd_pins ila_1/probe21]
  connect_bd_net -net xxv_ethernet_stat_rx_status_0 [get_bd_pins xxv_ethernet/stat_rx_status_0] [get_bd_pins ila_1/probe34]
  connect_bd_net -net xxv_ethernet_stat_rx_stomped_fcs_0 [get_bd_pins xxv_ethernet/stat_rx_stomped_fcs_0] [get_bd_pins ila_1/probe22]
  connect_bd_net -net xxv_ethernet_stat_rx_test_pattern_mismatch_0 [get_bd_pins xxv_ethernet/stat_rx_test_pattern_mismatch_0] [get_bd_pins ila_1/probe23]
  connect_bd_net -net xxv_ethernet_stat_rx_toolong_0 [get_bd_pins xxv_ethernet/stat_rx_toolong_0] [get_bd_pins ila_1/probe24]
  connect_bd_net -net xxv_ethernet_stat_rx_total_bytes_0 [get_bd_pins xxv_ethernet/stat_rx_total_bytes_0] [get_bd_pins ila_1/probe25]
  connect_bd_net -net xxv_ethernet_stat_rx_total_good_bytes_0 [get_bd_pins xxv_ethernet/stat_rx_total_good_bytes_0] [get_bd_pins ila_1/probe26]
  connect_bd_net -net xxv_ethernet_stat_rx_total_good_packets_0 [get_bd_pins xxv_ethernet/stat_rx_total_good_packets_0] [get_bd_pins ila_1/probe27]
  connect_bd_net -net xxv_ethernet_stat_rx_total_packets_0 [get_bd_pins xxv_ethernet/stat_rx_total_packets_0] [get_bd_pins ila_1/probe28]
  connect_bd_net -net xxv_ethernet_stat_rx_truncated_0 [get_bd_pins xxv_ethernet/stat_rx_truncated_0] [get_bd_pins ila_1/probe29]
  connect_bd_net -net xxv_ethernet_stat_rx_undersize_0 [get_bd_pins xxv_ethernet/stat_rx_undersize_0] [get_bd_pins ila_1/probe30]
  connect_bd_net -net xxv_ethernet_stat_rx_unicast_0 [get_bd_pins xxv_ethernet/stat_rx_unicast_0] [get_bd_pins ila_1/probe31]
  connect_bd_net -net xxv_ethernet_stat_rx_valid_ctrl_code_0 [get_bd_pins xxv_ethernet/stat_rx_valid_ctrl_code_0] [get_bd_pins ila_1/probe32]
  connect_bd_net -net xxv_ethernet_stat_rx_vlan_0 [get_bd_pins xxv_ethernet/stat_rx_vlan_0] [get_bd_pins ila_1/probe33]
  connect_bd_net -net xxv_ethernet_stat_tx_bad_fcs_0 [get_bd_pins xxv_ethernet/stat_tx_bad_fcs_0] [get_bd_pins ila_0/probe0]
  connect_bd_net -net xxv_ethernet_stat_tx_broadcast_0 [get_bd_pins xxv_ethernet/stat_tx_broadcast_0] [get_bd_pins ila_0/probe1]
  connect_bd_net -net xxv_ethernet_stat_tx_frame_error_0 [get_bd_pins xxv_ethernet/stat_tx_frame_error_0] [get_bd_pins ila_0/probe2]
  connect_bd_net -net xxv_ethernet_stat_tx_local_fault_0 [get_bd_pins xxv_ethernet/stat_tx_local_fault_0] [get_bd_pins ila_0/probe3]
  connect_bd_net -net xxv_ethernet_stat_tx_multicast_0 [get_bd_pins xxv_ethernet/stat_tx_multicast_0] [get_bd_pins ila_0/probe4]
  connect_bd_net -net xxv_ethernet_stat_tx_packet_large_0 [get_bd_pins xxv_ethernet/stat_tx_packet_large_0] [get_bd_pins ila_0/probe5]
  connect_bd_net -net xxv_ethernet_stat_tx_packet_small_0 [get_bd_pins xxv_ethernet/stat_tx_packet_small_0] [get_bd_pins ila_0/probe6]
  connect_bd_net -net xxv_ethernet_stat_tx_total_good_packets_0 [get_bd_pins xxv_ethernet/stat_tx_total_good_packets_0] [get_bd_pins ila_0/probe7]
  connect_bd_net -net xxv_ethernet_stat_tx_total_packets_0 [get_bd_pins xxv_ethernet/stat_tx_total_packets_0] [get_bd_pins ila_0/probe8]
  connect_bd_net -net xxv_ethernet_stat_tx_unicast_0 [get_bd_pins xxv_ethernet/stat_tx_unicast_0] [get_bd_pins ila_0/probe9]
  connect_bd_net -net xxv_ethernet_stat_tx_vlan_0 [get_bd_pins xxv_ethernet/stat_tx_vlan_0] [get_bd_pins ila_0/probe10]
  connect_bd_net -net zynq_ultra_ps_e_0_pl_clk0 [get_bd_pins zynq_ultra_ps_e/pl_clk0] [get_bd_pins zynq_ultra_ps_e/maxihpm0_fpd_aclk] [get_bd_pins ps8_axi_intercon/S00_ACLK] [get_bd_pins rst_ps8_99M/slowest_sync_clk] [get_bd_pins xxv_ethernet/s_axi_aclk_0] [get_bd_pins ps8_axi_intercon/M00_ACLK] [get_bd_pins ps8_axi_intercon/ACLK] [get_bd_pins zynq_ultra_ps_e/maxihpm1_fpd_aclk] [get_bd_pins ps8_axi_intercon/S01_ACLK] [get_bd_pins zynq_ultra_ps_e/saxihp0_fpd_aclk] [get_bd_pins xxv_ethernet/dclk] [get_bd_pins pl_ps_axi_intercon/M00_ACLK] [get_bd_pins pl_ps_axi_intercon/ACLK] [get_bd_pins ps8_axi_intercon/M01_ACLK] [get_bd_pins axi_dma/s_axi_lite_aclk] [get_bd_pins axi_dma/m_axi_sg_aclk] [get_bd_pins pl_ps_axi_intercon/S00_ACLK]
  connect_bd_net -net zynq_ultra_ps_e_0_pl_resetn0 [get_bd_pins zynq_ultra_ps_e/pl_resetn0] [get_bd_pins rst_ps8_99M/ext_reset_in]

  # Create address segments
  assign_bd_address -offset 0xA0010000 -range 0x00010000 -with_name SEG_axi_dma_0_Reg -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e/Data] [get_bd_addr_segs axi_dma/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0xA0000000 -range 0x00010000 -with_name SEG_xxv_ethernet_0_Reg -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e/Data] [get_bd_addr_segs xxv_ethernet/s_axi_0/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -with_name SEG_zynq_ultra_ps_e_0_HP0_DDR_LOW -target_address_space [get_bd_addr_spaces axi_dma/Data_MM2S] [get_bd_addr_segs zynq_ultra_ps_e/SAXIGP2/HP0_DDR_LOW] -force
  assign_bd_address -offset 0xE0000000 -range 0x10000000 -with_name SEG_zynq_ultra_ps_e_0_HP0_PCIE_LOW -target_address_space [get_bd_addr_spaces axi_dma/Data_MM2S] [get_bd_addr_segs zynq_ultra_ps_e/SAXIGP2/HP0_PCIE_LOW] -force
  assign_bd_address -offset 0xC0000000 -range 0x20000000 -with_name SEG_zynq_ultra_ps_e_0_HP0_QSPI -target_address_space [get_bd_addr_spaces axi_dma/Data_MM2S] [get_bd_addr_segs zynq_ultra_ps_e/SAXIGP2/HP0_QSPI] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -with_name SEG_zynq_ultra_ps_e_0_HP0_DDR_LOW -target_address_space [get_bd_addr_spaces axi_dma/Data_S2MM] [get_bd_addr_segs zynq_ultra_ps_e/SAXIGP2/HP0_DDR_LOW] -force
  assign_bd_address -offset 0xE0000000 -range 0x10000000 -with_name SEG_zynq_ultra_ps_e_0_HP0_PCIE_LOW -target_address_space [get_bd_addr_spaces axi_dma/Data_S2MM] [get_bd_addr_segs zynq_ultra_ps_e/SAXIGP2/HP0_PCIE_LOW] -force
  assign_bd_address -offset 0xC0000000 -range 0x20000000 -with_name SEG_zynq_ultra_ps_e_0_HP0_QSPI -target_address_space [get_bd_addr_spaces axi_dma/Data_S2MM] [get_bd_addr_segs zynq_ultra_ps_e/SAXIGP2/HP0_QSPI] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -with_name SEG_zynq_ultra_ps_e_0_HP0_DDR_LOW -target_address_space [get_bd_addr_spaces axi_dma/Data_SG] [get_bd_addr_segs zynq_ultra_ps_e/SAXIGP2/HP0_DDR_LOW] -force
  assign_bd_address -offset 0xE0000000 -range 0x10000000 -with_name SEG_zynq_ultra_ps_e_0_HP0_PCIE_LOW -target_address_space [get_bd_addr_spaces axi_dma/Data_SG] [get_bd_addr_segs zynq_ultra_ps_e/SAXIGP2/HP0_PCIE_LOW] -force
  assign_bd_address -offset 0xC0000000 -range 0x20000000 -with_name SEG_zynq_ultra_ps_e_0_HP0_QSPI -target_address_space [get_bd_addr_spaces axi_dma/Data_SG] [get_bd_addr_segs zynq_ultra_ps_e/SAXIGP2/HP0_QSPI] -force

  # Exclude Address Segments
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces axi_dma/Data_MM2S] [get_bd_addr_segs zynq_ultra_ps_e/SAXIGP2/HP0_DDR_HIGH]
  exclude_bd_addr_seg -offset 0xFF000000 -range 0x01000000 -target_address_space [get_bd_addr_spaces axi_dma/Data_MM2S] [get_bd_addr_segs zynq_ultra_ps_e/SAXIGP2/HP0_LPS_OCM]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces axi_dma/Data_S2MM] [get_bd_addr_segs zynq_ultra_ps_e/SAXIGP2/HP0_DDR_HIGH]
  exclude_bd_addr_seg -offset 0xFF000000 -range 0x01000000 -target_address_space [get_bd_addr_spaces axi_dma/Data_S2MM] [get_bd_addr_segs zynq_ultra_ps_e/SAXIGP2/HP0_LPS_OCM]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces axi_dma/Data_SG] [get_bd_addr_segs zynq_ultra_ps_e/SAXIGP2/HP0_DDR_HIGH]
  exclude_bd_addr_seg -offset 0xFF000000 -range 0x01000000 -target_address_space [get_bd_addr_spaces axi_dma/Data_SG] [get_bd_addr_segs zynq_ultra_ps_e/SAXIGP2/HP0_LPS_OCM]


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################



