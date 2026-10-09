`timescale 1ns/1ns
module data_driver(
    input clk_a,
    input rst_n,
    input data_ack,
    output reg [3:0] data,
    output reg data_req
);
    reg data_ack_d0_r, data_ack_d1_r, data_ack_d2_r;

    always @(posedge clk_a or negedge rst_n) begin
        if (!rst_n) begin
            data_ack_d0_r <= 1'b0;
            data_ack_d1_r <= 1'b0;
            data_ack_d2_r <= 1'b0;
        end else begin
            data_ack_d0_r <= data_ack;
            data_ack_d1_r <= data_ack_d0_r;
            data_ack_d2_r <= data_ack_d1_r;
        end
    end

    always @(posedge clk_a or negedge rst_n) begin
        if (!rst_n)
            data <= 4'd0;
        else if (data_ack_d1_r && !data_ack_d2_r)
            data <= (data == 4'd7) ? 4'd0 : data + 4'd1;
    end

    reg [2:0] cnt_r;
    always @(posedge clk_a or negedge rst_n) begin
        if (!rst_n)
            cnt_r <= 3'd0;
        else if (data_ack_d1_r && !data_ack_d2_r)
            cnt_r <= 3'd0;
        else if (!data_req)
            cnt_r <= cnt_r + 3'd1;
    end

    always @(posedge clk_a or negedge rst_n) begin
        if (!rst_n)
            data_req <= 1'b0;
        else if (data_ack_d1_r)
            data_req <= 1'b0;
        else if (cnt_r == 3'd4)
            data_req <= 1'b1;
    end
endmodule

module data_receiver(
    input clk_b,
    input rst_n,
    input [3:0] data,
    input data_req,
    output reg data_ack
);
    reg data_req_d0_r, data_req_d1_r;
    reg [3:0] data_r;

    always @(posedge clk_b or negedge rst_n) begin
        if (!rst_n) begin
            data_req_d0_r <= 1'b0;
            data_req_d1_r <= 1'b0;
        end else begin
            data_req_d0_r <= data_req;
            data_req_d1_r <= data_req_d0_r;
        end
    end

    always @(posedge clk_b or negedge rst_n) begin
        if (!rst_n) begin
            data_r   <= 4'd0;
            data_ack <= 1'b0;
        end else if (data_req_d1_r) begin
            data_r   <= data;
            data_ack <= 1'b1;
        end else begin
            data_ack <= 1'b0;
        end
    end
endmodule
