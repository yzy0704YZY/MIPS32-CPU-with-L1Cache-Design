module tb;

reg  clk = 0;
reg  rst = 1;

always #10 clk = ~clk;

initial begin
    #195
    rst = 0;
    #5000
    $finish;
end

SOPC sopc (clk, rst);

endmodule
