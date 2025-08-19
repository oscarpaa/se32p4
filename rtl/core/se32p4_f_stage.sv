
module se32p4_f_stage 
    import se32p4_pkg::*;
(
    input logic clk_i,
    input logic rst_i,

    input logic [31:0] boot_addr_i,
    input logic [31:0] mem_instr_i,
    output logic [31:0] mem_instr_f_o,
    
    input logic sel_pc_increment_2_4_e_i,
    input sel_pc_t pc_sel_e_i,
    
    input logic [31:0] pc_target_e_i,
    input logic [31:0] pc_jalr_e_i,

    output logic [31:0] pc_f_o,
    output logic [31:0] pc_plus_f_o    
);

    logic [31:0] pc_f, pc_next_f, pc_plus_f;
    logic [31:0] mem_instr_f;
    
    always_ff @(posedge clk_i, posedge rst_i) begin
        if (rst_i == 1'b1)
            pc <= boot_addr_i;
        else
            pc <= pc_next;
    end

    assign pc_plus_f = (sel_pc_increment_2_4_e_i == 1'b1) ? pc_f + 2 : pc_f + 4;;
    assign pc_next_f = (pc_sel_e_i == SEL_PC_PLUS)   ? pc_plus_f :
                       (pc_sel_e_i == SEL_PC_TARGET) ? pc_target_e_i : pc_jalr_e_i;

    assign pc_f_o = pc_f;
    assign pc_plus_f_o = pc_plus_f;
    assign mem_instr_f_o = mem_instr_i;

endmodule