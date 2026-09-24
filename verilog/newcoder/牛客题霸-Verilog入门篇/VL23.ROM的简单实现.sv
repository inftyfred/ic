// @nc app=nowcoder id=b76fdef7ffa747909b0ea46e0d13738a topic=301 question=5000625 lang=Verilog
// 2026-09-23 22:01:40
// https://www.nowcoder.com/practice/b76fdef7ffa747909b0ea46e0d13738a?tpId=301&tqId=5000625
// [VL23] ROM的简单实现

// @nc code=start

`timescale 1ns/1ns
module rom(
	input clk,
	input rst_n,
	input [7:0]addr,
	
	output [3:0]data
);

reg [3:0] mem [0:7];
reg [3:0] data_r;

assign data = data_r;

integer i;
initial begin
	for(i=0; i<8; i=i+1) begin
		mem[i] = i * 2;
	end
end

always @(*) begin
	if(!rst_n) begin
		data_r <= 4'b0;
	end else begin
		data_r <= mem[addr[2:0]];
	end
end

endmodule

// @nc code=end
