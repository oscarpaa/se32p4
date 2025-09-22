
module uart #(
    parameter int BOARD_CLK_FREQ = 100_000_000,
    parameter int BOARD_CLK_MUL  = 10,
    parameter int BOARD_CLK_DIV  = 20,
    parameter int UART_BAUD      = 9600
) (
    input logic clk_i,
    input logic rstn_i,

    input logic [3:0] byte_en_i,
    input logic read_en_i, write_en_i,

    output logic tx_bit_o,
    input logic [31:0] tx_dat_i,
    input logic rx_bit_i,
    output logic [31:0] rx_dat_o
);
    localparam logic [15:0] timer = ((BOARD_CLK_FREQ * BOARD_CLK_MUL / BOARD_CLK_DIV) / UART_BAUD); 
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
    logic [2:0] cur_rx_dat_bit_cnt, nxt_rx_dat_bit_cnt;

    logic tx_req, cur_tx_start, nxt_tx_start;
    logic rx_req, cur_rx_start, nxt_rx_start;

    always_ff @(posedge clk_i) begin
        if (write_en_i == 1'b1 && byte_en_i[1] == 1'b1) begin
            tx_fifo <= tx_dat_i[15:8];
            tx_req <= 1'b1;
        end else
            tx_req <= 1'b0;

        if (read_en_i == 1'b1 && byte_en_i[1] == 1'b1) begin
            rx_req <= 1'b1;
        end else
            rx_req <= 1'b0;
    end
    
    assign rx_dat_o = {timer, rx_fifo, 6'b0, cur_rx_start, cur_tx_start};

    always_ff @(posedge clk_i, negedge rstn_i) begin
        if (rstn_i == 1'b0) begin
            cur_tx_start <= 1'b0;
            cur_tx_state <= UART_IDLE_ST;
            cur_tx_dat_bit_cnt <= 3'b0;

            cur_rx_start <= 1'b0;
            cur_rx_state <= UART_IDLE_ST;
            rx_fifo <= 8'b0;
            cur_rx_dat_bit_cnt <= 3'b0;
        end else begin
            cur_tx_start <= nxt_tx_start;
            cur_tx_state <= nxt_tx_state;
            cur_tx_dat_bit_cnt <= nxt_tx_dat_bit_cnt;

            cur_rx_start <= nxt_rx_start;
            cur_rx_state <= nxt_rx_state;
            rx_fifo[cur_rx_dat_bit_cnt] <= rx_bit_i;
            cur_rx_dat_bit_cnt <= nxt_rx_dat_bit_cnt;
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
        nxt_tx_start <= cur_tx_start;
        nxt_tx_state <= cur_tx_state;
        nxt_tx_dat_bit_cnt <= cur_tx_dat_bit_cnt;
        tx_bit_o <= 1'b1;

        unique case(cur_tx_state)
            UART_IDLE_ST: begin
                if (tx_req == 1'b1) begin
                    nxt_tx_start <= 1'b1;
                    nxt_tx_state <= UART_START_ST;
                end
            end
            UART_START_ST: begin
                tx_bit_o <= 1'b0;
                if (tx_timer == 16'h0)
                    nxt_tx_state <= UART_DATA_ST;
            end
            UART_DATA_ST: begin
                if (cur_tx_dat_bit_cnt <= 3'h7) begin
                    tx_bit_o <= tx_fifo[cur_tx_dat_bit_cnt];
                    if (tx_timer == 16'h0)
                        nxt_tx_dat_bit_cnt <= cur_tx_dat_bit_cnt + 1;
                end 

                if (cur_tx_dat_bit_cnt == 3'h7) begin
                    if (tx_timer == 16'h0)
                        nxt_tx_state <= UART_STOP_ST;
                end
            end
            UART_STOP_ST: begin
                if (tx_timer == 16'h0) begin
                    nxt_tx_state <= UART_IDLE_ST;
                    nxt_tx_start <= 1'b0;
                end
            end
        endcase
    end

    always_ff @(posedge clk_i) begin
        if (cur_rx_state == UART_IDLE_ST)
            rx_timer <= {1'b0, timer[15:1]}; // timer / 2
        else if (rx_timer != 16'h0)
            rx_timer <= rx_timer - 1;
        else
            rx_timer <= timer;
    end

    always_comb begin : fsm_to_rx
        nxt_rx_start <= cur_rx_start;
        nxt_rx_state <= cur_rx_state;
        nxt_rx_dat_bit_cnt <= cur_rx_dat_bit_cnt;

        unique case(cur_rx_state)
            UART_IDLE_ST: begin
                nxt_rx_start <= 1'b0;
                if (rx_req == 1'b1) begin
                    nxt_rx_state <= UART_START_ST;
                end
            end
            UART_START_ST: begin
                if (rx_timer == 16'h0)
                    nxt_rx_state <= UART_DATA_ST;
            end
            UART_DATA_ST: begin
                if (cur_rx_dat_bit_cnt <= 3'h7) begin
                    if (rx_timer == 16'h0)
                        nxt_rx_dat_bit_cnt <= cur_rx_dat_bit_cnt + 1;
                end 

                if (cur_rx_dat_bit_cnt == 3'h7) begin
                    if (rx_timer == 16'h0)
                        nxt_rx_state <= UART_STOP_ST;
                end
            end
            UART_STOP_ST: begin
                if (rx_timer == 16'h0) begin
                    nxt_rx_state <= UART_IDLE_ST;
                    nxt_rx_start <= 1'b1;
                end
            end
        endcase
    end

endmodule