// @nc app=nowcoder id=b058395d003344e0a74dd67e44a33fae topic=311 question=5000691 lang=Verilog
// 2026-08-25 21:30:58
// https://www.nowcoder.com/practice/b058395d003344e0a74dd67e44a33fae?tpId=311&tqId=5000691
// [VL76] 任意奇数倍时钟分频

// @nc code=start

`timescale 1ns/1ns

module clk_divider
	#(parameter dividor = 5)
( 	input clk_in,
	input rst_n,
	output clk_out
);

localparam  CNT_MAX 	= dividor - 1; //reg [$clog2(dividor)-1:0]
localparam  HALF	  	= CNT_MAX / 2;
reg [$clog2(dividor)-1:0] cnt;
reg clk_pos, clk_neg;

assign clk_out = clk_pos || clk_neg;

always @(posedge clk_in or negedge rst_n) begin
	if(!rst_n) begin
		cnt <= 0;
	end else begin
		cnt <= (cnt == CNT_MAX) ? 0 : cnt + 1;
	end
end

//posedge count
always @(posedge clk_in or negedge rst_n) begin
	if(!rst_n) begin
		clk_pos <= 0;
	end else if(cnt == CNT_MAX) begin
		clk_pos <= 0;
	end  else if(cnt == HALF)begin
		clk_pos <= 1;
	end else begin
		clk_pos <= clk_pos;
	end
end

//negedge count
always @(negedge clk_in or negedge rst_n) begin
	if(!rst_n) begin
		clk_neg <= 0;
	end else if(cnt == CNT_MAX) begin
		clk_neg <= 0;
	end else if(cnt == HALF) begin
		clk_neg <= 1;
	end  else begin
		clk_neg <= clk_neg;
	end
end
endmodule

// @nc code=end
