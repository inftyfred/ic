// @nc app=nowcoder id=de8e9138214647f1826e99043a1b7990 topic=301 question=5000621 lang=Verilog
// 2026-09-06 21:48:34
// https://www.nowcoder.com/practice/de8e9138214647f1826e99043a1b7990?tpId=301&tqId=5000621
// [VL7] 求两个数的差值

// @nc code=start

`timescale 1ns/1ns
module data_minus(
	input clk,
	input rst_n,
	input [7:0]a,
	input [7:0]b,

	output  reg [8:0]c
);

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		c <= 0;
	end else begin
		if(a > b) begin
			c <= a - b;
		end else begin
			c <= b - a;
		end
	end
end

endmodule

// @nc code=end
