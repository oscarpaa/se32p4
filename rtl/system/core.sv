
module core #(
    parameter bit SIMULATION = 0,
    parameter logic [31:0] BOOT_ADDRESS = 32'b0,
    parameter int MEM_BYTES_LEN = 4096
) (
    input logic clk_i,
    input logic rstn_i
);

    logic [31:0] pc;
    logic [31:0] mem_address;
    logic [3:0] mem_byte_en;
    logic mem_read_en;
    logic mem_write_en;
    logic [31:0] mem_write_dat;
    logic [31:0] mem_read_dat;
    logic [31:0] mem_read_instr;


    se32p4_core #(.BOOT_ADDRESS(BOOT_ADDRESS)) u_cpu (
        .clk_i,
        .rstn_i,
        .pc_o(pc),
        .mem_address_o(mem_address),
        .mem_byte_en_o(mem_byte_en),
        .mem_read_en_o(mem_read_en),
        .mem_write_en_o(mem_write_en),
        .mem_write_dat_o(mem_write_dat),
        .mem_read_dat_i(mem_read_dat),
        .mem_read_instr_i(mem_read_instr)
    );
    
    memory #(
        .SIMULATION(SIMULATION),
        .MEM_BYTES_LEN(MEM_BYTES_LEN)
    ) u_mem (
        .clk_i,
        .rstn_i,
        .byte_en_i(mem_byte_en),
        .read_addr1_i(pc),
        .write_addr2_i(mem_address),
        .read_addr1_en_i(1'b1), 
        .read_addr2_en_i(mem_read_en), 
        .write_en_i(mem_write_en),
        .write_dat_i(mem_write_dat),
        .read_dat1_o(mem_read_instr),
        .read_dat2_o(mem_read_dat)
    );

endmodule