module hardware_counter (
	input clk, resetn,
	output reg [31:0] counter
);
	always @(posedge clk or negedge resetn) begin
		if(resetn == 0) begin
			counter <= 32'd0;
		end else begin
			counter <= counter + 1;
		end
	end
endmodule
