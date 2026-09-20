// @nc app=nowcoder id=be81e76ebade445baca7257aa4eca8f2 topic=301 question=5000587 lang=Verilog
// 2026-09-19 22:03:49
// https://www.nowcoder.com/practice/be81e76ebade445baca7257aa4eca8f2?tpId=301&tqId=5000587
// [VL19] 使用3-8译码器①实现逻辑函数

// @nc code=start

`timescale 1ns/1ns

module decoder_38(
   input             E1_n   ,
   input             E2_n   ,
   input             E3     ,
   input             A0     ,
   input             A1     ,
   input             A2     ,
   
   output wire       Y0_n   ,  
   output wire       Y1_n   , 
   output wire       Y2_n   , 
   output wire       Y3_n   , 
   output wire       Y4_n   , 
   output wire       Y5_n   , 
   output wire       Y6_n   , 
   output wire       Y7_n   
);
wire E ;
assign E = E3 & ~E2_n & ~E1_n;
assign  Y0_n = ~(E & ~A2 & ~A1 & ~A0);
assign  Y1_n = ~(E & ~A2 & ~A1 &  A0);
assign  Y2_n = ~(E & ~A2 &  A1 & ~A0);
assign  Y3_n = ~(E & ~A2 &  A1 &  A0);
assign  Y4_n = ~(E &  A2 & ~A1 & ~A0);
assign  Y5_n = ~(E &  A2 & ~A1 &  A0);
assign  Y6_n = ~(E &  A2 &  A1 & ~A0);
assign  Y7_n = ~(E &  A2 &  A1 &  A0);
     
endmodule

module decoder0(
   input             A     ,
   input             B     ,
   input             C     ,
   
   output wire       L
);

wire [7:0] Y_n;

assign L = ~(Y_n[1] & Y_n[3] & Y_n[6] & Y_n[7]);

decoder_38 u1(
   .E1_n(1'b0)   ,
   .E2_n(1'b0)   ,
   .E3  (1'b1)   ,
   .A0  (C)   ,
   .A1  (B)   ,
   .A2  (A)   ,
   
   .Y0_n(Y_n[0])   ,  
   .Y1_n(Y_n[1])   , 
   .Y2_n(Y_n[2])   , 
   .Y3_n(Y_n[3])   , 
   .Y4_n(Y_n[4])   , 
   .Y5_n(Y_n[5])   , 
   .Y6_n(Y_n[6])   , 
   .Y7_n(Y_n[7])   
);

endmodule

// @nc code=end
