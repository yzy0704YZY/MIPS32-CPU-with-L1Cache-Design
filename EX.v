/***************************************
 ********** Andy You Property **********
 ***************************************/


module    EX   (rst,
                alusel_i,
                aluop_i,
                reg1_i,
                reg2_i,
                wd_i,
                wreg_i,
                wd_o,
                wreg_o,
                wdata_o,
                hilo_mem_en,
                hilo_en,
                hi_mem,
                lo_mem,
                hi_hilo_i,
                lo_hilo_i,
                hi_hilo_o,
                lo_hilo_o,
                hilo_ex_en,
                hi_ex_o,
                lo_ex_o,
                stall_req_ex,
                hilo_temp_i,
                hilo_temp_o,
                hilo_temp_req,
                hilo_temp_ack,
                if_signed_o,
                start_div_o,
		start_mul_o,
                finish_div_i,
		finish_mul_i,
                quotient_i,
                remainder_i,
		link_address,
		is_in_delayslot,
		inst_ex,
		aluop_o,
		alusel_o,
		mem_addr_o,
		reg_store_o,
		cp0_reg_data_i,
		cp0_reg_read_addr_o,
		cp0_reg_we_o,
		cp0_reg_write_addr_o,
		cp0_reg_data_o,
		mem_cp0_reg_we,
		mem_cp0_reg_write_addr,
		mem_cp0_reg_data,
		wb_cp0_reg_we,
		wb_cp0_reg_write_addr,
		wb_cp0_reg_data,
		excepttype_i,
		current_inst_addr_i,
		excepttype_o,
		current_inst_addr_o,
		is_in_delayslot_o,
		mul_reg1_o,
		mul_reg2_o,
		mul_sign_diff_o,
		mul_result_i
		);


input  rst, wreg_i, finish_div_i, finish_mul_i;
input  [2:0]  alusel_i;
input  [7:0]  aluop_i;
input  [31:0] reg1_i, reg2_i;
input  [4:0]  wd_i;
input	      is_in_delayslot;
input  [31:0] inst_ex;
input  [31:0] hi_mem, lo_mem;
input  [31:0] hi_hilo_i, lo_hilo_i;
input  [31:0] hi_hilo_o, lo_hilo_o;
input  hilo_mem_en, hilo_en;
input  [63:0] hilo_temp_i;
input  hilo_temp_ack;
input  [31:0] quotient_i, remainder_i;
input  [31:0] link_address;
input  [31:0] cp0_reg_data_i;
input  mem_cp0_reg_we;
input  [4:0]  mem_cp0_reg_write_addr;
input  [31:0] mem_cp0_reg_data;
input  wb_cp0_reg_we;
input  [4:0]  wb_cp0_reg_write_addr;
input  [31:0] wb_cp0_reg_data;
input  [31:0] excepttype_i, current_inst_addr_i;
input  [63:0] mul_result_i;

output reg [4:0] wd_o;
output reg [7:0] aluop_o;
output reg [2:0] alusel_o; 
output reg [31:0] mem_addr_o;
output reg [31:0] reg_store_o;
output reg wreg_o, start_div_o, if_signed_o;
output reg start_mul_o, mul_sign_diff_o;
output reg [31:0] wdata_o;
output reg hilo_ex_en;
output reg [31:0] hi_ex_o, lo_ex_o;
output reg stall_req_ex;
output reg hilo_temp_req;
output reg [63:0] hilo_temp_o;
output reg cp0_reg_we_o;
output reg [4:0] cp0_reg_read_addr_o;
output reg [4:0] cp0_reg_write_addr_o;
output reg [31:0] cp0_reg_data_o;
output reg [31:0] current_inst_addr_o;
output reg is_in_delayslot_o;
output reg [31:0] mul_reg1_o, mul_reg2_o;

output wire [31:0] excepttype_o;

reg overflow, trap;

wire [31:0] reg1_i_b, reg2_i_b;
wire [63:0] hilo_temp_i_b;

assign reg1_i_b = (~reg1_i) + 1'b1;
assign reg2_i_b = (~reg2_i) + 1'b1;
assign hilo_temp_i_b = (~hilo_temp_i) + 1'b1;

