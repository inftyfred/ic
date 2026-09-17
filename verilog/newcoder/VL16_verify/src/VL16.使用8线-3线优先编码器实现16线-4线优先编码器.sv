// @nc app=nowcoder id=dcfa838e43de4744bc976abee96dc566 topic=301 question=5000585 lang=Verilog
// 2026-09-16 22:12:15
// https://www.nowcoder.com/practice/dcfa838e43de4744bc976abee96dc566?tpId=301&tqId=5000585
// [VL16] 使用8线-3线优先编码器Ⅰ实现16线-4线优先编码器

// @nc code=start

`timescale 1ns/1ns
module encoder_83(
   input      [7:0]       I   ,
   input                  EI  ,
   
   output wire [2:0]      Y   ,
   output wire            GS  ,
   output wire            EO    
);
assign Y[2] = EI & (I[7] | I[6] | I[5] | I[4]);
assign Y[1] = EI & (I[7] | I[6] | ~I[5]&~I[4]&I[3] | ~I[5]&~I[4]&I[2]);
assign Y[0] = EI & (I[7] | ~I[6]&I[5] | ~I[6]&~I[4]&I[3] | ~I[6]&~I[4]&~I[2]&I[1]);

assign EO = EI&~I[7]&~I[6]&~I[5]&~I[4]&~I[3]&~I[2]&~I[1]&~I[0];

assign GS = EI&(I[7] | I[6] | I[5] | I[4] | I[3] | I[2] | I[1] | I[0]);
//assign GS = EI&(| I);
         
endmodule

module encoder_164(
   input      [15:0]      A   ,
   input                  EI  ,
   
   output wire [3:0]      L   ,
   output wire            GS  ,
   output wire            EO    
);

wire GS1, GS2;
wire EO1;
wire [3:0] Y1, Y2;

assign L[0] = Y1[0] | Y2[0];
assign L[1] = Y1[1] | Y2[1];
assign L[2] = Y1[2] | Y2[2];
assign L[3] = GS1;//(~EO1) & EI;

assign GS = GS1 | GS2;

encoder_83 u1 (
   .I (A[15:8])  ,
   .EI(EI)  ,
   
   .Y (Y1)  ,
   .GS(GS1)  ,
   .EO(EO1)
);

encoder_83 u2 (
   .I (A[7:0])  ,
   .EI(EO1)  ,
   
   .Y (Y2)  ,
   .GS(GS2)  ,
   .EO(EO)    
);

endmodule

// @nc code=end
