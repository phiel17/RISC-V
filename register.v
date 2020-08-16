module reg_file (
	input clk,
	input resetn,
	input [4:0] rs1, rs2, rd,
	input rd_enablen,
	input [31:0] wdata,
	output reg [31:0] rreg1, rreg2
);
	reg [31:0] regfile[0:31];

	always @(negedge resetn or posedge clk) begin
		if(resetn == 0) begin
			regfile[0] <= 32'h00000000;
			rreg1 <= 32'b0;
			rreg2 <= 32'b0;
		end else begin
			if(|rd & ~rd_enablen) regfile[rd] <= wdata;
			rreg1 <= regfile[rs1];
			rreg2 <= regfile[rs2];
		end
	end

	// for gtkwave
	wire [31:0] reg0 = regfile[0];
	wire [31:0] reg1 = regfile[1];
	wire [31:0] reg2 = regfile[2];
	wire [31:0] reg3 = regfile[3];
	wire [31:0] reg4 = regfile[4];
	wire [31:0] reg5 = regfile[5];
	wire [31:0] reg6 = regfile[6];
	wire [31:0] reg7 = regfile[7];
	wire [31:0] reg8 = regfile[8];
	wire [31:0] reg9 = regfile[9];
	wire [31:0] reg10 = regfile[10];
	wire [31:0] reg11 = regfile[11];
	wire [31:0] reg12 = regfile[12];
	wire [31:0] reg13 = regfile[13];
	wire [31:0] reg14 = regfile[14];
	wire [31:0] reg15 = regfile[15];
	wire [31:0] reg16 = regfile[16];
	wire [31:0] reg17 = regfile[17];
	wire [31:0] reg18 = regfile[18];
	wire [31:0] reg19 = regfile[19];
	wire [31:0] reg20 = regfile[20];
	wire [31:0] reg21 = regfile[21];
	wire [31:0] reg22 = regfile[22];
	wire [31:0] reg23 = regfile[23];
	wire [31:0] reg24 = regfile[24];
	wire [31:0] reg25 = regfile[25];
	wire [31:0] reg26 = regfile[26];
	wire [31:0] reg27 = regfile[27];
	wire [31:0] reg28 = regfile[28];
	wire [31:0] reg29 = regfile[29];
	wire [31:0] reg30 = regfile[30];
	wire [31:0] reg31 = regfile[31];
endmodule
