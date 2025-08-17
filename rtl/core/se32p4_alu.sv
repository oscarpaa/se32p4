
module se32p4_alu 
    import se32p4_pkg::*;
(
    input aluop_t oper_type_i,
    input logic [31:0] oper_a_i, oper_b_i,
    output logic [31:0] oper_res_o,
    input logic oper_sign_i,
    output logic [1:0] compare_o
);
    logic [1:0] compare;
    
    assign compare[0] = (oper_a_i == oper_b_i) ? 1'b1 : 1'b0;

    assign compare[1] = (oper_sign_i == 1'b0 && oper_a_i < oper_b_i) ? 1'b1 : 
                        (oper_sign_i == 1'b1 && $signed(oper_a_i) < $signed(oper_b_i)) ? 1'b1 : 1'b0;
    
    assign compare_o = compare;
    
    always_comb begin
        unique case (oper_type_i)
            ALUOP_ADD:  oper_res_o <= oper_a_i + oper_b_i;
            ALUOP_SUB:  oper_res_o <= oper_a_i - oper_b_i;
            ALUOP_AND:  oper_res_o <= oper_a_i & oper_b_i;
            ALUOP_OR:   oper_res_o <= oper_a_i | oper_b_i;
            ALUOP_XOR:  oper_res_o <= oper_a_i ^ oper_b_i;
            ALUOP_SLT:  oper_res_o <= {31'b0, compare[1]};
            ALUOP_SLTU: oper_res_o <= {31'b0, compare[1]};
            ALUOP_SLL:  oper_res_o <= oper_a_i << oper_b_i[4:0];
            ALUOP_SRL:  oper_res_o <= oper_a_i >> oper_b_i[4:0];
            ALUOP_SRA:  oper_res_o <= oper_a_i >>> oper_b_i[4:0];
            default:    oper_res_o <= 32'b0;
        endcase
    end

endmodule