// @nc app=nowcoder id=1de5e9bf749244cb8e5908626cc36d36 topic=311 question=5000680 lang=Verilog
// 2026-08-18 22:17:58
// https://www.nowcoder.com/practice/1de5e9bf749244cb8e5908626cc36d36?tpId=311&tqId=5000680
// [VL64] 时钟切换

// @nc code=start

`timescale 1ns/1ns

module huawei6(
	input wire clk0  ,
	input wire clk1  ,
	input wire rst  ,
	input wire sel ,
	output wire clk_out
);
//*************code***********//

// 两路时钟在各自下降沿更新门控使能，保证只在时钟为低电平时切换。
// en_clk0 与 en_clk1 互斥，避免两路时钟同时驱动输出。
reg en_clk0;
reg en_clk1;

// sel=1 选择 clk0，sel=0 选择 clk1。
always @(negedge clk0 or negedge rst) begin
	if(!rst)
		en_clk0 <= 1'b0;
	else
		en_clk0 <= !sel && !en_clk1;
end

always @(negedge clk1 or negedge rst) begin
	if(!rst)
		en_clk1 <= 1'b0;
	else
		en_clk1 <= sel && !en_clk0;
end

assign clk_out = (clk0 & en_clk0) | (clk1 & en_clk1);

//*************code***********//
endmodule

// @nc code=end
