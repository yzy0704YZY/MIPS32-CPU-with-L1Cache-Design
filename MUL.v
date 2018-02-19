/***************************************
 ********** Andy You Property **********
 ***************************************/

//Parallel Multiplication method

module MUL (clk, rst, start, finish, a, b, sign_diff, result);

parameter IDLE = 3'b000, S0 = 3'b001, S1 = 3'b010, S2 = 3'b011,
          S3 = 3'b100, S4 = 3'b101, FINISH = 3'b110;

input  clk, rst, start, sign_diff;
input  [31:0] a, b;

output reg finish;
output reg [63:0] result;

reg [63:0] reglist [0:31];
reg [2:0] STATE;

always @(posedge clk) begin
    if (rst) begin
        finish <= 1'b0;
        result <= 64'h0;
        STATE <= IDLE;
    end
    else begin
        case (STATE) 
            IDLE : begin
                if (start) begin
                    STATE <= S0;
                    reglist[0] <= b[0]? {32'b0, a} : 64'b0;
                    reglist[1] <= b[1]? {31'b0, a, 1'b0} : 64'b0;
                    reglist[2] <= b[2]? {30'b0, a, 2'b0} : 64'b0;
                    reglist[3] <= b[3]? {29'b0, a, 3'b0} : 64'b0;
                    reglist[4] <= b[4]? {28'b0, a, 4'b0} : 64'b0;
                    reglist[5] <= b[5]? {27'b0, a, 5'b0} : 64'b0;
                    reglist[6] <= b[6]? {26'b0, a, 6'b0} : 64'b0;
                    reglist[7] <= b[7]? {25'b0, a, 7'b0} : 64'b0;
                    reglist[8] <= b[8]? {24'b0, a, 8'b0} : 64'b0;
                    reglist[9] <= b[9]? {23'b0, a, 9'b0} : 64'b0;
                    reglist[10] <= b[10]? {22'b0, a, 10'b0} : 64'b0;
                    reglist[11] <= b[11]? {21'b0, a, 11'b0} : 64'b0;
                    reglist[12] <= b[12]? {20'b0, a, 12'b0} : 64'b0;
                    reglist[13] <= b[13]? {19'b0, a, 13'b0} : 64'b0;
                    reglist[14] <= b[14]? {18'b0, a, 14'b0} : 64'b0;
                    reglist[15] <= b[15]? {17'b0, a, 15'b0} : 64'b0;
                    reglist[16] <= b[16]? {16'b0, a, 16'b0} : 64'b0;
                    reglist[17] <= b[17]? {15'b0, a, 17'b0} : 64'b0;
                    reglist[18] <= b[18]? {14'b0, a, 18'b0} : 64'b0;
                    reglist[19] <= b[19]? {13'b0, a, 19'b0} : 64'b0;
                    reglist[20] <= b[20]? {12'b0, a, 20'b0} : 64'b0;
                    reglist[21] <= b[21]? {11'b0, a, 21'b0} : 64'b0;
                    reglist[22] <= b[22]? {10'b0, a, 22'b0} : 64'b0;
                    reglist[23] <= b[23]? {9'b0, a, 23'b0} : 64'b0;
                    reglist[24] <= b[24]? {8'b0, a, 24'b0} : 64'b0;
                    reglist[25] <= b[25]? {7'b0, a, 25'b0} : 64'b0;
                    reglist[26] <= b[26]? {6'b0, a, 26'b0} : 64'b0;
                    reglist[27] <= b[27]? {5'b0, a, 27'b0} : 64'b0;
                    reglist[28] <= b[28]? {4'b0, a, 28'b0} : 64'b0;
                    reglist[29] <= b[29]? {3'b0, a, 29'b0} : 64'b0;
                    reglist[30] <= b[30]? {2'b0, a, 30'b0} : 64'b0;
                    reglist[31] <= b[31]? {1'b0, a, 31'b0} : 64'b0;
                end
                finish <= 1'b0;
            end
            S0 : begin
		STATE <= S1;
                reglist[0] <= reglist[0] + reglist[1];
                reglist[1] <= reglist[2] + reglist[3];
                reglist[2] <= reglist[4] + reglist[5];
                reglist[3] <= reglist[6] + reglist[7];
                reglist[4] <= reglist[8] + reglist[9];
                reglist[5] <= reglist[10] + reglist[11];
                reglist[6] <= reglist[12] + reglist[13];
                reglist[7] <= reglist[14] + reglist[15];
                reglist[8] <= reglist[16] + reglist[17];
                reglist[9] <= reglist[18] + reglist[19];
                reglist[10] <= reglist[20] + reglist[21];
                reglist[11] <= reglist[22] + reglist[23];
                reglist[12] <= reglist[24] + reglist[25];
                reglist[13] <= reglist[26] + reglist[27];
                reglist[14] <= reglist[28] + reglist[29];
                reglist[15] <= reglist[30] + reglist[31];
            end
	    S1 : begin
		STATE <= S2;
                reglist[0] <= reglist[0] + reglist[1];
                reglist[1] <= reglist[2] + reglist[3];
                reglist[2] <= reglist[4] + reglist[5];
                reglist[3] <= reglist[6] + reglist[7];
                reglist[4] <= reglist[8] + reglist[9];
                reglist[5] <= reglist[10] + reglist[11];
                reglist[6] <= reglist[12] + reglist[13];
                reglist[7] <= reglist[14] + reglist[15];
            end
	    S2 : begin
		STATE <= S3;
                reglist[0] <= reglist[0] + reglist[1];
                reglist[1] <= reglist[2] + reglist[3];
                reglist[2] <= reglist[4] + reglist[5];
                reglist[3] <= reglist[6] + reglist[7];
            end
	    S3 : begin
		STATE <= S4;
                reglist[0] <= reglist[0] + reglist[1];
                reglist[1] <= reglist[2] + reglist[3];
            end
	    S4 : begin
		STATE <= FINISH;
                reglist[0] <= reglist[0] + reglist[1];
            end
	    FINISH : begin
		STATE <= IDLE;
		finish <= 1'b1;
		result <= sign_diff? ((~reglist[0]) + 1'b1) : reglist[0];
	    end
        endcase
    end
end

endmodule
