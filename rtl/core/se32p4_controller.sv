
module se32p4_controller
    import se32p4_pkg::*;
(
    input logic clk_i,
    input logic rstn_i,

    input sel_pc_t pc_sel_e_i,

    input logic reg_write_en_w_i,
    input logic [4:0] reg_read_addr1_e_i, 
    input logic [4:0] reg_read_addr2_e_i, 
    input logic [4:0] reg_write_addr3_w_i,
    output logic forward_oper_a_e_o, forward_oper_b_e_o,
    input sel_wreg_t sel_reg_write_w_i,
    output logic load_en_o,
    output logic flush_o
);
    logic cur_load_state, nxt_load_state;

    logic mem_rdat_active;

    assign mem_rdat_active = (sel_reg_write_w_i == W_REG_READ_DATA) ? 1'b1 : 1'b0;

    assign flush_o = (pc_sel_e_i != SEL_PC_PLUS) ? 1'b1 : 1'b0; 

    always_ff @(posedge clk_i, negedge rstn_i) begin
        if (rstn_i == 1'b0) begin
            cur_load_state <= 1'b0;
        end else begin
            cur_load_state <= nxt_load_state;
        end
    end

    always_comb begin
        nxt_load_state <= cur_load_state;
        load_en_o <= 1'b1;
        if (cur_load_state == 1'b0) begin
            if (mem_rdat_active == 1'b1) begin
                nxt_load_state <= 1'b1;
                load_en_o <= 1'b0;
            end
        end else begin
            nxt_load_state <= 1'b0;
        end
    end
    
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
endmodule