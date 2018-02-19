/***************************************
 ********** Andy You Property **********
 ***************************************/


module PC (clk, rst, pc, ce, stall, branch_flag_i, branch_target_address_i, flush, new_pc);

input  clk, rst, stall, flush;
input  branch_flag_i;
input  [31:0] branch_target_address_i;
input  [31:0] new_pc;

output ce;
output [31:0] pc;

reg ce;
reg [31:0] pc;

always @(posedge clk) begin
    if (rst)
	ce <= 0;
    else
	ce <= 1'b1;
end

always @(posedge clk) begin
    if (rst)
	pc <= 32'h1000_0000;
    else begin
	if (flush)
	    pc <= new_pc;
	else if (stall)
            pc <= pc;
        else if (ce) begin
	    if (branch_flag_i)
		pc <= (branch_target_address_i);
	    else
	        pc <= pc + 32'h4;
        end
	else
	    pc <= pc;
    end
end

endmodule
