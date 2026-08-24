// [VL74] 异步复位同步释放 — copied from nowcoder for verification

`timescale 1ns/1ns

module ali16(
    input clk,
    input rst_n,
    input d,
    output reg dout
);

    reg r_flag, r_flag_d;

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

endmodule
