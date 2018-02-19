/***************************************
 ********** Andy You Property **********
 ***************************************/

// Serial division method

module DIV (clk, rst, if_signed_i, divident_i, divisor_i, start_i, quotient_o, remainder_o, finish_o);

parameter IDLE = 2'b00, ONGOING = 2'b01, FINISH = 2'b10, DIVISOR0 = 2'b11;

input  clk, rst, if_signed_i, start_i;
input  [31:0] divident_i, divisor_i;

output reg [31:0] quotient_o, remainder_o;
output reg finish_o;

reg  [1:0]  State;
reg  [1:0]  NextState;
reg  [31:0] divident;
reg  [31:0] divisor;
reg         if_sign_diff;
reg  [31:0] divident_r;
reg  [4:0]  counter;
reg  [31:0] minuend;
reg  [31:0] quotient_w;
reg  [31:0] remainder_w;

wire        minuend_less;
wire [31:0] minuend_diff;
wire [31:0] divident_w;

assign {minuend_less, minuend_diff} = {1'b0, minuend} +( ~{1'b0, divisor} + 1'b1);
assign divident_w = if_signed_i ? (divident_i[31]? ((~divident_i) + 1'b1) : divident_i) : divident_i;

always @(*) begin
    if (rst) begin
        quotient_w = 32'h0;
        remainder_w = 32'h0;
        NextState = IDLE;
    end
    else begin
        quotient_w = 32'h0;
        remainder_w = 32'h0;
        NextState = IDLE;
        if (start_i) begin
            case (State) 
                IDLE : begin
                    if (divisor_i == 32'h0)
                        NextState = DIVISOR0;
                    else
                        NextState = ONGOING;
                    quotient_w = 32'h0;
                    remainder_w = 32'h0;
                end
                ONGOING : begin
                    if (counter == 5'b11110)
			NextState = FINISH;
                    else
		        NextState = ONGOING;
                    quotient_w = {quotient_o[30:0], (~minuend_less)};
		    remainder_w = minuend_less ? minuend : minuend_diff;
                end
		FINISH : begin
		    NextState = IDLE;
		    if (if_sign_diff) begin
		        quotient_w = (~{quotient_o[30:0], (~minuend_less)}) + 1'b1;
			remainder_w = divident_i[31] ? 
				      ((~(minuend_less ? minuend : minuend_diff)) 
				      + 1'b1) : (minuend_less ? minuend : minuend_diff);
		    end
		    else begin
			quotient_w = {quotient_o[30:0], (~minuend_less)};
			remainder_w = minuend_less ? minuend : minuend_diff;
		    end
		end
                DIVISOR0 : begin
                    NextState = IDLE;
                    quotient_w = 32'h0;
                    remainder_w = 32'h0;
                end
            endcase
        end
    end
end

always @(posedge clk) begin
    if (rst) begin
        State <= IDLE;
        counter <= 5'b0;
        minuend <= 32'h0;
	finish_o <= 1'b0;
        divident_r <= 32'h0;
        quotient_o <= 32'b0;
        remainder_o <= 32'b0;
	if_sign_diff <= 1'b0;
	divident <= 32'b0;
	divisor <= 32'b0;
    end
    else if (start_i) begin
        State <= NextState;
        case (State)
            IDLE : begin
		finish_o <= 1'b0;
                counter <= 5'b0;
                minuend <= divident_w[31];
                divident_r <= {divident_w[30:0], 1'b0};
		if_sign_diff <= if_signed_i ? (divident_i[31]^divisor_i[31]) : 1'b0;
		divident <= divident_w;
		divisor <= if_signed_i ? (divisor_i[31]? ((~divisor_i) + 1'b1) : divisor_i) : divisor_i;
            end
            ONGOING : begin
		finish_o <= 1'b0;
                counter <= counter + 1'b1;
                divident_r <= {divident_r[30:0], 1'b0};
                quotient_o <= quotient_w;
                remainder_o <= remainder_w;
                if (minuend_less) 
                    minuend <= {minuend, divident_r[31]};
                else
                    minuend <= {minuend_diff, divident_r[31]};
            end
	    FINISH : begin
		counter <= 5'b0;
		minuend <= 32'h0;
		finish_o <= 1'b1;
		divident_r <= 32'h0;
		quotient_o <= quotient_w;
		remainder_o <= remainder_w;
	    end
            DIVISOR0 : begin
		finish_o <= 1'b0;
                counter <= 5'b0;
                minuend <= 32'h0;
                divident_r <= 32'h0;
                quotient_o <= 32'b0;
                remainder_o <= 32'b0;
            end
        endcase
    end
    else begin
        State <= IDLE;
        counter <= 5'b0;
	finish_o <= 1'b0;
        minuend <= 32'h0;
        divident_r <= 32'h0;
        quotient_o <= 32'b0;
        remainder_o <= 32'b0;
	if_sign_diff <= 1'b0;
	divident <= 32'b0;
	divisor <= 32'b0;
    end
end

endmodule
