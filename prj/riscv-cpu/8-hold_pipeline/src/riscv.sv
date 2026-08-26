`timescale 1ns/1ps
`include "define.sv"


module riscv #(
	parameter	FILE	=`FILE,
	parameter	AW		=`AW,
	parameter	DW		=`DW
)(
	input	logic	clk,
	input	logic	rst_n
);

logic				jump_en;
logic	[AW-1:0]	jump_addr;
logic	[AW-1:0]	pc_pointer;
logic	[DW-1:0]	instr_out_decode;
logic	[AW-1:0]	instr_addr_decode;
logic	[DW-1:0]	instr_out_rom;
logic	[DW-1:0]	instr_out_execute;
logic	[AW-1:0]	instr_addr_execute;

logic[4:0]			rd_rs1_addr			;
logic[4:0]			rd_rs2_addr			;
logic[4:0]			wr_reg_addr			;
logic[DW-1:0]		rd_rs1_data			;
logic[DW-1:0]		rd_rs2_data			;
logic[DW-1:0]		op1_decode			;
logic[DW-1:0]		op2_decode			;
logic[DW-1:0]		op1_execute			;
logic[DW-1:0]		op2_execute			;
logic				wr_reg_en			;
logic[DW-1:0]		wr_reg_data			;

//assign	jump_en		= 1'b0;
//assign	jump_addr 	= 'h0;
//assign  wr_reg_en	= 1'b1;
//assign	wr_reg_data	= op2_out;

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
.instr_out(instr_out_rom)
);

if2id #(
	.AW(AW),	
	.DW(DW)
)(
	.clk			(clk			)	,
	.rst_n			(rst_n			)	,
	.instr_hold		(jump_en		)	,
	.instr_addr_in	(pc_pointer		)	,
	.instr_in		(instr_out_rom	)	,
	.instr_addr_out	(instr_addr_decode)	,
	.instr_out		(instr_out_decode)
);


decode #(
	.DW(DW),
	.AW(AW)
)u1_decode_inst(
	.instr_addr_in  (instr_addr_decode)		,
	.instr_in		(instr_out_decode)	,
	.rd_rs1_addr	(rd_rs1_addr)		,
	.rd_rs2_addr	(rd_rs2_addr)		,
//	.wr_reg_addr	()					,
	.rd_rs1_data	(rd_rs1_data)		,
	.rd_rs2_data	(rd_rs2_data)		,
	.op1_out		(op1_decode	)		,
	.op2_out	    (op2_decode	)
);

register #(
  .DW(DW)                
) u1_register_inst (
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
id2ex #(
   .AW					(AW),         
   .DW					(DW)
)u1_id2ex_inst(
   .clk				(clk			),
   .rst_n			(rst_n			),
   .instr_hold		(jump_en		),
   .instr_addr_in	(instr_addr_decode),
   .instr_in		(instr_out_decode),
   .op1_in			(op1_decode		),
   .op2_in			(op2_decode		),
   .instr_addr_out	(instr_addr_execute),
   .instr_out		(instr_out_execute),
   .op1_out			(op1_execute	),
   .op2_out			(op2_execute	)	
);

execute #(
	.DW			(DW)	,
	.AW			(DW)
)u1_execute_inst(
	.instr_addr		(instr_addr_execute	)	,
	.instr			(instr_out_execute	)	,
	.op1			(op1_execute		)	,
	.op2			(op2_execute		)	,
	.wr_reg_en		(wr_reg_en			)	,
	.wr_reg_data	(wr_reg_data		)	,
	.wr_reg_addr	(wr_reg_addr		)	,
	.jump_en		(jump_en)				,
	.jump_addr		(jump_addr)				,
	.jump_hold		()						
);

endmodule
