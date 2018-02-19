/***************************************
 ********** Andy You Property **********
 ***************************************/


module ID    (rst,
              pc_i,
              inst_i,
              reg1_data_i,
              reg2_data_i,
              reg1_read_o,
              reg2_read_o,
              reg1_addr_o,
              reg2_addr_o,
              aluop_o,
              alusel_o,
              reg1_o,
              reg2_o,
              wd_o,
              wreg_o,
              stall_req_id,
              branch_flag_o,
              branch_target_address_o,
              is_in_delayslot_i,
              is_in_delayslot_o,
              link_address_o,
              next_inst_in_delayslot_o,
              inst_o,
              ex_wreg,
              ex_addr,
              ex_alusel,
              mem_wreg,
              mem_addr,
              mem_wdata,
      	      excepttype_o,
      	      current_inst_addr_o);

input  rst;
input  [31:0] pc_i, inst_i, reg1_data_i, reg2_data_i;
input  is_in_delayslot_i;
input  ex_wreg, mem_wreg;
input  [4:0] ex_addr, mem_addr;
input  [31:0] mem_wdata;
input  [2:0] ex_alusel;

output reg reg1_read_o, reg2_read_o;
output reg [4:0]  reg1_addr_o, reg2_addr_o;
output reg [31:0] reg1_o, reg2_o;
output reg [7:0]  aluop_o;
output reg [2:0]  alusel_o;
output reg [4:0]  wd_o;
output reg wreg_o;
output reg stall_req_id;
output reg [31:0] inst_o;
output reg branch_flag_o, is_in_delayslot_o, next_inst_in_delayslot_o;
output reg [31:0] branch_target_address_o, link_address_o;
output wire [31:0] excepttype_o, current_inst_addr_o;

wire [5:0] op  = inst_i[31:26];
wire [4:0] op2 = inst_i[10:6];
wire [5:0] op3 = inst_i[5:0];
wire [4:0] op4 = inst_i[20:16];
wire [4:0] op5 = inst_i[25:21];

wire [31:0] pc_4, pc_8;

assign pc_4 = pc_i + 32'd4;
assign pc_8 = pc_i + 32'd8;

wire [17:0] branch_offset_extend;
wire [31:0] jump_new_address;

