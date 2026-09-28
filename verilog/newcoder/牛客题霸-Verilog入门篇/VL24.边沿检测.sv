// @nc app=nowcoder id=fed4247d5ef64ac68c20283ebace11f4 topic=301 question=5000626 lang=Verilog
// 2026-09-27 21:13:38
// https://www.nowcoder.com/practice/fed4247d5ef64ac68c20283ebace11f4?tpId=301&tqId=5000626
// [VL24] 边沿检测

// @nc code=start

`timescale 1ns/1ns
module edge_detect(
	input clk,
	input rst_n,
	input a,
	
	output reg rise,
	output reg down
);

reg a_d0;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		rise <= 1'b0;
		down <= 1'b0;
	end else begin
		if(a ==1'b1 && a_d0 == 1'b0)
			rise <= 1'b1;
		else if(a == 1'b0 && a_d0 == 1'b1)
			down <= 1'b1;
		else begin
			rise <= 1'b0;
			down <= 1'b0;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		a_d0 <= 1'b0;
	end begin
		a_d0 <= a;
	end
end
	
endmodule

// @nc code=end
