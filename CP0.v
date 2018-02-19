/***************************************
 ********** Andy You Property **********
 ***************************************/

// Co-processor

module   CP0   (clk,
                rst,
                raddr_i,
                interrupt_i,
                we_i,
                waddr_i,
                wdata_i,
                data_o,
                count_o,
                compare_o,
                status_o,
                cause_o,
                epc_o,
                config_o,
                prid_o,
                timer_interrupt_o,
                excepttype,
                current_inst_addr,
                is_in_delayslot);


input  clk, rst, we_i;
input  [4:0] raddr_i, waddr_i;
input  [5:0] interrupt_i;
input  [31:0] wdata_i;
input  is_in_delayslot;
input  [31:0] excepttype;
input  [31:0] current_inst_addr;

output reg timer_interrupt_o;
output reg [31:0] data_o;
output reg [31:0] count_o;
output reg [31:0] compare_o;
output reg [31:0] status_o;
output reg [31:0] cause_o;
output reg [31:0] epc_o;
output reg [31:0] config_o;
output reg [31:0] prid_o;

// WRITE
always @(posedge clk) begin
    if (rst) begin
        count_o <= 32'b0;
        compare_o <= 32'b0;
        status_o <= 32'h1000;
        cause_o <= 32'b0;
        epc_o <= 32'b0;
        config_o <= 32'h0080;
        prid_o <= 32'hffff;
        timer_interrupt_o <= 1'b0;
    end
    else begin
        cause_o[15:10] <= interrupt_i;
        if (!we_i || waddr_i != `CP0_COUNT)
            count_o <= count_o + 1'b1;
        if (compare_o != 32'b0 && count_o == compare_o && (!we_i || waddr_i != `CP0_COMPARE))
            timer_interrupt_o <= 1'b1;
        if (excepttype != 32'h0) begin
            case (excepttype)
                32'h1 : begin
                    if (is_in_delayslot) begin
                        cause_o[31] <= 1'b1;
                        epc_o <= current_inst_addr - 32'h4;
                    end
                    else begin
                        cause_o[31] <= 1'b0;
                        epc_o <= current_inst_addr;
                    end
                    status_o[1] <= 1'b1;
                    cause_o[6:2] <= 5'b00001;
                end
                32'h8 : begin
                    if (!status_o[1]) begin
                        if (is_in_delayslot) begin
                            cause_o[31] <= 1'b1;
                            epc_o <= current_inst_addr - 32'h4;
                        end
                        else begin
                            cause_o[31] <= 1'b0;
                            epc_o <= current_inst_addr;
                        end
                    end
		    status_o[1] <= 1'b1;
                    cause_o[6:2] <= 5'b01000;
                end
                32'ha : begin
                    if (!status_o[1]) begin
                        if (is_in_delayslot) begin
                            cause_o[31] <= 1'b1;
                            epc_o <= current_inst_addr - 32'h4;
                        end
                        else begin
                            cause_o[31] <= 1'b0;
                            epc_o <= current_inst_addr;
                        end
                    end
		    status_o[1] <= 1'b1;
                    cause_o[6:2] <= 5'b01010;
                end
                32'hd : begin
                    if (!status_o[1]) begin
                        if (is_in_delayslot) begin
                            cause_o[31] <= 1'b1;
                            epc_o <= current_inst_addr - 32'h4;
                        end
                        else begin
                            cause_o[31] <= 1'b0;
                            epc_o <= current_inst_addr;
                        end
                    end
		    status_o[1] <= 1'b1;
                    cause_o[6:2] <= 5'b01101;
                end
                32'hc : begin
                    if (!status_o[1]) begin
                        if (is_in_delayslot) begin
                            cause_o[31] <= 1'b1;
                            epc_o <= current_inst_addr - 32'h4;
                        end
                        else begin
                            cause_o[31] <= 1'b0;
                            epc_o <= current_inst_addr;
                        end
                    end
		    status_o[1] <= 1'b1;
                    cause_o[6:2] <= 5'b01100;
                end
                32'he : begin
                    status_o[1] <= 1'b0;
                    cause_o[6:2] <= 5'b00000;
                end
            endcase
        end
        if (we_i == 1'b1) begin
            case (waddr_i) 
                `CP0_COUNT : count_o <= wdata_i;
                `CP0_COMPARE : begin
                    compare_o <= wdata_i;
                    timer_interrupt_o <= 1'b0;
                end
                `CP0_STATUS : begin
                    status_o[31:2] <= wdata_i[31:2];
                    status_o[0] <= wdata_i[0];
                end 
                `CP0_EPC : epc_o <= wdata_i;
                `CP0_CAUSE : begin
                    cause_o[23:22] <= wdata_i[23:22];
                    cause_o[9:8] <= wdata_i[9:8];
                end
            endcase
        end
    end
end


//READ
always @(*) begin
    if (rst)
        data_o = 32'b0;
    else begin
        data_o = 32'b0;
        case (raddr_i)
            `CP0_COUNT : data_o = count_o;
            `CP0_COMPARE : data_o = compare_o;
            `CP0_STATUS : data_o = status_o;
            `CP0_CAUSE : data_o = cause_o;
            `CP0_EPC : data_o = epc_o;
            `CP0_PRID : data_o = prid_o;
            `CP0_CONFIG : data_o = config_o;
        endcase
    end
end


endmodule
