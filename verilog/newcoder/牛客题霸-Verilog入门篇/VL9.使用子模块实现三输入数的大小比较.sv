// @nc app=nowcoder id=bfc9e2f37fe84c678f6fd04dbce0ad27 topic=301 question=5000623 lang=Verilog
// 2026-09-08 22:15:46
// https://www.nowcoder.com/practice/bfc9e2f37fe84c678f6fd04dbce0ad27?tpId=301&tqId=5000623
// [VL9] 使用子模块实现三输入数的大小比较

// @nc code=start

`timescale 1ns/1ns
module main_mod(
	input clk,
	input rst_n,
	input [7:0]a,
	input [7:0]b,
	input [7:0]c,

	output [7:0]d
);

wire [7:0] temp1;
wire [7:0] temp2;

compare u1(
	.clk	(clk	)	,
	.rst_n	(rst_n	)	,
	.a		(a		)	,
	.b		(b		)	,
	.c		(temp1	)
);

compare u2(
	.clk	(clk	)	,
	.rst_n	(rst_n	)	,
	.a		(b		)	,
	.b		(c		)	,
	.c		(temp2	)
);

compare u3(
	.clk	(clk	)	,
	.rst_n	(rst_n	)	,
	.a		(temp1	)	,
	.b		(temp2	)	,
	.c		(d		)
);

endmodule

module compare (
	input 			clk		,
	input 			rst_n	,
	input [7:0] 	a		,
	input [7:0] 	b		,
	output [7:0] 	c
);

reg [7:0] c_reg;
assign c = c_reg;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		c_reg <= 0;
	end else begin
		c_reg <= (a > b) ? b : a;
	end
end

endmodule

// @nc code=end