wire [32:0] reg1_signed_extend, reg2_b_signed_extend;
wire [32:0] reg1_unsign_extend, reg2_b_unsign_extend;
wire [32:0] rs_rt_diff_signed, rs_rt_diff_unsign;

assign reg1_signed_extend = {reg1_i[31], reg1_i};
assign reg1_unsign_extend = {1'b0, reg1_i};
assign reg2_b_signed_extend = (~({reg2_i[31], reg2_i})) + 1'b1;
assign reg2_b_unsign_extend = (~({1'b0, reg2_i})) + 1'b1;
assign rs_rt_diff_signed = reg1_signed_extend + reg2_b_signed_extend;
assign rs_rt_diff_unsign = reg1_unsign_extend + reg2_b_unsign_extend;
assign excepttype_o = {excepttype_i[31:12], overflow, trap, excepttype_i[9:0]};

always @(*) begin
    if (rst) begin
        wd_o = 5'b0;
        wreg_o = 1'b0;
        wdata_o = 32'h0;
        hilo_ex_en = 1'b0;
        hi_ex_o = 32'b0;
        lo_ex_o = 32'b0;
        overflow = 1'b0;
	trap = 1'b0;
        stall_req_ex = 1'b0;
        hilo_temp_o = 64'h0;
        hilo_temp_req = 1'b0;
	if_signed_o = 1'b0;
	start_div_o = 1'b0;
	aluop_o = 8'b0;
	mem_addr_o = 32'b0;
	reg_store_o = 32'h0;
	cp0_reg_we_o = 1'b0;
	cp0_reg_read_addr_o = 5'b0;
	cp0_reg_write_addr_o = 5'b0;
	cp0_reg_data_o = 32'h0;
	current_inst_addr_o = 32'h0;
	is_in_delayslot_o = 1'b0;
	start_mul_o = 1'b0;
	mul_reg1_o = 32'h0;
	mul_reg2_o = 32'h0;
	mul_sign_diff_o = 1'b0;
    end
    else begin
        wd_o = wd_i;
        wreg_o = wreg_i;
        wdata_o = 32'h0;
        hilo_ex_en = 1'b0;
        hi_ex_o = hi_mem;
        lo_ex_o = lo_mem;
        overflow = 1'b0;
	trap = 1'b0;
        stall_req_ex = 1'b0;
        hilo_temp_o = 64'h0;
        hilo_temp_req = 1'b0;
	if_signed_o = 1'b0;
	start_div_o = 1'b0;
	aluop_o = 8'b0;
	mem_addr_o = 32'b0;
	reg_store_o = 32'h0;
	cp0_reg_we_o = 1'b0;
	cp0_reg_read_addr_o = 5'b0;
	cp0_reg_write_addr_o = 5'b0;
	cp0_reg_data_o = 32'h0;
	current_inst_addr_o = current_inst_addr_i;
	is_in_delayslot_o = is_in_delayslot;
	start_mul_o = 1'b0;
	mul_reg1_o = reg1_i;
	mul_reg2_o = reg2_i;
	mul_sign_diff_o = 1'b0;
        if (alusel_i == `SEL_LOGIC) begin
            case (aluop_i)
                `OP_OR   : wdata_o = reg1_i | reg2_i;
                `OP_ORI  : wdata_o = reg1_i | reg2_i;
                `OP_AND  : wdata_o = reg1_i & reg2_i;
                `OP_ANDI : wdata_o = reg1_i & reg2_i;
                `OP_XOR  : wdata_o = reg1_i ^ reg2_i;
                `OP_XORI : wdata_o = reg1_i ^ reg2_i;
                `OP_NOR  : wdata_o = ~(reg1_i | reg2_i);
                `OP_LUI  : wdata_o = reg1_i;
            endcase
        end
        else if (alusel_i == `SEL_SHIFT) begin
            case (aluop_i)
                `OP_SLLV : wdata_o = reg2_i << reg1_i[4:0];
                `OP_SRLV : wdata_o = reg2_i >> reg1_i[4:0];
                `OP_SRAV : wdata_o = ({32{reg2_i[31]}} << (6'd32-reg1_i[4:0]))
                                      | (reg2_i >> reg1_i[4:0]);
                `OP_SLL  : wdata_o = reg2_i << reg1_i;
                `OP_SRL  : wdata_o = reg2_i >> reg1_i;
                `OP_SRA  : wdata_o = ({32{reg2_i[31]}} << (6'd32-reg1_i))
                                      | (reg2_i >> reg1_i);
            endcase
        end
        else if (alusel_i == `SEL_MOVE) begin
            case (aluop_i)
                `OP_MFHI : begin
                    if (hilo_mem_en)
                        wdata_o = hi_mem;
                    else if (hilo_en)
                        wdata_o = hi_hilo_i;
                    else
                        wdata_o = hi_hilo_o;
                end
                `OP_MFLO : begin
                    if (hilo_mem_en)
                        wdata_o = lo_mem;
                    else if (hilo_en)
                        wdata_o = lo_hilo_i;
                    else
                        wdata_o = lo_hilo_o;
                end
                `OP_MTHI : begin
                    hilo_ex_en = 1'b1;
                    hi_ex_o = reg1_i;
                end
                `OP_MTLO : begin
                    hilo_ex_en = 1'b1;
                    lo_ex_o = reg1_i;
                end
                `OP_MOVN : begin
                    if (reg2_i != 0)
                        wdata_o = reg1_i;
                    else begin
                        wd_o = 5'b0;
                        wreg_o = 1'b0;
                    end
                end
                `OP_MOVZ : begin
                    if (reg2_i == 0)
                        wdata_o = reg1_i;
                    else begin
                        wd_o = 5'b0;
                        wreg_o = 1'b0;
                    end
                end
		`OP_MTC0 : begin
		    cp0_reg_write_addr_o = wd_i;
		    cp0_reg_we_o = 1'b1;
		    cp0_reg_data_o = reg2_i;
		    wreg_o = 1'b0;
		end
		`OP_MFC0 : begin
		    cp0_reg_read_addr_o = inst_ex[15:11];
		    wreg_o = 1'b1;
		    wd_o = inst_ex[20:16];
		    if (mem_cp0_reg_we && mem_cp0_reg_write_addr == cp0_reg_read_addr_o)
			wdata_o = mem_cp0_reg_data;
		    else if (wb_cp0_reg_we && wb_cp0_reg_write_addr == cp0_reg_read_addr_o)
			wdata_o = wb_cp0_reg_data;
		    else 
			wdata_o = cp0_reg_data_i;
		end
            endcase
        end
        else if (alusel_i == `SEL_ARITHMETIC) begin
            case (aluop_i)
                `OP_ADD, `OP_ADDI  : begin
                    wdata_o = reg1_i + reg2_i;
                    overflow = (!reg1_i[31] & !reg2_i[31] & wdata_o[31]) ||
                               (reg1_i[31] & reg2_i[31] & !wdata_o[31]);
                    if (overflow) begin
                        wreg_o = 1'b0;
                        wd_o = 5'b0;
                    end
                end
                `OP_ADDU, `OP_ADDIU : wdata_o = reg1_i + reg2_i;
                `OP_SUB  : begin
                    wdata_o = reg1_i + reg2_i_b;
                    overflow = (!reg1_i[31] & !reg2_i_b[31] & wdata_o[31]) ||
                               (reg1_i[31] & reg2_i_b[31] & !wdata_o[31]);
                    if (overflow) begin
                        wreg_o = 1'b0;
                        wd_o = 5'b0;
                    end
                end
                `OP_SUBU : wdata_o = reg1_i + reg2_i_b;
                `OP_SLT, `OP_SLTI  : begin
                    if (!reg1_i[31] && reg2_i[31])
                        wdata_o = 1'b0;
                    else if (reg1_i[31] && !reg2_i[31])
                        wdata_o = 1'b1;
                    else if (!reg1_i[31] && !reg2_i[31])
                        wdata_o = (reg1_i < reg2_i)? 1'b1 : 1'b0;
                    else
                        wdata_o = (reg1_i > reg2_i)? 1'b1 : 1'b0;
                end
                `OP_SLTU, `OP_SLTIU : wdata_o = (reg1_i < reg2_i)? 1'b1 : 1'b0;
                `OP_CLZ  : begin
                    wdata_o = reg1_i[31] ? 0 :
                             (reg1_i[30] ? 1 : 
                             (reg1_i[29] ? 2 : 
                             (reg1_i[28] ? 3 :
                             (reg1_i[27] ? 4 :
                             (reg1_i[26] ? 5 :
                             (reg1_i[25] ? 6 :
                             (reg1_i[24] ? 7 :
                             (reg1_i[23] ? 8 :
                             (reg1_i[22] ? 9 :
                             (reg1_i[21] ? 10 :
                             (reg1_i[20] ? 11 :
                             (reg1_i[19] ? 12 :
                             (reg1_i[18] ? 13 :
                             (reg1_i[17] ? 14 :
                             (reg1_i[16] ? 15 :
                             (reg1_i[15] ? 16 :
                             (reg1_i[14] ? 17 :
                             (reg1_i[13] ? 18 :
                             (reg1_i[12] ? 19 :
                             (reg1_i[11] ? 20 :
                             (reg1_i[10] ? 21 :
                             (reg1_i[9]  ? 22 :
                             (reg1_i[8]  ? 23 :
                             (reg1_i[7]  ? 24 :
                             (reg1_i[6]  ? 25 :
                             (reg1_i[5]  ? 26 :
                             (reg1_i[4]  ? 27 :
                             (reg1_i[3]  ? 28 :
                             (reg1_i[2]  ? 29 :
                             (reg1_i[1]  ? 30 :
                             (reg1_i[0] ? 31 : 32
                              )))))))))))))))))))))))))))))));
                end
                `OP_CLO :  begin
                    wdata_o = ~reg1_i[31] ? 0 :
                             (~reg1_i[30] ? 1 : 
                             (~reg1_i[29] ? 2 : 
                             (~reg1_i[28] ? 3 :
                             (~reg1_i[27] ? 4 :
                             (~reg1_i[26] ? 5 :
                             (~reg1_i[25] ? 6 :
                             (~reg1_i[24] ? 7 :
                             (~reg1_i[23] ? 8 :
                             (~reg1_i[22] ? 9 :
                             (~reg1_i[21] ? 10 :
                             (~reg1_i[20] ? 11 :
                             (~reg1_i[19] ? 12 :
                             (~reg1_i[18] ? 13 :
                             (~reg1_i[17] ? 14 :
                             (~reg1_i[16] ? 15 :
                             (~reg1_i[15] ? 16 :
                             (~reg1_i[14] ? 17 :
                             (~reg1_i[13] ? 18 :
                             (~reg1_i[12] ? 19 :
                             (~reg1_i[11] ? 20 :
                             (~reg1_i[10] ? 21 :
                             (~reg1_i[9]  ? 22 :
                             (~reg1_i[8]  ? 23 :
                             (~reg1_i[7]  ? 24 :
                             (~reg1_i[6]  ? 25 :
                             (~reg1_i[5]  ? 26 :
                             (~reg1_i[4]  ? 27 :
                             (~reg1_i[3]  ? 28 :
                             (~reg1_i[2]  ? 29 :
                             (~reg1_i[1]  ? 30 :
                             (~reg1_i[0]  ? 31 : 32
                              )))))))))))))))))))))))))))))));
                end
                `OP_MULTU : begin
		    if (finish_mul_i) begin
			stall_req_ex = 1'b0;
			start_mul_o = 1'b0;
			hilo_ex_en = 1'b1;
			{hi_ex_o, lo_ex_o} = mul_result_i;
		    end
		    else begin
			stall_req_ex = 1'b1;
			start_mul_o = 1'b1;
		    end
                end
                `OP_MUL   : begin
		    if (finish_mul_i) begin
			wdata_o = mul_result_i;
			start_mul_o = 1'b0;
			stall_req_ex = 1'b0;
		    end
		    else begin
			stall_req_ex = 1'b1;
			start_mul_o = 1'b1;
			if (reg1_i[31] && !reg2_i[31]) begin
			    mul_reg1_o = reg1_i_b;
			    mul_sign_diff_o = 1'b1;
		        end
			else if (!reg1_i[31] && reg2_i[31]) begin
			    mul_reg2_o = reg2_i_b;
			    mul_sign_diff_o = 1'b1;
		        end
			else if (reg1_i[31] && reg2_i[31]) begin
			    mul_reg1_o = reg1_i_b;
			    mul_reg2_o = reg2_i_b;
		        end
		    end
                end
                `OP_MULT : begin
		    if (finish_mul_i) begin
			hilo_ex_en = 1'b1;
			{hi_ex_o, lo_ex_o} = mul_result_i;
			start_mul_o = 1'b0;
			stall_req_ex = 1'b0;
		    end
		    else begin
			stall_req_ex = 1'b1;
			start_mul_o = 1'b1;
			if (reg1_i[31] && !reg2_i[31]) begin
			    mul_reg1_o = reg1_i_b;
			    mul_sign_diff_o = 1'b1;
		        end
			else if (!reg1_i[31] && reg2_i[31]) begin
			    mul_reg2_o = reg2_i_b;
			    mul_sign_diff_o = 1'b1;
		        end
			else if (reg1_i[31] && reg2_i[31]) begin
			    mul_reg1_o = reg1_i_b;
			    mul_reg2_o = reg2_i_b;
		        end
		    end
                end
                `OP_MADD : begin
                    if (!hilo_temp_ack && !finish_mul_i) begin
			stall_req_ex = 1'b1;
			hilo_temp_req = 1'b0;
			start_mul_o = 1'b1;
			if (reg1_i[31] && !reg2_i[31]) begin
                            mul_reg1_o = reg1_i_b;
			    mul_sign_diff_o = 1'b1;
		        end
			else if (!reg1_i[31] && reg2_i[31]) begin
                            mul_reg2_o = reg2_i_b;
			    mul_sign_diff_o = 1'b1;
			end
			else if (reg1_i[31] && reg2_i[31]) begin
			    mul_reg1_o = reg1_i_b;
			    mul_reg2_o = reg2_i_b;
			end
		    end
		    else if (!hilo_temp_ack && finish_mul_i) begin
                        hilo_temp_o = mul_result_i;
			stall_req_ex = 1'b1;
			hilo_temp_req = 1'b1;
			start_mul_o = 1'b0;
                    end
		    else if (hilo_temp_ack) begin
                        hilo_temp_req = 1'b0;
                        stall_req_ex = 1'b0;
                        hilo_ex_en = 1'b1;
                        {hi_ex_o, lo_ex_o} = {hi_ex_o, lo_ex_o} + hilo_temp_i;
                    end
                end
                `OP_MADDU : begin
                    if (!hilo_temp_ack && !finish_mul_i) begin
			stall_req_ex = 1'b1;
			hilo_temp_req = 1'b0;
			start_mul_o = 1'b1;
		    end
		    else if (!hilo_temp_ack && finish_mul_i) begin
                        hilo_temp_o = mul_result_i;
			stall_req_ex = 1'b1;
			hilo_temp_req = 1'b1;
                    end
		    else if (hilo_temp_ack) begin
                        hilo_temp_req = 1'b0;
                        stall_req_ex = 1'b0;
                        hilo_ex_en = 1'b1;
                        {hi_ex_o, lo_ex_o} = {hi_ex_o, lo_ex_o} + hilo_temp_i;
		    end
                end
                `OP_MSUB : begin
		    if (!hilo_temp_ack && !finish_mul_i) begin
			stall_req_ex = 1'b1;
			hilo_temp_req = 1'b0;
			start_mul_o = 1'b1;
			if (reg1_i[31] && !reg2_i[31]) begin
                            mul_reg1_o = reg1_i_b;
			    mul_sign_diff_o = 1'b1;
		        end
			else if (!reg1_i[31] && reg2_i[31]) begin
                            mul_reg2_o = reg2_i_b;
			    mul_sign_diff_o = 1'b1;
			end
			else if (reg1_i[31] && reg2_i[31]) begin
			    mul_reg1_o = reg1_i_b;
			    mul_reg2_o = reg2_i_b;
			end
		    end
		    else if (!hilo_temp_ack && finish_mul_i) begin
                        hilo_temp_o = mul_result_i;
			stall_req_ex = 1'b1;
			hilo_temp_req = 1'b1;
		    end
                    else if (hilo_temp_ack) begin
                        hilo_temp_req = 1'b0;
                        stall_req_ex = 1'b0;
                        hilo_ex_en = 1'b1;
                        {hi_ex_o, lo_ex_o} = {hi_ex_o, lo_ex_o} + hilo_temp_i_b;
                    end
                end
                `OP_MSUBU : begin
		    if (!hilo_temp_ack && !finish_mul_i) begin
			stall_req_ex = 1'b1;
			hilo_temp_req = 1'b0;
			start_mul_o = 1'b1;
		    end
		    else if (!hilo_temp_ack && finish_mul_i) begin
                        hilo_temp_o = mul_result_i;
			stall_req_ex = 1'b1;
			hilo_temp_req = 1'b1;
                    end
                    else if (hilo_temp_ack) begin
                        hilo_temp_req = 1'b0;
                        stall_req_ex = 1'b0;
                        hilo_ex_en = 1'b1;
                        {hi_ex_o, lo_ex_o} = {hi_ex_o, lo_ex_o} + hilo_temp_i_b;
                    end
                end
                `OP_DIV : begin
                    if (finish_div_i) begin
                        start_div_o = 1'b0;
			stall_req_ex = 1'b0;
			hilo_ex_en = 1'b1;
			{hi_ex_o, lo_ex_o} = {remainder_i, quotient_i};
                    end
		    else begin
			start_div_o = 1'b1;
			stall_req_ex = 1'b1;
			if_signed_o = 1'b1;
		    end
                end
		`OP_DIVU : begin
                    if (finish_div_i) begin
                        start_div_o = 1'b0;
			stall_req_ex = 1'b0;
			hilo_ex_en = 1'b1;
			{hi_ex_o, lo_ex_o} = {remainder_i, quotient_i};
                    end
		    else begin
			start_div_o = 1'b1;
			stall_req_ex = 1'b1;
			if_signed_o = 1'b0;
		    end
                end
            endcase
        end
	else if (alusel_i == `SEL_JUMP_BRANCH) begin
	    case (aluop_i)
		`OP_JALR, `OP_JAL, `OP_BLTZAL, `OP_BGTZ : begin
		    wdata_o = link_address;
		end
	    endcase
	end
	else if (alusel_i == `SEL_LOAD_STORE) begin
	    aluop_o = aluop_i;
	    alusel_o = alusel_i;
	    mem_addr_o = {{16{inst_ex[15]}}, inst_ex[15:0]} + reg1_i;
	    reg_store_o = reg2_i;
	end
	else if (alusel_i == `SEL_EXCEPTION) begin
	    case (aluop_i)
		`OP_TEQ, `OP_TEQI : begin
		    if (reg1_i == reg2_i)
			trap = 1'b1;
		end
		`OP_TGE, `OP_TGEI : begin
		    if (!rs_rt_diff_signed[32] && (|rs_rt_diff_signed))
			trap = 1'b1;
		end
		`OP_TGEU, `OP_TGEIU : begin
		    if (!rs_rt_diff_unsign[32] && (|rs_rt_diff_unsign))
			trap = 1'b1;
		end
		`OP_TLT, `OP_TLTI : begin
		    if (rs_rt_diff_signed[32])
			trap = 1'b1;
		end
		`OP_TLTU, `OP_TLTIU : begin
		    if (rs_rt_diff_unsign[32])
			trap = 1'b1;
		end
		`OP_TNE, `OP_TNEI : begin
		    if (reg1_i != reg2_i)
			trap = 1'b1;
		end
	    endcase
	end
    end
end

endmodule
