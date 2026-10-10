// @nc app=nowcoder id=1fe78a981bd640edb35b91d467341061 topic=311 question=5000694 lang=Verilog
// 2026-10-10 01:04:58
// https://www.nowcoder.com/practice/1fe78a981bd640edb35b91d467341061?tpId=311&tqId=5000694
// [VL62] 序列发生器

// @nc code=start

`timescale 1ns/1ns

module sequence_generator(
	input clk,
	input rst_n,
	output reg data
	);

	reg [5:0] seq;

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			seq <= 6'b001_011;
			data <= 1'b0;
		end else begin
			data <= seq[5];
			seq <= {seq[4:0], seq[5]};
		end
	end

endmodule

// @nc code=end
