/***************************************
 ********** Andy You Property **********
 ***************************************/


module REGFILE (clk,
		rst,
		waddr,
		wdata,
		we,
		raddr1,
		re1,
		rdata1,
		raddr2,
		re2,
		rdata2,
		ex_waddr,
		ex_wreg,
		ex_wdata,
		mem_waddr,
		mem_wreg,
		mem_wdata,
		stall);

input  clk, rst, we, re1, re2, stall;
input  [4:0] waddr, raddr1, raddr2;
input  [31:0] wdata;

input  ex_wreg, mem_wreg;
input  [4:0]  ex_waddr, mem_waddr;
input  [31:0] ex_wdata, mem_wdata;

output [31:0] rdata1, rdata2;
reg    [31:0] rdata1, rdata2;

reg [31:0] registers [0:31];

always @(posedge clk)
begin
    if (!stall && !rst && we && waddr != 5'h0) begin
	registers[waddr] <= wdata;
    end	
end

always @(*)
begin
    if (rst)
	rdata1 = 32'h0;
    else if (re1)
    begin
	if (raddr1 == 5'h0)
	    rdata1 = 32'h0;
	else if (raddr1 == ex_waddr && ex_wreg)
	    rdata1 = ex_wdata;
        else if (raddr1 == mem_waddr && mem_wreg)
	    rdata1 = mem_wdata;
        else if (raddr1 == waddr && we)
	    rdata1 = wdata;
        else
	    rdata1 = registers[raddr1];
    end
    else
	rdata1 = 32'h0;
end

always @(*)
begin
    if (rst)
	rdata2 = 32'h0;
    else if (re2)
    begin
	if (raddr2 == 5'h0)
	    rdata2 = 32'h0;
        else if (raddr2 == ex_waddr && ex_wreg)
	    rdata2 = ex_wdata;
        else if (raddr2 == mem_waddr && mem_wreg)
	    rdata2 = mem_wdata;
        else if (raddr2 == waddr && we)
	    rdata2 = wdata;
        else
	    rdata2 = registers[raddr2];
    end
    else
	rdata2 = 32'h0;
end

endmodule
