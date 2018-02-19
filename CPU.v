/***************************************
 ********** Andy You Property **********
 ***************************************/


`include "./include/defines.v"

module CPU_TOP (clk,
		rst,
		interrupt_i,
		timer_interrupt_o,
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

input  clk, rst;
input  [5:0] interrupt_i;
input  iwishbone_ack_i, dwishbone_ack_i;
input  [31:0] iwishbone_data_i, dwishbone_data_i;

output timer_interrupt_o;
output iwishbone_we_o, dwishbone_we_o;
output iwishbone_stb_o, dwishbone_stb_o;
output iwishbone_cyc_o, dwishbone_cyc_o;
output [3:0] iwishbone_sel_o, dwishbone_sel_o;
output [31:0] iwishbone_addr_o, dwishbone_addr_o,
	      iwishbone_data_o, dwishbone_data_o;

wire [31:0] pc_counter;
wire [31:0] inst;
wire [31:0] data_i_ram, data_o_ram;

wire [31:0] id_pc;
wire [31:0] id_inst;
wire [31:0] id_read_data1, id_read_data2;
wire [4:0]  id_read_addr1, id_read_addr2;
wire        id_re1, id_re2;
wire [7:0]  id_aluop;
wire [2:0]  id_alusel;
wire [31:0] id_reg1, id_reg2;
wire [4:0]  id_wd;
wire        id_wreg;
wire [4:0]  waddr;
wire [31:0] wdata;
wire        we;
wire [2:0]  ex_alusel;
wire [7:0]  ex_aluop;
wire [31:0] ex_reg1, ex_reg2;
wire [4:0]  ex_wd;
wire        ex_wreg;
wire [4:0]  ex_wd_o;
wire        ex_wreg_o;
wire [31:0] ex_wdata;
wire [4:0]  mem_wd;
wire        mem_wreg;
wire [31:0] mem_wdata;
wire [4:0]  mem_wd_o;
wire        mem_wreg_o;
wire [31:0] mem_wdata_o;
wire        hilo_en, hilo_ex_en;
wire        hilo_mem_en, hilo_mem_en_o;
wire [31:0] hi_mem, hi_mem_o;
wire [31:0] lo_mem, lo_mem_o;
wire [3:0]  mem_sel;
wire        ce_ram, we_ram;
wire [31:0] hi_i, lo_i, hi_o, lo_o;
wire [31:0] hi_ex, lo_ex;
wire        req_id, req_ex, req_pc, req_mem;
wire [5:0]  stall;
wire [63:0] hilo_temp_i, hilo_temp_o;
wire        hilo_temp_req, hilo_temp_ack;
wire	    if_signed, start_div, start_mul, finish_div, finish_mul;
wire [31:0] quotient, remainder;
wire	    branch_flag;
wire [31:0] branch_target_address;
wire        is_in_delayslot_i;
wire	    is_in_delayslot_o;
wire [31:0] link_address_id;
wire [31:0] link_address_ex;
wire        next_inst_in_delayslot;
wire	    ex_is_in_delayslot;
wire [31:0] inst_id, inst_ex;
wire [2:0]  alusel_ex, alusel_mem;
wire [7:0]  aluop_ex, aluop_mem;
wire [31:0] mem_addr_ex, mem_addr_mem;
wire [31:0] reg_store_ex, reg_store_mem;
wire [31:0] cp0_data_o;
wire [4:0]  cp0_raddr_i;
wire        cp0_ex_we, cp0_mem_we, cp0_mem_we_o, cp0_wb_we;
wire [4:0]  cp0_ex_waddr, cp0_mem_waddr, cp0_mem_waddr_o, cp0_wb_waddr;
wire [31:0] cp0_ex_data, cp0_mem_data, cp0_mem_data_o, cp0_wb_data;
wire        cp0_we_i;
wire [4:0]  cp0_waddr_i;
wire [31:0] cp0_wdata_i;
wire [31:0] cp0_count_o, cp0_compare_o, cp0_status_o, cp0_cause_o,
	    cp0_epc_o, cp0_config_o, cp0_prid_o;
wire        flush, ex_is_in_delayslot_o, mem_is_in_delayslot;
wire [31:0] new_pc, new_epc;
wire [31:0] id_excepttype, id_current_inst_addr,
	    ex_excepttype, ex_current_inst_addr,
	    ex_excepttype_o, ex_current_inst_addr_o,
	    mem_excepttype, mem_current_inst_addr,
	    mem_excepttype_o, mem_current_inst_addr_o;
wire [31:0] mul_a, mul_b;
wire [63:0] mul_result;
wire        mul_sign_diff;
wire        we_cache_to_sb;
wire [31:0] wdata_cache_to_sb, waddr_cache_to_sb;
wire        fifo_full, fifo_empty, fifo_re;
wire        fetch_from_cache;
wire [5:0]  read_ptr;
wire [31:0] raddr_from_fifo, rdata_from_fifo;
wire        wishbone_from_cache_we;
wire        wishbone_from_cache_stb;
wire        wishbone_from_cache_cyc;
wire [3:0]  wishbone_from_cache_sel;
wire [31:0] wishbone_from_cache_addr;
wire        wishbone_ack_to_cache_o;

assign cp0_we_i = cp0_wb_we;
assign cp0_waddr_i = cp0_wb_waddr;
assign cp0_wdata_i = cp0_wb_data;

//Initiate PC
PC pc  (clk,
	rst,
	pc_counter,
	pc_ce,
	stall[0],
	branch_flag,
	branch_target_address,
	flush,
	new_pc
        );

//Initiate IF2ID
IF2ID   if2id  (clk,
		rst,
		pc_counter,
		inst,
		id_pc,
		id_inst,
		stall[1],
		flush
	        );

//Initiate ID
ID id  (rst,
	id_pc,
	id_inst,
	id_read_data1,
	id_read_data2,
	id_re1,
	id_re2,
        id_read_addr1,
	id_read_addr2,
	id_aluop,
	id_alusel,
        id_reg1,
	id_reg2,
	id_wd,
	id_wreg,
	req_id,
	branch_flag,
        branch_target_address,
	is_in_delayslot_i,
	is_in_delayslot_o,
        link_address_id,
	next_inst_in_delayslot,
	inst_id,
	ex_wreg,
        ex_wd,
	ex_alusel,
	mem_wreg,
	mem_wd,
	mem_wdata_o,
	id_excepttype,
	id_current_inst_addr
        );

//Initiate REGFILE
REGFILE regfile(clk,
		rst,
		waddr,
		wdata,
		we,
		id_read_addr1,
		id_re1,
		id_read_data1,
		id_read_addr2,
		id_re2,
		id_read_data2,
	 	ex_wd_o,
		ex_wreg_o,
		ex_wdata,
		mem_wd_o,
		mem_wreg_o,
		mem_wdata_o,
		stall[5]
		);

//Initiate ID2EX
ID2EX  id2ex   (clk,
		rst,
		id_alusel,
		id_aluop,
		id_reg1,
		id_reg2,
		id_wd,
		id_wreg,
	        ex_alusel,
		ex_aluop,
		ex_reg1,
		ex_reg2,
		ex_wd,
		ex_wreg,
		stall[2],
       	        next_inst_in_delayslot,
		is_in_delayslot_o,
		is_in_delayslot_i,
	        ex_is_in_delayslot,
		link_address_id,
		link_address_ex,
     	        inst_id,
		inst_ex,
		flush,
		id_excepttype,
		id_current_inst_addr,
     	        ex_excepttype,
		ex_current_inst_addr
		);

//Initiate EX
EX ex  (rst,
	ex_alusel,
	ex_aluop,
	ex_reg1,
	ex_reg2,
	ex_wd,
	ex_wreg,
        ex_wd_o,
	ex_wreg_o,
	ex_wdata,
	hilo_mem_en,
	hilo_en,
	hi_mem,
	lo_mem,
        hi_i,
	lo_i,
	hi_o,
	lo_o,
	hilo_ex_en,
	hi_ex,
	lo_ex,
	req_ex,
        hilo_temp_i,
	hilo_temp_o,
	hilo_temp_req,
	hilo_temp_ack,
        if_signed,
	start_div,
	start_mul,
	finish_div,
	finish_mul,
        quotient,
	remainder,
	link_address_ex,
	ex_is_in_delayslot,
	inst_ex,
        aluop_ex,
	alusel_ex,
	mem_addr_ex,
	reg_store_ex,
	cp0_data_o,
	cp0_raddr_i,
        cp0_ex_we,
	cp0_ex_waddr,
	cp0_ex_data,
	cp0_mem_we,
        cp0_mem_waddr,
	cp0_mem_data,
	cp0_wb_we,
	cp0_wb_waddr,
        cp0_wb_data,
	ex_excepttype,
	ex_current_inst_addr,
        ex_excepttype_o,
	ex_current_inst_addr_o,
	ex_is_in_delayslot_o,
        mul_a,
	mul_b,
	mul_sign_diff,
	mul_result
        );

//Initiate EX2MEM
EX2MEM ex2mem  (clk,
		rst,
		ex_wd_o,
		ex_wreg_o,
		ex_wdata,
		hilo_ex_en,
		hi_ex,
		lo_ex,
	        mem_wd,
		mem_wreg,
		mem_wdata,
		hilo_mem_en,
		hi_mem,
		lo_mem,
		stall[3],
       	        hilo_temp_o,
		hilo_temp_i,
		hilo_temp_req,
		hilo_temp_ack,
       	        aluop_ex,
		aluop_mem,
		alusel_ex,
		alusel_mem,
		mem_addr_ex,
		mem_addr_mem,
       	        reg_store_ex,
		reg_store_mem,
		cp0_ex_we,
		cp0_ex_waddr,
       	        cp0_ex_data,
		cp0_mem_we,
		cp0_mem_waddr,
		cp0_mem_data,
       	        flush,
		ex_excepttype_o,
		ex_current_inst_addr_o,
		ex_is_in_delayslot_o,
       	        mem_excepttype,
		mem_current_inst_addr,
		mem_is_in_delayslot
		);

//Initiate MEM
MEM mem(rst,
	mem_wd,
	mem_wreg,
	mem_wdata,
	hilo_mem_en,
	hi_mem,
	lo_mem,
	mem_wd_o,
	mem_wreg_o,
	mem_wdata_o,
	hilo_mem_en_o,
	hi_mem_o,
	lo_mem_o,
 	aluop_mem,
	alusel_mem,
	mem_addr_mem,
	reg_store_mem,
	ce_ram,
	we_ram,
	data_i_ram,
	data_o_ram,
	cp0_mem_we,
	cp0_mem_waddr,
	cp0_mem_data,
        cp0_mem_we_o,
	cp0_mem_waddr_o,
	cp0_mem_data_o,
	mem_excepttype,
	ex_current_inst_addr_o,
	mem_current_inst_addr,
	mem_is_in_delayslot,
	cp0_status_o,
        cp0_cause_o,
	cp0_epc_o,
	cp0_wb_we,
	cp0_wb_waddr,
	cp0_wb_data,
 	mem_excepttype_o,
	mem_current_inst_addr_o,
	mem_is_in_delayslot_o,
	new_epc,
	mem_sel,
	cache_ack,
	req_mem
	);

//Initiate MEM2WB
MEM2WB mem2wb  (clk,
		rst,
		mem_wd_o,
		mem_wreg_o,
		mem_wdata_o,
		hilo_mem_en_o,
	        hi_mem_o,
		lo_mem_o,
		waddr,
		we,
		wdata,
		hilo_en,
		hi_i,
		lo_i,
		stall[4],
       	        cp0_mem_we_o,
		cp0_mem_waddr_o,
		cp0_mem_data_o,
		cp0_wb_we,
	        cp0_wb_waddr,
		cp0_wb_data,
		flush
	        );

HILO hilo (clk,
	   rst,
	   hilo_en,
	   hi_i,
	   lo_i,
	   hi_o,
	   lo_o
           );

CTRL ctrl (clk,
	   rst,
	   req_id,
	   req_ex,
	   stall,
	   new_epc,
	   mem_excepttype_o,
	   new_pc,
	   flush,
   	   req_pc,
   	   req_mem
           );

DIV div (clk,
	 rst,
	 if_signed,
	 ex_reg1,
	 ex_reg2,
	 start_div,
	 quotient,
	 remainder,
	 finish_div
         );

MUL mul (clk,
	 rst,
	 start_mul,
	 finish_mul,
	 mul_a,
	 mul_b,
	 mul_sign_diff,
	 mul_result
         );

CP0 cp0 (clk,
	 rst,
	 cp0_raddr_i,
	 interrupt_i,
	 cp0_we_i,
	 cp0_waddr_i,
	 cp0_wdata_i,
	 cp0_data_o,
	 cp0_count_o,
	 cp0_compare_o,
	 cp0_status_o,
	 cp0_cause_o,
	 cp0_epc_o,
	 cp0_config_o,
	 cp0_prid_o,
	 timer_interrupt_o,
	 mem_excepttype_o,
	 mem_current_inst_addr_o,
	 mem_is_in_delayslot_o
 	 );


CACHE      cache         (clk,
                          rst,
                          ce_ram,
                          we_ram,
                          mem_sel,
                          mem_addr_mem,
                          data_o_ram,
                          data_i_ram,
                          we_cache_to_sb,
			  wdata_cache_to_sb,
			  waddr_cache_to_sb,
                          fifo_full,
                          cache_ack,
			  wishbone_from_cache_we,
			  wishbone_from_cache_stb,
			  wishbone_from_cache_cyc,
			  wishbone_from_cache_sel,
			  wishbone_from_cache_addr,
			  wishbone_ack_to_cache_o,
			  dwishbone_data_i,
		          fetch_from_cache
                          );

STOREBUFFER  storebuffer (clk,
			  rst,
			  we_cache_to_sb,
			  wdata_cache_to_sb,
			  waddr_cache_to_sb,
			  fifo_full,
			  fifo_empty,
			  fifo_re,
			  raddr_from_fifo,
			  rdata_from_fifo,
			  read_ptr
			  );

IWISHBONE wishbone_flash (clk,
			  rst, 
			  stall, 
			  flush, 
			  pc_ce, 
			  32'h0, 
			  pc_counter,
			  1'b0,
			  4'hf,
			  inst,
			  iwishbone_addr_o,
			  iwishbone_data_o,
			  iwishbone_we_o,
			  iwishbone_sel_o,
			  iwishbone_stb_o,
			  iwishbone_cyc_o,
			  iwishbone_data_i,
			  iwishbone_ack_i,
			  req_pc
			  );

DWISHBONE  wishbone_mem  (clk,
			  rst,
			  ce_ram,
		          we_ram,
		          mem_sel,
		          mem_addr_mem,
		          data_o_ram,
		          data_i_ram,
		          cache_ack,
			  dwishbone_ack_i,
		          dwishbone_data_i,
			  dwishbone_we_o,
			  dwishbone_stb_o,
			  dwishbone_cyc_o,
			  dwishbone_sel_o,
			  dwishbone_addr_o,
			  dwishbone_data_o,
			  fifo_empty,
			  fifo_re,
			  wishbone_from_cache_we,
			  wishbone_from_cache_stb,
			  wishbone_from_cache_cyc,
			  wishbone_from_cache_sel,
			  wishbone_from_cache_addr,
			  wishbone_ack_to_cache_o,
			  fetch_from_cache,
			  read_ptr,
			  raddr_from_fifo,
			  rdata_from_fifo
		          );

endmodule

