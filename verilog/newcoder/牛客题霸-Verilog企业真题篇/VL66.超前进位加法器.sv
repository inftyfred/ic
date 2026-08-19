// @nc app=nowcoder id=c4c6afdab9ce45a3a2279a98391686ca topic=311 question=5000682 lang=Verilog
// 2026-08-19 02:09:04
// https://www.nowcoder.com/practice/c4c6afdab9ce45a3a2279a98391686ca?tpId=311&tqId=5000682
// [VL66] 超前进位加法器

// @nc code=start

`timescale 1ns/1ns

module huawei8//四位超前进位加法器
(
	input wire [3:0]A,
	input wire [3:0]B,
	output wire [4:0]OUT
);

//*************code***********//

	wire [3:0] P;
	wire [3:0] G;
	wire [4:1] Ci;
	wire Gm;
	wire Pm;
	wire [3:0] f;

	Add1 u0 (.a(A[0]), .b(B[0]), .C_in(1'b0), 		.f(f[0]), 	.g(G[0]), .p(P[0]));
	Add1 u1 (.a(A[1]), .b(B[1]), .C_in(Ci[1]),  	.f(f[1]), 	.g(G[1]), .p(P[1]));
	Add1 u2 (.a(A[2]), .b(B[2]), .C_in(Ci[2]),  	.f(f[2]), 	.g(G[2]), .p(P[2]));
	Add1 u3 (.a(A[3]), .b(B[3]), .C_in(Ci[3]),  	.f(f[3]), 	.g(G[3]), .p(P[3]));

	CLA_4 uu0 (.P(P), .G(G), .C_in(1'b0), .Ci(Ci), .Gm(Gm), .Pm(Pm));

	assign OUT = {Ci[4], f};

//*************code***********//
endmodule



//////////////下面是两个子模块////////

module Add1
(
		input a,
		input b,
		input C_in,
		output f,
		output g,
		output p
		);

		assign p = a ^ b;
		assign g = a & b;
		assign f = a ^ b ^ C_in;

endmodule






module CLA_4(
		input [3:0]P,
		input [3:0]G,
		input C_in,
		output [4:1]Ci,
		output Gm,
		output Pm
	);

	assign Ci[1] = G[0] | (C_in & P[0]);
	assign Ci[2] = G[1] | G[0]&P[1] | C_in&P[1]&P[0];
	assign Ci[3] = G[2] | G[1]&P[2] | G[0]&P[2]&P[1] | C_in&P[2]&P[1]&P[0];
	assign Ci[4] = G[3] | G[2]&P[3] | G[1]&P[3]&P[2] | G[0]&P[3]&P[2]&P[1] | C_in&P[3]&P[2]&P[1]&P[0];

	assign Pm = P[3] & P[2] & P[1] & P[0];
	assign Gm = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]);
	
endmodule

// @nc code=end
