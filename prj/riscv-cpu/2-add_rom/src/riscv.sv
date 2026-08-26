`timescale 1ns/1ps


module riscv #(
	parameter	FILE	="rv32ui-p-addi.txt",
	parameter	AW		=32,
	parameter	DW		=32
)(
	input	logic	clk,
	input	logic	rst_n
);

logic				jump_en;
logic	[AW-1:0]	jump_addr;
logic	[AW-1:0]	pc_pointer;
logic	[AW-1:0]	instr_out;

assign	jump_en		= 1'b0;
assign	jump_addr 	= 'h0;

pc_counter #(
  	.AW(AW)
  ) u1_pc_counter(
  	.clk(clk),
  	.rst_n(rst_n),
  	.jump_en(jump_en),
  	.jump_addr(jump_addr),
  	.pc_pointer(pc_pointer)
);

rom #(
	.FILE(FILE)	,
	.AW(AW)	  	,
	.DW(DW)	  	
) u1_rom(
.clk(clk),
.rst_n(rst_n),
.instr_addr(pc_pointer),
.instr_out(instr_out)
);


endmodule
