// @nc app=nowcoder id=83c5850805004b6d8c48742f582f304a topic=311 question=5000690 lang=Verilog
// 2026-08-24 01:55:19
// https://www.nowcoder.com/practice/83c5850805004b6d8c48742f582f304a?tpId=311&tqId=5000690
// [VL73] 串行进位加法器

// @nc code=start

`timescale 1ns/1ns

module add_half(
   input                A   ,
   input                B   ,
 
   output	wire        S   ,
   output   wire        C   
);

assign S = A ^ B;
assign C = A & B;
endmodule

/***************************************************************/
module add_full(
   input                A   ,
   input                B   ,
   input                Ci  , 

   output	wire        S   ,
   output   wire        Co   
);

wire c_1;
wire c_2;
wire sum_1;

add_half add_half_1(
   .A   (A),
   .B   (B),
         
   .S   (sum_1),
   .C   (c_1)  
);
add_half add_half_2(
   .A   (sum_1),
   .B   (Ci),
         
   .S   (S),
   .C   (c_2)  
);

assign Co = c_1 | c_2;
endmodule

module add_4(
   input         [3:0]  A   ,
   input         [3:0]  B   ,
   input                Ci  , 

   output	wire [3:0]  S   ,
   output   wire        Co   
);

wire [4:1] C;

add_full af_u1(
   .A(A[0]),
   .B(B[0]),
   .Ci(Ci),
   .S(S[0]),
   .Co(C[1])
);

add_full af_u2(
   .A(A[1]),
   .B(B[1]),
   .Ci(C[1]),
   .S(S[1]),
   .Co(C[2])
);

add_full af_u3(
   .A(A[2]),
   .B(B[2]),
   .Ci(C[2]),
   .S(S[2]),
   .Co(C[3])
);

add_full af_u4(
   .A(A[3]),
   .B(B[3]),
   .Ci(C[3]),
   .S(S[3]),
   .Co(C[4])
);

assign Co = C[4];

endmodule

// @nc code=end
