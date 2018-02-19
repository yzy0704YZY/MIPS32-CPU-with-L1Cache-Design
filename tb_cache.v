module tb;

reg         clk, rst, sysce_i, syswe_i;
reg  [3:0]  sel_i;
reg  [31:0] addr_i;
reg  [31:0] data_to_store_i;

wire        cache_ack_o;
wire        wishbone_from_mem_ack_i;
wire [31:0] wishbone_from_mem_data_i;
wire        wishbone_to_mem_we_o;
wire        wishbone_to_mem_stb_o;
wire        wishbone_to_mem_cyc_o;
wire [3:0]  wishbone_to_mem_sel_o;
wire [31:0] wishbone_to_mem_addr_o;
wire [31:0] wishbone_to_mem_data_o;
wire [31:0] data_to_load_o;
wire [31:0] dwish_slave_addr_o;
wire [31:0] dwish_slave_data_o;
wire        dwish_slave_we_o;
wire        dwish_slave_stb_o;
wire        dwish_slave_cyc_o;
wire [3:0]  dwish_slave_sel_o;
wire        dwish_slave_ack_i;
wire [31:0] dwish_slave_data_i;


always #1 clk = ~clk;

initial begin
    clk = 0;
    rst = 1;
    sysce_i = 1'b0;
    syswe_i = 1'b0;
    sel_i = 4'b0;
    addr_i = 32'b0;
    #196
    rst = 0;
    test_begin;
    #500
    $finish;
end


task test_begin;
begin
    @(posedge clk);
    sysce_i <= 1'b1;
    syswe_i <= 1'b1;
    sel_i <= 4'b1111;
    addr_i <= 32'h0000_0008;
    data_to_store_i <= 32'h6868_6868;
    @(cache_ack_o);
    sysce_i <= 1'b0;
    syswe_i <= 1'b0;

    repeat (2) @(posedge clk);
    sysce_i <= 1'b1;
    syswe_i <= 1'b1;
    sel_i <= 4'b1111;
    addr_i <= 32'h0000_0004;
    data_to_store_i <= 32'h3434_3434;
    @(cache_ack_o);
    sysce_i = 1'b0;
    syswe_i = 1'b0;

    repeat (2) @(posedge clk);
    sysce_i <= 1'b1;
    syswe_i <= 1'b1;
    sel_i <= 4'b1111;
    addr_i <= 32'h0000_000c;
    data_to_store_i <= 32'habab_abab;
    @(cache_ack_o);
    sysce_i = 1'b0;
    syswe_i = 1'b0;

    repeat (2) @(posedge clk);
    sysce_i <= 1'b1;
    syswe_i <= 1'b1;
    sel_i <= 4'b1111;
    addr_i <= 32'h0000_0000;
    data_to_store_i <= 32'hffff_ffff;
    @(cache_ack_o)
    sysce_i = 1'b0;
    syswe_i = 1'b0;

    // way1
    repeat (2) @(posedge clk);
    sysce_i <= 1'b1;
    syswe_i <= 1'b1;
    sel_i <= 4'b1111;
    addr_i <= 32'h0000_0400;
    data_to_store_i <= 32'h2222_2222;
    @(cache_ack_o)
    sysce_i = 1'b0;
    syswe_i = 1'b0;

    // way2
    repeat (2) @(posedge clk);
    sysce_i <= 1'b1;
    syswe_i <= 1'b1;
    sel_i <= 4'b1111;
    addr_i <= 32'h0000_0800;
    data_to_store_i <= 32'h3333_3333;
    @(cache_ack_o)
    sysce_i = 1'b0;
    syswe_i = 1'b0;

    // way3
    repeat (2) @(posedge clk);
    sysce_i <= 1'b1;
    syswe_i <= 1'b1;
    sel_i <= 4'b1111;
    addr_i <= 32'h0000_0c00;
    data_to_store_i <= 32'h4444_4444;
    @(cache_ack_o)
    sysce_i = 1'b0;
    syswe_i = 1'b0;

    // evict way0
    repeat (2) @(posedge clk);
    sysce_i <= 1'b1;
    syswe_i <= 1'b1;
    sel_i <= 4'b1111;
    addr_i <= 32'h0000_1800;
    data_to_store_i <= 32'h6666_6666;
    @(cache_ack_o)
    sysce_i = 1'b0;
    syswe_i = 1'b0;

    // fetch way0
    repeat (2) @(posedge clk);
    sysce_i <= 1'b1;
    syswe_i <= 1'b1;
    sel_i <= 4'b1100;
    addr_i <= 32'h0000_0c10;
    data_to_store_i <= 32'h1234_5678;
    @(cache_ack_o)
    sysce_i = 1'b0;
    syswe_i = 1'b0;

    // evict way1
    repeat (2) @(posedge clk);
    sysce_i <= 1'b1;
    syswe_i <= 1'b0;
    sel_i <= 4'b1111;
    addr_i <= 32'h0000_000c;
    @(cache_ack_o)
    sysce_i = 1'b0;
    syswe_i = 1'b0;

end
endtask


CACHETOP cachetop (clk,
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
                   wishbone_to_mem_data_o
                   );

DATARAM  data_ram (clk,
                   rst,
                   dwish_slave_addr_o,
                   dwish_slave_data_o,
                   dwish_slave_we_o,
                   dwish_slave_sel_o,
                   dwish_slave_stb_o,
                   dwish_slave_cyc_o,
                   dwish_slave_data_i,
                   dwish_slave_ack_i
                     );


wb_conmax_top  wishbone_top(
                  .clk_i(clk), 
                  .rst_i(rst),

                  // Master 0 Interface
                  .m0_data_i(wishbone_to_mem_data_o),
                  .m0_data_o(wishbone_from_mem_data_i),
                  .m0_addr_i(wishbone_to_mem_addr_o), 
                  .m0_sel_i(wishbone_to_mem_sel_o), 
                  .m0_we_i(wishbone_to_mem_we_o), 
                  .m0_cyc_i(wishbone_to_mem_cyc_o),
                  .m0_stb_i(wishbone_to_mem_stb_o), 
                  .m0_ack_o(wishbone_from_mem_ack_i),

                  // Slave 0 Interface
                  .s0_data_i(dwish_slave_data_i), 
                  .s0_data_o(dwish_slave_data_o), 
                  .s0_addr_o(dwish_slave_addr_o), 
                  .s0_sel_o(dwish_slave_sel_o), 
                  .s0_we_o(dwish_slave_we_o), 
                  .s0_cyc_o(dwish_slave_cyc_o),
                  .s0_stb_o(dwish_slave_stb_o), 
                  .s0_ack_i(dwish_slave_ack_i)

        );

endmodule
