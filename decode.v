`include "define.vh"

module decode(
	input [31:0] ins,
	output [6:0] opcode,
	output [2:0] funct3,
	output [4:0] rd,
	output [31:0] imm
);
	wire [31:0] imm_i, imm_s, imm_b, imm_u, imm_j, funct7;

	assign opcode = ins[6:0];
	assign funct3 = ins[14:12];
	assign rd = ins[11:7];
	assign imm = select_imm(imm_i, imm_s, imm_b, imm_u, imm_j, funct7);

	assign imm_i = {{20{ins[31]}}, ins[31:20]};
    assign imm_s = {{20{ins[31]}}, ins[31:25], ins[11:7]};
    assign imm_b = {{20{ins[31]}}, ins[7], ins[30:25], ins[11:8], 1'b0};
    assign imm_u = {ins[31:12], 12'b0};
    assign imm_j = {{12{ins[31]}}, ins[19:12], ins[20], ins[30:21], 1'b0};
	assign funct7 = {{25{ins[31]}}, ins[31:25]};

	function [31:0] select_imm;
		input [31:0] imm_i, imm_s, imm_b, imm_u, imm_j, funct7;

		case (ins[6:0])
			`LUI:
				select_imm = imm_u;
			`AUIPC:
				select_imm = imm_u;
			`JAL:
				select_imm = imm_j;
			`JALR:
				select_imm = imm_j;
			`BRANCH:
				select_imm = imm_b;
			`LOAD:
				select_imm = imm_i;
			`STORE:
				select_imm = imm_s;
			`OPIMM:
				select_imm = imm_i;
			`OP:
				select_imm = funct7;
			default:
				select_imm = 32'b0;
		endcase
	endfunction
endmodule
