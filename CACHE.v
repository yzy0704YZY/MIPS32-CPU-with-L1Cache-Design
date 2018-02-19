/***************************************
 ********** Andy You Property **********
 ***************************************/


/* Implement 4KB, 4-way associative Cache,
   LRU replacement policy, write-back mode */

module  CACHE  (clk,
                rst,
                ce,
                we,
                sel_i,
                addr_i,
                data_to_store_i,
                data_to_load_o,
                we_sb_o,
                wdata_sb_o,
                waddr_sb_o,
                full_sb_i,
                cache_ack_o,
                wishbone_we_o,
                wishbone_stb_o,
                wishbone_cyc_o,
                wishbone_sel_o,
                wishbone_addr_o,
                wishbone_ack_i,
                wishbone_data_i,
                fetch_to_sb_o
                );

input  clk, rst, we, ce;
input  [3:0] sel_i; //which offsets of a word
input  [31:0] addr_i, data_to_store_i;
input  full_sb_i;
input  wishbone_ack_i;
input  [31:0] wishbone_data_i;

output [31:0] data_to_load_o;
output cache_ack_o;  //(one of) the whole cache flow finish
output fetch_to_sb_o;

output we_sb_o;  //enable write to store buffer
output [31:0] wdata_sb_o; //data to be written into store buffer
output [31:0] waddr_sb_o; //addr to be written into store buffer

output wishbone_we_o, wishbone_stb_o, wishbone_cyc_o;
output [3:0]  wishbone_sel_o;
output [31:0] wishbone_addr_o;

wire   valid0_i, valid1_i, valid2_i, valid3_i;
wire   dirty0_i, dirty1_i, dirty2_i, dirty3_i;
wire   cache_ack0_i, cache_ack1_i, cache_ack2_i, cache_ack3_i;
wire   fetch_ack0_i, fetch_ack1_i, fetch_ack2_i, fetch_ack3_i;
wire   evict_ack0_i, evict_ack1_i, evict_ack2_i, evict_ack3_i;
wire   we_sb0_i, we_sb1_i, we_sb2_i, we_sb3_i;
wire   tag_match0_i, tag_match1_i, tag_match2_i, tag_match3_i;

wire   wishbone_we0_i, wishbone_we1_i, wishbone_we2_i, wishbone_we3_i;
wire   wishbone_stb0_i, wishbone_stb1_i, wishbone_stb2_i, wishbone_stb3_i;
wire   wishbone_cyc0_i, wishbone_cyc1_i, wishbone_cyc2_i, wishbone_cyc3_i;
wire   [3:0]  wishbone_sel0_i, wishbone_sel1_i, wishbone_sel2_i, wishbone_sel3_i;
wire   [31:0] wishbone_addr0_i, wishbone_addr1_i, wishbone_addr2_i, wishbone_addr3_i;

wire   [1:0] curr_lru0_i, curr_lru1_i, curr_lru2_i, curr_lru3_i;
wire   [31:0] wdata_sb0_i, wdata_sb1_i, wdata_sb2_i, wdata_sb3_i;
wire   [31:0] waddr_sb0_i, waddr_sb1_i, waddr_sb2_i, waddr_sb3_i;
wire   [31:0] data0_to_load_i, data1_to_load_i, data2_to_load_i, data3_to_load_i;
wire   load_store_ready0_i, load_store_ready1_i, load_store_ready2_i, load_store_ready3_i;

wire   [21:0]  tag;
wire   [1:0]   word;
wire   [5:0]   index;

wire write_lru;

wire ce0, ce1, ce2, ce3;
wire we0, we1, we2, we3;

reg  evict0, evict1, evict2, evict3;
reg  fetch0, fetch1, fetch2, fetch3;
reg  [1:0] next_lru0, next_lru1, next_lru2, next_lru3;

assign wishbone_we_o = wishbone_we0_i | wishbone_we1_i | wishbone_we2_i | wishbone_we3_i;
assign wishbone_stb_o = wishbone_stb0_i | wishbone_stb1_i | wishbone_stb2_i | wishbone_stb3_i;
assign wishbone_cyc_o = wishbone_cyc0_i | wishbone_cyc1_i | wishbone_cyc2_i | wishbone_cyc3_i;

