module uart (
	input clk,
	input resetn,
	input uart_enablen,
	input [7:0] data,
	output uart_busy,
	output reg uart_tx
);
	reg [3:0] bitcount;
	reg [8:0] shifter;
	wire sending = |bitcount;
	wire uart_busy = |bitcount[3:1];

	// create 115200Hz clock (sysclk: 30000000Hz)
	reg [28:0] d;
	wire [28:0] dInc = d[28] ? (115200) : (115200 - 30000000);
	wire [28:0] dNxt = d + dInc;
	always @(posedge clk or negedge resetn) begin
		if(!resetn) begin
			d <= 29'b0;
		end else begin
			d <= dNxt;
		end
	end
	wire ser_clk = ~d[28];

	always @(posedge clk or negedge resetn) begin
		if(!resetn) begin
			uart_tx <= 1;
			bitcount <= 0;
			shifter <= 0;
		end else begin
			if(~uart_enablen & ~uart_busy) begin
				shifter <= {data[7:0], 1'h0};
				bitcount <= (1 + 8 + 2);
			end

			if(sending & ser_clk) begin
				{shifter, uart_tx} <= {1'h1, shifter};
				bitcount <= bitcount - 1;
			end
		end
	end
endmodule
