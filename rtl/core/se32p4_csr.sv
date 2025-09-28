module se32p4_csr
    import se32p4_pkg::*;
(
    input logic clk_i,
    input logic rstn_i,
    input logic csr_write_en_i,
    input csrop_t csr_oper_i,
    input logic [11:0] csr_addr_i,
    input logic [31:0] csr_read_dat_i,
    output logic [31:0] csr_write_dat_o

);
    logic [31:0] MISA;
    logic [31:0] MSTATUS;
    
    logic [31:0] CSR_I, CSR_O;
    
    always_comb begin
        unique case (csr_addr_i)
            CSR_MSTATUS: CSR_O <= MSTATUS;
            CSR_MISA:    CSR_O <= MISA;
            default:     CSR_O <= 32'b0;
        endcase
    end
    
    always_comb begin       
        unique case (csr_oper_i)
            CSROP_RW: CSR_I <= csr_read_dat_i;
            CSROP_RS: CSR_I <= CSR_O | csr_read_dat_i;
            CSROP_RC: CSR_I <= CSR_O & (~csr_read_dat_i);
            default:  CSR_I <= 32'b0;
        endcase
    end
    
    always_ff @(posedge clk_i, negedge rstn_i) begin
        if (rstn_i == 1'b0) begin
            MSTATUS <= 32'h0;
            MISA    <= 32'h40000100;
        end else if (csr_write_en_i == 1'b1) begin  
            case (csr_addr_i)
                CSR_MSTATUS: MSTATUS <= CSR_I;
                CSR_MISA:    MISA    <= CSR_I;
            endcase
        end
    end
    
    assign csr_write_dat_o = CSR_O;
    
endmodule