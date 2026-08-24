// @nc app=nowcoder id=d04c046febb74e72949baee9aa99d958 topic=311 question=5000689 lang=Verilog
// 2026-08-24 01:26:22
// https://www.nowcoder.com/practice/d04c046febb74e72949baee9aa99d958?tpId=311&tqId=5000689
// [VL72] 全加器

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

wire S1, C1, S2, C2;

add_half ah_u1(
   .A(A),
   .B(B),
   .S(S1),
   .C(C1)
);

add_half ah_u2(
   .A(S1),
   .B(Ci),
   .S(S2),
   .C(C2)
);


assign S = S2;
assign Co = C1 | C2;

endmodule

// @nc code=end
