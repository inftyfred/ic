// @nc app=nowcoder id=67d4dd382bb44c559a1d0a023857a7a6 topic=301 question=5000606 lang=Verilog
// 2026-08-31 22:36:46
// https://www.nowcoder.com/practice/67d4dd382bb44c559a1d0a023857a7a6?tpId=301&tqId=5000606
// [VL3] 奇偶校验

// @nc code=start

`timescale 1ns/1ns
module odd_sel(
input [31:0] bus,
input sel,
output check
);
//*************code***********//

wire out = ^bus;

assign check = (sel==1) ? out : ~out;

//*************code***********//
endmodule

// @nc code=end
