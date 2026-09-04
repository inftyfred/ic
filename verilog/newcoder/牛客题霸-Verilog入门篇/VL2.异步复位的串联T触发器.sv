// @nc app=nowcoder id=9c8cb743919d405b9dac28eadecddfb5 topic=301 question=5000605 lang=Verilog
// 2026-08-18 04:01:35
// https://www.nowcoder.com/practice/9c8cb743919d405b9dac28eadecddfb5?tpId=301&tqId=5000605
// [VL2] 异步复位的串联T触发器

// @nc code=start

`timescale 1ns/1ns
module Tff_2 (
input wire data, clk, rst,
output reg q  
);
//*************code***********//

reg q0;

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        q0 <= 0;
        q <= 0;
    end else begin
        q0 <= q0 ^ data;
        q <= q ^ q0;
    end
end

//*************code***********//
endmodule

// @nc code=end