assign wishbone_sel_o = (fetch0)? wishbone_sel0_i :
                        ((fetch1)? wishbone_sel1_i :
                        ((fetch2)? wishbone_sel2_i :
                        ((fetch3)? wishbone_sel3_i :
                        4'b0)));

assign wishbone_addr_o = (fetch0)? wishbone_addr0_i :
                        ((fetch1)? wishbone_addr1_i :
                        ((fetch2)? wishbone_addr2_i :
                        ((fetch3)? wishbone_addr3_i :
                        4'b0)));

assign cache_ack_o = cache_ack0_i | cache_ack1_i | cache_ack2_i | cache_ack3_i;  

assign we_sb_o = we_sb0_i | we_sb1_i | we_sb2_i | we_sb3_i;

assign wdata_sb_o = (we_sb0_i)? wdata_sb0_i : 
                    ((we_sb1_i)? wdata_sb1_i : 
                    ((we_sb2_i)? wdata_sb2_i : 
                    ((we_sb3_i)? wdata_sb3_i : 
                    32'b0)));

assign waddr_sb_o = (we_sb0_i)? waddr_sb0_i : 
                    ((we_sb1_i)? waddr_sb1_i : 
                    ((we_sb2_i)? waddr_sb2_i : 
                    ((we_sb3_i)? waddr_sb3_i : 
                    32'b0)));

assign data_to_load_o = (cache_ack0_i)? data0_to_load_i : 
                        ((cache_ack1_i)? data1_to_load_i : 
                        ((cache_ack2_i)? data2_to_load_i : 
                        ((cache_ack3_i)? data3_to_load_i :
                        32'b0)));

assign index  = addr_i[9:4];
assign tag    = addr_i[31:10];
assign word   = addr_i[3:2];

assign ce0 = ce & (tag_match0_i | load_store_ready0_i);
assign ce1 = ce & (tag_match1_i | load_store_ready1_i);
assign ce2 = ce & (tag_match2_i | load_store_ready2_i);
assign ce3 = ce & (tag_match3_i | load_store_ready3_i);

assign we0 = we & (tag_match0_i | load_store_ready0_i);
assign we1 = we & (tag_match1_i | load_store_ready1_i);
assign we2 = we & (tag_match2_i | load_store_ready2_i);
assign we3 = we & (tag_match3_i | load_store_ready3_i);

assign write_lru = ce0 | ce1 | ce2 | ce3;

assign fetch_to_sb_o = fetch0 | fetch1 | fetch2 | fetch3;

always @(*) begin
    if (rst) begin
        fetch0 = 1'b0;
        fetch1 = 1'b0;
        fetch2 = 1'b0;
        fetch3 = 1'b0;
        evict0 = 1'b0;
        evict1 = 1'b0;
        evict2 = 1'b0;
        evict3 = 1'b0;
        next_lru0 = 2'b0;
        next_lru1 = 2'b0;
        next_lru2 = 2'b0;
        next_lru3 = 2'b0;
    end
    else if (ce) begin
        fetch0 = 1'b0;
        fetch1 = 1'b0;
        fetch2 = 1'b0;
        fetch3 = 1'b0;
        evict0 = 1'b0;
        evict1 = 1'b0;
        evict2 = 1'b0;
        evict3 = 1'b0;
        next_lru0 = 2'b00;
        next_lru1 = 2'b00;
        next_lru2 = 2'b00;
        next_lru3 = 2'b00;
        if ({tag_match0_i, tag_match1_i, tag_match2_i, tag_match3_i} == 4'b0000) begin //No match found in 4 ways
            if (!valid0_i) begin //Block 0 is available, only fetch one
                next_lru0 = 2'b00;
                next_lru1 = (valid1_i)? (curr_lru1_i + 1'b1) : curr_lru1_i;
                next_lru2 = (valid2_i)? (curr_lru2_i + 1'b1) : curr_lru2_i;
                next_lru3 = (valid3_i)? (curr_lru3_i + 1'b1) : curr_lru3_i;
                fetch0 = !fetch_ack0_i;
            end
            else if (!valid1_i) begin //Block 1 is available, only fetch one
                next_lru1 = 2'b00;
                next_lru0 = (valid0_i)? (curr_lru0_i + 1'b1) : curr_lru0_i;
                next_lru2 = (valid2_i)? (curr_lru2_i + 1'b1) : curr_lru2_i;
                next_lru3 = (valid3_i)? (curr_lru3_i + 1'b1) : curr_lru3_i;
                fetch1 = !fetch_ack1_i;
            end
            else if (!valid2_i) begin //Block 2 is available, only fetch one
                next_lru2 = 2'b00;
                next_lru0 = (valid0_i)? (curr_lru0_i + 1'b1) : curr_lru0_i;
                next_lru1 = (valid1_i)? (curr_lru1_i + 1'b1) : curr_lru1_i;
                next_lru3 = (valid3_i)? (curr_lru3_i + 1'b1) : curr_lru3_i;
                fetch2 = !fetch_ack2_i;
            end
            else if (!valid3_i) begin //Block 3 is available, only fetch one
                next_lru3 = 2'b00;
                next_lru0 = (valid0_i)? (curr_lru0_i + 1'b1) : curr_lru0_i;
                next_lru1 = (valid1_i)? (curr_lru1_i + 1'b1) : curr_lru1_i;
                next_lru2 = (valid2_i)? (curr_lru2_i + 1'b1) : curr_lru2_i;
                fetch3 = !fetch_ack3_i;
            end
            else begin //No cache block is available, need to evict one and fetch one
                if (curr_lru0_i == 2'b11) begin
                        evict0 = dirty0_i & !evict_ack0_i & !full_sb_i;
                        fetch0 = !fetch_ack0_i;
                        next_lru0 = 2'b00;
                        next_lru1 = curr_lru1_i + 1'b1;
                        next_lru2 = curr_lru2_i + 1'b1;
                        next_lru3 = curr_lru3_i + 1'b1;
                end
                else if (curr_lru1_i == 2'b11) begin
                        evict1 = dirty1_i & !evict_ack1_i & !full_sb_i;
                        fetch1 = !fetch_ack1_i;
                        next_lru1 = 2'b00;
                        next_lru0 = curr_lru0_i + 1'b1;
                        next_lru2 = curr_lru2_i + 1'b1;
                        next_lru3 = curr_lru3_i + 1'b1;
                end
                else if (curr_lru2_i == 2'b11) begin
                        evict2 = dirty2_i & !evict_ack2_i & !full_sb_i;
                        fetch2 = !fetch_ack2_i;
                        next_lru2 = 2'b00;
                        next_lru0 = curr_lru0_i + 1'b1;
                        next_lru1 = curr_lru1_i + 1'b1;
                        next_lru3 = curr_lru3_i + 1'b1;
                end
                else if (curr_lru3_i == 2'b11) begin
                        evict3 = dirty3_i & !evict_ack3_i & !full_sb_i;
                        fetch3 = !fetch_ack3_i;
                        next_lru3 = 2'b00;
                        next_lru0 = curr_lru0_i + 1'b1;
                        next_lru1 = curr_lru1_i + 1'b1;
                        next_lru2 = curr_lru2_i + 1'b1;
                end
            end
        end
        else begin  //One of the block match, only change the LRU number
            if (tag_match0_i) begin
                next_lru0 = 2'b00;
                next_lru1 = (curr_lru1_i <= curr_lru0_i & valid1_i)? (curr_lru1_i + 1'b1) : curr_lru1_i;
                next_lru2 = (curr_lru2_i <= curr_lru0_i & valid2_i)? (curr_lru2_i + 1'b1) : curr_lru2_i;
                next_lru3 = (curr_lru3_i <= curr_lru0_i & valid3_i)? (curr_lru3_i + 1'b1) : curr_lru3_i;
            end
            else if (tag_match1_i) begin
                next_lru1 = 2'b00;
                next_lru0 = (curr_lru0_i <= curr_lru1_i & valid0_i)? (curr_lru0_i + 1'b1) : curr_lru0_i;
                next_lru2 = (curr_lru2_i <= curr_lru1_i & valid2_i)? (curr_lru2_i + 1'b1) : curr_lru2_i;
                next_lru3 = (curr_lru3_i <= curr_lru1_i & valid3_i)? (curr_lru3_i + 1'b1) : curr_lru3_i;
            end
            else if (tag_match2_i) begin
                next_lru2 = 2'b00;
                next_lru0 = (curr_lru0_i <= curr_lru2_i & valid0_i)? (curr_lru0_i + 1'b1) : curr_lru0_i;
                next_lru1 = (curr_lru1_i <= curr_lru2_i & valid1_i)? (curr_lru1_i + 1'b1) : curr_lru1_i;
                next_lru3 = (curr_lru3_i <= curr_lru2_i & valid3_i)? (curr_lru3_i + 1'b1) : curr_lru3_i;
            end
            else if (tag_match3_i) begin
                next_lru3 = 2'b00;
                next_lru0 = (curr_lru0_i <= curr_lru3_i & valid0_i)? (curr_lru0_i + 1'b1) : curr_lru0_i;
                next_lru1 = (curr_lru1_i <= curr_lru3_i & valid1_i)? (curr_lru1_i + 1'b1) : curr_lru1_i;
                next_lru2 = (curr_lru2_i <= curr_lru3_i & valid2_i)? (curr_lru2_i + 1'b1) : curr_lru2_i;
            end
        end
    end
    else begin
        fetch0 = 1'b0;
        fetch1 = 1'b0;
        fetch2 = 1'b0;
        fetch3 = 1'b0;
        evict0 = 1'b0;
        evict1 = 1'b0;
        evict2 = 1'b0;
        evict3 = 1'b0;
        next_lru0 = 2'b0;
        next_lru1 = 2'b0;
        next_lru2 = 2'b0;
        next_lru3 = 2'b0;
    end
end

// Initiate 4-way
// Pass in ce, we, tag, index, fetch, evict, next_lru 
subCACHE  way0 (clk,
                rst,
                ce,
                we,
                ce0,
                we0,
                fetch0,
                evict0,
                index,
                tag,
                word,
                sel_i,
                data_to_store_i,
                next_lru0,
                cache_ack0_i,
                evict_ack0_i,
                fetch_ack0_i,
                tag_match0_i,
                valid0_i,
                dirty0_i,
                curr_lru0_i,
                data0_to_load_i,
                we_sb0_i,
                wdata_sb0_i,
                waddr_sb0_i,
                wishbone_ack_i,
                wishbone_data_i,
                wishbone_we0_i,
                wishbone_stb0_i,
                wishbone_cyc0_i,
                wishbone_sel0_i,
                wishbone_addr0_i,
                load_store_ready0_i,
                write_lru
                );

subCACHE  way1 (clk,
                rst,
                ce,
                we,
                ce1,
                we1,
                fetch1,
                evict1,
                index,
                tag,
                word,
                sel_i,
                data_to_store_i,
                next_lru1,
                cache_ack1_i,
                evict_ack1_i,
                fetch_ack1_i,
                tag_match1_i,
                valid1_i,
                dirty1_i,
                curr_lru1_i,
                data1_to_load_i,
                we_sb1_i,
                wdata_sb1_i,
                waddr_sb1_i,
                wishbone_ack_i,
                wishbone_data_i,
                wishbone_we1_i,
                wishbone_stb1_i,
                wishbone_cyc1_i,
                wishbone_sel1_i,
                wishbone_addr1_i,
                load_store_ready1_i,
                write_lru
                );

subCACHE  way2 (clk,
                rst,
                ce,
                we,
                ce2,
                we2,
                fetch2,
                evict2,
                index,
                tag,
                word,
                sel_i,
                data_to_store_i,
                next_lru2,
                cache_ack2_i,
                evict_ack2_i,
                fetch_ack2_i,
                tag_match2_i,
                valid2_i,
                dirty2_i,
                curr_lru2_i,
                data2_to_load_i,
                we_sb2_i,
                wdata_sb2_i,
                waddr_sb2_i,
                wishbone_ack_i,
                wishbone_data_i,
                wishbone_we2_i,
                wishbone_stb2_i,
                wishbone_cyc2_i,
                wishbone_sel2_i,
                wishbone_addr2_i,
                load_store_ready2_i,
                write_lru
                );

subCACHE  way3 (clk,
                rst,
                ce,
                we,
                ce3,
                we3,
                fetch3,
                evict3,
                index,
                tag,
                word,
                sel_i,
                data_to_store_i,
                next_lru3,
                cache_ack3_i,
                evict_ack3_i,
                fetch_ack3_i,
                tag_match3_i,
                valid3_i,
                dirty3_i,
                curr_lru3_i,
                data3_to_load_i,
                we_sb3_i,
                wdata_sb3_i,
                waddr_sb3_i,
                wishbone_ack_i,
                wishbone_data_i,
                wishbone_we3_i,
                wishbone_stb3_i,
                wishbone_cyc3_i,
                wishbone_sel3_i,
                wishbone_addr3_i,
                load_store_ready3_i,
                write_lru
                );

endmodule



// sub Cache, means a way

module subCACHE(clk,
                rst,
                sysce,
                syswe,
                ce,
                we,
                fetch,
                evict,
                index,
                tag,
                word,
                sel_i,
                data_to_store_i,
                next_lru_i,
                cache_ack_o,
                evict_ack_o,
                fetch_ack_o,
                tag_match_o,
                curr_valid_o,
                curr_dirty_o,
                curr_lru_o,
                data_to_load_o,
                we_sb_o,
                wdata_sb_o,
                waddr_sb_o,
                wishbone_ack_i,
                wishbone_data_i,
                wishbone_we_o,
                wishbone_stb_o,
                wishbone_cyc_o,
                wishbone_sel_o,
                wishbone_addr_o,
                load_store_ready_o,
                write_lru_i
                );

input  clk, rst, sysce, syswe, ce, we;
input  fetch, evict;
input  [31:0] data_to_store_i;
input  [21:0] tag;
input  [1:0]  word;
input  [5:0]  index;
input  [3:0]  sel_i;
input  [1:0]  next_lru_i;
input  write_lru_i;
input  wishbone_ack_i;
input  [31:0] wishbone_data_i;

output reg cache_ack_o;
output reg evict_ack_o;
output reg fetch_ack_o;

output tag_match_o;
output curr_valid_o, curr_dirty_o;
output [1:0] curr_lru_o;
output reg [31:0] data_to_load_o;
output reg load_store_ready_o;

output reg we_sb_o;
output reg [31:0] wdata_sb_o;
output reg [31:0] waddr_sb_o;

output reg wishbone_we_o;
output reg wishbone_stb_o;
output reg wishbone_cyc_o;
output reg [3:0] wishbone_sel_o;
output reg [31:0] wishbone_addr_o;


// Cache tag
/*******************************
| [25:4] | [3] |  [2]  | [1:0] |
|  tag   |  V  | Dirty |  LRU  |
*******************************/
reg [25:0] tags [0:63];

// Cache ram
reg [31:0] ram [0:255];

assign curr_valid_o = tags[index][3];
assign curr_dirty_o = tags[index][2];
assign curr_lru_o = tags[index][1:0];
assign tag_match_o = (tags[index][25:4] == tag && tags[index][3] == 1'b1)? 1'b1 : 1'b0;

// Evict a Cache line
reg [2:0] EVICT_STATE;
always @(posedge clk) begin
    if (rst) begin
        EVICT_STATE <= 3'b000;
        we_sb_o <= 1'b0;
        wdata_sb_o <= 32'b0;
        waddr_sb_o <= 32'b0;
        evict_ack_o <= 1'b0;
    end
    else begin
        if (sysce) begin
            if (evict) begin
                we_sb_o <= 1'b1;
                case (EVICT_STATE)
                    3'b000 : begin
                        wdata_sb_o <= ram[{index, 2'b00}];
                        waddr_sb_o <= {tags[index][25:4], index, 4'b0000};
                        EVICT_STATE <= 3'b001;
                    end
                    3'b001 : begin
                        wdata_sb_o <= ram[{index, 2'b01}];
                        waddr_sb_o <= {tags[index][25:4], index, 4'b0100};
                        EVICT_STATE <= 3'b010;
                    end
                    3'b010 : begin
                        wdata_sb_o <= ram[{index, 2'b10}];
                        waddr_sb_o <= {tags[index][25:4], index, 4'b1000};
                        EVICT_STATE <= 3'b011;
                    end
                    3'b011 : begin
                        wdata_sb_o <= ram[{index, 2'b11}];
                        waddr_sb_o <= {tags[index][25:4], index, 4'b1100};
                        EVICT_STATE <= 3'b100;
                        evict_ack_o <= 1'b1;
                    end
                    3'b100 : begin
                        if (ce) begin
                            EVICT_STATE <= 3'b000;
                            evict_ack_o <= 1'b0;
                        end
                    end
                endcase
            end
	    else begin
		we_sb_o <= 1'b0;
		if (ce) begin
		    EVICT_STATE <= 3'b000;
		    evict_ack_o <= 1'b0;
		end
	    end
        end
        else begin
            we_sb_o <= 1'b0;
            wdata_sb_o <= 32'b0;
            waddr_sb_o <= 32'b0;
            evict_ack_o <= 1'b0;
        end
    end
end


integer i;
reg [3:0] FETCH_STATE;

always @(posedge clk) begin

    if (rst) begin

        //BEGIN: Initiate tags when reset
        for (i=0; i<64; i=i+1) begin
            tags[i][3:0] <= 4'b0;
        end
        //END: Initiate tags when reset

        //BEGIN: Initiate fetch state        
        FETCH_STATE <= 4'b0000;
        //fetch_ack_o <= 1'b0;
        //END: Initiate fetch state

        //BEGIN: Initiate load data and cache finish state
        data_to_load_o <= 32'b0;
        cache_ack_o <= 1'b0;
        //END: Initiate load data and cache finish state
        
    end

    else begin

        if (sysce) begin

            //BEGIN: Cache Load/Store when Hit
            if (ce) begin
                cache_ack_o <= 1'b1;
                //fetch_ack_o <= 1'b0;
                FETCH_STATE <= 4'b0000;
                if (we) begin
                    ram[{index, word}][7:0]   <= (sel_i[0])? data_to_store_i[7:0] : ram[{index, word}][7:0];
                    ram[{index, word}][15:8]  <= (sel_i[1])? data_to_store_i[15:8] : ram[{index, word}][15:8];
                    ram[{index, word}][23:16] <= (sel_i[2])? data_to_store_i[23:16] : ram[{index, word}][23:16];
                    ram[{index, word}][31:24] <= (sel_i[3])? data_to_store_i[31:24] : ram[{index, word}][31:24];
                end
                else begin
                    data_to_load_o[7:0]   <= (sel_i[0])? ram[{index, word}][7:0] : 8'b0;
                    data_to_load_o[15:8]  <= (sel_i[1])? ram[{index, word}][15:8] : 8'b0;
                    data_to_load_o[23:16] <= (sel_i[2])? ram[{index, word}][23:16] : 8'b0;
                    data_to_load_o[31:24] <= (sel_i[3])? ram[{index, word}][31:24] : 8'b0;
                end
                //Update tag, valid, dirty
                tags[index][3:2] <= syswe? 2'b11 : 2'b10;
                tags[index][25:4] <= tag;
            end
            //END: Cache Load/Store when Hit
            
            //BEGIN: Update LRU
            if (write_lru_i)
                tags[index][1:0] <= next_lru_i;
            //END: Update LRU
            
            else begin

                cache_ack_o <= 1'b0; //ack is 0 if ce is 0

                //BEGIN: Fetch data from RAM to Cache
                if (fetch) begin
                    case (FETCH_STATE)
                        4'b0000 : begin
                            FETCH_STATE <= 4'b0001;
                        end
                        4'b0001 : begin
                            if (wishbone_ack_i) begin
                                FETCH_STATE <= 4'b0010;
                                ram[{index, 2'b00}] <= wishbone_data_i;
                            end
                        end
                        4'b0010 : begin
                            FETCH_STATE <= 4'b0011;
                        end
                        4'b0011 : begin
                            if (wishbone_ack_i) begin
                                FETCH_STATE <= 4'b0100;
                                ram[{index, 2'b01}] <= wishbone_data_i;
                            end
                        end
                        4'b0100 : begin
                            FETCH_STATE <= 4'b0101;
                        end
                        4'b0101 : begin
                            if (wishbone_ack_i) begin
                                FETCH_STATE <= 4'b0110;
                                ram[{index, 2'b10}] <= wishbone_data_i;
                            end
                        end
                        4'b0110 : begin
                            FETCH_STATE <= 4'b0111;
                        end
                        4'b0111 : begin
                            if (wishbone_ack_i) begin
                                FETCH_STATE <= 4'b1000;
                                //fetch_ack_o <= 1'b1;
                                //tags[index][3:2] <= syswe? 2'b11 : 2'b10;
                                //tags[index][25:4] <= tag;
                                ram[{index, 2'b11}] <= wishbone_data_i;
                            end
                        end
                    endcase
                end
                //END: Fetch data from RAM to Cache

            end
        end

        //When sysce goes down, ack goes down
        else begin
            cache_ack_o <= 1'b0;
        end

    end
end

always @(*) begin
    if (rst) begin
        wishbone_we_o = 1'b0;
        wishbone_stb_o = 1'b0;
        wishbone_cyc_o = 1'b0;
        wishbone_addr_o = 32'b0;
        wishbone_sel_o = 4'b0;
        fetch_ack_o = 1'b0;
        load_store_ready_o = 1'b0;
    end
    else begin
        wishbone_we_o = 1'b0;
        wishbone_stb_o = 1'b0;
        wishbone_cyc_o = 1'b0;
        wishbone_addr_o = 32'b0;
        wishbone_sel_o = 4'b0;
        fetch_ack_o = 1'b0;
        load_store_ready_o = 1'b0;
        case (FETCH_STATE)
            4'b0000 : begin
                if (fetch) begin
                    wishbone_stb_o = 1'b1;
                    wishbone_cyc_o = 1'b1;
                    wishbone_addr_o = {tag, index, 2'b00, 2'b00};
                    wishbone_sel_o = 4'b1111;
                end
            end
            4'b0001 : begin
                if (wishbone_ack_i) begin
                    wishbone_stb_o = 1'b0;
                    wishbone_cyc_o = 1'b0;
                end
                else begin
                    wishbone_stb_o = 1'b1;
                    wishbone_cyc_o = 1'b1;
		    wishbone_sel_o = 4'b1111;
		    wishbone_addr_o = {tag, index, 2'b00, 2'b00};
                end
            end
            4'b0010 : begin
                if (fetch) begin
                    wishbone_stb_o = 1'b1;
                    wishbone_cyc_o = 1'b1;
                    wishbone_addr_o = {tag, index, 2'b01, 2'b00};
                    wishbone_sel_o = 4'b1111;
                end
            end
            4'b0011 : begin
                if (wishbone_ack_i) begin
                    wishbone_stb_o = 1'b0;
                    wishbone_cyc_o = 1'b0;
                end
                else begin
                    wishbone_stb_o = 1'b1;
                    wishbone_cyc_o = 1'b1;
		    wishbone_sel_o = 4'b1111;
		    wishbone_addr_o = {tag, index, 2'b01, 2'b00};
                end
            end
            4'b0100 : begin
                if (fetch) begin
                    wishbone_stb_o = 1'b1;
                    wishbone_cyc_o = 1'b1;
                    wishbone_addr_o = {tag, index, 2'b10, 2'b00};
                    wishbone_sel_o = 4'b1111;
                end
            end
            4'b0101 : begin
                if (wishbone_ack_i) begin
                    wishbone_stb_o = 1'b0;
                    wishbone_cyc_o = 1'b0;
                end
                else begin
                    wishbone_stb_o = 1'b1;
                    wishbone_cyc_o = 1'b1;
		    wishbone_sel_o = 4'b1111;
		    wishbone_addr_o = {tag, index, 2'b10, 2'b00};
                end
            end
            4'b0110 : begin
                if (fetch) begin
                    wishbone_stb_o = 1'b1;
                    wishbone_cyc_o = 1'b1;
                    wishbone_addr_o = {tag, index, 2'b11, 2'b00};
                    wishbone_sel_o = 4'b1111;
                end
            end
            4'b0111 : begin
                if (wishbone_ack_i) begin
                    wishbone_stb_o = 1'b0;
                    wishbone_cyc_o = 1'b0;
                end
                else begin
                    wishbone_stb_o = 1'b1;
                    wishbone_cyc_o = 1'b1;
		    wishbone_sel_o = 4'b1111;
		    wishbone_addr_o = {tag, index, 2'b11, 2'b00};
                end
            end
            4'b1000 : begin
                wishbone_stb_o = 1'b0;
                wishbone_cyc_o = 1'b0;
                fetch_ack_o = 1'b1;
                load_store_ready_o = 1'b1;
            end
        endcase
    end
end

endmodule
