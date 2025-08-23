
module se32p4_c_decoder
    import se32p4_pkg::*;
(
    input logic [31:0] instr_i,
    output logic [31:0] instr_o,
    output logic is_compressed_o
);
    // funct3 RV32C
    localparam logic [2:0] F3C_LW_LWSP = 3'b010;
    localparam logic [2:0] F3C_SW_SWSP = 3'b110;
 
    localparam logic [2:0] F3C_JAL = 3'b001;
    localparam logic [2:0] F3C_J   = 3'b101;
    
    localparam logic [2:0] F3C_BEQZ = 3'b110;
    localparam logic [2:0] F3C_BNEZ = 3'b111;
    
    localparam logic [2:0] F3C_ADDI         = 3'b000;
    localparam logic [2:0] F3C_ADDI4SPN     = 3'b000;
    localparam logic [2:0] F3C_ADDI16SP_LUI = 3'b011;
    localparam logic [2:0] F3C_LI           = 3'b010;
    
    localparam logic [2:0] F3C_ALU = 3'b100;
    localparam logic [1:0] FC_SRLI = 2'b00;
    localparam logic [1:0] FC_SRAI = 2'b01;
    localparam logic [1:0] FC_ANDI = 2'b10;
    
    localparam logic [2:0] F3C_SLLI   = 3'b000;
    
    // funct6 RV32C
    localparam logic [5:0] F6C_CSA    = 6'b100011;
    localparam logic [2:0] F6C_LO_CSA = 3'b011;    
    
    // funct2 RV32C
    localparam logic [1:0] F2C_SUB     = 2'b00;
    localparam logic [1:0] F2C_XOR     = 2'b01;
    localparam logic [1:0] F2C_OR      = 2'b10;
    localparam logic [1:0] F2C_AND     = 2'b11;
    
    // funct4 RV32C
    localparam logic [3:0] F4C_JR_MV    = 4'b1000;
    localparam logic [3:0] F4C_JALR_ADD = 4'b1001;
    localparam logic [2:0] F4C_HI_CR    = 3'b100;

    logic [1:0] op_inst16 = instr_i[1:0];
    logic [2:0] f3_inst16 = instr_i[15:13];
    logic [1:0] f2_inst16 = instr_i[6:5];

    always_comb begin : convert_16_to_32_instructions
        unique case (op_inst16)
            2'b00:
                unique case (f3_inst16)
                    F3C_ADDI4SPN:
                        instr_o <= {
                            2'b0, instr_i[10:7], instr_i[12:11], instr_i[5], instr_i[6], 2'b0, 
                            5'h2, 
                            F3_SUB_ADD, 
                            2'b01, instr_i[4:2], 
                            OP_ALUI
                        };
                    F3C_LW_LWSP:
                        instr_o <= {
                            5'b0, instr_i[5], instr_i[12:10], instr_i[6], 2'b0, 
                            2'b01, instr_i[9:7],
                            F3_LW_SW,
                            2'b01, instr_i[4:2], 
                            OP_LOAD
                        };
                    F3C_SW_SWSP:
                        instr_o <= {
                            5'b0, instr_i[5], instr_i[12], 
                            2'b01, instr_i[4:2],
                            2'b01, instr_i[9:7],
                            F3_LW_SW,
                            instr_i[11:10], instr_i[6], 2'b0,
                            OP_STORE
                        };
                    default: instr_o <= 32'b0;
                endcase
            2'b01:
                unique case (f3_inst16)
                    F3C_ADDI:
                        instr_o <= {
                            {6{instr_i[12]}}, instr_i[12], instr_i[6:2], 
                            instr_i[11:7], 
                            F3_SUB_ADD, 
                            instr_i[11:7], 
                            OP_ALUI
                        };
                    F3C_LI:
                        instr_o <= {
                            {6{instr_i[12]}}, instr_i[12], instr_i[6:2], 
                            5'h0, 
                            F3_SUB_ADD, 
                            instr_i[11:7], 
                            OP_ALUI
                        };
                    F3C_JAL, F3C_J:
                        instr_o <= {
                            instr_i[12], instr_i[8], instr_i[10:9], instr_i[6], instr_i[7], instr_i[2], instr_i[11], instr_i[5:3], {9{instr_i[12]}},
                            4'h0, ~instr_i[15],
                            OP_JAL
                        };
                    F3C_ADDI16SP_LUI: 
                        if (instr_i[11:7] == 5'h2) begin : c_addi16sp
                            instr_o <= {
                                {3{instr_i[12]}}, instr_i[4:3], instr_i[5], instr_i[2], instr_i[6], 4'b0, 
                                instr_i[11:7], 
                                F3_SUB_ADD, 
                                instr_i[11:7], 
                                OP_ALUI
                            };
                        end else begin : c_lui
                            instr_o <= {
                                {15{instr_i[12]}}, instr_i[6:2],
                                instr_i[11:7], 
                                OP_LUI
                            };
                        end
                    F3C_ALU:
                        casez (instr_i[12:10])
                            {1'b?, FC_SRLI}, {1'b?, FC_SRAI}: 
                                instr_o <= {
                                    1'b0, instr_i[10], 5'b0,
                                    instr_i[6:2],
                                    2'b01, instr_i[9:7],
                                    F3_SRL_SRA,
                                    2'b01, instr_i[9:7],
                                    OP_ALUI
                                };
                            {1'b?, FC_ANDI}:
                                instr_o <= {
                                    {6{instr_i[12]}}, instr_i[12], instr_i[6:2],
                                    2'b01, instr_i[9:7],
                                    F3_AND,
                                    2'b01, instr_i[9:7],
                                    OP_ALUI
                                };
                            F6C_LO_CSA:
                                unique case (f2_inst16)
                                    F2C_SUB: 
                                        instr_o <= {
                                            7'b0100000,
                                            2'b01, instr_i[4:2],
                                            2'b01, instr_i[9:7],
                                            F3_SUB_ADD,
                                            2'b01, instr_i[9:7],
                                            OP_ALUR
                                        };
                                    F2C_XOR:
                                        instr_o <= {
                                            7'b0,
                                            2'b01, instr_i[4:2],
                                            2'b01, instr_i[9:7],
                                            F3_XOR,
                                            2'b01, instr_i[9:7],
                                            OP_ALUR
                                        };
                                    F2C_OR:
                                        instr_o <= {
                                            7'b0,
                                            2'b01, instr_i[4:2],
                                            2'b01, instr_i[9:7],
                                            F3_OR,
                                            2'b01, instr_i[9:7],
                                            OP_ALUR
                                        };
                                    F2C_AND: 
                                        instr_o <= {
                                            7'b0,
                                            2'b01, instr_i[4:2],
                                            2'b01, instr_i[9:7],
                                            F3_AND,
                                            2'b01, instr_i[9:7],
                                            OP_ALUR
                                        };
                                    default: instr_o <= 32'b0;
                                endcase
                            default: instr_o <= 32'b0;
                        endcase
                    F3C_BEQZ, F3C_BNEZ:
                        instr_o <= {
                            {4{instr_i[12]}},
                            instr_i[6:5],
                            instr_i[2],
                            5'h0,
                            2'b01, instr_i[9:7],
                            2'b00, instr_i[13],
                            instr_i[11:10], instr_i[4:3], instr_i[12],
                            OP_BRANCH
                        };
                    default: instr_o <= 32'b0;
                endcase
            2'b10:
                unique case (f3_inst16)
                    F3C_SLLI:
                        instr_o <= {
                            7'b0, 
                            instr_i[6:2], 
                            instr_i[11:7], 
                            F3_SLL, 
                            instr_i[11:7], 
                            OP_ALUI
                        };
                    F3C_LW_LWSP:
                        instr_o <= {
                            4'b0, instr_i[3:2], instr_i[12], instr_i[6:4], 2'b0, 
                            5'h2,
                            F3_LW_SW,
                            instr_i[11:7], 
                            OP_LOAD
                        };
                    F3C_SW_SWSP:
                        instr_o <= {
                            4'b0, instr_i[8:7], instr_i[12],
                            instr_i[6:2],
                            5'h2,
                            F3_LW_SW,
                            instr_i[11:9], 2'b0,
                            OP_STORE
                        };
                    F4C_HI_CR:
                        if (instr_i[12] == 1'b0) begin
                            if (instr_i[6:2] == 5'h0) begin // c_jr
                                instr_o <= {
                                    12'b0, 
                                    instr_i[11:7], 
                                    F3_JALR, 
                                    5'h0, 
                                    OP_JALR
                                };
                            end else begin : c_mv
                                instr_o <= {
                                    7'b0, 
                                    instr_i[6:2], 
                                    5'h0, 
                                    F3_SUB_ADD, 
                                    instr_i[11:7], 
                                    OP_ALUR
                                };
                            end
                        end else begin
                            if (instr_i[6:2] == 5'h0) begin // c_ebreak
                                if (instr_i[11:7] == 5'h0) begin
                                    instr_o <= {
                                        12'b1,
                                        5'h0,
                                        F3_EBREAK_ECALL_XRET,
                                        5'h0,
                                        OP_PRIVILEGED
                                    };
                                end else begin // c_jalr
                                    instr_o <= {
                                        12'b0, 
                                        instr_i[11:7], 
                                        F3_JALR, 
                                        5'h1, 
                                        OP_JALR
                                    };
                                end 
                            end else begin // c_add
                                instr_o <= {
                                    7'b0, 
                                    instr_i[6:2], 
                                    instr_i[11:7], 
                                    F3_SUB_ADD, 
                                    instr_i[11:7], 
                                    OP_ALUR
                                };
                            end
                        end
                    default: instr_o <= 32'b0;
                endcase 
            default: instr_o <= instr_i;
        endcase
    end

endmodule