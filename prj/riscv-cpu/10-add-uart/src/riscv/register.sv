`timescale 1ns/1ps

module register #(
	parameter DW	=32
)(
	input	logic			clk			,
	input	logic			rst_n		,
	input	logic[4:0]		rd_rs1_addr	,
	input	logic[4:0]		rd_rs2_addr	,
	output	logic[DW-1:0]	rd_rs1_data	,
	output	logic[DW-1:0]	rd_rs2_data	,
	input	logic			wr_reg_en	,
	input	logic[4:0]		wr_reg_addr	,
	input	logic[DW-1:0]	wr_reg_data	,
	output	logic[DW-1:0]	reg_s10		,
	output	logic[DW-1:0]	reg_s11	
);

logic	[DW-1:0]		regs[31:0];

assign	reg_s10	=	regs[26];
assign	reg_s11	=	regs[27];

always_comb begin
	if(!rst_n)
		rd_rs1_data = 'h0;
	else if(rd_rs1_addr == 5'h0)
		rd_rs1_data	= 'h0;
	else if(wr_reg_en && (rd_rs1_addr == wr_reg_addr))
		rd_rs1_data = wr_reg_data;
	else
		rd_rs1_data = regs[rd_rs1_addr];
end

always_comb	begin
	if(!rst_n)
		rd_rs2_data = 'h0;
	else if(rd_rs2_addr == 'h0)
		rd_rs2_data = 'h0;
	else if(wr_reg_en && (rd_rs2_addr == wr_reg_addr))
		rd_rs2_data = wr_reg_data;
	else
		rd_rs2_data = regs[rd_rs2_addr];
end

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		for(int i = 0; i < 32; i++) begin
			regs[i] <= 'h0;
		end
	end
	else if(wr_reg_en && (wr_reg_addr != 5'h0)) begin
		regs[wr_reg_addr] <= wr_reg_data;
	end
end

endmodule
