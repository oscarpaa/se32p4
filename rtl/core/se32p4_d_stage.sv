
module se32p4_d_stage 
    import se32p4_pkg::*; 
(
    input logic clk_i,
    input logic rst_i,

    input logic [31:0] pc_f_i,
    input logic [31:0] pc_plus_f_i,
    input logic [31:0] mem_instr_f_i,

    output logic [31:0] pc_d_o,
    output logic [31:0] pc_plus_d_o,

    output logic [31:0] immediate_d_o,
    
    output sel_lsu_t sel_load_store_d_o,
    output logic sel_pc_increment_2_4_d_o,
    output logic sel_alu_immed_oper_b_d_o,
    output sel_wreg_t sel_write_reg_d_o,

    output sel_pc_t is_jump_d_o,
    output branch_t is_branch_d_o

    output aluop_t alu_oper_d_o,
    output logic alu_sign_d_o,
    output logic lsu_sign_d_o,

    output logic reg_write_en_d_o,
    output mem_rw_en_t memory_en_d_o,

    output logic [31:0] reg_read_dat1_d_o, reg_read_dat2_d_o,
    output logic [4:0] reg_write_addr3_d_o,

    input logic [4:0] reg_write_addr3_w_i,
    input logic [31:0] reg_write_dat3_w_i,

    output logic [31:0] csr_write_dat_d_o
);

    logic [31:0] immediate_d;
    logic [4:0] read_addr1_d, read_addr2_d;

    logic [31:0] mem_instr_d;

    csrop_t csr_oper_d;
    logic csr_write_en_d;
    logic sel_csr_read_dat1_addr_d;
    logic [31:0] csr_read_dat_d;

    logic [31:0] read_dat1_d;

    always_ff @(posedge clk_i, posedge rst_i) begin : f_d_stage
        if (rst_i == 1'b1) begin
            pc_d_o      <= 32'b0;
            mem_instr_d <= 32'b0;
            pc_plus_d_o <= 32'b0;
        end else begin
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
        .sel_pc_increment_2_4_o(sel_pc_increment_2_4_d_o),
        .sel_read_dat1_addr_o(sel_csr_read_dat1_addr_d),
        .sel_alu_immed_oper_b_o(sel_alu_immed_oper_b_d_o),
        .sel_write_reg_o(sel_write_reg_d_o),
        .is_jump_o(is_jump_d_o),
        .is_branch_o(is_branch_d_o),
        .reg_read_addr1_o(reg_read_addr1_d), 
        .reg_read_addr2_o(reg_read_addr2_d), 
        .reg_write_addr3_o(reg_write_addr3_d_o),
        .alu_oper_o(alu_oper_d_o),
        .alu_sign_o(alu_sign_d_o),
        .lsu_sign_o(lsu_sign_d_o),
        .csr_oper_o(csr_oper_d),
        .csr_write_en_o(csr_write_en_d),
        .reg_write_en_o(reg_write_en_d_o),
        .memory_en_o(memory_en_d_o)
    );

    assign csr_read_dat_d = (sel_csr_read_dat1_addr_d == 1'b0) ? {27'b0, read_addr1_d} : read_dat1_d;

    se32p4_csr u_csr (
        .clk_i,
        .rst_i,
        .csr_write_en_i(csr_write_en_d),
        .csr_oper_i(csr_oper_d),
        .csr_addr_i(immediate_d),
        .csr_read_dat_i(csr_read_dat_d),
        .csr_write_dat_o(csr_write_dat_d_o)
    );

    assign read_dat1_d_o = read_dat1_d;

    se32p4_regfile u_regfile (
        .clk_i,
        .rst_i,
        .write_en_i(),
        .read_addr1_i(read_addr1_d),
        .read_addr2_i(read_addr2_d),
        .write_addr3_i(write_addr3_w_i),
        .read_dat1_o(read_dat1_d),
        .read_dat2_o(read_dat2_d_o),
        .write_dat3_i(write_dat3_w_i)
    );

endmodule