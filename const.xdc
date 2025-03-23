create_clock -period 10.000 -name clk -waveform {0.000 5.000} [get_ports clk]
set_property PACKAGE_PIN B3 [get_ports phy_reset]
set_property IOSTANDARD LVCMOS33 [get_ports phy_reset]

set_property PACKAGE_PIN T10 [get_ports led]
set_property IOSTANDARD LVCMOS33 [get_ports led]

set_property PACKAGE_PIN J15 [get_ports sw]
set_property IOSTANDARD LVCMOS33 [get_ports sw]


set_property PACKAGE_PIN C11 [get_ports d0]
set_property IOSTANDARD LVCMOS33 [get_ports d0]

set_property PACKAGE_PIN D10 [get_ports d1]
set_property IOSTANDARD LVCMOS33 [get_ports d1]

set_property PACKAGE_PIN D9 [get_ports dv]
set_property IOSTANDARD LVCMOS33 [get_ports dv]


#############################################################
set_property PACKAGE_PIN T13 [get_ports {reg_addr[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_addr[0]}]

set_property PACKAGE_PIN H6 [get_ports {reg_addr[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_addr[1]}]

set_property PACKAGE_PIN U12 [get_ports {reg_addr[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_addr[2]}]

set_property PACKAGE_PIN U11 [get_ports {reg_addr[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_addr[3]}]

set_property PACKAGE_PIN V10 [get_ports {reg_addr[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {reg_addr[4]}]
#############################################################

set_property PACKAGE_PIN H17 [get_ports {data_read[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_read[0]}]

set_property PACKAGE_PIN K15 [get_ports {data_read[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_read[1]}]

set_property PACKAGE_PIN J13 [get_ports {data_read[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_read[2]}]

set_property PACKAGE_PIN N14 [get_ports {data_read[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_read[3]}]

set_property PACKAGE_PIN R18 [get_ports {data_read[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_read[4]}]

set_property PACKAGE_PIN V17 [get_ports {data_read[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_read[5]}]

set_property PACKAGE_PIN U17 [get_ports {data_read[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_read[6]}]

set_property PACKAGE_PIN U16 [get_ports {data_read[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_read[7]}]

set_property PACKAGE_PIN V16 [get_ports {data_read[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_read[8]}]

set_property PACKAGE_PIN T15 [get_ports {data_read[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_read[9]}]

set_property PACKAGE_PIN U14 [get_ports {data_read[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_read[10]}]

set_property PACKAGE_PIN T16 [get_ports {data_read[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_read[11]}]

set_property PACKAGE_PIN V15 [get_ports {data_read[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_read[12]}]

set_property PACKAGE_PIN V14 [get_ports {data_read[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_read[13]}]

set_property PACKAGE_PIN V12 [get_ports {data_read[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_read[14]}]

set_property PACKAGE_PIN V11 [get_ports {data_read[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_read[15]}]



set_property PACKAGE_PIN E3 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

set_property PACKAGE_PIN L16 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]

set_property PACKAGE_PIN B8 [get_ports eth_int]
set_property IOSTANDARD LVCMOS33 [get_ports eth_int]

set_property PACKAGE_PIN D5 [get_ports clk_out]
set_property IOSTANDARD LVCMOS33 [get_ports clk_out]

set_property PACKAGE_PIN C9 [get_ports mdio_clk]
set_property IOSTANDARD LVCMOS33 [get_ports mdio_clk]

set_property PACKAGE_PIN A9 [get_ports mdio_data]
set_property IOSTANDARD LVCMOS33 [get_ports mdio_data]








create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 4 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER true [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 131072 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL true [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list clk100Mhz]]
set_property port_width 1 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list clk_out_OBUF]]
connect_debug_port u_ila_0/clk [get_nets [list clk_IBUF_BUFG]]


set_property MARK_DEBUG true [get_nets mdio_data_IBUF]




connect_debug_port dbg_hub/clk [get_nets clk_IBUF_BUFG]


create_debug_port u_ila_0 probe
set_property port_width 8 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {valid_data_reg[0]} {valid_data_reg[1]} {valid_data_reg[2]} {valid_data_reg[3]} {valid_data_reg[4]} {valid_data_reg[5]} {valid_data_reg[6]} {valid_data_reg[7]}]]

create_debug_port u_ila_0 probe
set_property port_width 8 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {data[0]} {data[1]} {data[2]} {data[3]} {data[4]} {data[5]} {data[6]} {data[7]}]]
create_debug_port u_ila_0 probe
set_property port_width 1 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list dv_IBUF]]


set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk100Mhz]
