
module se32p4_core #(
    parameter logic [31:0] BOOT_ADDRESS = 32'b0
) (
    input logic clk_i,
    input logic rst_i
);

    logic [31:0] pc_f, pc_d;
    logic [31:0] pc_plus_f, pc_plus_d, pc_plus_e;
    logic [31:0] immediate_d, immediate_e;
    load_store_t ls_type_d, ls_type_e;

    logic [31:0] mem_instr_f;

    sel_lsu_t sel_load_store_d, sel_load_store_e;
    logic sel_alu_immed_oper_b_d;
    sel_wreg_t sel_reg_write_d, sel_reg_write_e;

    sel_pc_t is_jump_d;
    branch_t is_branch_d;

    aluop_t alu_oper_d;
    logic alu_sign_d;
    logic lsu_sign_d, lsu_sign_e, lsu_sign_w;

    logic reg_write_en_d, reg_write_en_e, reg_write_en_w;
    mem_rw_en_t memory_en_d, memory_en_e;

    logic [31:0] reg_read_dat1_d;
    logic [31:0] reg_read_dat2_d, reg_read_dat2_e;
    logic [4:0] reg_write_addr3_d, reg_write_addr3_e, reg_write_addr3_w;

    logic [31:0] csr_write_dat_d, csr_write_dat_e;

    logic [31:0] alu_result_e;
    sel_pc_t pc_sel_e;
    logic [31:0] pc_target_e;
    logic [31:0] pc_jalr_e;

    logic [31:0] reg_write_dat3_w;
	sel_lsu_t sel_load_store_w;

	logic [3:0] mem_byte_en_w;


    // se32p4_controller u_controller (
    
    // );
    
    se32p4_f_stage #(.BOOT_ADDRESS(BOOT_ADDRESS)) u_f_stage (
        .clk_i,
        .rst_i,
        .mem_instr_i(),
        .mem_instr_f_o(mem_instr_f),
        .pc_sel_e_i(pc_sel_e),
        .pc_target_e_i(pc_target_e),
        .pc_jalr_e_i(pc_jalr_e),
        .pc_f_o(pc_f),
        .pc_plus_f_o(pc_plus_f)    
    );
    
    se32p4_d_stage u_d_stage (
        .clk_i,
        .rst_i,
        .pc_f_i(pc_f),
        .pc_plus_f_i(pc_plus_f),
        .mem_instr_f_i(mem_instr_f),
        .pc_d_o(pc_d),
        .pc_plus_d_o(pc_plus_d),
        .immediate_d_o(immediate_d),
        .sel_load_store_d_o(sel_load_store_d),
        .sel_alu_immed_oper_b_d_o(sel_alu_immed_oper_b_d),
        .sel_reg_write_d_o(sel_reg_write_d),
        .is_jump_d_o(is_jump_d),
        .is_branch_d_o(is_branch_d),
        .alu_oper_d_o(alu_oper_d),
        .alu_sign_d_o(alu_sign_d),
        .lsu_sign_d_o(lsu_sign_d),
        .reg_write_en_d_o(reg_write_en_d),
        .memory_en_d_o(memory_en_d),
        .ls_type_d_o(ls_type_d),
        .reg_read_dat1_d_o(reg_read_dat1_d), 
        .reg_read_dat2_d_o(reg_read_dat2_d),
        .reg_write_addr3_d_o(reg_write_addr3_d),
        .reg_write_en_w_i(reg_write_en_w),
        .reg_write_addr3_w_i(reg_write_addr3_w),
        .reg_write_dat3_w_i(reg_write_dat3_w),
        .csr_write_dat_d_o(csr_write_dat_d)
    );
    
    se32p4_e_stage u_e_stage (
        .clk_i,
        .rst_i,
        .pc_d_i(pc_d),
        .pc_plus_d_i(pc_plus_d),
        .immediate_d_i(immediate_d),
        .sel_load_store_d_i(sel_load_store_d),
        .sel_alu_immed_oper_b_d_i(sel_alu_immed_oper_b_d),
        .sel_reg_write_d_i(sel_reg_write_d),
        .is_jump_d_i(is_jump_d),
        .is_branch_d_i(is_branch_d),
        .alu_oper_d_i(alu_oper_d),
        .alu_sign_d_i(alu_sign_d),
        .lsu_sign_d_i(lsu_sign_d),
        .reg_write_en_d_i(reg_write_en_d),
        .memory_en_d_i(memory_en_d),
        .ls_type_d_i(ls_type_d),
        .reg_read_dat1_d_i(reg_read_dat1_d), 
        .reg_read_dat2_d_i(reg_read_dat2_d),
        .reg_write_addr3_d_i(reg_write_addr3_d),
        .csr_write_dat_d_i(csr_write_dat_d),
        .csr_write_dat_e_o(csr_write_dat_e),
        .immediate_e_o(immediate_e),
        .alu_result_e_o(alu_result_e),
        .reg_read_dat2_e_o(reg_read_dat2_e),
        .lsu_sign_e_o(lsu_sign_e),
        .sel_load_store_e_o(sel_load_store_e),
        .pc_sel_e_o(pc_sel_e),
        .pc_plus_e_o(pc_plus_e),
        .pc_target_e_o(pc_target_e),
        .pc_jalr_e_o(pc_jalr_e),
        .sel_reg_write_e_o(sel_reg_write_e),
        .reg_write_addr3_e_o(reg_write_addr3_e),
        .reg_write_en_e_o(reg_write_en_e),
        .memory_en_e_o(memory_en_e),
        .ls_type_e_o(ls_type_e)
    );
    
    se32p4_w_stage u_w_stage (
        .clk_i,
        .rst_i,   
        .immediate_e_i(immediate_e),
        .csr_write_dat_e_i(csr_write_dat_e),
        .alu_result_e_i(alu_result_e),
        .reg_read_dat2_e_i(reg_read_dat2_e),
        .lsu_sign_e_i(lsu_sign_e),
        .pc_plus_e_i(pc_plus_e),
        .pc_target_e_i(pc_target_e),
        .sel_load_store_e_i(sel_load_store_e),
        .sel_reg_write_e_i(sel_reg_write_e),
        .reg_write_addr3_e_i(reg_write_addr3_e),
        .reg_write_dat3_w_o(reg_write_dat3_w),
        .reg_write_en_e_i(reg_write_en_e),
        .memory_en_e_i(memory_en_e),
        .ls_type_e_i(ls_type_e),
        .reg_write_en_w_o(reg_write_en_w),
        .sel_load_store_w_o(sel_load_store_w),
        .reg_write_addr3_w_o(reg_write_addr3_w),
        .lsu_sign_w_o(lsu_sign_w),
        .memory_en_w_o,
        .mem_address_w_o,
        .mem_rdat_i,
        .mem_wdat_w_o,
        .mem_byte_en_w_o(mem_byte_en_w)
    );
    
    se32p4_lsu u_lsu (
        .load_store_i(sel_load_store_w),
        .sign_i(lsu_sign_w),
        .byte_en_i(mem_byte_en_w),
        .read_dat_i(),
        .write_dat_o()
    );

endmodule