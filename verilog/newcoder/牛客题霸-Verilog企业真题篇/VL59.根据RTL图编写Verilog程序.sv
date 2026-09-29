// @nc app=nowcoder id=41a06522d8b242808c31a152bf948b5e topic=311 question=5000693 lang=Verilog
// 2026-09-28 21:20:12
// https://www.nowcoder.com/practice/41a06522d8b242808c31a152bf948b5e?tpId=311&tqId=5000693
// [VL59] 根据RTL图编写Verilog程序

// @nc code=start

`timescale 1ns/1ns

module RTL(
	input clk,
	input rst_n,
	input data_in,
	output reg data_out
	);

reg data_in_reg;

wire always1 = data_in & ~data_in_reg;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		data_in_reg <= 1'b0;
	end else begin
		data_in_reg <= data_in;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		data_out <= 1'b0;
	end else begin
		data_out <= always1;
	end
end

endmodule

// @nc code=end
