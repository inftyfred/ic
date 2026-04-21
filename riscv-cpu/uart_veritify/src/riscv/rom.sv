`timescale 1ns/1ps

module rom #(
	parameter FILE 	= "ri32ui-p-addi.txt",
	parameter AW	=	32				 ,
	parameter DW	=	32
)(
	input	logic		clk,
	input	logic		rst_n,
	input	logic	[AW-1:0]	instr_addr,
	output	logic	[DW-1:0]	instr_out
);


initial begin
	$readmemh(FILE, rom_mem);
end

logic	[DW-1:0]		rom_mem[0:4095];


always_comb begin
	instr_out	= rom_mem[instr_addr[AW-1:2]];
end

endmodule
