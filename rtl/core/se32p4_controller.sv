
module se32p4_controller
    import se32p4_pkg::*;
(
    input logic clk_i, 
    input logic rstn_i,

    input logic reg_write_en_w_i,
    input logic [4:0] reg_read_addr1_e_i, 
    input logic [4:0] reg_read_addr2_e_i, 
    input logic [4:0] reg_write_addr3_w_i,
    output logic forward_oper_a_e_o, forward_oper_b_e_o,

    input logic [31:0] alu_result_e_i, /* and range alu_result_e_i */
    input sel_wreg_t sel_reg_write_e_i,
    output logic load_active_o
);
    
    always_comb begin
        if (reg_write_en_w_i == 1'b1) begin
            if ((reg_read_addr1_e_i == reg_write_addr3_w_i) && reg_read_addr1_e_i != 5'h0)
                forward_oper_a_e_o <= 1'b1;
            else
                forward_oper_a_e_o <= 1'b0;
            
            if ((reg_read_addr2_e_i == reg_write_addr3_w_i) && reg_read_addr2_e_i != 5'h0)
                forward_oper_b_e_o <= 1'b1;
            else
                forward_oper_b_e_o <= 1'b0;
        end else begin
            forward_oper_a_e_o <= 1'b0;
            forward_oper_b_e_o <= 1'b0;
        end
    end

    always_ff @(posedge clk_i, negedge rstn_i) begin
        if (rstn_i == 1'b0) begin
            load_active_o <= 1'b0;
        end else begin  
            load_active_o <= (sel_reg_write_e_i == W_REG_READ_DATA) ? 1'b1 : 1'b0; 
        end

    end

endmodule