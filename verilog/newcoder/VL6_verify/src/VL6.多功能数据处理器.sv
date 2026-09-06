// @nc app=nowcoder id=e009ab1a7a4c46fb9042c09c77ee27b8 topic=301 question=5000620 lang=Verilog
// 2026-09-05 21:58:49
// https://www.nowcoder.com/practice/e009ab1a7a4c46fb9042c09c77ee27b8?tpId=301&tqId=5000620
// [VL6] 多功能数据处理器

// @nc code=start

`timescale 1ns/1ns
module data_select(
	input clk,
	input rst_n,
	input signed[7:0]a,
	input signed[7:0]b,
	input [1:0]select,
	output reg signed [8:0]c
);

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		c <= 0;
	end else begin
		case(select)
			2'b00: c <= a;
			2'b01: c <= b;
			2'b10: c <= a + b;
			2'b11: c <= a - b;
			default: c <= 0;
		endcase
	end
end

endmodule

// @nc code=end
