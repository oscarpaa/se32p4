
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

    input logic [31:0] instr_i,
    output logic [31:0] immediate_d_o,

    output sel_pc_t is_jump_d_o,
    output branch_t is_branch_d_o
);

    logic [31:0] mem_instr_d; 

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

    logic [31:0] immediate;

    logic [4:0] read_addr1, read_addr2, write_addr3;

    se32p4_decoder u_decoder (
        .instr_i,
        .immediate_o(immediate),
        .sel_load_store_o,
        .sel_pc_increment_2_4_o,
        .sel_read_dat1_addr_o,
        .sel_alu_immed_oper_b_o,
        .sel_write_reg_o,
        .is_jump_o(is_jump_d_o),
        .is_branch_o(is_branch_d_o),
        .read_addr1_o(read_addr1), 
        .read_addr2_o(read_addr2), 
        .write_addr3_o(write_addr3),
        .alu_oper_o,
        .alu_sign_o,
        .lsu_sign_o,
        .csr_oper_o,
        .csr_write_e_o,
        .reg_write_e_o,
        .mem_enable_o
    );

    se32p4_csr u_csr (
        .clk_i,
        .rst_i,
        .csr_write_e_i(),
        .csr_oper_i(),
        .csr_addr_i(immediate),
        .csr_read_dat_i(),
        .csr_write_dat_o()
    );

    se32p4_regfile u_regfile (
        .clk_i,
        .rst_i,
        .read_addr1_i(read_addr1),
        .read_addr2_i(read_addr2),
        .write_addr3_i(write_addr3),
        .read_dat1_o(),
        .read_dat2_o(),
        .write_dat3_i()
    );

endmodule