`include "define.vh"

module execute (
	input [6:0] opcode,
	input [2:0] funct3,
	input [31:0] rs1, rs2,
	input [31:0] imm,
	input [31:0] pc,
	output rd_enablen,
	output [3:0] mem_enablen,
	output [31:0] result, nextpc
);
	wire [31:0] alu_result;
	wire branch_flag;

	assign result = calc_result(opcode, alu_result, pc + 32'd4);
	assign rd_enablen = calc_rd_enablen(opcode);
	assign mem_enablen = calc_mem_enablen(opcode, funct3);
	assign branch_flag = calc_branch_flag(opcode, |alu_result);
	assign nextpc = (branch_flag)? alu_result : pc + 32'd4;

	function [31:0] calc_result;
		input [6:0] opcode;
		input [31:0] alu_result, pc4;

		case (opcode)
			`JAL: calc_result = pc4;
			`JALR: calc_result = pc4;
			default: calc_result = alu_result;
		endcase
	endfunction

	function calc_rd_enablen;
		input [6:0] opcode;

		case (opcode)
			`BRANCH: calc_rd_enablen = 1'b1;
			`STORE: calc_rd_enablen = 1'b1;
			default: calc_rd_enablen = 1'b0;
		endcase
	endfunction

	function [3:0] calc_mem_enablen;
		input [6:0] opcode;
		input [2:0] funct3;

		if(opcode == `STORE) begin
			case (funct3)
				3'b000: calc_mem_enablen = 4'b1110;
				3'b001: calc_mem_enablen = 4'b1100;
				3'b010: calc_mem_enablen = 4'b0000;
				default: calc_mem_enablen = 4'b1111;
			endcase
		end else begin
			calc_mem_enablen = 4'b1111;
		end
	endfunction

	function calc_branch_flag;
		input [6:0] opcode;
		input alu_result_or;

		case (opcode)
			`JAL: calc_branch_flag = 1'b1;
			`JALR: calc_branch_flag = 1'b1;
			`BRANCH: calc_branch_flag = alu_result_or;
			default: calc_branch_flag = 1'b0;
		endcase
	endfunction

	alu alu0(
		.opcode(opcode),
		.funct3(funct3),
		.rs1(rs1),
		.rs2(rs2),
		.imm(imm),
		.pc(pc),
		.alu_result(alu_result)
	);
endmodule
