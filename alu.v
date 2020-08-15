`include "define.vh"

module alu (
	input [6:0] opcode,
	input [2:0] funct3,
	input [31:0] rs1,
	input [31:0] rs2,
	input [31:0] imm, 
	input [31:0] pc,
	output [31:0] alu_result
);
	assign alu_result = alu_calc(opcode, funct3, rs1, rs2, imm, pc);

	function [31:0] alu_calc;
		input [6:0] opcode;
		input [2:0] funct3;
		input [31:0] rs1, rs2, imm, pc;

		case (opcode)
			`LUI:
				alu_calc = imm;
			`AUIPC:
				alu_calc = pc + imm;
			`JAL:
				alu_calc = pc + imm;
			`JALR:
				alu_calc = rs1 + imm;
			`BRANCH:
				case (funct3)
					3'b000:	alu_calc = (rs1 == rs2)? pc + imm : 32'b0;
					3'b001:	alu_calc = (rs1 != rs2)? pc + imm : 32'b0;
					3'b100:	alu_calc = ($signed(rs1) < $signed(rs2))? pc + imm : 32'b0;
					3'b101:	alu_calc = ($signed(rs1) >= $signed(rs2))? pc + imm : 32'b0;
					3'b110:	alu_calc = (rs1 < rs2)? pc + imm : 32'b0;
					3'b111:	alu_calc = (rs1 >= rs2)? pc + imm : 32'b0;
					default: alu_calc = 32'b0;
				endcase
				// alu_calc = pc + imm;
			`LOAD:
				alu_calc = rs1 + imm;
			`STORE:
				alu_calc = rs1 + imm;
			`OPIMM:
				case (funct3)
					3'b000:	// ADDI
						alu_calc = rs1 + imm;
					3'b010:	// SLTI
						alu_calc = $signed(rs1) < $signed(imm);
					3'b011:	// SLTIU
						alu_calc = rs1 < imm;
					3'b100:	// XORI
						alu_calc = rs1 ^ imm;
					3'b110:	// ORI
						alu_calc = rs1 | imm;
					3'b111:	// ANDI
						alu_calc = rs1 & imm;
					3'b001:	// SLLI
						alu_calc = rs1 << imm[4:0];
					3'b101:	// SRLI / SRAI
						alu_calc = (imm[10])? $signed(rs1) >>> imm[4:0] : $signed(rs1) >> imm[4:0];
				endcase
			`OP:
				case (funct3)
					3'b000:	// ADD / SUB
						alu_calc = (imm[5])? $signed(rs1) - $signed(rs2) : rs1 + rs2;
					3'b010:	// SLT
						alu_calc = $signed(rs1) < $signed(rs2);
					3'b011:	// SLTU
						alu_calc = rs1 < rs2;
					3'b100:	// XOR
						alu_calc = rs1 ^ rs2;
					3'b110:	// OR
						alu_calc = rs1 | rs2;
					3'b111:	// AND
						alu_calc = rs1 & rs2;
					3'b001:	// SLL
						alu_calc = rs1 << rs2[4:0];
					3'b101:	// SRL / SRA
						alu_calc = (imm[5])? $signed(rs1) >>> rs2[4:0] : $signed(rs1) >> rs2[4:0];
				endcase

			default:
				alu_calc = 32'b0;
		endcase
	endfunction

endmodule
