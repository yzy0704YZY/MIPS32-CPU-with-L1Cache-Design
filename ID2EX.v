/***************************************
 ********** Andy You Property **********
 ***************************************/


module  ID2EX  (clk,
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
		stall,
		next_inst_in_delayslot_i,
		is_in_delayslot_i,
		is_in_delayslot_o,
	        ex_is_in_delayslot_o,
		link_address_i,
		link_address_o,
		inst_id,
		inst_ex,
		flush,
		id_excepttype,
		id_current_inst_addr,
		ex_excepttype,
		ex_current_inst_addr
		);


input  clk, rst, id_wreg, stall, flush;
input  [2:0]  id_alusel;
input  [7:0]  id_aluop;
input  [31:0] id_reg1;
input  [31:0] id_reg2;
input  [4:0]  id_wd;
input  [31:0] link_address_i;
input	      is_in_delayslot_i;
input         next_inst_in_delayslot_i;
input  [31:0] inst_id;
input  [31:0] id_excepttype, id_current_inst_addr;

output reg [2:0]  ex_alusel;
output reg [7:0]  ex_aluop;
output reg [31:0] ex_reg1;
output reg [31:0] ex_reg2;
output reg [4:0]  ex_wd;
output reg        ex_wreg;
output reg [31:0] link_address_o;
output reg        is_in_delayslot_o;
output reg	  ex_is_in_delayslot_o;
output reg [31:0] inst_ex;
output reg [31:0] ex_excepttype, ex_current_inst_addr;

always @(posedge clk) begin
    if (rst | flush) begin
	ex_alusel <= `SEL_NONE;
	ex_aluop <= `OP_NONE;
	ex_reg1 <= 32'h0;
	ex_reg2 <= 32'h0;
	ex_wd <= 5'h0;
	ex_wreg <= 1'b0;
	link_address_o <= 32'h0;
	is_in_delayslot_o <= 1'b0;
	ex_is_in_delayslot_o <= 1'b0;
	inst_ex <= 32'h0;
	ex_excepttype <= 32'h0;
	ex_current_inst_addr <= 32'h0;
    end
    else begin
	if (stall) begin
	    ex_alusel <= ex_alusel;
	    ex_aluop <= ex_aluop;
	    ex_reg1 <= ex_reg1;
	    ex_reg2 <= ex_reg2;
	    ex_wd <= ex_wd;
	    ex_wreg <= ex_wreg;
	    link_address_o <= link_address_o;
	    is_in_delayslot_o <= is_in_delayslot_o;
	    ex_is_in_delayslot_o <= ex_is_in_delayslot_o;
	    inst_ex <= inst_ex;
	end
	else begin
	    if (next_inst_in_delayslot_i) begin
		is_in_delayslot_o <= 1'b1;
		link_address_o <= link_address_i;
	    end
	    else begin
		link_address_o <= 32'h0;
		is_in_delayslot_o <= 1'b0;
	    end
	    ex_excepttype <= id_excepttype;
	    ex_current_inst_addr <= id_current_inst_addr;
	    ex_alusel <= id_alusel;
	    ex_aluop <= id_aluop;
	    ex_reg1 <= id_reg1;
	    ex_reg2 <= id_reg2;
	    ex_wd <= id_wd;
	    ex_wreg <= id_wreg;
	    inst_ex <= inst_id;
	    ex_is_in_delayslot_o <= is_in_delayslot_i;
        end
    end
end

endmodule
