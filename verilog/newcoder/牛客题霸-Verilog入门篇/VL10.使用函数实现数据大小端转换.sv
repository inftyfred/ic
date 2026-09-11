// @nc app=nowcoder id=74c0c19ad0c444959c436a049647a93c topic=301 question=5000624 lang=Verilog
// 2026-09-09 22:53:56
// https://www.nowcoder.com/practice/74c0c19ad0c444959c436a049647a93c?tpId=301&tqId=5000624
// [VL10] 使用函数实现数据大小端转换

// @nc code=start

`timescale 1ns/1ns



module function_mod(
	input [3:0]a,
	input [3:0]b,

	output [3:0]c,
	output [3:0]d
);

function automatic reg [7:0] turn(input reg [3:0] a, input reg [3:0] b);
	turn = {b[0], b[1], b[2], b[3], a[0], a[1], a[2], a[3]};
endfunction

//reg [7:0] out;

assign {d, c} = turn(a, b);


endmodule

// @nc code=end
