
module core #(
    parameter bit SIMULATION = 0,
    parameter logic [31:0] BOOT_ADDRESS = 32'b0,
    parameter int MEM_BYTES_LEN = 16 * 1024, // 32 KB

    parameter int BOARD_CLK_FREQ = 100_000_000,
    parameter int BOARD_CLK_MUL  = 10,
    parameter int BOARD_CLK_DIV  = 20,
    parameter int UART_BAUD      = 9600
) (
    input logic board_clk,
    input logic board_rst,

    input logic rx_bit_i,
    output logic tx_bit_o
);
    logic sysrst, sysclk;
    
    assign sysclk = board_clk;
    assign sysrst = board_rst;

    logic [31:0] pc;
    logic [31:0] mem_address;
    logic [3:0] mem_byte_en;
    logic mem_instr_read_en;
    logic core_read_en, mem_read_en, uart_read_en;
    logic core_write_en, mem_write_en, uart_write_en;
    logic [31:0] core_write_dat;
    logic [31:0] core_read_dat, mem_read_dat, uart_rx_dat;
    logic [31:0] mem_read_instr;

    se32p4_core #(
        .BOOT_ADDRESS(BOOT_ADDRESS),
        .MEM_BYTES_LEN(MEM_BYTES_LEN)
    ) u_cpu (
        .clk_i(sysclk),
        .rstn_i(sysrst),
        .pc_o(pc),
        .mem_dat_addr_o(mem_address),
        .mem_byte_en_o(mem_byte_en),
        .mem_instr_read_en_o(mem_instr_read_en),
        .mem_read_en_o(core_read_en),
        .mem_write_en_o(core_write_en),
        .mem_write_dat_o(core_write_dat),
        .mem_read_dat_i(core_read_dat),
        .mem_read_instr_i(mem_read_instr)
    );

    assign core_read_dat = (mem_address < MEM_BYTES_LEN)  ? mem_read_dat  : uart_rx_dat;
    assign mem_read_en   = (mem_address < MEM_BYTES_LEN)  ? core_read_en  : 1'b0;
    assign mem_write_en  = (mem_address < MEM_BYTES_LEN)  ? core_write_en : 1'b0;
    
    // UART0_BASE = MEM_BASE_END
    assign uart_read_en  = (mem_address[31:2] == (MEM_BYTES_LEN >> 2)) ? core_read_en  : 1'b0;
    assign uart_write_en = (mem_address[31:2] == (MEM_BYTES_LEN >> 2)) ? core_write_en : 1'b0;
    
    memory #(
        .SIMULATION(SIMULATION),
        .MEM_BYTES_LEN(MEM_BYTES_LEN)
    ) u_mem (
        .clk_i(sysclk),
        .rstn_i(sysrst),
        .byte_en_i(mem_byte_en),
        .read_addr1_i(pc),
        .write_addr2_i(mem_address),
        .read_addr1_en_i(mem_instr_read_en), 
        .read_addr2_en_i(mem_read_en), 
        .write_en_i(mem_write_en),
        .write_dat_i(core_write_dat),
        .read_dat1_o(mem_read_instr),
        .read_dat2_o(mem_read_dat)
    );

    uart #(
        .BOARD_CLK_FREQ     (BOARD_CLK_FREQ),
        .BOARD_CLK_MUL (BOARD_CLK_MUL),
        .BOARD_CLK_DIV (BOARD_CLK_DIV),
        .UART_BAUD     (UART_BAUD)
    ) u_uart (
        .clk_i(sysclk),
        .rstn_i(sysrst),
        .byte_en_i(mem_byte_en),
        .read_en_i(uart_read_en),
        .write_en_i(uart_write_en),
        .tx_bit_o,
        .tx_dat_i(core_write_dat),
        .rx_bit_i,
        .rx_dat_o(uart_rx_dat)
    );

endmodule