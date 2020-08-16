`include "define.vh"
`include "path.vh"

module memory (
	input clk,
	input [31:0] address,
	input [31:0] wdata,
	input [3:0] mem_enablen,
	input [31:0] hc_data,
	output reg [31:0] rdata,
	output [7:0] uart_data,
	output uart_write_enablen
);
	reg [7:0] d_mem[0:131072];

	assign uart_data = wdata[7:0];
	assign uart_write_enablen = (address == `UART_ADDR)? mem_enablen[0] : 1'b1;

	// write
	always @(posedge clk) begin
		if(~mem_enablen[0]) d_mem[address] <= wdata[7:0];
		if(~mem_enablen[1]) d_mem[address + 2'b01] <= wdata[15:8];
		if(~mem_enablen[2]) d_mem[address + 2'b10] <= wdata[23:16];
		if(~mem_enablen[3]) d_mem[address + 2'b11] <= wdata[31:24];

		rdata <= (address == `HC_ADDR)? hc_data : {d_mem[address + 2'b11], d_mem[address + 2'b10], d_mem[address + 2'b01], d_mem[address]};
	end

	initial begin
		$readmemh(`MEM_TESTPATH, d_mem);
	end
endmodule
