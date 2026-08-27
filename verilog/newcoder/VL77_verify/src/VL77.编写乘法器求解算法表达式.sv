// @nc app=nowcoder id=c414335a34b842aeb9960acfe5fc879f topic=311 question=5000695 lang=Verilog
// 2026-08-27 00:34:24
// https://www.nowcoder.com/practice/c414335a34b842aeb9960acfe5fc879f?tpId=311&tqId=5000695
// [VL77] 编写乘法器求解算法表达式

// @nc code=start c=12*a+5*b

`timescale 1ns/1ns


//kcm乘法器
module cal_4_kcm (
	input clk,
	input rst_n,
	input [3:0] a,
	input [3:0] b,
	output [8:0] c
);

reg [3:0] a_d, b_d;
reg [8:0] c_d;

assign c = c_d;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		a_d <= 0;
		b_d <= 0;
	end else begin
		a_d <= a;
		b_d <= b;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		c_d <= 0;
	end else begin
		c_d <= (a_d<<3) + (a_d<<2) + (b_d<<2) + b_d;
	end
end

endmodule

//通用乘法器
module cal_4 (
	input clk,
	input rst_n,
	input [3:0] a,
	input [3:0] b,
	output [7:0] c
);

reg [7:0] prod;
reg [7:0] SL [0:3];
reg [3:0] b_bit;
reg [7:0] mux_out [0:3];

//SL
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		SL[3] <= 8'd0;
		SL[2] <= 8'd0;
		SL[1] <= 8'd0;
		SL[0] <= 8'd0;
	end else begin
		SL[3] <= a << 3;
		SL[2] <= a << 2;
		SL[1] <= a << 1;
		SL[0] <= a;
	end
end

//b_bit
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		b_bit <= 4'b0;
	end else begin
		b_bit <= b;
	end
end

//mux_out
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		mux_out[0] <= 0;
		mux_out[1] <= 0;
		mux_out[2] <= 0;
		mux_out[3] <= 0;
	end else begin
		mux_out[0] <= (b_bit[0] == 0) ? 0 : SL[0];
		mux_out[1] <= (b_bit[1] == 0) ? 0 : SL[1];
		mux_out[2] <= (b_bit[2] == 0) ? 0 : SL[2];
		mux_out[3] <= (b_bit[3] == 0) ? 0 : SL[3];
	end
end

assign c = mux_out[0] + mux_out[1] + mux_out[2] + mux_out[3];

endmodule


module calculation(
	input clk,
	input rst_n,
	input [3:0] a,
	input [3:0] b,
	output [8:0] c
	);

wire [7:0] c1, c2;

// cal_4_kcm u1(
// 	.clk(clk),
// 	.rst_n(rst_n),
// 	.a(a),
// 	.b(b),
// 	.c(c1)
// );

cal_4 u1(
	.clk(clk),
	.rst_n(rst_n),
	.a(4'd12),
	.b(a),
	.c(c1)
);

cal_4 u2(
	.clk(clk),
	.rst_n(rst_n),
	.a(4'd5),
	.b(b),
	.c(c2)
);

assign c = c1 + c2;

endmodule

// @nc code=end
