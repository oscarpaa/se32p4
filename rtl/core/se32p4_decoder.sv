
module se32p4_decoder
    import se32p4_pkg::*;
(
    input logic [31:0] instr_i,

    output logic [31:0] immediate_o,
    
    output logic is_reg_shift_o,
    output sel_lsu_t sel_load_store_o,
    output logic sel_read_dat1_addr_o,
    output logic sel_alu_immed_oper_b_o,
    output sel_wreg_t sel_reg_write_o,
    
    output sel_pc_t is_jump_o,
    output branch_t is_branch_o,
    
    output logic [4:0] reg_read_addr1_o, reg_read_addr2_o, reg_write_addr3_o,
    
    output aluop_t alu_oper_o,
    output logic alu_sign_o,
    output logic lsu_sign_o,
    
    output csrop_t csr_oper_o,
    output logic csr_write_en_o,
    
    output logic reg_write_en_o,
    output mem_rw_en_t memory_en_o
);

    logic [6:0] op_inst32 = instr_i[6:0];
    logic [6:0] f7_inst32 = instr_i[31:25];
    logic [2:0] f3_inst32 = instr_i[14:12];

    csrop_t csr_oper;
    sel_wreg_t sel_reg_write;

    assign is_reg_shift_o = ((op_inst32 == OP_ALUR) &&
                            ((f3_inst32 == F3_SLL) ||
                             (f3_inst32 == F3_SRL_SRA))) ? 1'b1 : 1'b0;

    always_comb begin : immediate_generator
        unique case (op_inst32)
            OP_ALUI:
                unique case (f3_inst32)
                    F3_SLL, F3_SRL_SRA: immediate_o <= {27'b0, instr_i[24:20]};
                    default:            immediate_o <= {{20{instr_i[31]}}, instr_i[31:20]};
                endcase
            OP_LOAD, OP_JALR, OP_PRIVILEGED: 
                immediate_o <= {{20{instr_i[31]}}, instr_i[31:20]};
            OP_STORE:
                immediate_o <= {{20{instr_i[31]}}, instr_i[31:25], instr_i[11:7]};
            OP_BRANCH:
                immediate_o <= {{20{instr_i[31]}}, instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0};
            OP_JAL:
                immediate_o <= {{20{instr_i[31]}}, instr_i[19:12], instr_i[20], instr_i[30:21], 1'b0};
            OP_AUIPC, OP_LUI:
                immediate_o <= {instr_i[31:12], 12'b0};
            default: 
                immediate_o <= 32'b0;
        endcase
    end
    
    assign reg_read_addr1_o  = instr_i[19:15]; 
    assign reg_read_addr2_o  = instr_i[24:20];
    assign reg_write_addr3_o = instr_i[11:7];
    
    always_comb begin : aluop_decoder
        unique case (op_inst32)
            OP_LOAD, OP_STORE: alu_oper_o <= ALUOP_ADD;
            OP_ALUI, OP_ALUR:
                unique case (f3_inst32)
                    F3_SUB_ADD: begin
                        if (op_inst32 == OP_ALUI) begin
                            alu_oper_o <= ALUOP_ADD;
                        end else if (op_inst32 == OP_ALUR && f7_inst32[5] == 1'b0) begin
                            alu_oper_o <= ALUOP_ADD;
                        end else begin
                            alu_oper_o <= ALUOP_SUB;
                        end
                    end
                    F3_AND:  alu_oper_o <= ALUOP_AND;
                    F3_OR:   alu_oper_o <= ALUOP_OR;
                    F3_XOR:  alu_oper_o <= ALUOP_XOR;
                    F3_SLT:  alu_oper_o <= ALUOP_SLT;
                    F3_SLTU: alu_oper_o <= ALUOP_SLTU;
                    F3_SLL:  alu_oper_o <= ALUOP_SLL;
                    F3_SRL_SRA:
                        if (f7_inst32[5] == 1'b0) alu_oper_o <= ALUOP_SRL;
                        else                      alu_oper_o <= ALUOP_SRA;
                    default: alu_oper_o <= ALUOP_NONE;
                endcase
            default: alu_oper_o <= ALUOP_NONE;
        endcase
    end

    assign alu_sign_o = (f3_inst32 == F3_SLTU) ? 1'b0 : 
                        (f3_inst32 == F3_BLTU) ? 1'b0 : 
                        (f3_inst32 == F3_BGEU) ? 1'b0 : 1'b1;
                          
    assign lsu_sign_o = (f3_inst32 == F3_LB_SB) ? 1'b1 : 
                        (f3_inst32 == F3_LH_SH) ? 1'b1 : 1'b0;

    assign is_jump_o = (op_inst32 == OP_JAL)  ? SEL_PC_TARGET :
                       (op_inst32 == OP_JALR) ? SEL_JALR      : SEL_PC_PLUS;

    always_comb begin : brach_select
        if (op_inst32 == OP_BRANCH) begin
            unique case (f3_inst32)
                F3_BEQ:          is_branch_o <= BRANCH_BEQ;
                F3_BNE:          is_branch_o <= BRANCH_BNE;
                F3_BLT, F3_BLTU: is_branch_o <= BRANCH_BLT;
                F3_BGE, F3_BGEU: is_branch_o <= BRANCH_BGE;
                default:         is_branch_o <= BRANCH_NONE;
            endcase
        end else is_branch_o <= BRANCH_NONE;
    end

    always_comb begin : alu_oper_b_select
        unique case (op_inst32)
            OP_ALUI, OP_LOAD, OP_STORE: 
                sel_alu_immed_oper_b_o <= 1'b1;
            default: 
                sel_alu_immed_oper_b_o <= 1'b0;
        endcase
    end

    always_comb begin : read_dat1_select
        if (op_inst32 == OP_PRIVILEGED) begin
            unique case (f3_inst32)
                F3_CSRRWI, F3_CSRRSI, F3_CSRRCI:
                    sel_read_dat1_addr_o <= 1'b0;
                default:
                    sel_read_dat1_addr_o <= 1'b1;
            endcase
        end else sel_read_dat1_addr_o <= 1'b1;
    end

    assign sel_reg_write_o = sel_reg_write;
    assign reg_write_en_o = (sel_reg_write == W_REG_NONE) ? 1'b0 : 1'b1;

    always_comb begin : write_to_reg_select
        unique case (op_inst32)
            OP_ALUI, OP_ALUR: sel_reg_write <= W_REG_ALURES;
            OP_LOAD:          sel_reg_write <= W_REG_READ_DATA;
            OP_JAL, OP_JALR:  sel_reg_write <= W_REG_PC_PLUS;
            OP_LUI:           sel_reg_write <= W_REG_IMMEDIATE;
            OP_AUIPC:         sel_reg_write <= W_REG_PC_TARGET;
            OP_PRIVILEGED:    sel_reg_write <= W_REG_CSR;
            default:          sel_reg_write <= W_REG_NONE;
        endcase
    end

    always_comb begin : memory_select
        unique case (op_inst32)
            OP_LOAD: begin
                memory_en_o      <= '{1'b1, 1'b0};
                sel_load_store_o  <= LSU_LOAD;
            end
            OP_STORE: begin
                memory_en_o      <= '{1'b0, 1'b1};
                sel_load_store_o  <= LSU_STORE;
            end
            default: begin
                memory_en_o      <= '{1'b0, 1'b0};
                sel_load_store_o  <= LSU_NONE;
            end
        endcase
    end

    assign csr_oper_o = csr_oper;
    assign csr_write_en_o = (csr_oper == CSROP_NONE) ? 1'b0 : 1'b1;

    always_comb begin : csr_operator_select
        if (op_inst32 == OP_PRIVILEGED) begin
            unique case (f3_inst32)
                F3_CSRRW, F3_CSRRWI: csr_oper <= CSROP_RW;
                F3_CSRRS, F3_CSRRSI: csr_oper <= CSROP_RS;
                F3_CSRRC, F3_CSRRCI: csr_oper <= CSROP_RC;
                default:             csr_oper <= CSROP_NONE;
            endcase
        end else csr_oper <= CSROP_NONE;
    end
    
endmodule