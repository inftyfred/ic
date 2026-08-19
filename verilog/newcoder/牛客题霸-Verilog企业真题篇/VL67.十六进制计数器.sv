// @nc app=nowcoder id=7a7cf1062faf4b5dbb578e0c761c2b42 topic=311 question=5000685 lang=Verilog
// 2026-08-19 03:34:43
// https://www.nowcoder.com/practice/7a7cf1062faf4b5dbb578e0c761c2b42?tpId=311&tqId=5000685
// [VL67] 十六进制计数器

// @nc code=start

`timescale 1ns/1ns

module counter_16(
   input                clk   ,
   input                rst_n ,
 
   output   reg  [3:0]  Q      
);

always@(posedge clk or negedge rst_n) begin
   if(!rst_n) begin
      Q <= 0;
   end else begin
      Q <= Q + 1;
   end
end

endmodule

// @nc code=end
