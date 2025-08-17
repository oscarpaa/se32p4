
module se32p4_decoder
    import se32p4_pkg::*;
(
    input logic [31:0] instr_i,
    output logic [31:0] immediate_o,
    
    output sel_lsu_t sel_load_store_o,
    output logic sel_pc_increment_2_4_o,
    output logic sel_read_dat1_addr_o,
    output logic sel_alu_immed_oper_b_o,
    output sel_wreg_t sel_write_reg_o,
    
    output sel_pc_t is_jump_o,
    output branch_t is_branch_o,
    
    output logic [4:0] read_addr1_o, read_addr2_o, write_addr3_o,
    
    output aluop_t alu_oper_o,
    output logic alu_sign_o,
    output logic lsu_sign_o,
    
    output csrop_t csr_oper_o,
    output logic csr_write_e_o,
    
    output logic reg_write_e_o,
    output mem_rw_enable_t mem_enable_o
);

    logic [6:0] op_inst32 = instr_i[6:0];
    logic [6:0] f7_inst32 = instr_i[31:25];
    logic [2:0] f3_inst32 = instr_i[14:12];
    
    logic [1:0] op_inst16 = instr_i[1:0];
    //logic [5:0] f6_inst16 = instr_i[15:10];
    //logic [3:0] f4_inst16 = instr_i[15:12];
    logic [2:0] f3_inst16 = instr_i[15:13];
    logic [1:0] f2_inst16 = instr_i[6:5];
    logic [1:0] f_inst16 = instr_i[11:10];
    
    logic is_compressed = (op_inst16 == OPC_ZERO ||
                           op_inst16 == OPC_ONE  ||
                           op_inst16 == OPC_TWO) ? 1'b1 : 1'b0;

    csrop_t csr_oper;
    sel_wreg_t sel_write_reg;
    cformat_t c_type;

    always_comb begin : c_format_decoder
        if (is_compressed == 1'b1) begin
            case (op_inst16)
                OPC_ZERO:
                    unique case (f3_inst16)
                        F3C_ADDI4SPN: c_type <= CIW_T;
                        F3C_LW_LWSP:  c_type <= CL_T;
                        F3C_SW_SWSP:  c_type <= CS_T;
                        default:      c_type <= CNONE_T;
                    endcase
                OPC_ONE:
                    unique case (f3_inst16)
                        F3C_ADDI, F3C_LI, F3C_ADDI16SP_LUI:
                            c_type <= CI_T;
                        F3C_JAL, F3C_J:
                            c_type <= CJ_T;
                        F3C_ALU:
                            casez (instr_i[12:10])
                                {1'b?, FC_SRLI}, {1'b?, FC_SRAI}, {1'b?, FC_ANDI}:
                                    c_type <= CBA_T;
                                F6C_LO_CSA:
                                    c_type <= CSA_T;
                                default:
                                    c_type <= CNONE_T;
                            endcase
                        F3C_BEQZ, F3C_BNEZ: c_type <= CB_T;
                        default:            c_type <= CNONE_T;
                        
                    endcase
                OPC_TWO:
                    unique case (f3_inst16)
                        F3C_SLLI, F3C_LW_LWSP: 
                            c_type <= CI_T;
                        F4C_HI_CR:
                            c_type <= CR_T;
                        F3C_SW_SWSP: 
                            c_type <= CSS_T;
                        default:
                            c_type <= CNONE_T;
                     endcase 
                default: c_type <= CNONE_T;
            endcase
        end else begin
            c_type <= CNONE_T;
        end
    end
                          
    always_comb begin : immediate_generator
        if (is_compressed == 1'b1) begin
            case (op_inst16)
                OPC_ZERO:
                    unique case (f3_inst16)
                        F3C_ADDI4SPN:
                            immediate_o <= {22'b0, instr_i[10:7], instr_i[12], instr_i[11], instr_i[5], instr_i[6], 2'b0};
                        F3C_LW_LWSP, F3C_SW_SWSP:
                            immediate_o <= {25'b0, instr_i[5], instr_i[12:10], instr_i[6], 2'b0};
                        default:
                            immediate_o <= 32'b0;
                    endcase
                OPC_ONE:
                    unique case (f3_inst16)
                        F3C_ADDI, F3C_LI:
                            immediate_o <= {{26{instr_i[12]}}, instr_i[12], instr_i[6:2]};
                        F3C_JAL, F3C_J:
                            immediate_o <= {{21{instr_i[12]}}, instr_i[12], instr_i[8], instr_i[10:9], instr_i[6], instr_i[7], instr_i[2], instr_i[11], instr_i[5:3], 1'b0};
                        F3C_ADDI16SP_LUI: 
                            if (instr_i[11:7] == 5'h2) begin : c_addi16sp
                                immediate_o <= {{22{instr_i[5]}}, instr_i[5], instr_i[4:3], instr_i[5], instr_i[2], instr_i[6], instr_i[6], 4'b0};
                            end else begin : c_lui
                                immediate_o <= {{14{instr_i[12]}}, instr_i[12], instr_i[6:2], 12'b0};
                            end
                        F3C_ALU:
                            casez (instr_i[12:10])
                                {1'b?, FC_SRLI}, {1'b?, FC_SRAI}, {1'b?, FC_ANDI}: 
                                    immediate_o <= {{26{instr_i[12]}}, instr_i[12], instr_i[6:2]};
                                default:
                                    immediate_o <= 32'b0;
                            endcase
                        F3C_BEQZ, F3C_BNEZ:
                            immediate_o <= {{23{instr_i[12]}}, instr_i[12], instr_i[6:5], instr_i[2], instr_i[11:10], instr_i[4:3], 1'b0};
                        default:
                            immediate_o <= 32'b0;
                    endcase
                OPC_TWO:
                     unique case (f3_inst16)
                        F3C_SLLI:
                            immediate_o <= {{26{instr_i[12]}}, instr_i[12], instr_i[6:2]};
                        F3C_LW_LWSP:
                            immediate_o <= {24'b0, instr_i[3:2], instr_i[12], instr_i[6:4], 2'b0};
                        F3C_SW_SWSP:
                            immediate_o <= {24'b0, instr_i[8:7], instr_i[12:9], 2'b0};
                        default:
                            immediate_o <= 32'b0;
                     endcase 
                default:
                    immediate_o <= 32'b0;
            endcase
        end else begin
            unique case (op_inst32)
                OP_LOAD, OP_ALUI, OP_JALR, OP_PRIVILEGED: 
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
    end
    
    always_comb begin : register_addresses_decoder
        if (is_compressed == 1'b1) begin
            unique case (c_type)
                CIW_T: begin
                    read_addr1_o  <= 5'h2; // sp
                    read_addr2_o  <= 5'h0;
                    write_addr3_o <= {2'b01, instr_i[4:2]};
                end
                CL_T: begin
                    read_addr1_o  <= {2'b01, instr_i[9:7]}; 
                    read_addr2_o  <= 5'h0;
                    write_addr3_o <= {2'b01, instr_i[4:2]};
                end
                CS_T: begin
                    read_addr1_o  <= {2'b01, instr_i[9:7]}; 
                    read_addr2_o  <= {2'b01, instr_i[4:2]};
                    write_addr3_o <= 5'h0;
                end
                CI_T: 
                    unique case (f3_inst16)
                        F3C_ADDI, F3C_SLLI: begin
                            read_addr1_o  <= instr_i[11:7];
                            read_addr2_o  <= 5'h0;
                            write_addr3_o <= instr_i[11:7];
                        end
                        F3C_LI: begin
                            read_addr1_o  <= 5'h0;
                            read_addr2_o  <= 5'h0;
                            write_addr3_o <= instr_i[11:7];
                        end
                        F3C_ADDI16SP_LUI: 
                            if (instr_i[11:7] == 5'h2) begin : c_addi16sp
                                read_addr1_o  <= 5'h2; // sp
                                read_addr2_o  <= 5'h0;
                                write_addr3_o <= 5'h2; // sp
                            end else begin : c_lui
                                read_addr1_o  <= 5'h0;
                                read_addr2_o  <= 5'h0;
                                write_addr3_o <= instr_i[11:7];
                            end
                        F3C_LW_LWSP: begin
                            read_addr1_o  <= 5'h2; // sp
                            read_addr2_o  <= 5'h0;
                            write_addr3_o <= instr_i[11:7];
                        end
                        default: begin
                            read_addr1_o  <= 5'h0;
                            read_addr2_o  <= 5'h0;
                            write_addr3_o <= 5'h0;
                        end
                    endcase
                CJ_T:
                    unique case (f3_inst16)
                        F3C_JAL: begin
                            read_addr1_o  <= 5'h0;
                            read_addr2_o  <= 5'h0;
                            write_addr3_o <= 5'h1; // ra
                        end
                        F3C_J: begin
                            read_addr1_o  <= 5'h0;
                            read_addr2_o  <= 5'h0;
                            write_addr3_o <= 5'h0;
                        end
                    endcase
                CBA_T: begin
                    read_addr1_o  <= {2'b01, instr_i[9:7]};
                    read_addr2_o  <= 5'h0;
                    write_addr3_o <= {2'b01, instr_i[9:7]};
                end
                CSA_T: begin
                    read_addr1_o  <= {2'b01, instr_i[9:7]};
                    read_addr2_o  <= {2'b01, instr_i[4:2]};
                    write_addr3_o <= {2'b01, instr_i[9:7]};
                end
                CB_T: begin
                    read_addr1_o  <= {2'b01, instr_i[9:7]};
                    read_addr2_o  <= 5'h0;
                    write_addr3_o <= 5'h0;
                end
                CR_T:
                    if (instr_i[12] == 1'b0) begin
                        if (instr_i[6:2] == 5'h0) begin : c_jr
                            read_addr1_o  <= instr_i[11:7];
                            read_addr2_o  <= 5'h0;
                            write_addr3_o <= 5'h0;
                        end else begin : c_mv
                            read_addr1_o  <= 5'h0;
                            read_addr2_o  <= instr_i[6:2];
                            write_addr3_o <= instr_i[11:7];
                        end
                    end else begin
                        if (instr_i[6:2] == 5'h0) begin : c_jalr
                            read_addr1_o  <= instr_i[11:7];
                            read_addr2_o  <= 5'h0;
                            write_addr3_o <= 5'h1; // ra
                        end else begin : c_add
                            read_addr1_o  <= instr_i[11:7];
                            read_addr2_o  <= instr_i[6:2];
                            write_addr3_o <= instr_i[11:7];
                        end
                    end
                CSS_T: begin
                    read_addr1_o  <= 5'h2; // sp
                    read_addr2_o  <= instr_i[6:2];
                    write_addr3_o <= 5'h0;
                end
                default: begin
                    read_addr1_o  <= 5'h0; 
                    read_addr2_o  <= 5'h0;
                    write_addr3_o <= 5'h0;
                end
            endcase
        end else begin
            read_addr1_o  <= instr_i[19:15]; 
            read_addr2_o  <= instr_i[24:20];
            write_addr3_o <= instr_i[11:7];
        end
    end
    
    always_comb begin : aluop_decoder
        if (is_compressed == 1'b1) begin
            unique case (c_type)
                CIW_T, CL_T, CS_T, CSS_T: alu_oper_o <= ALUOP_ADD;
                CI_T:
                    unique case (op_inst16)
                        OPC_ONE:
                            unique case (f3_inst16)
                                F3C_ADDI, F3C_LI: alu_oper_o <= ALUOP_ADD;
                                F3C_ADDI16SP_LUI: 
                                    if (instr_i[11:7] == 5'h2) begin : c_addi16sp
                                        alu_oper_o <= ALUOP_ADD;
                                    end else begin : c_lui
                                        alu_oper_o <= ALUOP_NONE;
                                    end
                                default: alu_oper_o <= ALUOP_NONE;
                            endcase
                        OPC_TWO:
                            unique case (f3_inst16)
                                F3C_LW_LWSP: alu_oper_o <= ALUOP_ADD;
                                F3C_SLLI: alu_oper_o <= ALUOP_SLL;
                                default: alu_oper_o <= ALUOP_NONE;
                            endcase
                        default: alu_oper_o <= ALUOP_NONE;
                    endcase
                CBA_T:
                    unique case (f_inst16)
                        FC_SRLI: alu_oper_o <= ALUOP_SRL;
                        FC_SRAI: alu_oper_o <= ALUOP_SRA;
                        FC_ANDI: alu_oper_o <= ALUOP_AND;
                        default: alu_oper_o <= ALUOP_NONE;
                    endcase
                CSA_T:
                    unique case (f2_inst16)
                        F2C_SUB: alu_oper_o <= ALUOP_SUB;
                        F2C_XOR: alu_oper_o <= ALUOP_XOR;
                        F2C_OR:  alu_oper_o <= ALUOP_OR;
                        F2C_AND: alu_oper_o <= ALUOP_AND;
                    endcase
                CR_T:
                    if (instr_i[12] == 1'b0) begin
                        if (instr_i[6:2] == 5'h0) begin : c_jr
                            alu_oper_o <= ALUOP_NONE;
                        end else begin : c_mv
                            alu_oper_o <= ALUOP_ADD;
                        end
                    end else begin
                        if (instr_i[6:2] == 5'h0) begin : c_jalr
                            alu_oper_o <= ALUOP_NONE;
                        end else begin : c_add
                            alu_oper_o <= ALUOP_ADD;
                        end
                    end
                default: alu_oper_o <= ALUOP_NONE;
            endcase
        end else begin
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
                        F3_SR:
                            if (f7_inst32[5] == 1'b0) alu_oper_o <= ALUOP_SRL;
                            else                      alu_oper_o <= ALUOP_SRA;
                        default: alu_oper_o <= ALUOP_NONE;
                    endcase
                default: alu_oper_o <= ALUOP_NONE;
            endcase
        end
    end
    
    assign alu_sign_o = (is_compressed == 1'b0 && 
                         (f3_inst32 == F3_SLTU || 
                          f3_inst32 == F3_BLTU || 
                          f3_inst32 == F3_BGEU)) ? 1'b0 : 1'b1;
                          
    assign lsu_sign_o = (is_compressed == 1'b0 && 
                         (f3_inst32 == F3_LB_SB || 
                          f3_inst32 == F3_LH_SH)) ? 1'b1 : 1'b0;

    assign sel_pc_increment_2_4_o = is_compressed;

    always_comb begin : jump_select
        if (is_compressed == 1'b1) begin
            unique case (c_type)
                CJ_T: is_jump_o <= SEL_PC_TARGET;
                CR_T:
                    if (instr_i[12] == 1'b0) begin
                        if (instr_i[6:2] == 5'h0) begin : c_jr
                            is_jump_o <= SEL_JALR;
                        end else begin : c_mv
                            is_jump_o <= SEL_PC_PLUS;
                        end
                    end else begin
                        if (instr_i[6:2] == 5'h0) begin : c_jalr
                            is_jump_o <= SEL_JALR;
                        end else begin : c_add
                            is_jump_o <= SEL_PC_PLUS;
                        end
                    end
                default: is_jump_o <= SEL_PC_PLUS;
            endcase
        end else begin
            unique case (op_inst32)
                OP_JAL:  is_jump_o <= SEL_PC_TARGET;
                OP_JALR: is_jump_o <= SEL_JALR;
                default: is_jump_o <= SEL_PC_PLUS;
            endcase
        end
    end

    always_comb begin : brach_select
        if (is_compressed == 1'b1) begin
            if (c_type == CB_T) begin
                unique case (f3_inst16)
                    F3C_BEQZ: is_branch_o <= BRANCH_BEQ;
                    F3C_BNEZ: is_branch_o <= BRANCH_BNE;
                    default:  is_branch_o <= BRANCH_NONE;
                endcase
            end else is_branch_o <= BRANCH_NONE;
        end else begin
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
    end

    always_comb begin : alu_oper_b_select
        if (is_compressed == 1'b1) begin
            unique case (c_type)
                CIW_T, CL_T, CS_T, CI_T, CBA_T, CSS_T: 
                    sel_alu_immed_oper_b_o <= 1'b1;
                default: 
                    sel_alu_immed_oper_b_o <= 1'b0;
            endcase
        end else begin
            unique case (op_inst32)
                OP_ALUI, OP_LOAD, OP_STORE: 
                    sel_alu_immed_oper_b_o <= 1'b1;
                default: 
                    sel_alu_immed_oper_b_o <= 1'b0;
            endcase
        end
    end

    always_comb begin : read_dat1_select
        if (is_compressed == 1'b1) 
            sel_read_dat1_addr_o <= 1'b1;
        else 
            if (op_inst32 == OP_PRIVILEGED) begin
                unique case (f3_inst32)
                    F3_CSRRWI, F3_CSRRSI, F3_CSRRCI:
                        sel_read_dat1_addr_o <= 1'b0;
                    default: sel_read_dat1_addr_o <= 1'b1;
                endcase
            end else sel_read_dat1_addr_o <= 1'b1;
    end

    assign sel_write_reg_o = sel_write_reg;
    assign reg_write_e_o = (sel_write_reg == W_REG_NONE) ? 1'b0 : 1'b1;

    always_comb begin : write_to_reg_select
        if (is_compressed == 1'b1) begin
            unique case (c_type)
                CIW_T, CBA_T, CSA_T: sel_write_reg <= W_REG_ALURES;
                CL_T:         sel_write_reg <= W_REG_READ_DATA;
                CI_T:
                    unique case (f3_inst16)
                        F3C_ADDI16SP_LUI:
                            if (instr_i[11:7] == 5'h2) begin : c_addi16sp
                                sel_write_reg <= W_REG_ALURES;
                            end else begin : c_lui
                                sel_write_reg <= W_REG_IMMEDIATE;
                            end
                        F3C_LW_LWSP: sel_write_reg <= W_REG_READ_DATA;
                        default:     sel_write_reg <= W_REG_ALURES;
                    endcase 
                CJ_T:  sel_write_reg <= W_REG_PC_PLUS;
                CR_T:
                    if (instr_i[12] == 1'b0) begin
                        if (instr_i[6:2] == 5'h0) begin : c_jr
                            sel_write_reg <= W_REG_PC_PLUS;
                        end else begin : c_mv
                            sel_write_reg <= W_REG_ALURES;
                        end
                    end else begin
                        if (instr_i[6:2] == 5'h0) begin : c_jalr
                            sel_write_reg <= W_REG_PC_PLUS;
                        end else begin : c_add
                            sel_write_reg <= W_REG_ALURES;
                        end
                    end
                default: sel_write_reg <= W_REG_NONE;
            endcase
        end else begin
            unique case (op_inst32)
                OP_ALUI, OP_ALUR: sel_write_reg <= W_REG_ALURES;
                OP_LOAD:          sel_write_reg <= W_REG_READ_DATA;
                OP_JAL, OP_JALR:  sel_write_reg <= W_REG_PC_PLUS;
                OP_LUI:           sel_write_reg <= W_REG_IMMEDIATE;
                OP_AUIPC:         sel_write_reg <= W_REG_PC_TARGET;
                OP_PRIVILEGED:    sel_write_reg <= W_REG_CSR;
                default:          sel_write_reg <= W_REG_NONE;
            endcase
        end
    end

    always_comb begin : memory_select
        if (is_compressed == 1'b1) begin
            unique case (c_type)
                CL_T: begin
                    mem_enable_o      <= '{1'b1, 1'b0};
                    sel_load_store_o  <= LSU_LOAD;
                end
                CI_T: begin
                    if (f3_inst16 == F3C_LW_LWSP) begin
                        mem_enable_o      <= '{1'b1, 1'b0};
                        sel_load_store_o  <= LSU_LOAD;
                    end else begin
                        mem_enable_o      <= '{1'b0, 1'b0};
                        sel_load_store_o  <= LSU_NONE;
                    end
                end
                CS_T, CSS_T: begin
                    mem_enable_o      <= '{1'b0, 1'b1};
                    sel_load_store_o  <= LSU_STORE;
                end
                default: begin
                    mem_enable_o      <= '{1'b0, 1'b0};
                    sel_load_store_o  <= LSU_NONE;
                end
            endcase
        end else begin
            unique case (op_inst32)
                OP_LOAD: begin
                    mem_enable_o      <= '{1'b1, 1'b0};
                    sel_load_store_o  <= LSU_LOAD;
                end
                OP_STORE: begin
                    mem_enable_o      <= '{1'b0, 1'b1};
                    sel_load_store_o  <= LSU_STORE;
                end
                default: begin
                    mem_enable_o      <= '{1'b0, 1'b0};
                    sel_load_store_o  <= LSU_NONE;
                end
            endcase
        end
    end

    assign csr_oper_o = csr_oper;
    assign csr_write_e_o = (csr_oper == CSROP_NONE) ? 1'b0 : 1'b1;

    always_comb begin : csr_operator_select
        if (op_inst32 == OP_PRIVILEGED)
            unique case (f3_inst32)
                F3_CSRRW, F3_CSRRWI: csr_oper <= CSROP_RW;
                F3_CSRRS, F3_CSRRSI: csr_oper <= CSROP_RS;
                F3_CSRRC, F3_CSRRCI: csr_oper <= CSROP_RC;
                default:             csr_oper <= CSROP_NONE;
            endcase
        else
            csr_oper <= CSROP_NONE;
    end
    
endmodule