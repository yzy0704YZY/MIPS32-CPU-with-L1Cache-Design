/***************************************
 ********** Andy You Property **********
 ***************************************/


module CTRL (clk, rst, req_id, req_ex, stall, epc_i, excepttype_i, new_pc, flush, req_pc, req_mem);

input  clk, rst, req_id, req_ex, req_pc, req_mem;
input  [31:0] epc_i, excepttype_i;
output reg [5:0] stall;
output reg flush;
output reg [31:0] new_pc;


always @(*) begin
    if (rst) begin
        stall = 6'b000000;
        flush = 1'b0;
        new_pc = 32'h1000_0000;
    end
    else begin
	flush = 1'b0;
	new_pc = 32'h1000_0000;
	stall = 6'b000000;
        if (excepttype_i != 32'h0) begin
            case (excepttype_i)
  	        32'h1 : begin
		    new_pc = 32'h1000_0020;
		    flush = 1'b1;
	        end
		32'h8, 32'ha, 32'hd, 32'hc : begin
		    new_pc = 32'h1000_0040;
		    flush = 1'b1;
		end
		32'he : begin
		    new_pc = epc_i;
		    flush = 1'b1;
		end
	    endcase
        end
	else if (req_mem)
	    stall = 6'b111111;
        else if (req_ex)
            stall = 6'b001111;
        else if (req_id)
            stall = 6'b000111;
        else if (req_pc)
	    stall = 6'b000111;
    end
end

endmodule
