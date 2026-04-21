`timescale 1ns/1ps

module uart_top #(
    parameter CLK_FREQ   = 100_000_000,
    parameter BAUDRATE   = 115200,
    parameter PARITY     = "EVEN",
    parameter SEND_NBYTE = 1,
    parameter RECV_NBYTE = 2
) (
    input  logic clk,
    input  logic rst_n,
    input  logic rxd,
    input  logic send_en,
    input  logic [SEND_NBYTE*8-1:0] send_data,
    output logic send_done,
    output logic txd,
    output logic recv_vld,
    output logic [RECV_NBYTE*8-1:0] recv_data,
    output logic parity_err           // 新增
);
    logic baud_tick, baud_tick_x16;

    baud_gen #(
        .CLK_FREQ (CLK_FREQ),
        .BAUD_RATE(BAUDRATE)
    ) u_baud_gen (
        .clk          (clk),
        .rst_n        (rst_n),
        .baud_tick    (baud_tick),
        .baud_tick_x16(baud_tick_x16)
    );

    uart_tx #(
        .SEND_NBYTE(SEND_NBYTE),
        .PARITY    (PARITY)
    ) u_uart_tx (
        .clk       (clk),
        .rst_n     (rst_n),
        .baud_tick (baud_tick),
        .send_en   (send_en),
        .send_data (send_data),
        .txd       (txd),
        .send_done (send_done)
    );

    uart_rx #(
        .RECV_NBYTE(RECV_NBYTE),
        .PARITY    (PARITY)
    ) u_uart_rx (
        .clk           (clk),
        .rst_n         (rst_n),
        .baud_tick_x16 (baud_tick_x16),
        .rxd           (rxd),
        .recv_vld      (recv_vld),
        .recv_data     (recv_data),
        .parity_err    (parity_err)
    );
endmodule