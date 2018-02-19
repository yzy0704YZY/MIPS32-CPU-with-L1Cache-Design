/***************************************
 ********** Andy You Property **********
 ***************************************/


module EX2MEM  (clk,
		rst,
		ex_wd,
		ex_wreg,
		ex_wdata,
		hilo_en_i,
		hi_i,
		lo_i,
		mem_wd,
		mem_wreg,
		mem_wdata,
		hilo_en_o,
		hi_o,
		lo_o,
		stall,
		hilo_temp_i,
		hilo_temp_o,
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
		ex_cp0_reg_we,
		ex_cp0_reg_write_addr,
		ex_cp0_reg_data,
		mem_cp0_reg_we,
		mem_cp0_reg_write_addr,
		mem_cp0_reg_data,
		flush,
		ex_excepttype,
		ex_current_inst_addr,
		ex_is_in_delayslot,
		mem_excepttype,
		mem_current_inst_addr,
		mem_is_in_delayslot
		);


input  clk, rst, ex_wreg, stall, flush;
input  [4:0]  ex_wd;
input  [31:0] ex_wdata;
input  hilo_en_i;
input  [31:0] hi_i, lo_i;
input  [63:0] hilo_temp_i;
input  hilo_temp_req;
input  [7:0] aluop_ex;
input  [2:0] alusel_ex;
input  [31:0] mem_addr_ex;
input  [31:0] reg_store_ex;
input  ex_cp0_reg_we;
input  [4:0] ex_cp0_reg_write_addr;
input  [31:0] ex_cp0_reg_data;
input  ex_is_in_delayslot;
input  [31:0] ex_excepttype, ex_current_inst_addr;

output reg [4:0]  mem_wd;
output reg [31:0] mem_wdata;
output reg mem_wreg;
output reg hilo_en_o;
output reg [31:0] hi_o, lo_o;
output reg [63:0] hilo_temp_o;
output reg hilo_temp_ack;
output reg [7:0] aluop_mem;
output reg [2:0] alusel_mem;
output reg [31:0] mem_addr_mem;
output reg [31:0] reg_store_mem;
output reg mem_cp0_reg_we;
output reg [4:0] mem_cp0_reg_write_addr;
output reg [31:0] mem_cp0_reg_data;
output reg mem_is_in_delayslot;
output reg [31:0] mem_excepttype, mem_current_inst_addr;

always @(posedge clk) begin
    if (rst | flush) begin
	mem_wd <= 5'h0;
	mem_wreg <= 1'b0;
	mem_wdata <= 32'h0;
	hilo_en_o <= 1'b0;
	hi_o <= 32'h0;
	lo_o <= 32'h0;
	hilo_temp_o <= 64'h0;
	hilo_temp_ack <= 1'b0;
	aluop_mem <= 8'b0;
	alusel_mem <= 3'b0;
	mem_addr_mem <= 32'h0;
	reg_store_mem <= 32'h0;
	mem_cp0_reg_we <= 1'b0;
	mem_cp0_reg_write_addr <= 5'b0;
	mem_cp0_reg_data <= 32'h0;
	mem_is_in_delayslot <= 1'b0;
	mem_excepttype <= 32'h0;
	mem_current_inst_addr <= 32'h0;
    end
    else begin
	if (stall) begin
	    mem_wd <= mem_wd;
	    mem_wreg <= mem_wreg;
	    mem_wdata <= mem_wdata;
	    hilo_en_o <= hilo_en_o;
	    hi_o <= hi_o;
	    lo_o <= lo_o;
	    hilo_temp_ack <= hilo_temp_req;
	    hilo_temp_o <= hilo_temp_req ? hilo_temp_i : 64'h0;
	    aluop_mem <= aluop_mem;
	    alusel_mem <= alusel_mem;
	    mem_addr_mem <= mem_addr_mem;
	    reg_store_mem <= reg_store_mem;
	    mem_cp0_reg_we <= mem_cp0_reg_we;
	    mem_cp0_reg_write_addr <= mem_cp0_reg_write_addr;
	    mem_cp0_reg_data <= mem_cp0_reg_data;
	end
	else begin
	    mem_wd <= ex_wd;
	    mem_wreg <= ex_wreg;
	    mem_wdata <= ex_wdata;
	    hilo_en_o <= hilo_en_i;
	    hi_o <= hi_i;
	    lo_o <= lo_i;
	    hilo_temp_o <= 64'h0;
	    hilo_temp_ack <= 1'b0;
	    aluop_mem <= aluop_ex;
	    alusel_mem <= alusel_ex;
	    mem_addr_mem <= mem_addr_ex;
	    reg_store_mem <= reg_store_ex;
	    mem_cp0_reg_we <= ex_cp0_reg_we;
	    mem_cp0_reg_write_addr <= ex_cp0_reg_write_addr;
	    mem_cp0_reg_data <= ex_cp0_reg_data;
	    mem_is_in_delayslot <= ex_is_in_delayslot;
	    mem_excepttype <= ex_excepttype;
	    mem_current_inst_addr <= ex_current_inst_addr;
	end
    end
end

endmodule
