/***************************************
 ********** Andy You Property **********
 ***************************************/


module   MEM   (rst,
                wd_i,
                wreg_i,
                wdata_i,
                hilo_en_i,
                hi_i,
                lo_i,
                wd_o,
                wreg_o,
                wdata_o,
                hilo_en_o,
                hi_o,
                lo_o,
                aluop_mem_i,
		alusel_mem_i,
                mem_addr_i,
                reg_store_i,
                ce,
                we,
                data_i,
                data_o,
                cp0_reg_we_i,
                cp0_reg_write_addr_i,
                cp0_reg_data_i,
                cp0_reg_we_o,
                cp0_reg_write_addr_o,
                cp0_reg_data_o,
                excepttype_i,
		ex_current_inst_addr_i,
                mem_current_inst_addr_i,
                is_in_delayslot_i,
                cp0_status_i,
                cp0_cause_i,
                cp0_epc_i,
                wb_cp0_reg_we,
                wb_cp0_reg_write_addr,
                wb_cp0_reg_data,
                excepttype_o,
                current_inst_addr_o,
                is_in_delayslot_o,
                cp0_epc_o,
                mem_sel,
		cache_ack_i,
		stall_req
		);

input  rst, wreg_i;
input  [4:0] wd_i;
input  [31:0] wdata_i;
input  hilo_en_i;
input  [31:0] hi_i, lo_i;
input  [7:0] aluop_mem_i;
input  [2:0] alusel_mem_i;
input  [31:0] mem_addr_i;
input  [31:0] reg_store_i;
input  [31:0] data_i;
input  cp0_reg_we_i;
input  [4:0] cp0_reg_write_addr_i;
input  [31:0] cp0_reg_data_i;
input  [31:0] excepttype_i;
input  [31:0] ex_current_inst_addr_i;
input  [31:0] mem_current_inst_addr_i;
input  is_in_delayslot_i, wb_cp0_reg_we;
input  [31:0] cp0_status_i, cp0_cause_i, cp0_epc_i;
input  [4:0]  wb_cp0_reg_write_addr;
input  [31:0] wb_cp0_reg_data;
input  cache_ack_i;

output reg wreg_o;
output reg [4:0] wd_o;
output reg [31:0] wdata_o;
output reg hilo_en_o;
output reg [31:0] hi_o, lo_o;
output reg ce, we;
output reg [31:0] data_o;
output reg cp0_reg_we_o;
output reg [4:0] cp0_reg_write_addr_o;
output reg [31:0] cp0_reg_data_o;
output reg is_in_delayslot_o;
output reg [31:0] excepttype_o;
output reg [31:0] cp0_epc_o;
output reg [31:0] current_inst_addr_o;
output reg [3:0]  mem_sel;
output            stall_req;

wire [1:0] addr_offset;
assign addr_offset = mem_addr_i[1:0];
assign stall_req = ce;

reg [31:0] status_latest, cause_latest;

