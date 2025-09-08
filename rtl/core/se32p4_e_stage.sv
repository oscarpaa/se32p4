
module se32p4_e_stage 
    import se32p4_pkg::*;
(
    input logic clk_i,
    input logic rstn_i,
    input logic flush_i,
    input logic load_en_i,
    
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

    input logic [4:0] reg_read_addr1_d_i, reg_read_addr2_d_i,
    input logic [31:0] reg_read_dat1_d_i, reg_read_dat2_d_i,
    input logic [4:0] reg_write_addr3_d_i,

    input csrop_t csr_oper_d_i,
    input logic csr_write_en_d_i,
    input logic sel_csr_read_dat1_addr_d_i,
    output logic [31:0] csr_write_dat_e_o,

    output logic [31:0] immediate_e_o,
    input logic forward_oper_a_e_i, forward_oper_b_e_i,
    input logic [31:0] forward_reg_write_dat3_w_i,
    output logic [31:0] alu_result_e_o,
    output logic [31:0] reg_read_dat2_e_o,
    output logic lsu_sign_e_o,

    output sel_lsu_t sel_load_store_e_o,
    output sel_pc_t pc_sel_e_o,
    
    output logic [31:0] pc_plus_e_o,
    output logic [31:0] pc_target_e_o,
    output logic [31:0] pc_jalr_e_o,

    output sel_wreg_t sel_reg_write_e_o,
    output logic [4:0] reg_read_addr1_e_o, reg_read_addr2_e_o,
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

    logic [31:0] alu_oper_a_e, alu_oper_b_e;

    sel_pc_t is_jump_e;
    branch_t is_branch_e;

    logic [1:0] cmp_bits_e;

    logic [31:0] pc_e;
    logic [4:0] reg_read_addr1_e;

    logic [31:0] csr_read_dat_e;
    csrop_t csr_oper_e;
    logic csr_write_en_e;
    logic sel_csr_read_dat1_addr_e;

    always_ff @(posedge clk_i, negedge rstn_i) begin : d_e_stage
        if (rstn_i == 1'b0 || flush_i == 1'b1) begin
            immediate_e <= 32'b0;

            sel_load_store_e_o <= LSU_NONE;
            sel_alu_immed_oper_b_e <= 1'b0;
            sel_reg_write_e_o <= W_REG_NONE;

            is_jump_e <= SEL_PC_PLUS;
            is_branch_e <= BRANCH_NONE;
            
            alu_oper_e  <= ALUOP_NONE;
            alu_sign_e  <= 1'b0;
            lsu_sign_e_o <= 1'b0;
            reg_read_addr1_e <= 5'h0;
            reg_read_addr2_e_o <= 5'h0;
            reg_read_dat1_e <= 32'b0;
            reg_read_dat2_e <= 32'b0;
            reg_write_addr3_e_o <= 5'b0;
            reg_write_en_e_o <= 1'b0;
            memory_en_e_o <= '{1'b0, 1'b0};
            ls_type_e_o <= LS_NONE;

            pc_e <= 32'b0;
            pc_plus_e_o <= 32'b0;

            csr_oper_e <= CSROP_NONE;
            csr_write_en_e <= 1'b0;
            sel_csr_read_dat1_addr_e <= 1'b0; 
        end else if (load_en_i == 1'b1) begin
            immediate_e <= immediate_d_i;

            sel_load_store_e_o <= sel_load_store_d_i;
            sel_alu_immed_oper_b_e <= sel_alu_immed_oper_b_d_i;
            sel_reg_write_e_o <= sel_reg_write_d_i;

            is_jump_e <= is_jump_d_i;
            is_branch_e <= is_branch_d_i;
            
            alu_oper_e  <= alu_oper_d_i;
            alu_sign_e  <= alu_sign_d_i;
            lsu_sign_e_o <= lsu_sign_d_i;
            reg_read_addr1_e <= reg_read_addr1_d_i;
            reg_read_addr2_e_o <= reg_read_addr2_d_i;
            reg_read_dat1_e <= reg_read_dat1_d_i;
            reg_read_dat2_e <= reg_read_dat2_d_i;
            reg_write_addr3_e_o <= reg_write_addr3_d_i;
            reg_write_en_e_o <= reg_write_en_d_i;
            memory_en_e_o <= memory_en_d_i;
            ls_type_e_o <= ls_type_d_i;

            pc_e <= pc_d_i;
            pc_plus_e_o <= pc_plus_d_i;

            csr_oper_e <= csr_oper_d_i;
            csr_write_en_e <= csr_write_en_d_i;
            sel_csr_read_dat1_addr_e <= sel_csr_read_dat1_addr_d_i; 
        end
    end

    assign reg_read_addr1_e_o = reg_read_addr1_e;
    assign immediate_e_o = immediate_e;
    assign reg_read_dat2_e_o = (forward_oper_b_e_i == 1'b1) ? forward_reg_write_dat3_w_i : reg_read_dat2_e;

    always_comb begin
        if (forward_oper_a_e_i == 1'b1)
            alu_oper_a_e <= forward_reg_write_dat3_w_i;
        else
            alu_oper_a_e <= reg_read_dat1_e;

        if (sel_alu_immed_oper_b_e == 1'b0)
            if (forward_oper_b_e_i == 1'b1)
                alu_oper_b_e <= forward_reg_write_dat3_w_i;
            else
                alu_oper_b_e <= reg_read_dat2_e;
        else
            alu_oper_b_e <= immediate_e;
    end

    se32p4_alu u_alu (
        .oper_type_i(alu_oper_e),
        .oper_a_i(alu_oper_a_e),
        .oper_b_i(alu_oper_b_e),
        .oper_res_o(alu_result_e_o),
        .oper_sign_i(alu_sign_e),
        .cmp_bits_o(cmp_bits_e)
    );

    always_comb begin : pc_next_select
        unique case (is_branch_e)
            BRANCH_NONE: 
                pc_sel_e_o <= is_jump_e;
            BRANCH_BEQ:
                pc_sel_e_o <= (cmp_bits_e[0] == 1'b1) ? SEL_PC_TARGET : SEL_PC_PLUS;
            BRANCH_BNE:
                pc_sel_e_o <= (cmp_bits_e[0] == 1'b0) ? SEL_PC_TARGET : SEL_PC_PLUS;
            BRANCH_BLT:
                pc_sel_e_o <= (cmp_bits_e[1] == 1'b1) ? SEL_PC_TARGET : SEL_PC_PLUS;
            BRANCH_BGE:
                pc_sel_e_o <= (cmp_bits_e[1] == 1'b0) ? SEL_PC_TARGET : SEL_PC_PLUS;
            default:
                pc_sel_e_o <= SEL_PC_PLUS;
        endcase
    end

    assign pc_target_e_o = immediate_e + pc_e;
    assign pc_jalr_e_o = reg_read_dat1_e + immediate_e;


    assign csr_read_dat_e = (sel_csr_read_dat1_addr_e == 1'b0) ? {27'b0, reg_read_addr1_e} : alu_oper_a_e;

    se32p4_csr u_csr (
        .clk_i,
        .rstn_i,
        .csr_write_en_i(csr_write_en_e & load_en_i),
        .csr_oper_i(csr_oper_e),
        .csr_addr_i(immediate_e),
        .csr_read_dat_i(csr_read_dat_e),
        .csr_write_dat_o(csr_write_dat_e_o)
    );

endmodule