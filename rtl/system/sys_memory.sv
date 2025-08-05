
module sys_memory #(
    parameter int MEM_BYTES_LEN = 4096,
    parameter int ADDR_WIDTH = $clog2(MEM_BYTES_LEN)
) (
    input logic clk_i,
    input logic rst_i,
    input logic write_e_i,
    input logic [3:0] byte_e_i,
    input logic [ADDR_WIDTH-1:0] addr_i,
    input logic [31:0] write_dat_i,
    output logic [31:0] read_dat_o
);
    localparam int MEM_HALF_WORDS_LEN = MEM_BYTES_LEN/2;
    
    logic [15:0] SYS_MEMORY [0:MEM_HALF_WORDS_LEN-1];
    logic addr = addr_i[ADDR_WIDTH-1:1];
    
    always_ff @(posedge clk_i, posedge rst_i) begin : write_to_sys_mem
        if (rst_i == 1'b1) begin
            for (int i = 0; i < MEM_HALF_WORDS_LEN; i++) begin
                SYS_MEMORY[i] <= 16'b0;
            end
        end else if (write_e_i == 1'b1) begin
            if (byte_e_i[0] == 1'b1) begin
                SYS_MEMORY[addr][7:0] <= write_dat_i[7:0];
            end
            if (byte_e_i[1] == 1'b1) begin
                SYS_MEMORY[addr][15:8] <= write_dat_i[15:8];
            end
            if ((addr + 1) <= (MEM_HALF_WORDS_LEN - 1)) begin
                if (byte_e_i[2] == 1'b1) begin
                    SYS_MEMORY[addr + 1][7:0] <= write_dat_i[23:16];
                end           
                if (byte_e_i[3] == 1'b1) begin
                    SYS_MEMORY[addr + 1][15:8] <= write_dat_i[31:24];
                end
            end
        end
    end
    
    always_ff @(posedge clk_i, posedge rst_i) begin : read_from_sys_mem
        if (rst_i == 1'b1) read_dat_o <= 32'b0;
        else if (write_e_i == 1'b0) begin
            read_dat_o[15:0] <= SYS_MEMORY[addr];
            if ((addr + 1) <= (MEM_HALF_WORDS_LEN - 1)) begin
                read_dat_o[31:16] <= SYS_MEMORY[addr + 1];
            end else begin
                read_dat_o[31:16] <= 16'b0;
            end
        end
    end

endmodule