module se32p4_lsu 
    import se32p4_pkg::*; 
(
    input sel_lsu_t load_store_i,
    input logic sign_i,
    input logic [3:0] byte_en_i,
    input logic [31:0] unalign_dat_i,
    output logic [31:0] align_dat_o
);

    always_comb begin
        if (load_store_i == LSU_LOAD) begin : load_logic
            unique case (byte_en_i)
                4'b1000: 
                    if (sign_i == 1'b1) begin
                        align_dat_o <= {{24{unalign_dat_i[31]}}, unalign_dat_i[31:24]};
                    end else begin
                        align_dat_o <= {24'b0, unalign_dat_i[31:24]};
                    end
                4'b0100: 
                    if (sign_i == 1'b1) begin
                        align_dat_o <= {{24{unalign_dat_i[23]}}, unalign_dat_i[23:16]};
                    end else begin
                        align_dat_o <= {24'b0, unalign_dat_i[23:16]};
                    end
                4'b0010: 
                    if (sign_i == 1'b1) begin
                        align_dat_o <= {{24{unalign_dat_i[15]}}, unalign_dat_i[15:8]};
                    end else begin
                        align_dat_o <= {24'b0, unalign_dat_i[15:8]};
                    end
                4'b0001: 
                    if (sign_i == 1'b1) begin
                        align_dat_o <= {{24{unalign_dat_i[7]}}, unalign_dat_i[7:0]};
                    end else begin
                        align_dat_o <= {24'b0, unalign_dat_i[7:0]};
                    end
                4'b1100: 
                    if (sign_i == 1'b1) begin
                        align_dat_o <= {{24{unalign_dat_i[31]}}, unalign_dat_i[31:16]};
                    end else begin
                        align_dat_o <= {24'b0, unalign_dat_i[31:16]};
                    end
                4'b0011: 
                    if (sign_i == 1'b1) begin
                        align_dat_o <= {{24{unalign_dat_i[15]}}, unalign_dat_i[15:0]};
                    end else begin
                        align_dat_o <= {24'b0, unalign_dat_i[15:0]};
                    end
                4'b1111:
                    align_dat_o <= unalign_dat_i;
                default: 
                    align_dat_o <= 32'b0;
            endcase
        end else if (load_store_i == LSU_STORE) begin : store_logic
            unique case (byte_en_i)
                4'b1000: align_dat_o <= {unalign_dat_i[7:0], 24'b0};
                4'b0100: align_dat_o <= {8'b0, unalign_dat_i[7:0], 16'b0};
                4'b0010: align_dat_o <= {16'b0, unalign_dat_i[7:0], 8'b0};
                4'b0001: align_dat_o <= {24'b0, unalign_dat_i[7:0]};
                4'b1100: align_dat_o <= {unalign_dat_i[15:0], 16'b0};
                4'b0011: align_dat_o <= {16'b0, unalign_dat_i[15:0]};
                4'b1111: align_dat_o <= unalign_dat_i;
                default: align_dat_o <= 32'b0;
            endcase
        end else 
            align_dat_o <= 32'b0;
    end

endmodule