
module uart #(
    parameter int BOARD_CLK     = 100_000_000,
    parameter int BOARD_CLK_MUL = 10,
    parameter int BOARD_CLK_DIV = 20,
    parameter int UART_BAUD     = 9600
) (
    input logic clk_i,
    input logic rstn_i,

    input logic [3:0] byte_en_i,
    input logic read_en_i, write_en_i,

    ouput logic tx_bit_o,
    input logic [31:0] tx_dat_i,
    input logic rx_bit_i,
    output logic [31:0] rx_dat_o
);
    localparam logic [15:0] timer = ((BOARD_CLK * BOARD_CLK_MUL / BOARD_CLK_DIV) / UART_BAUD); 
    logic [15:0] tx_timer, rx_timer;

    typedef enum logic [1:0] { 
        UART_IDLE_ST,
        UART_START_ST,
        UART_DATA_ST,
        UART_STOP_ST
    } uart_states_t;

    uart_states_t cur_tx_state, nxt_tx_state;
    uart_states_t cur_rx_state, nxt_rx_state;

    logic [7:0] tx_fifo, rx_fifo;

    logic [2:0] cur_tx_dat_bit_cnt, nxt_tx_dat_bit_cnt;

    logic tx_req;
    logic tx_ack;

    logic rx_req;
    logic rx_ack;

    always_ff @(posedge clk_i) begin
        if (write_en_i == 1'b1 && byte_en_i[1] == 1'b1) begin
            tx_fifo <= tx_dat_i[15:8];
            // tx_req <= 1'b1;
        end

        if (read_en_i == 1'b1 && byte_en_i[1] == 1'b1) begin
            // rx_ack <= rx_req;
        end
    end

    always_ff @(posedge clk_i, negedge rstn_i) begin
        if (rstn_i == 1'b0) begin
            cur_tx_state <= UART_IDLE_ST;
            cur_tx_dat_bit_cnt <= 3'b0;

            cur_rx_state <= UART_IDLE_ST;
        end else begin
            cur_tx_state <= nxt_tx_state;
            cur_tx_dat_bit_cnt <= nxt_tx_dat_bit_cnt;

            cur_rx_state <= nxt_rx_state;
        end
    end

    always_ff @(posedge clk_i) begin
        if (cur_tx_state == UART_IDLE_ST)
            tx_timer <= timer;
        else if (tx_timer != 16'h0)
            tx_timer <= tx_timer - 1;
        else
            tx_timer <= timer;
    end

    always_comb begin : fsm_to_tx
        nxt_tx_state <= cur_tx_state;
        nxt_tx_dat_bit_cnt <= cur_tx_dat_bit_cnt;
        tx_bit_o <= 1'b1;

        if (tx_timer == 16'h0) begin
            unique case(cur_tx_state)
                UART_IDLE_ST: begin
                    // TODO: when jump to start ?
                    nxt_tx_state <= UART_START_ST;
                end
                UART_START_ST: begin
                    tx_bit_o <= 1'b0;
                    nxt_tx_state <= UART_DATA_ST;
                end
                UART_DATA_ST: begin
                    if (cur_tx_dat_bit_cnt <= 3'h7) begin
                        tx_bit_o <= tx_fifo[cur_tx_dat_bit_cnt]
                        nxt_tx_dat_bit_cnt <= cur_tx_dat_bit_cnt + 1;
                    end 

                    if (cur_tx_dat_bit_cnt == 3'h7)
                        nxt_tx_state <= UART_STOP_ST;
                    end
                end
                UART_STOP_ST: begin
                    nxt_tx_state <= UART_IDLE_ST;
                end
            endcase
        end
    end

endmodule