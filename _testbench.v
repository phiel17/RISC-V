`timescale 1ns / 1ps

module testbench;
	reg clk;
	reg resetn;
	wire uart_tx;

	parameter CYCLE = 100;

	always #(CYCLE / 2) clk = ~clk;

	CPU cpu0(
		.sysclk(clk),
		.cpu_resetn(resetn),
		.uart_tx(uart_tx)
	);

	initial begin
		$dumpfile("output.vcd");
		$dumpvars(0, cpu0);

		#10	clk = 1'd0;
			resetn = 1'd0;
		#(CYCLE) resetn = 1'd1;
		#(40000) $finish;
	end
endmodule