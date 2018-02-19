/***************************************
 ********** Andy You Property **********
 ***************************************/


module SOPC (clk, rst);

input  clk, rst;

wire iwishbone_ack_i, dwishbone_ack_i;
wire iwishbone_we_o, dwishbone_we_o;
wire iwishbone_stb_o, dwishbone_stb_o;
wire iwishbone_cyc_o, dwishbone_cyc_o;
wire [31:0] iwishbone_data_i, dwishbone_data_i;
wire [3:0] iwishbone_sel_o, dwishbone_sel_o;
wire [31:0] iwishbone_addr_o, dwishbone_addr_o;
wire [31:0] iwishbone_data_o, dwishbone_data_o;

wire iwish_slave_ack_i, dwish_slave_ack_i;
wire iwish_slave_we_o, dwish_slave_we_o;
wire iwish_slave_stb_o, dwish_slave_stb_o;
wire iwish_slave_cyc_o, dwish_slave_cyc_o;
wire [31:0] iwish_slave_data_i, dwish_slave_data_i;
wire [3:0] iwish_slave_sel_o, dwish_slave_sel_o;
wire [31:0] iwish_slave_addr_o, dwish_slave_addr_o;
wire [31:0] iwish_slave_data_o, dwish_slave_data_o;

wire timer_interrupt;
wire [5:0] interrupt;

assign interrupt = {5'b00000, timer_interrupt};

CPU_TOP   cpu    (clk,
		  rst,
		  interrupt,
		  timer_interrupt,
		  iwishbone_addr_o,
		  iwishbone_data_o,
		  iwishbone_we_o,
		  iwishbone_sel_o,
		  iwishbone_stb_o,
		  iwishbone_cyc_o,
		  iwishbone_data_i,
		  iwishbone_ack_i,
		  dwishbone_addr_o,
		  dwishbone_data_o,
		  dwishbone_we_o,
		  dwishbone_sel_o,
		  dwishbone_stb_o,
		  dwishbone_cyc_o,
		  dwishbone_data_i,
		  dwishbone_ack_i
	  	  );

//Already include the INSTROM controller
INSTROM inst_rom (clk,
		  rst,
		  iwish_slave_addr_o,
		  iwish_slave_data_o,
		  iwish_slave_we_o,
		  iwish_slave_sel_o,
		  iwish_slave_stb_o,
		  iwish_slave_cyc_o,
		  iwish_slave_data_i,
		  iwish_slave_ack_i
	          );

//Already include the DATARAM controller
DATARAM data_ram (clk,
		  rst,
		  dwish_slave_addr_o,
		  dwish_slave_data_o,
		  dwish_slave_we_o,
		  dwish_slave_sel_o,
		  dwish_slave_stb_o,
		  dwish_slave_cyc_o,
		  dwish_slave_data_i,
		  dwish_slave_ack_i
	          );


wb_conmax_top  wishbone_top(
	.clk_i(clk), .rst_i(rst),

	// Master 0 Interface
	.m0_data_i(dwishbone_data_o), .m0_data_o(dwishbone_data_i), .m0_addr_i(dwishbone_addr_o), 
	.m0_sel_i(dwishbone_sel_o), .m0_we_i(dwishbone_we_o), .m0_cyc_i(dwishbone_cyc_o),
	.m0_stb_i(dwishbone_stb_o), .m0_ack_o(dwishbone_ack_i),

	// Master 1 Interface
	.m1_data_i(iwishbone_data_o), .m1_data_o(iwishbone_data_i), .m1_addr_i(iwishbone_addr_o), 
	.m1_sel_i(iwishbone_sel_o), .m1_we_i(iwishbone_we_o), .m1_cyc_i(iwishbone_cyc_o),
	.m1_stb_i(iwishbone_stb_o), .m1_ack_o(iwishbone_ack_i),

	// Slave 0 Interface
	.s0_data_i(dwish_slave_data_i), .s0_data_o(dwish_slave_data_o), .s0_addr_o(dwish_slave_addr_o), 
	.s0_sel_o(dwish_slave_sel_o), .s0_we_o(dwish_slave_we_o), .s0_cyc_o(dwish_slave_cyc_o),
	.s0_stb_o(dwish_slave_stb_o), .s0_ack_i(dwish_slave_ack_i),

	// Slave 1 Interface
	.s1_data_i(iwish_slave_data_i), .s1_data_o(iwish_slave_data_o), .s1_addr_o(iwish_slave_addr_o), 
	.s1_sel_o(iwish_slave_sel_o), .s1_we_o(iwish_slave_we_o), .s1_cyc_o(iwish_slave_cyc_o),
	.s1_stb_o(iwish_slave_stb_o), .s1_ack_i(iwish_slave_ack_i)

	);

endmodule
