
module se32p4_d_stage 
    import se32p4_pkg::*; 
(
    input logic clk_i,
    input logic rstn_i,
    input logic flush_i,
    input logic load_en_i,

    input logic [31:0] pc_f_i,
    input logic [31:0] pc_plus_f_i,
    input logic [31:0] mem_instr_f_i,

    output logic [31:0] pc_d_o,
    output logic [31:0] pc_plus_d_o,

    output logic [31:0] immediate_d_o,
    
    output sel_lsu_t sel_load_store_d_o,
    output logic sel_alu_immed_oper_b_d_o,
    output sel_wreg_t sel_reg_write_d_o,

    output sel_pc_t is_jump_d_o,
    output branch_t is_branch_d_o,

    output aluop_t alu_oper_d_o,
    output logic alu_sign_d_o,
    output logic lsu_sign_d_o,

    output logic reg_write_en_d_o,
    output mem_rw_en_t memory_en_d_o,
    output load_store_t ls_type_d_o,

    output logic [4:0] reg_read_addr1_d_o, reg_read_addr2_d_o,
    output logic [31:0] reg_read_dat1_d_o, reg_read_dat2_d_o,
    output logic [4:0] reg_write_addr3_d_o,

    input logic reg_write_en_w_i,
    input logic [4:0] reg_write_addr3_w_i,
    input logic [31:0] reg_write_dat3_w_i,

    output csrop_t csr_oper_d_o,
    output logic csr_write_en_d_o,
    output logic sel_csr_read_dat1_addr_d_o
);

    logic [31:0] immediate_d;
    logic [4:0] reg_read_addr1_d, reg_read_addr2_d;

    logic [31:0] mem_instr_d;

    logic [31:0] reg_read_dat1_d;

    logic reg_write_en_w;

    always_ff @(posedge clk_i, negedge rstn_i) begin : f_d_stage
        if (rstn_i == 1'b0 || flush_i == 1'b1) begin
            pc_d_o      <= 32'b0;
            mem_instr_d <= 32'b0;
            pc_plus_d_o <= 32'b0;
        end else if (load_en_i == 1'b1) begin
            pc_d_o      <= pc_f_i;
            mem_instr_d <= mem_instr_f_i;
            pc_plus_d_o <= pc_plus_f_i;
        end
    end

    assign immediate_d_o = immediate_d;

    se32p4_decoder u_decoder (
        .instr_i(mem_instr_d),
        .immediate_o(immediate_d),
        .sel_load_store_o(sel_load_store_d_o),
        .sel_read_dat1_addr_o(sel_csr_read_dat1_addr_d_o),
        .sel_alu_immed_oper_b_o(sel_alu_immed_oper_b_d_o),
        .sel_reg_write_o(sel_reg_write_d_o),
        .is_jump_o(is_jump_d_o),
        .is_branch_o(is_branch_d_o),
        .reg_read_addr1_o(reg_read_addr1_d), 
        .reg_read_addr2_o(reg_read_addr2_d), 
        .reg_write_addr3_o(reg_write_addr3_d_o),
        .alu_oper_o(alu_oper_d_o),
        .alu_sign_o(alu_sign_d_o),
        .lsu_sign_o(lsu_sign_d_o),
        .csr_oper_o(csr_oper_d_o),
        .csr_write_en_o(csr_write_en_d_o),
        .reg_write_en_o(reg_write_en_d_o),
        .memory_en_o(memory_en_d_o),
        .ls_type_o(ls_type_d_o)
    );

    assign reg_read_addr1_d_o = reg_read_addr1_d;
    assign reg_read_addr2_d_o = reg_read_addr2_d;
    
    assign reg_read_dat1_d_o = reg_read_dat1_d;

    assign reg_write_en_w = reg_write_en_w_i & load_en_i;

    se32p4_regfile u_regfile (
        .clk_i,
        .rstn_i,
        .write_en_i(reg_write_en_w),
        .read_addr1_i(reg_read_addr1_d),
        .read_addr2_i(reg_read_addr2_d),
        .write_addr3_i(reg_write_addr3_w_i),
        .read_dat1_o(reg_read_dat1_d),
        .read_dat2_o(reg_read_dat2_d_o),
        .write_dat3_i(reg_write_dat3_w_i)
    );

endmodule