assign branch_offset_extend = {{14{inst_i[15]}}, inst_i[15:0], 2'b00};
assign jump_new_address = {pc_4[31:28], inst_i[25:0], 2'b00};
//assign jump_new_address = {6'b000000, inst_i[25:0]};

reg  is_eret, is_syscall;
wire is_invalid;

assign current_inst_addr_o = pc_i;
assign is_invalid = (aluop_o == `OP_INVALID) ? 1 : 0;
assign excepttype_o = {19'b0, is_eret, 2'b00, is_invalid, is_syscall, 8'h00};

always @(*) begin
    if (rst)
        aluop_o = `OP_NONE;
    else begin
        aluop_o = `OP_NONE;
        case (op)
            `EXE_SPECIAL_INST : begin
                case (op2) 
                    0 : begin
                        case (op3) 
                            `EXE_OR    : aluop_o = `OP_OR;
                            `EXE_AND   : aluop_o = `OP_AND;
                            `EXE_XOR   : aluop_o = `OP_XOR;
                            `EXE_NOR   : aluop_o = `OP_NOR;
                            `EXE_SLLV  : aluop_o = `OP_SLLV;
                            `EXE_SRLV  : aluop_o = `OP_SRLV;
                            `EXE_SRAV  : aluop_o = `OP_SRAV;
                            `EXE_SYNC  : aluop_o = `OP_NONE;
                            `EXE_MOVN  : aluop_o = `OP_MOVN;
                            `EXE_MOVZ  : aluop_o = `OP_MOVZ;
                            `EXE_MTHI  : aluop_o = `OP_MTHI;
                            `EXE_MTLO  : aluop_o = `OP_MTLO;
                            `EXE_ADD   : aluop_o = `OP_ADD;
                            `EXE_ADDU  : aluop_o = `OP_ADDU;
                            `EXE_SUB   : aluop_o = `OP_SUB;
                            `EXE_SUBU  : aluop_o = `OP_SUBU;
                            `EXE_SLT   : aluop_o = `OP_SLT;
                            `EXE_SLTU  : aluop_o = `OP_SLTU;
                            `EXE_MULT  : aluop_o = `OP_MULT;
                            `EXE_MULTU : aluop_o = `OP_MULTU;
                            `EXE_DIV   : aluop_o = `OP_DIV;
                            `EXE_DIVU  : aluop_o = `OP_DIVU;
                            `EXE_JR    : aluop_o = `OP_JR;
                            `EXE_JALR  : aluop_o = `OP_JALR;
                        endcase
                    end
                endcase
		case (op3)
		    `EXE_TEQ  : aluop_o = `OP_TEQ;
		    `EXE_TGE  : aluop_o = `OP_TGE;
		    `EXE_TGEU : aluop_o = `OP_TGEU;
		    `EXE_TLT  : aluop_o = `OP_TLT;
		    `EXE_TLTU : aluop_o = `OP_TLTU;
		    `EXE_TNE  : aluop_o = `OP_TNE;
		    `EXE_SYS  : aluop_o = `OP_SYS;
		endcase
            end
            `EXE_SPECIAL2_INST : begin
                case (op3) 
                    `EXE_CLZ   : aluop_o = `OP_CLZ;
                    `EXE_CLO   : aluop_o = `OP_CLO;
                    `EXE_MUL   : aluop_o = `OP_MUL;
                    `EXE_MADD  : aluop_o = `OP_MADD;
                    `EXE_MADDU : aluop_o = `OP_MADDU;
                    `EXE_MSUB  : aluop_o = `OP_MSUB;
                    `EXE_MSUBU : aluop_o = `OP_MSUBU;
                endcase
            end
            `EXE_REGIMM_INST : begin
                case (op4) 
                    `EXE_BLTZ   : aluop_o = `OP_BLTZ;
                    `EXE_BLTZAL : aluop_o = `OP_BLTZAL;
                    `EXE_BGEZ   : aluop_o = `OP_BGEZ;
                    `EXE_BGEZAL : aluop_o = `OP_BGEZAL;
		    `EXE_TEQI   : aluop_o = `OP_TEQI;
		    `EXE_TGEI   : aluop_o = `OP_TGEI;
		    `EXE_TGEIU  : aluop_o = `OP_TGEIU;
		    `EXE_TLTI   : aluop_o = `OP_TLTI;
		    `EXE_TLTIU  : aluop_o = `OP_TLTIU;
		    `EXE_TNEI   : aluop_o = `OP_TNEI;
                endcase
            end
	    `EXE_CP0MOVE : begin
		case (op5)
		    `EXE_MTC0 : aluop_o = `OP_MTC0;
		    `EXE_MFC0 : aluop_o = `OP_MFC0;
	        endcase
		if (op3 == `EXE_ERET)
		    aluop_o = `OP_ERET;
	    end
            `EXE_ORI   : aluop_o = `OP_ORI;
            `EXE_ANDI  : aluop_o = `OP_ANDI;
            `EXE_XORI  : aluop_o = `OP_XORI;
            `EXE_LUI   : aluop_o = `OP_LUI;
            `EXE_PREF  : aluop_o = `OP_NONE;
            `EXE_ADDI  : aluop_o = `OP_ADDI;
            `EXE_ADDIU : aluop_o = `OP_ADDIU;
            `EXE_SLTI  : aluop_o = `OP_SLTI;
            `EXE_SLTIU : aluop_o = `OP_SLTIU;
            `EXE_J     : aluop_o = `OP_J;
            `EXE_JAL   : aluop_o = `OP_JAL;
            `EXE_BEQ   : aluop_o = `OP_BEQ;
            `EXE_BGTZ  : aluop_o = `OP_BGTZ;
            `EXE_BLEZ  : aluop_o = `OP_BLEZ;
            `EXE_BNE   : aluop_o = `OP_BNE;
            `EXE_LB    : aluop_o = `OP_LB;
            `EXE_LBU   : aluop_o = `OP_LBU;
            `EXE_LH    : aluop_o = `OP_LH;
            `EXE_LHU   : aluop_o = `OP_LHU;
            `EXE_LW    : aluop_o = `OP_LW;
            `EXE_SB    : aluop_o = `OP_SB;
            `EXE_SH    : aluop_o = `OP_SH;
            `EXE_SW    : aluop_o = `OP_SW;
            `EXE_LWL   : aluop_o = `OP_LWL;
            `EXE_LWR   : aluop_o = `OP_LWR;
            `EXE_SWL   : aluop_o = `OP_SWL;
            `EXE_SWR   : aluop_o = `OP_SWR;
        endcase
        if (inst_i[31:21] == 11'b0) begin
            case (op3) 
                `EXE_SLL  : aluop_o = `OP_SLL;
                `EXE_SRL  : aluop_o = `OP_SRL;
                `EXE_SRA  : aluop_o = `OP_SRA;
                `EXE_MFHI : aluop_o = `OP_MFHI;
                `EXE_MFLO : aluop_o = `OP_MFLO;
            endcase
        end
	if (inst_i == 32'b0) begin
	    aluop_o = `OP_NONE;
	end
    end
end

always @(*)
begin
    if (rst) begin
        reg1_read_o = 1'b0;
        reg2_read_o = 1'b0;
        reg1_addr_o = 5'h0;
        reg2_addr_o = 5'h0;
        reg1_o = 32'h0;
        reg2_o = 32'h0;
        alusel_o = `SEL_NONE;
        wd_o = 5'b0;
        wreg_o = 1'b0;
        stall_req_id = 1'b0;
        branch_flag_o = 1'b0;
        is_in_delayslot_o =1'b0;
        next_inst_in_delayslot_o = 1'b0;
        branch_flag_o = 32'b0;
        link_address_o = 32'b0;
        inst_o = 32'h0;
	is_syscall = 1'b0;
	is_eret = 1'b0;
    end
    else begin
        alusel_o = `SEL_NONE;
        reg1_addr_o = inst_i[25:21];
        reg2_addr_o = inst_i[20:16];
        wd_o = inst_i[15:11];
        wreg_o = 1'b1;
        reg1_o = reg1_data_i;
        reg2_o = reg2_data_i;
        reg1_read_o = 1'b1;
        reg2_read_o = 1'b1;
        stall_req_id = 1'b0;
        branch_flag_o = 1'b0;
        is_in_delayslot_o = is_in_delayslot_i;
        next_inst_in_delayslot_o = 1'b0;
        branch_flag_o = 32'b0;
        link_address_o = 32'b0;
        inst_o = 32'h0;
	is_syscall = 1'b0;
	is_eret = 1'b0;
        // Choose Operation
        case (aluop_o)
            `OP_ORI : begin
                reg2_o = {16'h0, inst_i[15:0]};
                wd_o = inst_i[20:16];
                reg2_read_o = 1'b0;
                alusel_o = `SEL_LOGIC;
            end
            `OP_ANDI : begin
                reg2_o = {16'h0, inst_i[15:0]};
                wd_o = inst_i[20:16];
                reg2_read_o = 1'b0;
                alusel_o = `SEL_LOGIC;
            end
            `OP_XORI : begin
                reg2_o = {16'h0, inst_i[15:0]};
                wd_o = inst_i[20:16];
                reg2_read_o = 1'b0;
                alusel_o = `SEL_LOGIC;
            end
            `OP_OR : begin
                alusel_o = `SEL_LOGIC;
            end
            `OP_AND : begin
                alusel_o = `SEL_LOGIC;
            end
            `OP_XOR : begin
                alusel_o = `SEL_LOGIC;
            end
            `OP_NOR : begin
                alusel_o = `SEL_LOGIC;
            end
            `OP_SLLV : begin
                alusel_o = `SEL_SHIFT;
            end
            `OP_SRLV : begin
                alusel_o = `SEL_SHIFT;
            end
            `OP_SRAV : begin
                alusel_o = `SEL_SHIFT;
            end
            `OP_LUI : begin
                reg1_o = {inst_i[15:0], 16'h0};
                reg1_read_o = 1'b0;
                reg2_read_o = 1'b0;
                wd_o = inst_i[20:16];
                alusel_o = `SEL_LOGIC;
            end
            `OP_SLL : begin
                reg1_o = inst_i[10:6];
                reg1_read_o = 1'b0;
                alusel_o = `SEL_SHIFT;
            end
            `OP_SRL : begin
                reg1_o = inst_i[10:6];
                reg1_read_o = 1'b0;
                alusel_o = `SEL_SHIFT;
            end
            `OP_SRA : begin
                reg1_o = inst_i[10:6];
                reg1_read_o = 1'b0;
                alusel_o = `SEL_SHIFT;
            end
            `OP_MOVN : begin
                alusel_o = `SEL_MOVE;
            end
            `OP_MOVZ : begin
                alusel_o = `SEL_MOVE;
            end
            `OP_MFHI : begin
                reg1_read_o = 1'b0;
                reg2_read_o = 1'b0;
                alusel_o = `SEL_MOVE;
            end
            `OP_MFLO : begin
                reg1_read_o = 1'b0;
                reg2_read_o = 1'b0;
                alusel_o = `SEL_MOVE;
            end
            `OP_MTHI : begin
                wreg_o = 1'b0;
                wd_o = 5'b0;
                reg2_read_o = 1'b0;
                alusel_o = `SEL_MOVE;
            end
            `OP_MTLO : begin
                wreg_o = 1'b0;
                wd_o = 5'b0;
                reg2_read_o = 1'b0;
                alusel_o = `SEL_MOVE;
            end
            `OP_ADD : begin
                alusel_o = `SEL_ARITHMETIC;
            end
            `OP_ADDU : begin
                alusel_o = `SEL_ARITHMETIC;
            end
            `OP_SUB : begin
                alusel_o = `SEL_ARITHMETIC;
            end
            `OP_SUBU : begin
                alusel_o = `SEL_ARITHMETIC;
            end
            `OP_SLT : begin
                alusel_o = `SEL_ARITHMETIC;
            end
            `OP_SLTU : begin
                alusel_o = `SEL_ARITHMETIC;
            end
            `OP_ADDI : begin
                reg2_o = {{16{inst_i[15]}}, inst_i[15:0]};
                wd_o = inst_i[20:16];
                reg2_read_o = 1'b0;
                alusel_o = `SEL_ARITHMETIC;
            end
            `OP_ADDIU : begin
                reg2_o = {{16{inst_i[15]}}, inst_i[15:0]};
                wd_o = inst_i[20:16];
                reg2_read_o = 1'b0;
                alusel_o = `SEL_ARITHMETIC;
            end
            `OP_SLTI : begin
                reg2_o = {{16{inst_i[15]}}, inst_i[15:0]};
                wd_o = inst_i[20:16];
                reg2_read_o = 1'b0;
                alusel_o = `SEL_ARITHMETIC;
            end
            `OP_SLTIU : begin
                reg2_o = {{16{inst_i[15]}}, inst_i[15:0]};
                wd_o = inst_i[20:16];
                reg2_read_o = 1'b0;
                alusel_o = `SEL_ARITHMETIC;
            end
            `OP_CLZ : begin
                reg2_read_o = 1'b0;
                alusel_o = `SEL_ARITHMETIC;
            end
            `OP_CLO : begin
                reg2_read_o = 1'b0;
                alusel_o = `SEL_ARITHMETIC;
            end
            `OP_MUL : begin
                alusel_o = `SEL_ARITHMETIC;
            end
            `OP_MULT : begin
                wreg_o = 1'b0;
                wd_o = 5'b0;
                alusel_o = `SEL_ARITHMETIC;
            end
            `OP_MULTU : begin
                wreg_o = 1'b0;
                wd_o = 5'b0;
                alusel_o = `SEL_ARITHMETIC;
            end
            `OP_MADD : begin
                wreg_o = 1'b0;
                wd_o = 5'b0;
                alusel_o = `SEL_ARITHMETIC;
            end
            `OP_MSUB : begin
                wreg_o = 1'b0;
                wd_o = 5'b0;
                alusel_o = `SEL_ARITHMETIC;
            end
            `OP_MADDU : begin
                wreg_o = 1'b0;
                wd_o = 5'b0;
                alusel_o = `SEL_ARITHMETIC;
            end
            `OP_MSUBU : begin
                wreg_o = 1'b0;
                wd_o = 5'b0;
                alusel_o = `SEL_ARITHMETIC;
            end
            `OP_DIV, `OP_DIVU : begin
                wreg_o = 1'b0;
                wd_o = 5'b0;
                alusel_o = `SEL_ARITHMETIC;
            end
            `OP_JR : begin
                reg2_read_o = 1'b0;
                alusel_o = `SEL_JUMP_BRANCH;
                wreg_o = 1'b0;
                wd_o = 5'b0;
                branch_flag_o = 1'b1;
                next_inst_in_delayslot_o = 1'b1;
                branch_target_address_o = reg1_data_i;
            end
            `OP_JALR : begin
                reg2_read_o = 1'b0;
                alusel_o = `SEL_JUMP_BRANCH;
                wd_o = (|(inst_i[15:11]))? inst_i[15:11] : 5'b11111;
                link_address_o = pc_8;
                branch_flag_o = 1'b1;
                next_inst_in_delayslot_o = 1'b1;
                branch_target_address_o = reg1_data_i;
            end
            `OP_J : begin
                reg1_read_o = 1'b0;
                reg2_read_o = 1'b0;
                wreg_o = 1'b0;
                wd_o = 5'b0;
                alusel_o = `SEL_JUMP_BRANCH;
                branch_flag_o = 1'b1;
                next_inst_in_delayslot_o = 1'b1;
                branch_target_address_o = jump_new_address;
            end
            `OP_JAL : begin
                reg1_read_o = 1'b0;
                reg2_read_o = 1'b0;
                wd_o = (|(inst_i[15:11]))? inst_i[15:11] : 5'b11111;
                alusel_o = `SEL_JUMP_BRANCH;
                link_address_o = pc_8;
                branch_flag_o = 1'b1;
                next_inst_in_delayslot_o = 1'b1;
                branch_target_address_o = jump_new_address;
            end
            `OP_BEQ : begin
                wreg_o = 1'b0;
                wd_o = 5'b0;
                alusel_o = `SEL_JUMP_BRANCH;
                if (reg1_data_i == reg2_data_i) begin
                    branch_flag_o = 1'b1;
                    next_inst_in_delayslot_o = 1'b1;
                    branch_target_address_o = branch_offset_extend + pc_4;
                end
            end
            `OP_BGTZ : begin
                reg2_read_o = 1'b0;
                wreg_o = 1'b0;
                wd_o = 5'b0;
                alusel_o = `SEL_JUMP_BRANCH;
                if (reg1_data_i[31] == 1'b0 && (|reg1_data_i) == 1'b1) begin
                    branch_flag_o = 1'b1;
                    next_inst_in_delayslot_o = 1'b1;
                    branch_target_address_o = branch_offset_extend + pc_4;
                end
            end
            `OP_BLEZ : begin
                reg2_read_o = 1'b0;
                wreg_o = 1'b0;
                wd_o = 5'b0;
                alusel_o = `SEL_JUMP_BRANCH;
                if (reg1_data_i[31] == 1'b1 || (|reg1_data_i) == 1'b0) begin
                    branch_flag_o = 1'b1;
                    next_inst_in_delayslot_o = 1'b1;
                    branch_target_address_o = branch_offset_extend + pc_4;
                end
            end
            `OP_BNE : begin
                wreg_o = 1'b0;
                wd_o = 5'b0;
                alusel_o = `SEL_JUMP_BRANCH;
                if (reg1_data_i != reg2_data_i) begin
                    branch_flag_o = 1'b1;
                    next_inst_in_delayslot_o = 1'b1;
                    branch_target_address_o = branch_offset_extend + pc_4;
                end
            end
            `OP_BLTZ : begin
                reg2_read_o = 1'b0;
                wreg_o = 1'b0;
                wd_o = 5'b0;
                alusel_o = `SEL_JUMP_BRANCH;
                if (reg1_data_i[31] == 1'b1) begin
                    branch_flag_o = 1'b1;
                    next_inst_in_delayslot_o = 1'b1;
                    branch_target_address_o = branch_offset_extend + pc_4;
                end
            end
            `OP_BLTZAL : begin
                reg2_read_o = 1'b0;
                alusel_o = `SEL_JUMP_BRANCH;
                wreg_o = 1'b0;
                wd_o = 5'b0;
                if (reg1_data_i[31] == 1'b1) begin
                    wreg_o = 1'b1;
                    link_address_o = pc_8;
                    wd_o = 5'b11111;
                    branch_flag_o = 1'b1;
                    next_inst_in_delayslot_o = 1'b1;
                    branch_target_address_o = branch_offset_extend + pc_4;
                end
            end
            `OP_BGEZ : begin
                reg2_read_o = 1'b0;
                wreg_o = 1'b0;
                wd_o = 5'b0;
                alusel_o = `SEL_JUMP_BRANCH;
                if (reg1_data_i[31] == 1'b0) begin
                    branch_flag_o = 1'b1;
                    next_inst_in_delayslot_o = 1'b1;
                    branch_target_address_o = branch_offset_extend + pc_4;
                end
            end
            `OP_BGEZAL : begin
                reg2_read_o = 1'b0;
                wreg_o = 1'b0;
                wd_o = 5'b0;
                alusel_o = `SEL_JUMP_BRANCH;
                if (reg1_data_i[31] == 1'b0) begin
                    wreg_o = 1'b1;
                    link_address_o = pc_8;
                    wd_o = 5'b11111;
                    branch_flag_o = 1'b1;
                    next_inst_in_delayslot_o = 1'b1;
                    branch_target_address_o = branch_offset_extend + pc_4;
                end
            end
            `OP_LB, `OP_LBU, `OP_LH, `OP_LHU, `OP_LW : begin
                wd_o = inst_i[20:16];
                inst_o = inst_i;
                reg2_read_o = 1'b0;
                alusel_o = `SEL_LOAD_STORE;
            end
            `OP_LWL, `OP_LWR : begin
                wd_o = inst_i[20:16];
                inst_o = inst_i;
                alusel_o = `SEL_LOAD_STORE;
            end
            `OP_SB, `OP_SH, `OP_SW, `OP_SWL, `OP_SWR : begin
                wreg_o = 1'b0;
                wd_o = 5'b0;
                inst_o = inst_i;
                alusel_o = `SEL_LOAD_STORE;
            end
	    `OP_MTC0 : begin
		wreg_o = 1'b0;
		reg1_read_o = 1'b0;
		inst_o = inst_i;
		alusel_o = `SEL_MOVE;
	    end
	    `OP_MFC0 : begin
		wd_o = inst_i[20:16];
		reg1_read_o = 1'b0;
		reg2_read_o = 1'b0;
		inst_o = inst_i;
		alusel_o = `SEL_MOVE;
	    end
	    `OP_TEQ, `OP_TGE, `OP_TGEU, `OP_TLT, `OP_TLTU, `OP_TNE : begin
		wreg_o = 1'b0;
		wd_o = 5'b0;
		alusel_o = `SEL_EXCEPTION;
	    end
	    `OP_TEQI, `OP_TGEI, `OP_TGEIU, `OP_TLTI, `OP_TLTIU, `OP_TNEI : begin
		reg2_read_o = 1'b0;
		wreg_o = 1'b0;
		wd_o = 5'b0;
		reg2_o = {{16{inst_i[15]}}, inst_i[15:0]};
		alusel_o = `SEL_EXCEPTION;
	    end
	    `OP_SYS : begin
		is_syscall = 1'b1;
		reg1_read_o = 1'b0;
		reg2_read_o = 1'b0;
		alusel_o = `SEL_EXCEPTION;
		wreg_o = 1'b0;
		wd_o = 5'b0;
	    end
	    `OP_ERET : begin
		is_eret = 1'b1;
		reg1_read_o = 1'b0;
		reg2_read_o = 1'b0;
		alusel_o = `SEL_EXCEPTION;
		wreg_o = 1'b0;
		wd_o = 5'b0;
	    end
            default : begin
                reg1_read_o = 1'b0;
                reg2_read_o = 1'b0;
                reg1_o = 32'h0;
                reg2_o = 32'h0;
                alusel_o = `SEL_NONE;
                wd_o = 5'b0;
                wreg_o = 1'b0;
            end            
        endcase
        //bypass from MEM.v
        if (reg1_read_o && reg1_addr_o == ex_addr && ex_wreg && ex_alusel == `SEL_LOAD_STORE)
            stall_req_id = 1'b1;
        if (reg2_read_o && reg2_addr_o == ex_addr && ex_wreg && ex_alusel == `SEL_LOAD_STORE)
            stall_req_id = 1'b1;
        if (reg1_read_o && reg1_addr_o == mem_addr && mem_wreg) begin
            stall_req_id = 1'b0;
	    reg1_o = mem_wdata;
        end
	if (reg2_read_o && reg2_addr_o == mem_addr && mem_wreg) begin
            stall_req_id = 1'b0;
	    reg2_o = mem_wdata;
        end
            
    end
end

endmodule
