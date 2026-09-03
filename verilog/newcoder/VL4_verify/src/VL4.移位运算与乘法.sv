// @nc app=nowcoder id=1dd22852bcac42ce8f781737f84a3272 topic=301 question=5000607 lang=Verilog
// 2026-09-03 01:54:45
// https://www.nowcoder.com/practice/1dd22852bcac42ce8f781737f84a3272?tpId=301&tqId=5000607
// [VL4] 移位运算与乘法

// @nc code=start

`timescale 1ns/1ns
module multi_sel(
input [7:0]d ,
input clk,
input rst,
output reg input_grant,
output reg [10:0]out
);
//*************code***********//

parameter   IDLE    =   5'b0_0001;
parameter   MUL_1   =   5'b0_0010;
parameter   MUL_3   =   5'b0_0100;
parameter   MUL_7   =   5'b0_1000;
parameter   MUL_8   =   5'b1_0000;

reg [4:0] cur_s, next_s;
reg [7:0] d_reg;

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        cur_s <= MUL_1;
    end else begin
        cur_s <= next_s;
    end
end

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        input_grant <= 0;
        out <= 0;
        d_reg <= 0;
    end else begin
        case(cur_s)
            IDLE:out <= 0;
            MUL_1:begin
                input_grant <= 1;
                out <= d;
                d_reg <= d;
            end
            MUL_3:begin
                input_grant <= 0;
                out <= (d_reg << 2) - d_reg;
            end
            MUL_7:begin
                input_grant <= 0;
                out <= (d_reg << 3) - d_reg;
            end
            MUL_8:begin
                input_grant <= 0;
                out <= d_reg << 3;
            end
            default:begin
                input_grant <= 0;
                out <= 0;
            end
        endcase
    end
end

always @(*) begin
    case(cur_s)
        IDLE:  next_s = MUL_1;
        MUL_1: next_s = MUL_3;
        MUL_3: next_s = MUL_7;
        MUL_7: next_s = MUL_8;
        MUL_8: next_s = MUL_1;
        default: next_s = IDLE;
    endcase
end

//*************code***********//
endmodule

// @nc code=end
