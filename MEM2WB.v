/***************************************
 ********** Andy You Property **********
 ***************************************/


module  MEM2WB (clk,
		rst,
		mem_wd,
		mem_wreg,
		mem_wdata,
		hilo_en_i,
		hi_i,
		lo_i,
		wb_wd,
		wb_wreg,
		wb_wdata,
		hilo_en_o,
		hi_o,
		lo_o,
		stall,
		mem_cp0_reg_we,
		mem_cp0_reg_write_addr,
		mem_cp0_reg_data,
		wb_cp0_reg_we,
		wb_cp0_reg_write_addr,
		wb_cp0_reg_data,
		flush);


input  clk, rst, mem_wreg, stall, flush;
input  [4:0] mem_wd;
input  [31:0] mem_wdata;
input  hilo_en_i;
input  [31:0] hi_i, lo_i;
input  mem_cp0_reg_we;
input  [4:0] mem_cp0_reg_write_addr;
input  [31:0] mem_cp0_reg_data;

output reg wb_wreg;
output reg [4:0] wb_wd;
output reg [31:0] wb_wdata;
output reg hilo_en_o;
output reg [31:0] hi_o, lo_o;
output reg wb_cp0_reg_we;
output reg [4:0] wb_cp0_reg_write_addr;
output reg [31:0] wb_cp0_reg_data;

always @(posedge clk) begin
    if (rst | flush) begin
	wb_wd <= 5'b0;
	wb_wreg <= 1'b0;
	wb_wdata <= 32'b0;
	hilo_en_o <= 1'b0;
	hi_o <= 32'h0;
	lo_o <= 32'h0;
	wb_cp0_reg_we <= 1'b0;
	wb_cp0_reg_write_addr <= 5'b0;
	wb_cp0_reg_data <= 32'h0;
    end
    else begin
	if (stall) begin
	    wb_wd <= wb_wd;
	    wb_wreg <= wb_wreg;
	    wb_wdata <= wb_wdata;
	    hilo_en_o <= hilo_en_o;
	    hi_o <= hi_o;
	    lo_o <= lo_o;
	end
	else begin
	    wb_wd <= mem_wd;
	    wb_wreg <= mem_wreg;
	    wb_wdata <= mem_wdata;
	    hilo_en_o <= hilo_en_i;
	    hi_o <= hi_i;
	    lo_o <= lo_i;
	    wb_cp0_reg_we <= mem_cp0_reg_we;
	    wb_cp0_reg_write_addr <= mem_cp0_reg_write_addr;
	    wb_cp0_reg_data <= mem_cp0_reg_data;
	end
    end
end

endmodule
