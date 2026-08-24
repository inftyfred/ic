// @nc app=nowcoder id=e41980b698624eb2b20c0d6e2bee7f45 topic=311 question=5000683 lang=Verilog
// 2026-08-24 01:10:29
// https://www.nowcoder.com/practice/e41980b698624eb2b20c0d6e2bee7f45?tpId=311&tqId=5000683
// [VL71] 乘法与位运算

// @nc code=start

`timescale 1ns/1ns

module dajiang13(
    input  [7:0]    A,
    output [15:0]   B
	);

//*************code***********//

assign B = (A << 8) - (A << 2) - A;

//*************code***********//

endmodule

// @nc code=end
