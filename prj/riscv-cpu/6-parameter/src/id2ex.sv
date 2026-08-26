`timescale	1ns/1ps

module	id2ex #(
	parameter	AW	=	32,
	parameter	DW	=	32
)(
	input	logic				clk				,
	input	logic				rst_n			,
	input	logic	[AW-1:0]	instr_addr_in	,
	input	logic	[DW-1:0]	instr_in		,
	input	logic	[DW-1:0]	op1_in			,
	input	logic	[DW-1:0]	op2_in			,

	output	logic	[AW-1:0]	instr_addr_out	,
	output	logic	[DW-1:0]	instr_out		,
	output	logic	[DW-1:0]	op1_out			,
	output	logic	[DW-1:0]	op2_out			
);


always_ff @(posedge	clk or negedge rst_n) begin
	if(!rst_n)
		instr_addr_out <= 'h0;
	else
		instr_addr_out <= instr_addr_in;
end

always_ff @(posedge	clk or negedge rst_n) begin
	if(!rst_n)
		instr_out <= 'h0;
	else
		instr_out <= instr_in;
end


always_ff @(posedge	clk or negedge rst_n) begin
	if(!rst_n)
		op1_out <= 'h0;
	else
		op1_out <= op1_in;
end

always_ff @(posedge	clk or negedge rst_n) begin
	if(!rst_n)
		op2_out <= 'h0;
	else
		op2_out <= op2_in;
end

endmodule
