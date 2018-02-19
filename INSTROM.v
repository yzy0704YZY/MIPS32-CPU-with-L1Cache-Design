/***************************************
 ********** Andy You Property **********
 ***************************************/


//mfc0: 010000 00000 rt rd 00000000 sel
//mtc0: 010000 00100 rt rd 00000000 sel
//eret: 010000 1 0000 0000 0000 0000 000 011000
//syscall : 00000000000000000000000000 001100

module INSTROM (clk,
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
input  [3:0]  sel_i;
input  [31:0] addr_i, data_i;

output reg ack_o;
output reg [31:0] data_o;

reg    [31:0] ROM [0:1023];

wire [31:0] addr_real;

assign addr_real = (addr_i & 32'h0fff_ffff) >> 2;

initial $readmemh("./testcases/inst_rom.data", ROM);

//counter interrupt
/*
initial begin
    ROM[0] =  32'b00110100000000010000000100000000;
    ROM[1] =  32'b00000000001000000000000000001000;
    ROM[2] =  32'b00000000000000000000000000000000;
    ROM[8] =  32'b00100000010000100000000000000001;
    ROM[9] =  32'b01000000000000010101100000000000;
    ROM[10] = 32'b00100000001000010000000001100100;
    ROM[11] = 32'b01000000100000010101100000000000;
    ROM[12] = 32'b01000010000000000000000000011000;
    ROM[13] = 32'b00000000000000000000000000000000;
    ROM[64] = 32'b00110100000000100000000000000000;
    ROM[65] = 32'b00110100000000010000000001100100;
    ROM[66] = 32'b01000000100000010101100000000000;
    ROM[67] = 32'b00111100000000010001000000000000;
    ROM[68] = 32'b00110100001000010000010000000001;
    ROM[69] = 32'b01000000100000010110000000000000;
end
*/

always @(posedge clk) begin
    if (rst) begin
	data_o <= 32'h0;
	ack_o <= 1'b0;
    end
    else begin
	if (cyc_i && std_i) begin
            data_o <= ROM[addr_real];
	    ack_o <= 1'b1;
	end
	else begin
	    data_o = 32'h0;
	    ack_o <= 1'b0;
        end
    end
end

endmodule
