// @nc app=nowcoder id=03b8c5837d7f406797b4a57358057ef7 topic=301 question=5000583 lang=Verilog
// 2026-09-14 21:37:26
// https://www.nowcoder.com/practice/03b8c5837d7f406797b4a57358057ef7?tpId=301&tqId=5000583
// [VL14] 用优先编码器①实现键盘编码电路

// @nc code=start

`timescale 1ns/1ns
module encoder_0(
   input      [8:0]         I_n   ,
   
   output reg [3:0]         Y_n   
);

always @(*)begin
   casex(I_n)
      9'b111111111 : Y_n = 4'b1111;
      9'b0xxxxxxxx : Y_n = 4'b0110;
      9'b10xxxxxxx : Y_n = 4'b0111;
      9'b110xxxxxx : Y_n = 4'b1000;
      9'b1110xxxxx : Y_n = 4'b1001;
      9'b11110xxxx : Y_n = 4'b1010;
      9'b111110xxx : Y_n = 4'b1011;
      9'b1111110xx : Y_n = 4'b1100;
      9'b11111110x : Y_n = 4'b1101;
      9'b111111110 : Y_n = 4'b1110;
      default      : Y_n = 4'b1111;
   endcase    
end 
     
endmodule

module key_encoder(
      input      [9:0]         S_n   ,         
 
      output wire[3:0]         L     ,
      output wire              GS
);

wire [3:0] Y_n;

assign L = 4'b1111 - Y_n;

assign GS = ~((&Y_n) & S_n[0]);

encoder_0 u1(
   .I_n(S_n[9:1])   ,
   
   .Y_n(Y_n)   
);

endmodule

// @nc code=end
