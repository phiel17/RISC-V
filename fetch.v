`include "define.vh"
`include "path.vh"

module fetch (
	input [31:0] pc,
	output [31:0] ins
);
	reg [7:0] ins_mem[0:131071];

	assign ins = {ins_mem[pc + 2'b11], ins_mem[pc + 2'b10], ins_mem[pc + 2'b01], ins_mem[pc]};

	initial begin
		$readmemh(`INS_TESTPATH, ins_mem);
	end
endmodule
