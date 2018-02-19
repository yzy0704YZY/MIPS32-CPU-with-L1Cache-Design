/***************************************
 ********** Andy You Property **********
 ***************************************/


module HILO (clk, rst, we, hi_i, lo_i, hi_o, lo_o);

input  clk, rst, we;
input  [31:0] hi_i, lo_i;

output reg [31:0] hi_o, lo_o;

always @(posedge clk) begin
    if (rst) begin
	hi_o <= 32'h0;
	lo_o <= 32'h0;
    end
    else begin
	if (we) begin
	    hi_o <= hi_i;
	    lo_o <= lo_i;
	end
    end
end

endmodule
