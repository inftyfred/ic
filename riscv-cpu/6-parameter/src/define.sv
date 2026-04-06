

`define	AW	32
`define	DW	32
`define	FILE	"instr.txt"

//I type inst
`define	INST_TYPE_I			7'b0010011
`define	INST_ADDI			3'b000
`define	INST_SLTI			3'b010
`define	INST_SLTIU			3'b011
`define	INST_XORI			3'b100
`define	INST_ORI			3'b110
`define	INST_ANDI			3'b111
`define	INST_SLLT			3'b001
`define	INST_SRI			3'b101

//L type inst
`define	INST_TYPE_L			7'b0000011
`define	INST_LB				3'b000
`define	INST_LH				3'b001
`define	INST_LW				3'b010
`define	INST_LBU			3'b100
`define	INST_LHU			3'b101

//s type inst
`define	INST_TYPE_S			7'b0100011
`define	INST_SB				3'b000
`define	INST_SH				3'b001
`define	INST_SW				3'b010

//R and M type inst
`define INST_TYPE_R_M		7'b0110011

//R type
`define INST_ADD_SUB		3'b000
`define INST_SLL			3'b001
`define INST_SLT			3'b010
`define INST_SLTU			3'b011
`define INST_XOR			3'b100