always @(*) begin
    if (rst) begin
        status_latest = 32'h0;
        cause_latest = 32'h0;
        cp0_epc_o = 32'h0;
    end
    else begin
        status_latest = cp0_status_i;
        cause_latest = cp0_cause_i;
        cp0_epc_o = cp0_epc_i;
        if (wb_cp0_reg_we) begin
            case (wb_cp0_reg_write_addr)
                `CP0_STATUS : status_latest = wb_cp0_reg_data;
                `CP0_CAUSE : begin
                    cause_latest[9:8] = wb_cp0_reg_data[9:8];
                    cause_latest[23:22] = wb_cp0_reg_data[23:22];
                end
                `CP0_EPC : cp0_epc_o = wb_cp0_reg_data;
            endcase
        end
    end
end

always @(*) begin
    if (rst) begin
        excepttype_o = 32'h0;
    end
    else begin
        excepttype_o = 32'h0;
        if (mem_current_inst_addr_i != 32'h0) begin
            if ((status_latest[15:8] & cause_latest[15:8]) != 8'h00 && status_latest[1:0] == 2'b01)
                excepttype_o = 32'h1;  // Interrupt
            else if (excepttype_i[8])
                excepttype_o = 32'h8;  // System Call
            else if (excepttype_i[9])
                excepttype_o = 32'ha;  // Invalid instruction
            else if (excepttype_i[10])
                excepttype_o = 32'hd;  // Trap
            else if (excepttype_i[11])
                excepttype_o = 32'hc;  // Overflow
            else if (excepttype_i[12])
                excepttype_o = 32'he;  // Eret
        end
    end
end

always @(*) begin
    if (rst) begin
        wreg_o = cache_ack_i ? wreg_i : 1'b0;
        wd_o = 5'b0;
        wdata_o = 32'h0;
        hilo_en_o = 1'b0;
        hi_o = 32'h0;
        lo_o = 32'h0;
        ce = 1'b0;
        we = 1'b0;
        data_o = 32'h0;
        mem_sel = 4'b1111;
        cp0_reg_we_o = 1'b0;
        cp0_reg_write_addr_o = 5'b0;
        cp0_reg_data_o = 32'h0;
        is_in_delayslot_o = 1'b0;
        current_inst_addr_o = 32'h0;
    end
    else begin
        wreg_o = wreg_i;
        wd_o = wd_i;
        wdata_o = wdata_i;
        hilo_en_o = hilo_en_i;
        hi_o = hi_i;
        lo_o = lo_i;
        ce = 1'b0;
        we = 1'b0;
        data_o = 32'h0;
        mem_sel = 4'b0000;
        cp0_reg_we_o = cp0_reg_we_i;
        cp0_reg_write_addr_o = cp0_reg_write_addr_i;
        cp0_reg_data_o = cp0_reg_data_i;
        is_in_delayslot_o = is_in_delayslot_i;
        current_inst_addr_o = mem_current_inst_addr_i;
        case (aluop_mem_i)
            `OP_LB : begin
                ce = 1'b1;
		wreg_o = cache_ack_i ? wreg_i : 1'b0;
                case (addr_offset) 
                    2'b00 : begin
                        wdata_o = {{24{data_i[31]}},data_i[31:24]};
                        mem_sel = 4'b1000;
                    end
                    2'b01 : begin
                        wdata_o = {{24{data_i[23]}},data_i[23:16]};
                        mem_sel = 4'b0100;
                    end
                    2'b10 : begin
                        wdata_o = {{24{data_i[15]}},data_i[15:8]};
                        mem_sel = 4'b0010;
                    end
                    2'b11 : begin
                        wdata_o = {{24{data_i[7]}}, data_i[7:0]};
                        mem_sel = 4'b0001;
                    end
                endcase
            end
            `OP_LBU : begin
                ce = 1'b1;
		wreg_o = cache_ack_i ? wreg_i : 1'b0;
                case (addr_offset) 
                    2'b00 : begin
                        wdata_o = {24'h0, data_i[31:24]};
			mem_sel = 4'b1000;
		    end
		    2'b01 : begin
			wdata_o = {24'h0, data_i[23:16]};
			mem_sel = 4'b0100;
		    end
		    2'b10 : begin
			wdata_o = {24'h0, data_i[15:8]};
			mem_sel = 4'b0010;
	 	    end
		    2'b11 : begin
			wdata_o = {24'h0, data_i[7:0]};
			mem_sel = 4'b0001;
		    end
                endcase
            end
            `OP_LH : begin
                ce = 1'b1;
		wreg_o = cache_ack_i ? wreg_i : 1'b0;
                case (addr_offset) 
		    2'b00 : begin
			wdata_o = {{16{data_i[31]}},data_i[31:16]};
			mem_sel = 4'b1100;
		    end
		    2'b10 : begin
			wdata_o = {{16{data_i[15]}},data_i[15:0]};
			mem_sel = 4'b0011;
		    end
                    default : begin
                        ce = 1'b0;
                        wdata_o = 32'h0;
                    end
                endcase
            end
            `OP_LHU : begin
                ce = 1'b1;
		wreg_o = cache_ack_i ? wreg_i : 1'b0;
                case (addr_offset) 
		    2'b00 : begin
		        wdata_o = {16'h0,data_i[31:16]};
			mem_sel = 4'b1100;
		    end
		    2'b10 : begin
			wdata_o = {16'h0,data_i[15:0]};
			mem_sel = 4'b0011;
	            end
                    default : begin
                        ce = 1'b0;
                        wdata_o = 32'h0;
                    end
                endcase
            end
            `OP_LW : begin
                if (addr_offset == 2'b00) begin
                    ce = 1'b1;
		    wreg_o = cache_ack_i ? wreg_i : 1'b0;
                    wdata_o = data_i;
		    mem_sel = 4'b1111;
                end
                else begin
                    wdata_o = 32'h0;
                end
            end
            `OP_LWL : begin
                ce = 1'b1;
		wreg_o = cache_ack_i ? wreg_i : 1'b0;
                case (addr_offset)
		    2'b00 : begin
			wdata_o = data_i;
			mem_sel = 4'b1111;
		    end
		    2'b01 : begin 
		        wdata_o = {data_i[23:0], reg_store_i[7:0]};
			mem_sel = 4'b0111;
		    end
		    2'b10 : begin
			wdata_o = {data_i[15:0], reg_store_i[15:0]};
			mem_sel = 4'b0011;
		    end
		    2'b11 : begin
			wdata_o = {data_i[7:0],  reg_store_i[23:0]};
			mem_sel = 4'b0001;
		    end
                endcase
            end
            `OP_LWR : begin
                ce = 1'b1;
		wreg_o = cache_ack_i ? wreg_i : 1'b0;
                case (addr_offset)
		    2'b00 : begin
			wdata_o = {reg_store_i[31:8], data_i[31:24]};
			mem_sel = 4'b1000;
		    end
		    2'b01 : begin
			wdata_o = {reg_store_i[31:16], data_i[31:16]};
			mem_sel = 4'b1100;
		    end
		    2'b10 : begin
			wdata_o = {reg_store_i[31:24], data_i[31:8]};
			mem_sel = 4'b1110;
		    end
		    2'b11 : begin
			wdata_o = data_i;
			mem_sel = 4'b1111;
		    end
                endcase
            end
            `OP_SB : begin
                ce = 1'b1;
		wreg_o = cache_ack_i ? wreg_i : 1'b0;
                we = (|excepttype_o) ? 1'b0 : 1'b1;
                case (addr_offset)
		    2'b00 : begin
			data_o = {reg_store_i[7:0], 24'b0};
			mem_sel = 4'b1000;
		    end
		    2'b01 : begin
			data_o = {8'b0, reg_store_i[7:0], 16'b0};
			mem_sel = 4'b0100;
		    end
		    2'b10 : begin
			data_o = {16'b0, reg_store_i[7:0], 8'b0};
			mem_sel = 4'b0010;
		    end
		    2'b11 : begin
			data_o = {24'b0, reg_store_i[7:0]};
			mem_sel = 4'b0001;
		    end
                endcase
            end
            `OP_SH : begin
                ce = 1'b1;
		wreg_o = cache_ack_i ? wreg_i : 1'b0;
                we = (|excepttype_o) ? 1'b0 : 1'b1;
                case (addr_offset)
		    2'b00 : begin
			data_o = {reg_store_i[15:0], 16'b0};
			mem_sel = 4'b1100;
		    end
		    2'b10 : begin
			data_o = {16'b0, reg_store_i[15:0]};
			mem_sel = 4'b0011;
		    end
                    default : begin
                        ce = 1'b0;
                        we = 1'b0;
                    end
                endcase
            end
            `OP_SW : begin
                if (addr_offset == 2'b00) begin
                    ce = 1'b1;
		    wreg_o = cache_ack_i ? wreg_i : 1'b0;
                    we = (|excepttype_o) ? 1'b0 : 1'b1;
                    data_o = reg_store_i;
		    mem_sel = 4'b1111;
                end
                else begin
                    data_o = 32'h0;
                end
            end
            `OP_SWL : begin
                ce = 1'b1;
		wreg_o = cache_ack_i ? wreg_i : 1'b0;
                we = (|excepttype_o) ? 1'b0 : 1'b1;
                case (addr_offset)
		    2'b00 : begin
			data_o = reg_store_i;
			mem_sel = 4'b1111;
		    end
		    2'b01 : begin
			data_o = {8'b0, reg_store_i[31:8]};
			mem_sel = 4'b0111;
		    end
		    2'b10 : begin
			data_o = {16'b0, reg_store_i[31:16]};
			mem_sel = 4'b0011;
		    end
		    2'b11 : begin
			data_o = {24'b0, reg_store_i[31:24]};
			mem_sel = 4'b0001;
		    end
                endcase
            end
            `OP_SWR : begin
                ce = 1'b1;
		wreg_o = cache_ack_i ? wreg_i : 1'b0;
                we = (|excepttype_o) ? 1'b0 : 1'b1;
                case (addr_offset)
		    2'b00 : begin
			data_o = {reg_store_i[7:0], 24'b0};
			mem_sel = 4'b1000;
		    end
		    2'b01 : begin
			data_o = {reg_store_i[15:0], 16'b0};
			mem_sel = 4'b1100;
		    end
		    2'b10 : begin
			data_o = {reg_store_i[23:0], 8'b0};
			mem_sel = 4'b1110;
		    end
		    2'b11 : begin
			data_o = reg_store_i;
			mem_sel = 4'b1111;
		    end
                endcase
            end
        endcase
	if (cache_ack_i || ex_current_inst_addr_i != mem_current_inst_addr_i) begin
	    ce = 1'b0;
	    we = 1'b0;
	end
    end
end

endmodule
