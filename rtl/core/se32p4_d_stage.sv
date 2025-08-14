module se32p4_d_stage (
    input logic clk_i,
    input logic rst_i,
    input logic [31:0] mem_dat_i
);

    se32p4_decoder u_decoder (
        
    );

    se32p4_csr u_csr (
        .clk_i,
        .rst_i,
        .csr_write_e_i(),
        .csr_oper_i(),
        .csr_addr_i(),
        .csr_read_dat_i(),
        .csr_write_dat_o()
    );

    se32p4_regfile u_regfile (
        .clk_i,
        .rst_i,
        .read_addr1_i(),
        .read_addr2_i(),
        .write_addr3_i(),
        .read_dat1_o(),
        .read_dat2_o(),
        .write_dat3_i()
    );
    

endmodule