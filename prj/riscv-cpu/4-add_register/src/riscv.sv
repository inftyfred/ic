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
logic	[DW-1:0]	instr_out;
logic	[AW-1:0]	instr_addr_out;

logic	[DW-1:0]	instr_out2;

logic[4:0]			rd_rs1_addr			;
logic[4:0]			rd_rs2_addr			;
logic[4:0]			wr_reg_addr			;
logic[DW-1:0]		rd_rs1_data			;
logic[DW-1:0]		rd_rs2_data			;
logic[DW-1:0]		op1_out				;
logic[DW-1:0]		op2_out				;
logic				wr_reg_en			;
logic[DW-1:0]		wr_reg_data			;

assign	jump_en		= 1'b0;
assign	jump_addr 	= 'h0;
//assign	rd_rs1_data	= 'd50;
//assign	rd_rs2_data	= 'd100;
assign  wr_reg_en	= 1'b1;
assign	wr_reg_data	= op2_out;

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

if2id #(
	.AW(AW),	
	.DW(DW)
)(
	.clk			(clk			)	,
	.rst_n			(rst_n			)	,
	.instr_addr_in	(pc_pointer		)	,
	.instr_in		(instr_out		)	,
	.instr_addr_out	(instr_addr_out)	,
	.instr_out		(instr_out2		)
);


decode #(
	.DW(DW)
)u1_decode_inst(
	.instr_in		(instr_out2	)		,
	.rd_rs1_addr	(rd_rs1_addr)		,
	.rd_rs2_addr	(rd_rs2_addr)		,
	.wr_reg_addr	(wr_reg_addr)		,
	.rd_rs1_data	(rd_rs1_data)		,
	.rd_rs2_data	(rd_rs2_data)		,
	.op1_out		(op1_out	)		,
	.op2_out	    (op2_out	)
);

register #(
  .DW(DW)                
) u1_regster_inst (
	.clk				(clk		),
 	.rst_n				(rst_n		),
	.rd_rs1_addr		(rd_rs1_addr),
 	.rd_rs2_addr		(rd_rs2_addr),
	.rd_rs1_data		(rd_rs1_data),
 	.rd_rs2_data		(rd_rs2_data),
 	.wr_reg_en			(wr_reg_en	),
 	.wr_reg_addr		(wr_reg_addr),
 	.wr_reg_data	    (wr_reg_data)
);

endmodule
