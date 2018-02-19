/***************************************
 ********** Andy You Property **********
 ***************************************/


module IF2ID (clk, rst, if_pc, if_inst, id_pc, id_inst, stall, flush);

input  clk, rst, stall, flush;
input  [31:0] if_pc, if_inst;

output [31:0] id_pc, id_inst;
reg    [31:0] id_pc, id_inst;

always @(posedge clk)
begin
    if (rst | flush) begin
	id_pc <= 32'h0;
	id_inst <= 32'h0;
    end
    else begin
	if (stall) begin
	    id_pc <= id_pc;
	    id_inst <= id_inst;
	end
	else begin
	    id_pc <= if_pc;
	    id_inst <= if_inst;
        end
    end
end

endmodule
