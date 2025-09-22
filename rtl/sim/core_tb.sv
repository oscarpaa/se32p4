`timescale 1ns / 1ps

module core_tb #(
    parameter bit SIMULATION = 1,
    parameter logic [31:0] BOOT_ADDRESS = 32'b0,
    parameter int MEM_BYTES_LEN = 256,
    
    parameter int BOARD_CLK_FREQ = 100_000_000,
    parameter int BOARD_CLK_MUL  = 1,
    parameter int BOARD_CLK_DIV  = 1,
    parameter int UART_BAUD      = 10_000_000
);
    logic clk, rstn;

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        rstn = 1'b1;
        #2 rstn = 1'b0;
        #10 rstn = 1'b1;
    end

    core #(
        .SIMULATION(SIMULATION),
        .BOOT_ADDRESS(BOOT_ADDRESS),
        .MEM_BYTES_LEN(MEM_BYTES_LEN),
        .BOARD_CLK_FREQ(BOARD_CLK_FREQ),
        .BOARD_CLK_MUL(BOARD_CLK_MUL),
        .BOARD_CLK_DIV(BOARD_CLK_DIV),
        .UART_BAUD(UART_BAUD)
    ) u_core (
        .clk_i(clk),
        .rstn_i(rstn),
        .rx_bit_i(1'b0),
        .tx_bit_o()
    );
endmodule