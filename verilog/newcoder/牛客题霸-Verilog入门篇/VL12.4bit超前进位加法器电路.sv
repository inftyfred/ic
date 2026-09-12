// @nc app=nowcoder id=4d5b6dc4bb2848039da2ee40f9738363 topic=301 question=5000581 lang=Verilog
// 2026-09-11 22:43:51
// https://www.nowcoder.com/practice/4d5b6dc4bb2848039da2ee40f9738363?tpId=301&tqId=5000581
// [VL12] 4bit超前进位加法器电路

// @nc code=start

`timescale 1ns/1ns

module lca_4(
	input		[3:0]       A_in  ,
	input	    [3:0]		B_in  ,
    input                   C_1   ,

 	output	 wire			CO    ,
	output   wire [3:0]	    S
);

wire [3:0] P, G;
wire [4:0] C;
wire [3:0] A, B;

assign A = A_in;
assign B = B_in;

assign C[0] = C_1;

//output
assign CO = C[3];

genvar i;
generate
	for(i=0; i<4; i=i+1) begin: g_PG
		assign G[i] = A[i]&B[i];
		assign P[i] = A[i]^B[i];
		assign C[i+1] = G[i] | P[i]&C[i];
		assign S[i] = P[i] ^ C[i];//output
	end
endgenerate

endmodule

// @nc code=end
