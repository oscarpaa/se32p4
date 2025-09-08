
module se32p4_f_stage 
    import se32p4_pkg::*;
#(
    parameter logic [31:0] BOOT_ADDRESS = 32'b0
) (
    input logic clk_i,
    input logic rstn_i,
    input logic load_en_i,

    input logic [31:0] mem_instr_i,
    output logic [31:0] mem_instr_f_o,
    
    input sel_pc_t pc_sel_e_i,
    
    input logic [31:0] pc_target_e_i,
    input logic [31:0] pc_jalr_e_i,

    output logic [31:0] pc_f_o,
    output logic [31:0] pc_plus_f_o,
    output logic [31:0] pc_next_f_o
);
    logic is_compressed;

    logic [31:0] pc_f, pc_next_f, pc_plus_f;
    
    always_ff @(posedge clk_i, negedge rstn_i) begin
        if (rstn_i == 1'b0) begin
            pc_f <= BOOT_ADDRESS;
        end else if (load_en_i == 1'b1) begin
            pc_f <= pc_next_f;
        end
    end
    
    assign pc_next_f = (rstn_i == 1'b0)              ? BOOT_ADDRESS  : 
                       (load_en_i == 1'b0)           ? pc_f          :
                       (pc_sel_e_i == SEL_PC_PLUS)   ? pc_plus_f     :
                       (pc_sel_e_i == SEL_PC_TARGET) ? pc_target_e_i : pc_jalr_e_i;

    assign pc_plus_f = (is_compressed == 1'b1) ? pc_f + 2 : pc_f + 4;

    assign pc_next_f_o = pc_next_f;
    assign pc_f_o = pc_f;
    assign pc_plus_f_o = pc_plus_f;

    se32p4_c_decoder u_c_decoder (
        .instr_i(mem_instr_i),
        .instr_o(mem_instr_f_o),
        .is_compressed_o(is_compressed)
    );

endmodule