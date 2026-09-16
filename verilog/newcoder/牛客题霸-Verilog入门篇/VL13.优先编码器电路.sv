// @nc app=nowcoder id=0594ed5303ad48a19aed90bc48839d00 topic=301 question=5000582 lang=Verilog
// 2026-09-13 23:00:15
// https://www.nowcoder.com/practice/0594ed5303ad48a19aed90bc48839d00?tpId=301&tqId=5000582
// [VL13] 优先编码器电路①

// @nc code=start

`timescale 1ns/1ns

module encoder_0(
   input      [8:0]         I_n   ,

   output reg [3:0]         Y_n
);

always @(*) begin
   casez(I_n)
      9'b1_1111_1111:Y_n = 4'b1111;
      9'b0_????_????:Y_n = 4'b0110;
      9'b1_0???_????:Y_n = 4'b0111;
      9'b1_10??_????:Y_n = 4'b1000;
      9'b1_110?_????:Y_n = 4'b1001;
      9'b1_1110_????:Y_n = 4'b1010;
      9'b1_1111_0???:Y_n = 4'b1011;
      9'b1_1111_10??:Y_n = 4'b1100;
      9'b1_1111_110?:Y_n = 4'b1101;
      9'b1_1111_1110:Y_n = 4'b1110;
      default:     Y_n = 4'b0000;
   endcase
end


endmodule

// @nc code=end
