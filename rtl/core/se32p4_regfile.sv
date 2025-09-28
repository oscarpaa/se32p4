
module se32p4_regfile (
    input logic clk_i,
    input logic rstn_i,
    input logic write_en_i,
    input logic [4:0] read_addr1_i, read_addr2_i, write_addr3_i,
    output logic [31:0] read_dat1_o, read_dat2_o,
    input logic [31:0] write_dat3_i
);
    logic [31:0] REGISTER_MEM [31:0];
    
    always_ff @(negedge clk_i, negedge rstn_i) begin : write_to_reg
        if (rstn_i == 1'b0) begin
            REGISTER_MEM <= '{default: 32'b0};
        end else if (write_en_i == 1'b1) begin
            if (write_addr3_i != 5'b0) begin
                REGISTER_MEM[write_addr3_i] <= write_dat3_i;
            end
        end
    end
    
    assign read_dat1_o = (read_addr1_i == 5'b0) ? 32'b0 : REGISTER_MEM[read_addr1_i];
    assign read_dat2_o = (read_addr2_i == 5'b0) ? 32'b0 : REGISTER_MEM[read_addr2_i];

endmodule