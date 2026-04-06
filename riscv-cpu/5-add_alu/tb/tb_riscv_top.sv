`timescale 1ns/1ps

module tb_riscv_top;

parameter	FILE	="ri32ui-p-addi.txt";
parameter	AW		=32;
parameter	DW		=32;

logic		clk;
logic		rst_n;

riscv #(
	.FILE(FILE),
	.AW		(AW),
	.DW		(DW)
) u1_riscv_inst (
	.clk	(clk)		,
	.rst_n	(rst_n)		
);

always #5 clk = ~clk;

initial begin
	clk = 1'b0;
	rst_n = 1'b0;
	#1000;
	rst_n = 1'b1;
	#10000;
	$finish;
end


endmodule
