
module memory #(
    parameter int MEM_BYTES_LEN = 4096
) (
    input logic clk_i,
    input logic rst_i,
    input logic [3:0] byte_en_i,
    input logic [31:0] read_addr1_i,
    input logic [31:0] write_addr2_i,
    input logic read_addr1_en_i, read_addr2_en_i, write_en_i,
    input logic [31:0] write_dat_i,
    output logic [31:0] read_dat1_o,
    output logic [31:0] read_dat2_o

);
    localparam int ADDR_WIDTH = $clog2(MEM_BYTES_LEN);
    localparam int MEM_HALF_WORDS_LEN = MEM_BYTES_LEN/2;
    
    logic [15:0] SYS_MEMORY [0:MEM_HALF_WORDS_LEN-1];
    logic addr1 = read_addr1_i[ADDR_WIDTH-1:1];
    logic addr2 = write_addr2_i[ADDR_WIDTH-1:1];
    
    always_ff @(posedge clk_i, posedge rst_i) begin : write_to_sys_mem
        if (rst_i == 1'b1) begin
            for (int i = 0; i < MEM_HALF_WORDS_LEN; i++)
                SYS_MEMORY[i] <= 16'b0;
                
        end else if (write_en_i == 1'b1) begin
            if (byte_en_i[0] == 1'b1)
                SYS_MEMORY[addr2][7:0] <= write_dat_i[7:0];
                
            if (byte_en_i[1] == 1'b1)
                SYS_MEMORY[addr2][15:8] <= write_dat_i[15:8];
                
            if ((addr2 + 1) <= (MEM_HALF_WORDS_LEN - 1)) begin
                if (byte_en_i[2] == 1'b1)
                    SYS_MEMORY[addr2 + 1][7:0] <= write_dat_i[23:16];
                       
                if (byte_en_i[3] == 1'b1)
                    SYS_MEMORY[addr2 + 1][15:8] <= write_dat_i[31:24];
            end
        end
    end
    
    always_ff @(posedge clk_i, posedge rst_i) begin : read_from_sys_mem_a2
        if (rst_i == 1'b1) read_dat2_o <= 32'b0;
        else if (read_addr2_en_i == 1'b1) begin
            read_dat2_o[15:0] <= SYS_MEMORY[addr2];
            if ((addr2 + 1) <= (MEM_HALF_WORDS_LEN - 1))
                read_dat2_o[31:16] <= SYS_MEMORY[addr2 + 1];
            else
                read_dat2_o[31:16] <= 16'b0;
        end
    end
    
    always_ff @(posedge clk_i, posedge rst_i) begin : read_from_sys_mem_a1
        if (rst_i == 1'b1) read_dat1_o <= 32'b0;
        else if (read_addr1_en_i == 1'b1) begin
            read_dat1_o[15:0] <= SYS_MEMORY[addr1];
            if ((addr1 + 1) <= (MEM_HALF_WORDS_LEN - 1))
                read_dat1_o[31:16] <= SYS_MEMORY[addr1 + 1];
            else
                read_dat1_o[31:16] <= 16'b0;
        end
    end

endmodule