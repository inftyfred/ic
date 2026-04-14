`timescale 1ns/1ps

module decode #(
	parameter	DW	=32,
	parameter	AW	=32
)(
	input	logic[AW-1:0]		instr_addr_in		,
	input	logic[DW-1:0]		instr_in			,
	//to register
	output	logic[4:0]			rd_rs1_addr			,
	output	logic[4:0]			rd_rs2_addr			,
	//output	logic[4:0]			wr_reg_addr			,
	//from register
	input	logic[DW-1:0]		rd_rs1_data			,
	input	logic[DW-1:0]		rd_rs2_data			,
	//to instr execute
	output	logic[DW-1:0]		op1_out				,
	output	logic[DW-1:0]		op2_out	
);

logic	[6:0]						opcode				;
logic	[4:0]						rd					;
logic	[2:0]						func3				;
logic	[4:0]						rs1					;
logic	[4:0]						rs2					;
logic	[6:0]						func7				;
logic	[31:0]						imm					;

assign	opcode					=	instr_in[6:0];
assign	rd						=	instr_in[11:7];
assign	func3					=	instr_in[14:12];
assign	rs1						=	instr_in[19:15];
assign	rs2						=	instr_in[24:20];
assign	funct7					=	instr_in[31:25];
//assign	imm						=	instr_in[31:20];

//always_comb	begin
//	if(opcode == 7'b0010011 && func3 == 3'b000) begin //addi-Itype
//		rd_rs1_addr =	rs1;
//		rd_rs2_addr	=	5'h0;
//		op1_out		=	rd_rs1_data;
//		op2_out		=	{{20{imm[11]}},imm};
//		wr_reg_addr	=	rd;
//	end 
//	else begin
//		rd_rs1_addr =instr_in[31:20]	'h0;
//		rd_rs2_addr =	'h0;
//		op1_out		=	'h0;
//		op2_out		=	'h0;
//		wr_reg_addr	=	'h0;
//	end
//end

//get imm
always_comb begin
	case(opcode) 
		`INST_TYPE_I, `INST_TYPE_L, `INST_JALR: 
			imm = {{20{instr_in[31]}}, instr_in[31:20]};
		`INST_TYPE_S:
			imm = {{20{instr_in[31]}}, instr_in[31:25], instr_in[11:7]};
		`INST_TYPE_B:
			imm = {{20{instr_in[31]}},instr_in[7],instr_in[30:25], instr_in[11:8], 1'b0};
		`INST_JAL:
			imm = {{12{instr_in[31]}}, instr_in[19:12], instr_in[20],instr_in[30:21], 1'b0};
		`INST_LUI, `INST_LUIPC:
			imm = {instr_in[31:12], 12'b0};//imm << 12
		default:
			imm = 32'h0;
	endcase
end

always_comb begin
	case(opcode)
		`INST_TYPE_I: begin
			case(func3)
				`INST_ADDI: begin
					rd_rs1_addr =	rs1;
					rd_rs2_addr	=	5'h0;
					op1_out		=	rd_rs1_data;
					op2_out		=	imm;
					end
				`INST_ANDI:begin
					rd_rs1_addr =	rs1;
					rd_rs2_addr	=	5'h0;
					op1_out		=	rd_rs1_data;
					op2_out		=	imm;
				end
				default: begin
					rd_rs1_addr = 	'h0;
					rd_rs2_addr = 	'h0;
					op1_out		=	'h0;
					op2_out		=	'h0;
				end
			endcase
		end
		`INST_TYPE_R_M: begin
			case(func3)
				`INST_ADD_SUB: begin
					rd_rs1_addr = rs1;
					rd_rs2_addr	= rs2;
					op1_out		= rd_rs1_data;
					op2_out		= rd_rs2_data;
				end
				default: begin
					rd_rs1_addr = 	'h0;
					rd_rs2_addr = 	'h0;
					op1_out		=	'h0;
					op2_out		=	'h0;
				end
			endcase
		end
		`INST_TYPE_B: begin
			case(func3)
				`INST_BNE: begin
					rd_rs1_addr = rs1;
					rd_rs2_addr = rs2;
					op1_out		= rd_rs1_data;
					op2_out		= rd_rs2_data;
				end
				`INST_BEQ: begin
					rd_rs1_addr = rs1;
					rd_rs2_addr = rs2;
					op1_out 	= rd_rs1_data;
					op2_out		= rd_rs2_data;
				end
				`INST_BLT: begin
					rd_rs1_addr = rs1;
					rd_rs2_addr = rs2;
					op1_out 	= rd_rs1_data;
					op2_out		= rd_rs2_data;
				end
				`INST_BGE: begin
					rd_rs1_addr = rs1;
					rd_rs2_addr = rs2;
					op1_out 	= rd_rs1_data;
					op2_out		= rd_rs2_data;
				end
				`INST_BGEU: begin
					rd_rs1_addr = rs1;
					rd_rs2_addr = rs2;
					op1_out 	= rd_rs1_data;
					op2_out		= rd_rs2_data;
				end
				`INST_BLTU: begin
					rd_rs1_addr = rs1;
					rd_rs2_addr = rs2;
					op1_out 	= rd_rs1_data;
					op2_out		= rd_rs2_data;
				end
				default: begin
					rd_rs1_addr = 	'h0;
					rd_rs2_addr = 	'h0;
					op1_out		=	'h0;
					op2_out		=	'h0;
				end
			endcase
		end
		`INST_JAL: begin
			rd_rs1_addr	= 'h0;
			rd_rs2_addr	= 'h0;
			op1_out		= 'h0;
			op2_out		= imm;
		end
		`INST_JALR: begin
			rd_rs1_addr = rs1;
			rd_rs2_addr = 'h0;
			op1_out		= rd_rs1_data;
			op2_out		= imm;
		end
		`INST_LUI: begin
			rd_rs1_addr = 'h0;
			rd_rs2_addr = 'h0;
			op1_out		= 'h0;
			op2_out		= imm;
		end
		`INST_LUIPC: begin
			rd_rs1_addr = 'h0;
			rd_rs2_addr = 'h0;
			op1_out		= instr_addr_in; 
			op2_out		= imm;
		end
		`INST_NOP_OP: begin
			rd_rs1_addr = 'h0;
			rd_rs2_addr = 'h0;
			op1_out		= 'h0;
			op2_out		= 'h0;
		end
		default: begin
			rd_rs1_addr = 	'h0;
			rd_rs2_addr = 	'h0;
			op1_out		=	'h0;
			op2_out		=	'h0;
		end
	endcase
end


endmodule
