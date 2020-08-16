all:
	iverilog alu.v decode.v define.vh execute.v fetch.v hardware_counter.v memory.v path.vh program_counter.v register.v uart.v CPU.v _testbench.v
	./a.out

clean:
	rm a.out output.vcd