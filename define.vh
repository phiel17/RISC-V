// flag
`define ENABLE	1'b1
`define DISABLE	1'b0

// opcodes
`define LUI		7'b0110111
`define AUIPC	7'b0010111
`define JAL		7'b1101111
`define JALR	7'b1100111
`define BRANCH	7'b1100011
`define LOAD	7'b0000011
`define STORE	7'b0100011
`define OPIMM	7'b0010011
`define OP		7'b0110011

// pipeline stages
`define ST_FET	5'b10000
`define ST_DEC	5'b01000
`define ST_EXE	5'b00100
`define ST_MEM	5'b00010
`define ST_WBK	5'b00001

// hardware counter/UART address
`define HC_ADDR		32'hffffff00
`define UART_ADDR	32'hf6fff070
