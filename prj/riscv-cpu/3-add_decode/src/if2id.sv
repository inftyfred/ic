`timescale 1ns/1ps
//打一拍
module if2id #(
	parameter	AW	=32,
	parameter	DW	=32
)(
	input	logic			clk				,
	input	logic			rst_n			,
	input	logic[AW-1:0]	instr_addr_in	,
	input	logic[DW-1:0]	instr_in		,
	output	logic[AW-1:0]	instr_addr_out	,
	output	logic[DW-1:0]	instr_out		
);

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		instr_out <= 'd0;
	else
		instr_out <= instr_in;
end

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		instr_addr_out <= 'd0;
	else
		instr_addr_out <= instr_addr_in;
end

endmodule
