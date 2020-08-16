`include "define.vh"

module CPU(
	input sysclk,
	input cpu_resetn,
	output uart_tx
);
	wire [31:0] pc, ins, rreg1, rreg2, imm, ex_result, rmem, nextpc, hc_data;
	wire [6:0] opcode;
	wire [2:0] funct3;
	wire [4:0] rd;
	wire rd_enablen, uart_write_enablen;
	wire [3:0] mem_enablen;
	wire [7:0] uart_data;

	reg [4:0] pipeline_stage;

	reg [31:0] ins_reg_F, pc_reg_F;

	reg [6:0] opcode_reg_D;
	reg [2:0] funct3_reg_D;
	reg [4:0] rd_reg_D;
	reg [31:0] imm_reg_D, pc_reg_D;

	reg [6:0] opcode_reg_E;
	reg [2:0] funct3_reg_E;
	reg [4:0] rd_reg_E;
	reg rd_enablen_reg_E;
	reg [3:0] mem_enablen_reg_E;
	reg [31:0] ex_result_reg_E, nextpc_reg_E, rreg2_reg_E;

	reg [6:0] opcode_reg_M;
	reg [2:0] funct3_reg_M;
	reg [4:0] rd_reg_M;
	reg rd_enablen_reg_M;
	reg [31:0] ex_result_reg_M, nextpc_reg_M;

	always @(negedge cpu_resetn or posedge sysclk) begin
		pipeline_stage <= (~cpu_resetn)? `ST_FET : {pipeline_stage[0], pipeline_stage[4:1]};

		ins_reg_F <= (~cpu_resetn)? 32'b0: (pipeline_stage & `ST_FET)? ins : ins_reg_F;

		opcode_reg_D <= (~cpu_resetn)? 7'b0 : (pipeline_stage & `ST_DEC)? opcode : opcode_reg_D;
		opcode_reg_E <= (~cpu_resetn)? 7'b0 : (pipeline_stage & `ST_EXE)? opcode_reg_D : opcode_reg_E;
		opcode_reg_M <= (~cpu_resetn)? 7'b0 : (pipeline_stage & `ST_MEM)? opcode_reg_E : opcode_reg_M;

		funct3_reg_D <= (~cpu_resetn)? 3'b0 : (pipeline_stage & `ST_DEC)? funct3 : funct3_reg_D;
		funct3_reg_E <= (~cpu_resetn)? 3'b0 : (pipeline_stage & `ST_EXE)? funct3_reg_D : funct3_reg_E;
		funct3_reg_M <= (~cpu_resetn)? 3'b0 : (pipeline_stage & `ST_MEM)? funct3_reg_E : funct3_reg_M;

		rd_reg_D <= (~cpu_resetn)? 5'b0 : (pipeline_stage & `ST_DEC)? rd : rd_reg_D;
		rd_reg_E <= (~cpu_resetn)? 5'b0 : (pipeline_stage & `ST_EXE)? rd_reg_D : rd_reg_E;
		rd_reg_M <= (~cpu_resetn)? 5'b0 : (pipeline_stage & `ST_MEM)? rd_reg_E : rd_reg_M;

		imm_reg_D <= (~cpu_resetn)? 32'b0 : (pipeline_stage & `ST_DEC)? imm : imm_reg_D;

		rreg2_reg_E <= (~cpu_resetn)? 32'b0 : (pipeline_stage & `ST_EXE)? rreg2 : rreg2_reg_E;

		pc_reg_F <= (~cpu_resetn)? 32'h8000 : (pipeline_stage & `ST_FET)? pc : pc_reg_F;
		pc_reg_D <= (~cpu_resetn)? 32'h8000 : (pipeline_stage & `ST_DEC)? pc_reg_F : pc_reg_D;
		nextpc_reg_E <= (~cpu_resetn)? 32'h8000 : (pipeline_stage & `ST_EXE)? nextpc : nextpc_reg_E;
		nextpc_reg_M <= (~cpu_resetn)? 32'h8000 : (pipeline_stage & `ST_MEM)? nextpc_reg_E : nextpc_reg_M;

		rd_enablen_reg_E <= (~cpu_resetn)? 1 : (pipeline_stage & `ST_EXE)? rd_enablen : rd_enablen_reg_E;
		rd_enablen_reg_M <= (~cpu_resetn)? 1 : (pipeline_stage & `ST_MEM)? rd_enablen_reg_E : rd_enablen_reg_M;

		mem_enablen_reg_E <= (~cpu_resetn)? 4'b1111 : (pipeline_stage & `ST_EXE)? mem_enablen : mem_enablen_reg_E;

		ex_result_reg_E <= (~cpu_resetn)? 32'b0 : (pipeline_stage & `ST_EXE)? ex_result : ex_result_reg_E;
		ex_result_reg_M <= (~cpu_resetn)? 32'b0 : (pipeline_stage & `ST_MEM)? ex_result_reg_E : ex_result_reg_M;
	end

	fetch fetch0(
		.pc(pc),
		.ins(ins)
	);

	decode decode0(
		.ins(ins_reg_F),
		.opcode(opcode),
		.funct3(funct3),
		.rd(rd),
		.imm(imm)
	);
	reg_file reg_file0(
		.clk(sysclk),
		.resetn(cpu_resetn),
		.rs1(ins_reg_F[19:15]),
		.rs2(ins_reg_F[24:20]),
		.rd(rd_reg_M),
		.rd_enablen(~|(pipeline_stage & `ST_WBK) | rd_enablen_reg_M),
		.wdata(
			(opcode != `LOAD)? ex_result_reg_M : 
			(funct3 == 3'b000)? {{24{rmem[7]}}, rmem[7:0]} : 
			(funct3 == 3'b001)? {{16{rmem[15]}}, rmem[15:0]} : 
			(funct3 == 3'b010)? rmem : 
			(funct3 == 3'b100)? {24'b0, rmem[7:0]} : 
			(funct3 == 3'b101)? {16'b0, rmem[15:0]} : 
			ex_result_reg_M
		),
		.rreg1(rreg1),	// already reg
		.rreg2(rreg2)
	);

	execute execute0(
		.opcode(opcode_reg_D),
		.funct3(funct3_reg_D),
		.rs1(rreg1),
		.rs2(rreg2),
		.imm(imm_reg_D),
		.pc(pc_reg_D),
		.rd_enablen(rd_enablen),
		.mem_enablen(mem_enablen),
		.result(ex_result),
		.nextpc(nextpc)
	);

	memory memory0(
		.clk(sysclk),
		.address(ex_result_reg_E),
		.wdata(rreg2_reg_E),
		.mem_enablen(~|(pipeline_stage & `ST_MEM) | mem_enablen_reg_E),
		.hc_data(hc_data),
		.rdata(rmem),	// already reg
		.uart_data(uart_data),
		.uart_write_enablen(uart_write_enablen)
	);


	program_counter program_counter0(
		.clk(sysclk),
		.resetn(cpu_resetn),
		.nextpc(nextpc_reg_M),
		.pc(pc)
	);

	hardware_counter hardware_counter0(
		.clk(sysclk),
		.resetn(cpu_resetn),
		.counter(hc_data)
	);

	uart uart0(
		.clk(sysclk),
		.resetn(cpu_resetn),
		.uart_enablen(uart_write_enablen),
		.data(uart_data),
		// .uart_busy(uart_busy),
		.uart_tx(uart_tx)
	);
endmodule