// @nc app=nowcoder id=e02fde10f1914527b6b6871b97aef86d topic=301 question=5000580 lang=Verilog
// 2026-09-11 00:00:18
// https://www.nowcoder.com/practice/e02fde10f1914527b6b6871b97aef86d?tpId=301&tqId=5000580
// [VL11] 4位数值比较器电路

// @nc code=start

`timescale 1ns/1ns

module comparator_4(
	input		[3:0]       A   	,
	input	   [3:0]		B   	,

 	output	 wire		Y2    , //A>B
	output   wire        Y1    , //A=B
    output   wire        Y0      //A<B
);

wire [3:0] AGB;
wire [3:0] AEB;
wire [3:0] ALB;
wire [3:0] NA;
wire [3:0] NB;

genvar i;
generate
	for(i=0; i<4; i=i+1) begin : gen_get_AB
		not(NA[i], A[i]);
		not(NB[i], B[i]);
		and(AGB[i], A[i], NB[i]);
		xnor(AEB[i], A[i], B[i]);
		and(ALB[i], NA[i], B[i]);
	end
endgenerate


//Y2
wire Y2_1, Y2_2, Y2_3, Y2_4;
and(Y2_1, AGB[3]);
and(Y2_2, AEB[3], AGB[2]);
and(Y2_3, AEB[3], AEB[2], AGB[1]);
and(Y2_4, AEB[3], AEB[2], AEB[1], AGB[0]);
or(Y2, Y2_1, Y2_2, Y2_3, Y2_4);

//Y1
and(Y1, AEB[3], AEB[2], AEB[1], AEB[0]);

//Y0
wire Y0_1, Y0_2, Y0_3, Y0_4;
and(Y0_1, ALB[3]);
and(Y0_2, AEB[3], ALB[2]);
and(Y0_3, AEB[3], AEB[2], ALB[1]);
and(Y0_4, AEB[3], AEB[2], AEB[1], ALB[0]);
or(Y0, Y0_1, Y0_2, Y0_3, Y0_4);

endmodule

// @nc code=end
