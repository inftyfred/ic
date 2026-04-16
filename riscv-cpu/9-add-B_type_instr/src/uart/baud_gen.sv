`timescale	1ns/1ps

module baud_gen #(
    parameter CLK_FREQ  = 100_000_000,
    parameter BAUD_RATE = 115200
) (
    input  logic clk,
    input  logic rst_n,
    output logic baud_tick,     // 位时钟使能（发送用）
    output logic baud_tick_x16  // 16 倍波特率使能（接收采样用）
);
    localparam BAUD_DIV     = CLK_FREQ / BAUD_RATE;
    localparam BAUD_DIV_X16 = BAUD_DIV / 16;

    logic [15:0] cnt_baud;
    logic [15:0] cnt_baud_x16;

    // 16 倍采样时钟
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_baud_x16 <= 0;
            baud_tick_x16 <= 1'b0;
        end else begin
            if (cnt_baud_x16 >= BAUD_DIV_X16 - 1) begin
                cnt_baud_x16 <= 0;
                baud_tick_x16 <= 1'b1;
            end else begin
                cnt_baud_x16 <= cnt_baud_x16 + 1;
                baud_tick_x16 <= 1'b0;
            end
        end
    end

    // 位时钟
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_baud <= 0;
            baud_tick <= 1'b0;
        end else begin
            if (cnt_baud >= BAUD_DIV - 1) begin
                cnt_baud <= 0;
                baud_tick <= 1'b1;
            end else begin
                cnt_baud <= cnt_baud + 1;
                baud_tick <= 1'b0;
            end
        end
    end
endmodule



























