`timescale 1ns/1ps

module decode #(
	parameter	DW	=32
)(
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

logic[6:0]						opcode				;
logic[4:0]						rd					;
logic[2:0]						func3				;
logic[4:0]						rs1					;
logic[4:0]						rs2					;
logic[6:0]						func7				;
logic[11:0]						imm					;

assign	opcode					=	instr_in[6:0];
assign	rd						=	instr_in[11:7];
assign	func3					=	instr_in[14:12];
assign	rs1						=	instr_in[19:15];
assign	rs2						=	instr_in[24:20];
assign	funct7					=	instr_in[31:25];
assign	imm						=	instr_in[31:20];

//always_comb	begin
//	if(opcode == 7'b0010011 && func3 == 3'b000) begin //addi-Itype
//		rd_rs1_addr =	rs1;
//		rd_rs2_addr	=	5'h0;
//		op1_out		=	rd_rs1_data;
//		op2_out		=	{{20{imm[11]}},imm};
//		wr_reg_addr	=	rd;
//	end 
//	else begin
//		rd_rs1_addr =	'h0;
//		rd_rs2_addr =	'h0;
//		op1_out		=	'h0;
//		op2_out		=	'h0;
//		wr_reg_addr	=	'h0;
//	end
//end

always_comb begin
	case(opcode)
		`INST_TYPE_I: begin
			case(func3)
				`INST_ADDI: begin
						rd_rs1_addr =	rs1;
						rd_rs2_addr	=	5'h0;
						op1_out		=	rd_rs1_data;
						op2_out		=	{{20{imm[11]}},imm};
					end
				default: begin
						rd_rs1_addr = 	'h0;
						rd_rs2_addr = 	'h0;
						op1_out		=	'h0;
						op2_out		=	'h0;
					end
			endcase
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
