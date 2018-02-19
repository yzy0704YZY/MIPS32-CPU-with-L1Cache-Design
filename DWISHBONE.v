/***************************************
 ********** Andy You Property **********
 ***************************************/


module DWISHBONE (clk,
		  rst,
		  sysce_i,
		  syswe_i,
		  sel_i,
		  addr_i,
		  data_to_store_i,
		  data_to_load_o,
		  cache_ack_o,
		  wishbone_from_mem_ack_i,
		  wishbone_from_mem_data_i,
		  wishbone_to_mem_we_o,
		  wishbone_to_mem_stb_o,
		  wishbone_to_mem_cyc_o,
		  wishbone_to_mem_sel_o,
		  wishbone_to_mem_addr_o,
		  wishbone_to_mem_data_o,
		  fifo_empty,
		  fifo_re,
		  wishbone_from_cache_we,
		  wishbone_from_cache_stb,
		  wishbone_from_cache_cyc,
		  wishbone_from_cache_sel,
		  wishbone_from_cache_addr,
		  wishbone_ack_to_cache_o,
		  fetch_from_cache,
		  read_ptr,
		  raddr_from_fifo,
		  rdata_from_fifo
		  );


input  clk, rst, sysce_i, syswe_i;
input  [3:0]  sel_i;
input  [31:0] addr_i, data_to_store_i;
input  wishbone_from_mem_ack_i;
input  [31:0] wishbone_from_mem_data_i;
input  fifo_empty;
input  wishbone_from_cache_we;
input  wishbone_from_cache_stb;
input  wishbone_from_cache_cyc;
input  [3:0]  wishbone_from_cache_sel;
input  [31:0] wishbone_from_cache_addr;
input  fetch_from_cache;
input  [31:0] raddr_from_fifo, rdata_from_fifo;

output cache_ack_o;
output reg fifo_re;
output [31:0] data_to_load_o;
output reg wishbone_to_mem_we_o;
output reg wishbone_to_mem_stb_o;
output reg wishbone_to_mem_cyc_o;
output reg [3:0]  wishbone_to_mem_sel_o;
output reg [31:0] wishbone_to_mem_addr_o;
output reg [31:0] wishbone_to_mem_data_o;
output reg wishbone_ack_to_cache_o;
output reg [5:0] read_ptr;


// Controller, choose either "fetch data from mem to cache", or "push data from store buffer to mem"
reg [1:0] NEXTSTATE, STATE;

always @(*) begin
    if (rst) begin
        wishbone_to_mem_we_o = 1'b0;
        wishbone_to_mem_stb_o = 1'b0;
        wishbone_to_mem_cyc_o = 1'b0;
        wishbone_to_mem_sel_o = 4'b0;
        wishbone_to_mem_addr_o = 32'b0;
	wishbone_ack_to_cache_o = 1'b0;
        NEXTSTATE = 2'b00;
    end
    else begin
	wishbone_to_mem_we_o = 1'b0;
        wishbone_to_mem_stb_o = 1'b0;
        wishbone_to_mem_cyc_o = 1'b0;
        wishbone_to_mem_sel_o = 4'b0;
        wishbone_to_mem_addr_o = 32'b0;
	wishbone_ack_to_cache_o = 1'b0;
        NEXTSTATE = 2'b00;
        case (STATE) 
            2'b00 : begin
                if (!fifo_empty) begin
                    fifo_re = 1'b1;
                    wishbone_to_mem_we_o = 1'b1;
                    wishbone_to_mem_stb_o = 1'b1;
                    wishbone_to_mem_cyc_o = 1'b1;
                    wishbone_to_mem_sel_o = 4'b1111;
                    wishbone_to_mem_addr_o = raddr_from_fifo;
                    wishbone_to_mem_data_o = rdata_from_fifo;
                    NEXTSTATE = 2'b01;
                end
                else if (fetch_from_cache) begin
                    wishbone_to_mem_we_o = wishbone_from_cache_we;
                    wishbone_to_mem_stb_o = wishbone_from_cache_stb;
                    wishbone_to_mem_cyc_o = wishbone_from_cache_cyc;
                    wishbone_to_mem_sel_o = wishbone_from_cache_sel;
                    wishbone_to_mem_addr_o = wishbone_from_cache_addr;
                    wishbone_to_mem_data_o = 32'b0;
                    NEXTSTATE = 2'b10;
                end
            end
	    2'b01 : begin
		if (wishbone_from_mem_ack_i) begin
		    fifo_re = 1'b0;
                    NEXTSTATE = 2'b00;
		end
		else begin
		    fifo_re = 1'b1;
		    wishbone_to_mem_we_o = 1'b1;
                    wishbone_to_mem_stb_o = 1'b1;
                    wishbone_to_mem_cyc_o = 1'b1;
                    wishbone_to_mem_sel_o = 4'b1111;
		    wishbone_to_mem_addr_o = raddr_from_fifo;
                    wishbone_to_mem_data_o = rdata_from_fifo;
                    NEXTSTATE = 2'b01;
		end
	    end
	    2'b10 : begin
		wishbone_to_mem_we_o = wishbone_from_cache_we;
                wishbone_to_mem_stb_o = wishbone_from_cache_stb;
                wishbone_to_mem_cyc_o = wishbone_from_cache_cyc;
                wishbone_to_mem_sel_o = wishbone_from_cache_sel;
                wishbone_to_mem_addr_o = wishbone_from_cache_addr;
                wishbone_to_mem_data_o = 32'b0;
		wishbone_ack_to_cache_o = wishbone_from_mem_ack_i;
		if (!fetch_from_cache) begin
		    NEXTSTATE = 2'b00;
		end
		else begin
		    NEXTSTATE = 2'b10;
		end
	    end
        endcase
    end
end

// Get next STATE
always @(posedge clk) begin
    if (rst) begin
	STATE <= 2'b0;
	read_ptr <= 6'b0;
    end
    else begin
	STATE <= NEXTSTATE;
	if (STATE == 2'b01 && wishbone_from_mem_ack_i)
	    read_ptr <= read_ptr + 1'b1;
    end
end


endmodule
