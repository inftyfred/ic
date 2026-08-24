// @nc app=nowcoder id=9b892b6f75954267b4574b042f8a8d6a topic=311 question=5000696 lang=Verilog
// 2026-08-24 02:01:15
// https://www.nowcoder.com/practice/9b892b6f75954267b4574b042f8a8d6a?tpId=311&tqId=5000696
// [VL74] 异步复位同步释放

// @nc code=start

`timescale 1ns/1ns

module ali16(
input clk,
input rst_n,
input d,
output reg dout
 );

reg r_flag, r_flag_d;

//*************code***********//
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        r_flag <= 0;
        r_flag_d <= 0;
    end else begin
        r_flag <= 1;
        r_flag_d <= r_flag;
    end
end


always @(posedge clk or negedge r_flag_d) begin
    if(!r_flag_d) begin
        dout <= 0;
    end else begin
        dout <= d;
    end
end

//*************code***********//
endmodule

// @nc code=end
