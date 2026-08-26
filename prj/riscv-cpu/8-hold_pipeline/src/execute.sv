`timescale 1ns/1ps


module execute #(
	parameter	DW	=	32,
	parameter	AW	=	32
)(
	input	logic	[AW-1:0]		instr_addr		,
	input	logic	[DW-1:0]		instr			,
	input	logic	[DW-1:0]		op1				,
	input	logic	[DW-1:0]		op2				,

	output	logic					wr_reg_en		,
	output	logic	[DW-1:0]		wr_reg_data		,
	output	logic	[4:0]			wr_reg_addr		,

	//to ctrl
	output logic					jump_en			,
	output logic	[AW-1:0]		jump_addr		,
	output logic					jump_hold
);


logic[6:0]						opcode				;
logic[4:0]						rd					;
logic[2:0]						func3				;
logic[6:0]						func7				;
logic[31:0]						imm					;
logic							equal				;
logic[AW-1:0]					jump_imm			;

assign	opcode					=	instr[6:0];
assign	rd						=	instr[11:7];
assign	func3					=	instr[14:12];
assign	func7					=	instr[31:25];

assign	imm = {{20{instr[31]}},instr[7],instr[30:25], instr[11:8], 1'b0};
assign	equal					=	(op1 == op2) ? 1'b1 : 1'b0;
assign	jump_imm				=	instr_addr + imm;


always_comb	begin
	case(opcode)
		`INST_TYPE_I: begin
			case(func3)
				`INST_ADDI: begin
					wr_reg_en	=	1'b1;
					wr_reg_addr	=	rd;
					wr_reg_data	=	op1 + op2;
					jump_en		= 	1'b0;
					jump_addr	=	'h0;
					jump_hold	=	1'b0;
					end
				`INST_ANDI: begin
					wr_reg_en	=	1'b1;
					wr_reg_addr	=	rd;
					wr_reg_data	=	op1 & op2;
					jump_en		= 	1'b0;
					jump_addr	=	'h0;
					jump_hold	=	1'b0;
				end
				default: begin
					wr_reg_en	=	1'b0;
					wr_reg_addr	=	'h0;
					wr_reg_data	=	'h0;
					jump_en		=	1'b0;
					jump_addr	=	'h0;
					jump_hold	=	1'b0;
				end
			endcase
		end
		`INST_TYPE_R_M: begin
			case(func3)
				`INST_ADD_SUB : begin
					if(func7 == 7'b000_0000) begin
						wr_reg_en	=	1'b1;
						wr_reg_addr	=	rd;
						wr_reg_data	=	op1 + op2;
						jump_en		=	1'b0;
						jump_addr	=	'h0;
						jump_hold	=	1'b0;
					end
					else if(func7 == 7'b010_0000) begin
						wr_reg_en	=	1'b1;
						wr_reg_addr	=	rd;
						wr_reg_data	=	op1 - op2;
						jump_en		=	1'b0;
						jump_addr	=	'h0;
						jump_hold	=	1'b0;
					end
					else begin
						wr_reg_en	=	1'b0;
						wr_reg_addr	=	'h0;
						wr_reg_data	=	'h0;
						jump_en		=	1'b0;
						jump_addr	=	'h0;
						jump_hold	=	1'b0;
					end
				end
			endcase
		end
		`INST_TYPE_B : begin
			case(func3)
				`INST_BNE : begin
						wr_reg_en	=	1'b0;
						wr_reg_addr	=	'h0;
						wr_reg_data	=	'h0;
						jump_en		=	~equal;
						jump_addr	=	~equal ? jump_imm : 'h0;
						jump_hold	=	1'b0;
				end
				default : begin
						wr_reg_en	=	1'b0;
						wr_reg_addr	=	'h0;
						wr_reg_data	=	'h0;
						jump_en		=	1'b0;
						jump_addr	=	'h0;
						jump_hold	=	1'b0;
				end
			endcase
		end
		`INST_JAL: begin
			wr_reg_en	=	1'b1;
			wr_reg_addr	=	rd;
			wr_reg_data	=	instr_addr + 32'd4;
			jump_en		=	1'b1;
			jump_addr	=	instr_addr + op2;
			jump_hold	=	1'b0;
		end
		`INST_JALR: begin
			wr_reg_en	=	1'b1;
			wr_reg_addr	=	rd;
			wr_reg_data	=	instr_addr + 32'd4;
			jump_en		=	1'b1;
			jump_addr	=	op1 + op2;
			jump_hold	=	1'b0;
		end
		`INST_LUI: begin
			wr_reg_en	=	1'b1;
			wr_reg_addr	=	rd;
			wr_reg_data	=	op2;
			jump_en		=	1'b0;
			jump_addr	=	'h0;
			jump_hold	=	1'b0;
		end
		`INST_LUIPC: begin
			wr_reg_en	=	1'b1;
			wr_reg_addr	=	rd;
			wr_reg_data	=	op1 + op2;
			jump_en		=	1'b0;
			jump_addr	=	'h0;
			jump_hold	=	1'b0;
		end
		`INST_NOP_OP: begin
			wr_reg_en	=	1'b0;
			wr_reg_addr	=	'h0;
			wr_reg_data	=	'h0;
			jump_en		=	1'b0;
			jump_addr	=	'h0;
			jump_hold	=	1'b0;
		end
		default: begin
				wr_reg_en	=	1'b0;
				wr_reg_addr	=	'h0;
				wr_reg_data	=	'h0;
				jump_en		=	1'b0;
				jump_addr	=	'h0;
				jump_hold	=	1'b0;
		end
	endcase
end

endmodule
