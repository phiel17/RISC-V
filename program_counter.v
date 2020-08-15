module program_counter (
	input clk, resetn,
	input [31:0] nextpc,
	output reg [31:0] pc
);
	always @(negedge resetn or posedge clk) begin
		if (resetn == 0) pc <= 32'h00008000;
		else if (clk == 1) pc <= nextpc;
	end
endmodule
