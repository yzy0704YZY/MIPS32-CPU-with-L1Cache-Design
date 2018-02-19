/***************************************
 ********** Andy You Property **********
 ***************************************/


module DATARAM (clk,
		rst,
		addr_i,
		data_i,
		we_i,
		sel_i,
		std_i,
		cyc_i,
		data_o,
		ack_o);

input  clk, rst, we_i;
input  std_i, cyc_i;
input  [3:0] sel_i;
input  [31:0] addr_i, data_i;

output reg ack_o;
output reg [31:0] data_o;

reg [31:0] RAM [0:4095];

wire [31:0] addr_real;

assign addr_real = addr_i >> 2;

always @(posedge clk) begin
    if (rst) begin
	data_o <= 32'h0;
	ack_o <= 1'b0;
    end
    else begin
	if (cyc_i && std_i) begin
	    ack_o <= 1'b1;
	    if (!we_i) begin
		data_o[7:0] <= sel_i[0] ? RAM[addr_real][7:0] : 8'b0;
		data_o[15:8] <= sel_i[1] ? RAM[addr_real][15:8] : 8'b0;
		data_o[23:16] <= sel_i[2] ? RAM[addr_real][23:16] : 8'b0;
		data_o[31:24] <= sel_i[3] ? RAM[addr_real][31:24] : 8'b0;
	    end
	    else begin
		RAM[addr_real][7:0]   <= sel_i[0] ? data_i[7:0]   : RAM[addr_real][7:0];
		RAM[addr_real][15:8]  <= sel_i[1] ? data_i[15:8]  : RAM[addr_real][15:8];
		RAM[addr_real][23:16] <= sel_i[2] ? data_i[23:16] : RAM[addr_real][23:16];
		RAM[addr_real][31:24] <= sel_i[3] ? data_i[31:24] : RAM[addr_real][31:24];
	    end
	end
	else begin
	    ack_o <= 1'b0;
	    //data_o <= 32'h0;
        end
    end
end

endmodule
