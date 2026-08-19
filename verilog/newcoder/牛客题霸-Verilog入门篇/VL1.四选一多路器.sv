// @nc app=nowcoder id=cba4617e1ef64e9ea52cbb400a0725a3 topic=301 question=5000604 lang=Verilog
// 2026-08-18 04:01:55
// https://www.nowcoder.com/practice/cba4617e1ef64e9ea52cbb400a0725a3?tpId=301&tqId=5000604
// [VL1] 四选一多路器

// @nc code=start

`timescale 1ns/1ns
module mux4_1(
input [1:0]d1,d2,d3,d0,
input [1:0]sel,
output[1:0]mux_out
);
//*************code***********//

// 使用连续赋值 assign，输出 mux_out 保持为线网(wire)类型
assign mux_out = (sel == 2'b00) ? d3 :
                 (sel == 2'b01) ? d2 :
                 (sel == 2'b10) ? d1 :
                                  d0;

//*************code***********//
endmodule

// @nc code=end
