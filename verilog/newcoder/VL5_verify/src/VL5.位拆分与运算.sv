// @nc app=nowcoder id=1649582a755a4fabb9763d07e62a9752 topic=301 question=5000608 lang=Verilog
// 2026-09-03 21:56:15
// https://www.nowcoder.com/practice/1649582a755a4fabb9763d07e62a9752?tpId=301&tqId=5000608
// [VL5] 位拆分与运算

// @nc code=start

`timescale 1ns/1ns

module data_cal(
input clk,
input rst,
input [15:0]d,
input [1:0]sel,

output [4:0]out,
output validout
);
//*************code***********//

reg [15:0] d_reg;
reg [4:0] out_reg;
reg validout_reg;

assign out = out_reg;
assign validout = validout_reg;

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        validout_reg <= 0;
        d_reg <= 0;
        out_reg <= 0;
    end else begin
        case(sel)
            2'b00:begin
                validout_reg <= 0;
                d_reg <= d;
                out_reg <= 0;
            end
            2'b01:begin
                validout_reg <= 1;
                out_reg <= d_reg[3:0] + d_reg[7:4];
            end
            2'b10:begin
                validout_reg <= 1;
                out_reg <= d_reg[3:0] + d_reg[11:8];
            end
            2'b11:begin
                validout_reg <= 1;
                out_reg <= d_reg[3:0] + d_reg[15:12];
            end
            default:begin
                validout_reg <= 0;
                d_reg <= 0;
                out_reg <= 0;
            end
        endcase
    end
end

//*************code***********//
endmodule

// @nc code=end
