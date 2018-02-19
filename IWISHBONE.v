/***************************************
 ********** Andy You Property **********
 ***************************************/


module IWISHBONE (clk,
                  rst,
                  stall_i,
                  flush_i,
                  instreq,
                  cpu_data_i,
                  cpu_addr_i,
                  cpu_we_i,
                  cpu_sel_i,
                  cpu_data_o,
                  wishbone_addr_o,
                  wishbone_data_o,
                  wishbone_we_o,
                  wishbone_sel_o,
                  wishbone_stb_o,
                  wishbone_cyc_o,
                  wishbone_data_i,
                  wishbone_ack_i,
                  stallreq
                  );


parameter IDLE = 2'b00, BUSY = 2'b01, STALL = 2'b10;

input  clk, rst, flush_i;
input  instreq, cpu_we_i, wishbone_ack_i;
input  [31:0] cpu_data_i;
input  [31:0] cpu_addr_i;
input  [3:0]  cpu_sel_i;
input  [5:0]  stall_i;
input  [31:0] wishbone_data_i;

output reg wishbone_we_o, stallreq;
output reg wishbone_stb_o, wishbone_cyc_o;
output reg [31:0] cpu_data_o;
output reg [31:0] wishbone_addr_o, wishbone_data_o;
output reg [3:0]  wishbone_sel_o;

reg [1:0]  STATE;
reg [31:0] cpu_data_tmp;

//Logic begin
always @(posedge clk) begin
    if (rst | flush_i) begin
        cpu_data_tmp <= 32'h0;
        STATE <= IDLE;
    end
    else begin
        case (STATE)
            IDLE : begin
                if (instreq) begin
                    //cpu_data_tmp <= 32'h0;
                    STATE <= BUSY;
                end
            end
	    BUSY : begin
                if (wishbone_ack_i) begin
		    cpu_data_tmp <= wishbone_data_i;
		    if (stall_i != 6'b000000) begin
                        STATE <= STALL;
                        //cpu_data_tmp <= wishbone_data_i;
                    end
                    else begin
                        STATE <= IDLE;
                    end
                end
            end
            STALL : begin
                if (stall_i == 6'b000000)
                    STATE <= IDLE;
            end
        endcase
    end
end


always @(*) begin
    if (rst) begin
        wishbone_we_o = 1'b0;
        wishbone_stb_o = 1'b0;
        wishbone_cyc_o = 1'b0;
        wishbone_addr_o = 32'b0;
        wishbone_data_o = 32'b0;
        wishbone_sel_o = 4'b0;
    end
    else begin
	wishbone_we_o = cpu_we_i;
	wishbone_stb_o = 1'b1;
	wishbone_cyc_o = 1'b1;
	wishbone_addr_o = cpu_addr_i;
	wishbone_data_o = cpu_data_i;
	wishbone_sel_o = cpu_sel_i;
        case (STATE)
            IDLE : begin
                if (!instreq) begin
		    wishbone_we_o = 1'b0;
		    wishbone_stb_o = 1'b0;
		    wishbone_cyc_o = 1'b0;
		end
            end
	    BUSY : begin
                if (wishbone_ack_i) begin
                    wishbone_we_o = 1'b0;
                    wishbone_stb_o = 1'b0;
                    wishbone_cyc_o = 1'b0;
                end
            end
	    STALL : begin
		wishbone_we_o = 1'b0;
		wishbone_stb_o = 1'b0;
		wishbone_cyc_o = 1'b0;
	    end
        endcase
    end
end



always @(*) begin
    if (rst) begin
	stallreq = 1'b0;
	cpu_data_o = 32'h0;
    end
    else begin
	stallreq = 1'b0;
	//cpu_data_o = 32'b0;
	cpu_data_o = cpu_data_tmp;
	case (STATE)
	    IDLE : begin
		if (instreq)
		    stallreq = 1'b1;
	    end
	    BUSY : begin
		if (wishbone_ack_i) begin
		    cpu_data_o = wishbone_data_i;
	        end
		else begin
		    stallreq = 1'b1;
		end
	    end
	    STALL : begin
		if (stall_i == 6'b000000)
		    cpu_data_o = cpu_data_tmp;
	    end
	endcase
    end
end

endmodule
