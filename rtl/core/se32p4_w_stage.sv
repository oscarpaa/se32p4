
module se32p4_w_stage
  import se32p4_pkg::*;
(
    input logic clk_i,
    input logic rst_i,
    
    input logic [31:0] immediate_e_i,

    input logic [31:0] csr_write_dat_e_i,
    input logic [31:0] alu_result_e_i,
    input logic [31:0] reg_read_dat2_e_i,
    input logic lsu_sign_e_i,

    input logic [31:0] pc_plus_e_i,
    input logic [31:0] pc_target_e_i,

	input sel_lsu_t sel_load_store_e_i,
    input sel_wreg_t sel_reg_write_e_i,
    input logic [4:0] reg_write_addr3_e_i,
	output logic [31:0] reg_write_dat3_w_o,

    input logic reg_write_en_e_i,
    input mem_rw_en_t memory_en_e_i,

	output sel_lsu_t sel_load_store_w_o,
	output logic [4:0] reg_write_addr3_w_o,
    output logic lsu_sign_w_o,

    output logic [31:0] mem_address_w_o,
    input  logic [31:0] mem_rdat_i,
    output logic [31:0] mem_wdat_w_o,
	output logic [3:0] mem_byte_en_w_o
);
    logic [31:0] immediate_w;
	logic [31:0] csr_write_dat_w;
	logic [31:0] alu_result_w;
	logic [31:0] pc_plus_w;
	logic [31:0] pc_target_w;
	sel_wreg_t sel_reg_write_w;
	logic reg_write_en_w;
	mem_rw_en_t memory_en_w;

	always_ff @(posedge clk_i, posedge rst_i) begin : e_w_stage
		if (rst_i == 1'b1) begin
			immediate_w <= 32'b0;
			csr_write_dat_w <= 32'b0;
			alu_result_w <= 32'b0;
			mem_wdat_w_o <= 32'b0;
			pc_plus_w <= 32'b0;
			pc_target_w <= 32'b0;
			sel_reg_write_w <= W_REG_NONE;
			reg_write_addr3_w_o <= 5'b0;
			reg_write_en_w <= 1'b0;
			memory_en_w <= '{1'b0, 1'b0};
			sel_load_store_w_o <= LSU_NONE;
			lsu_sign_w_o <= 1'b0;
		end else begin
			immediate_w <= immediate_e_i;
			csr_write_dat_w <= csr_write_dat_e_i;
			alu_result_w <= alu_result_e_i;
			mem_wdat_w_o <= reg_read_dat2_e_i;
			pc_plus_w <= pc_plus_e_i;
			pc_target_w <= pc_target_e_i;
			sel_reg_write_w <= sel_reg_write_e_i;
			reg_write_addr3_w_o <= reg_write_addr3_e_i;
			reg_write_en_w <= reg_write_en_e_i;
			memory_en_w <= memory_en_e_i;
			sel_load_store_w_o <= sel_load_store_e_i;
			lsu_sign_w_o <= lsu_sign_e_i;
		end
	end

	assign mem_address_w_o = alu_result_w;

	always_comb begin : memory_byte_enable
		if (fun3_i == f3_lsb || fun3_i == f3_lbu) begin // sb / lb
			unique case (alu_result_w[1:0])
				2'b11:    mem_byte_en_w_o <= 4'b1000;
				2'b10:    mem_byte_en_w_o <= 4'b0100;
				2'b01:    mem_byte_en_w_o <= 4'b0010;
				default:  mem_byte_en_w_o <= 4'b0001;
			endcase
		end else if (fun3_i == f3_lsh || fun3_i == f3_lhu) begin // sh / lh
			if (alu_result_w[1] == 1'b1)
				mem_byte_en_w_o <= 4'b1100;
			else
				mem_byte_en_w_o <= 4'b0011;
		end else begin // sw / lw
			mem_byte_en_w_o <= 4'b1111;
		end
	end


	always_comb begin : reg_write_select
		unique case (sel_reg_write_w)
			W_REG_ALURES: reg_write_dat3_w_o <= alu_result_w;
			W_REG_READ_DATA: reg_write_dat3_w_o <= mem_rdat_i;
			W_REG_IMMEDIATE: reg_write_dat3_w_o <= immediate_w;
			W_REG_CSR: reg_write_dat3_w_o <= csr_write_dat_w;
			W_REG_PC_PLUS: reg_write_dat3_w_o <= pc_plus_w;
			W_REG_PC_TARGET: reg_write_dat3_w_o <= pc_target_w;
			default: reg_write_dat3_w_o <= 32'b0;
		endcase
	end

endmodule
