// @nc app=nowcoder id=618cb8d16a2c4e87b9e305f6659efe40 topic=301 question=5000622 lang=Verilog
// 2026-09-07 22:00:23
// https://www.nowcoder.com/practice/618cb8d16a2c4e87b9e305f6659efe40?tpId=301&tqId=5000622
// [VL8] 使用generate…for语句简化代码

// @nc code=start

`timescale 1ns/1ns
module gen_for_module(
    input [7:0] data_in,
    output [7:0] data_out
);

genvar i;
generate
    for(i = 0; i < 8; i=i+1) begin:g_assign_data
        assign data_out[i] = data_in[7-i];
    end
endgenerate

endmodule

// @nc code=end
