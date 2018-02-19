/***************************************
 ********** Andy You Property **********
 ***************************************/


/* Implement a store buffer to
   store data evicted from cache */

module   STOREBUFFER   (clk,
			rst,
			we_cache_to_sb_i,
			wdata_cache_to_sb_i,
			waddr_cache_to_sb_i,
			fifo_full,
			fifo_empty,
			fifo_re,
			raddr_from_fifo,
			rdata_from_fifo,
			read_ptr_i
			);

input  clk, rst;
input  we_cache_to_sb_i;
input  [31:0] wdata_cache_to_sb_i;
input  [31:0] waddr_cache_to_sb_i;
input  [5:0] read_ptr_i;

output fifo_full, fifo_empty;
output [31:0] raddr_from_fifo;
output [31:0] rdata_from_fifo;

input fifo_re;
wire  fifo_we;

reg [1:0] NEXTSTATE, STATE;

assign fifo_we = we_cache_to_sb_i;


FIFO    fifo   (clk,
                rst,
                fifo_we,
                fifo_re,
                waddr_cache_to_sb_i,
                wdata_cache_to_sb_i,
                raddr_from_fifo,
                rdata_from_fifo,
                fifo_full,
                fifo_empty,
		read_ptr_i
                );

endmodule



module  FIFO   (clk,
                rst,
                we_i,
                re_i,
                waddr_i,
                wdata_i,
                raddr_o,
                rdata_o,
                fifo_full_o,
                fifo_empty_o,
		read_ptr
                );

input  clk, rst, re_i, we_i;
input  [31:0] waddr_i;
input  [31:0] wdata_i;
input  [5:0]  read_ptr;

output reg [31:0] raddr_o;
output reg [31:0] rdata_o;

output wire fifo_full_o;
output wire fifo_empty_o;

// RAM for address and data
reg [31:0] ram_addr [0:31];
reg [31:0] ram_data [0:31];

reg [5:0] write_ptr;

assign fifo_full_o = (write_ptr[4:0] == read_ptr[4:0]) & (write_ptr[5] ^ read_ptr[5]);
assign fifo_empty_o = (write_ptr == read_ptr);

// wRITE THE sTORE bUFFER
always @(posedge clk) begin
    if (rst) begin
        write_ptr <= 5'b0;
    end
    else begin
        if (we_i) begin
            ram_addr[write_ptr[4:0]] <= waddr_i;
            ram_data[write_ptr[4:0]] <= wdata_i;
            write_ptr <= write_ptr + 1'b1;
        end
    end
end

// lOAD THE sTORE bUFFER
always @(*) begin
    if (rst) begin
	raddr_o = 32'b0;
	rdata_o = 32'b0;
    end
    else begin
        if (re_i) begin
	    raddr_o = ram_addr[read_ptr];
	    rdata_o = ram_data[read_ptr];
	end
	else begin
	    raddr_o = 32'b0;
	    rdata_o = 32'b0;
	end
    end
end

endmodule
