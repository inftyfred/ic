// @nc app=nowcoder id=d5c5b853b892402ea80d27879b8fbfd6 topic=311 question=5000688 lang=Verilog
// 2026-08-24 00:22:18
// https://www.nowcoder.com/practice/d5c5b853b892402ea80d27879b8fbfd6?tpId=311&tqId=5000688
// [VL70] 序列检测器（Moore型）

// @nc code=start

`timescale 1ns/1ns

module det_moore(
   input                clk   ,
   input                rst_n ,
   input                din   ,
 
   output	reg         Y   
);


parameter IDLE = 5'b0_0001;
parameter S1   = 5'b0_0010;
parameter S2   = 5'b0_0100;
parameter S3   = 5'b0_1000;
parameter S4   = 5'b1_0000;

reg [4:0] cur_state, next_state;

always @(posedge clk or negedge rst_n) begin
   if(!rst_n) begin
      cur_state <= IDLE;
   end else begin
      cur_state <= next_state;
   end
end

always @(*) begin
   case(cur_state)
      IDLE:begin
         next_state = (din == 1) ? S1 : IDLE;
      end
      S1:begin
         next_state = (din == 1) ? S2 : IDLE;
      end
      S2:begin
         next_state = (din == 1) ? S1 : S3;
      end
      S3:begin
         next_state = (din == 1) ? S4 : IDLE;
      end
      default:begin
         next_state = IDLE;
      end
   endcase
end

always @(posedge clk or negedge rst_n) begin
   if(!rst_n) begin
      Y <= 0;
   end else begin
      case(cur_state)
         IDLE, S1, S2, S3: Y <= 0;
         S4: Y <= 1;
         default: Y <= 0;
      endcase
   end
end


endmodule

// @nc code=end
