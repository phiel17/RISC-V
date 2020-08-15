`include "define.vh"

module CPU(
	input sysclk,
	input cpu_resetn,
	output uart_tx
);
	wire [31:0] pc, ins, rreg1, rreg2, imm, ex_result, rmem, nextpc, hc_data;
	wire [6:0] opcode;
	wire [2:0] funct3;
	wire [4:0] srcregnum1, srcregnum2, dstregnum;
	wire rd_enablen, uart_write_enablen;
	wire [3:0] mem_enablen;
	wire [7:0] uart_data;

	fetch fetch0(
		.pc(pc),
		.ins(ins)
	);

	decode decode0(
		.ins(ins),
		.opcode(opcode),
		.funct3(funct3),
		.rs1(srcregnum1),
		.rs2(srcregnum2),
		.rd(dstregnum),
		.imm(imm)
	);

	reg_file reg_file0(
		.clk(sysclk),
		.resetn(cpu_resetn),
		.rs1(srcregnum1),
		.rs2(srcregnum2),
		.rd(dstregnum),
		.rd_enablen(rd_enablen),
		.wdata(
			(opcode != `LOAD)? ex_result : 
			(funct3 == 3'b000)? {{24{rmem[7]}}, rmem[7:0]} : 
			(funct3 == 3'b001)? {{16{rmem[15]}}, rmem[15:0]} : 
			(funct3 == 3'b010)? rmem : 
			(funct3 == 3'b100)? {24'b0, rmem[7:0]} : 
			(funct3 == 3'b101)? {16'b0, rmem[15:0]} : 
			ex_result
		),
		.rreg1(rreg1),
		.rreg2(rreg2)
	);

	execute execute0(
		.opcode(opcode),
		.funct3(funct3),
		.rs1(rreg1),
		.rs2(rreg2),
		.imm(imm),
		.pc(pc),
		.rd_enablen(rd_enablen),
		.mem_enablen(mem_enablen),
		.result(ex_result),
		.nextpc(nextpc)
	);

	memory memory0(
		.clk(sysclk),
		.address(ex_result),
		.wdata(rreg2),
		.mem_enablen(mem_enablen),
		.hc_data(hc_data),
		.rdata(rmem),
		.uart_data(uart_data),
		.uart_write_enablen(uart_write_enablen)
	);

	program_counter program_counter0(
		.clk(sysclk),
		.resetn(cpu_resetn),
		.nextpc(nextpc),
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