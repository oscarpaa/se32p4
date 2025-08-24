
module se32p4_e_stage 
    import se32p4_pkg::*;
(
    input logic clk_i,
    input logic rst_i,
    
    input logic [31:0] pc_d_i,
    input logic [31:0] pc_plus_d_i,

    input logic [31:0] immediate_d_i,
    
    input sel_lsu_t sel_load_store_d_i,
    input logic sel_alu_immed_oper_b_d_i,
    input sel_wreg_t sel_reg_write_d_i,

    input sel_pc_t is_jump_d_i,
    input branch_t is_branch_d_i,

    input aluop_t alu_oper_d_i,
    input logic alu_sign_d_i,
    input logic lsu_sign_d_i,

    input logic reg_write_en_d_i,
    input mem_rw_en_t memory_en_d_i,
    input load_store_t ls_type_d_i,

    input logic [31:0] reg_read_dat1_d_i, reg_read_dat2_d_i,
    input logic [4:0] reg_write_addr3_d_i,

    input logic [31:0] csr_write_dat_d_i,
    output logic [31:0] csr_write_dat_e_o,

    output logic [31:0] immediate_e_o,
    output logic [31:0] alu_result_e_o,
    output logic [31:0] reg_read_dat2_e_o,
    output logic lsu_sign_e_o,

    output sel_lsu_t sel_load_store_e_o,
    output sel_pc_t pc_sel_e_o,
    
    output logic [31:0] pc_plus_e_o,
    output logic [31:0] pc_target_e_o,
    output logic [31:0] pc_jalr_e_o,

    output sel_wreg_t sel_reg_write_e_o,
    output logic [4:0] reg_write_addr3_e_o,

    output logic reg_write_en_e_o,
    output mem_rw_en_t memory_en_e_o,
    output load_store_t ls_type_e_o
);

    logic [31:0] immediate_e;
    logic sel_alu_immed_oper_b_e;

    aluop_t alu_oper_e;
    logic alu_sign_e;

    logic [31:0] reg_read_dat1_e, reg_read_dat2_e;

    logic [31:0] alu_oper_b_e;

    sel_pc_t is_jump_e;
    branch_t is_branch_e;

    logic [1:0] compare_e;

    logic [31:0] pc_e;

    always_ff @(posedge clk_i, posedge rst_i) begin : d_e_stage
        if (rst_i == 1'b1) begin
            immediate_e <= 32'b0;

            sel_load_store_e_o <= LSU_NONE;
            sel_alu_immed_oper_b_e <= 1'b0;
            sel_reg_write_e_o <= W_REG_NONE;

            is_jump_e <= SEL_PC_PLUS;
            is_branch_e <= BRANCH_NONE;

            csr_write_dat_e_o <= 32'b0;
            
            alu_oper_e  <= ALUOP_NONE;
            alu_sign_e  <= 1'b0;
            lsu_sign_e_o <= 1'b0;
            reg_read_dat1_e <= 32'b0;
            reg_read_dat2_e <= 32'b0;
            reg_write_addr3_e_o <= 5'b0;
            reg_write_en_e_o <= 1'b0;
            memory_en_e_o <= '{1'b0, 1'b0};
            ls_type_e_o <= LS_NONE;

            pc_e <= pc_d_i;
            pc_plus_e_o <= pc_plus_d_i;
        end else begin
            immediate_e <= immediate_d_i;

            sel_load_store_e_o <= sel_load_store_d_i;
            sel_alu_immed_oper_b_e <= sel_alu_immed_oper_b_d_i;
            sel_reg_write_e_o <= sel_reg_write_d_i;

            is_jump_e <= is_jump_d_i;
            is_branch_e <= is_branch_d_i;

            csr_write_dat_e_o <= csr_write_dat_d_i;
            
            alu_oper_e  <= alu_oper_d_i;
            alu_sign_e  <= alu_sign_d_i;
            lsu_sign_e_o <= lsu_sign_d_i;
            reg_read_dat1_e <= reg_read_dat1_d_i;
            reg_read_dat2_e <= reg_read_dat2_d_i;
            reg_write_addr3_e_o <= reg_write_addr3_d_i;
            reg_write_en_e_o <= reg_write_en_d_i;
            memory_en_e_o <= memory_en_d_i;
            ls_type_e_o <= ls_type_d_i;

            pc_e <= pc_d_i;
            pc_plus_e_o <= pc_plus_d_i;
        end
    end

    assign immediate_e_o = immediate_e;
    assign reg_read_dat2_e_o = reg_read_dat2_e;
    assign alu_oper_b_e = (sel_alu_immed_oper_b_e == 1'b0) ? reg_read_dat2_e : immediate_e;

    se32p4_alu u_alu (
        .oper_type_i(alu_oper_e),
        .oper_a_i(reg_read_dat1_e),
        .oper_b_i(alu_oper_b_e),
        .oper_res_o(alu_result_e_o),
        .oper_sign_i(alu_sign_e),
        .compare_o(compare_e)
    );

    always_comb begin : pc_next_select
        unique case (is_branch_e)
            BRANCH_NONE: 
                pc_sel_e_o <= is_jump_e;
            BRANCH_BEQ:
                pc_sel_e_o <= (compare_e[0] == 1'b1) ? SEL_PC_TARGET : SEL_PC_PLUS;
            BRANCH_BNE:
                pc_sel_e_o <= (compare_e[0] == 1'b0) ? SEL_PC_TARGET : SEL_PC_PLUS;
            BRANCH_BLT:
                pc_sel_e_o <= (compare_e[1] == 1'b1) ? SEL_PC_TARGET : SEL_PC_PLUS;
            BRANCH_BGE:
                pc_sel_e_o <= (compare_e[1] == 1'b0) ? SEL_PC_TARGET : SEL_PC_PLUS;
            default:
                pc_sel_e_o <= SEL_PC_PLUS;
        endcase
    end

    assign pc_target_e_o = immediate_e + pc_e;
    assign pc_jalr_e_o = reg_read_dat1_e + immediate_e;

endmodule