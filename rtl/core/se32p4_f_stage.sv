module se32p4_f_stage 
    import se32p4_pkg::*;
(
    input logic clk_i,
    input logic rst_i,

    input logic [31:0] boot_addr_i,
    input logic [31:0] mem_dat_i,
    output logic [31:0] mem_dat_o,
    
    input logic compress_i,
    input sel_pc_t pc_sel_if_i,
    input logic [31:0] pc_target_if_i,
    input logic [31:0] pc_jalr_if_i,
    output logic [31:0] pc_if_o,
    output logic [31:0] pc_plus_if_o    
);
    logic [31:0] pc, pc_next, pc_plus;
    
    always_ff @(posedge clk_i, posedge rst_i) begin
        if (rst_i == 1'b1)
            pc <= boot_addr_i;
        else
            pc <= pc_next;
    end
    
    assign pc_plus = compress_i == 1'b1 ? pc + 2 : pc + 4;
    assign pc_next = (pc_sel_if_i == SEL_PC_PLUS) ? pc_plus :
                     (pc_sel_if_i == SEL_PC_TARGET) ? pc_target_if_i : pc_jalr_if_i;
    
    assign pc_if_o = pc;
    assign pc_plus_if_o = pc_plus;

endmodule