// @nc app=nowcoder id=2bf1b28a4e634d1ba447d3495134baac topic=311 question=5000697 lang=Verilog
// 2026-10-08 22:46:03
// https://www.nowcoder.com/practice/2bf1b28a4e634d1ba447d3495134baac?tpId=311&tqId=5000697
// [VL60] 使用握手信号实现跨时钟域数据传输

// @nc code=start

`timescale 1ns/1ns
module data_driver(
	input clk_a,
	input rst_n,
	input data_ack,
	output reg [3:0]data,
	output reg data_req
	);
    
    
    reg data_ack_d0_r;
    reg data_ack_d1_r;
    reg data_ack_d2_r;
    
    always @(posedge clk_a or negedge rst_n) begin
        if (!rst_n) begin
            data_ack_d0_r <= 'd0;
            data_ack_d1_r <= 'd0;
            data_ack_d2_r <= 'd0;
        end
        else begin
            data_ack_d0_r <= data_ack;
            data_ack_d1_r <= data_ack_d0_r;
            data_ack_d2_r <= data_ack_d1_r;
        end
    end

    always @(posedge clk_a or negedge rst_n) begin
        if (!rst_n) begin
            data <= 'd0;
        end
        else if (data_ack_d1_r & !data_ack_d2_r) begin
            data <= data == 'd7 ? 'd0 : data + 'd1;
        end
    end
    
    reg [3-1:0] cnt_r;
    always @(posedge clk_a or negedge rst_n) begin
        if (!rst_n) begin
            cnt_r <= 'd0;
        end
        else if (data_ack_d1_r & !data_ack_d2_r) begin
            cnt_r <= 'd0;
        end
        else if (data_req) begin
            cnt_r <= cnt_r;
        end
        else begin
            cnt_r <= cnt_r + 'd1;
        end
    end
    
    
    always @(posedge clk_a or negedge rst_n) begin
        if (!rst_n) begin
            data_req <= 'd0;
        end
        else if (data_ack_d1_r) begin
            data_req <= 'd0;
        end
        else if (cnt_r == 'd4) begin
            data_req <= 'd1;
        end
    end
endmodule


module data_receiver(
	input clk_b,
	input rst_n,
	input [3:0]data,
	input data_req,
	output reg data_ack
	);
    
    reg data_req_d0_r;
    reg data_req_d1_r;
    reg data_r;
    always @(posedge clk_b or negedge rst_n) begin
        if (!rst_n) begin
            data_req_d0_r <= 'd0;
            data_req_d1_r <= 'd0;
        end
        else begin
            data_req_d0_r <= data_req;
            data_req_d1_r <= data_req_d0_r;
        end
    end
    
    always @(posedge clk_b or negedge rst_n) begin
        if (!rst_n) begin
            data_r <= 'd0;
            data_ack <= 'd0;
        end
        else if (data_req_d1_r) begin
            data_r <= data;
            data_ack <= 'd1;
        end
        else begin
            data_ack <= 'd0;
        end
    end
    
    
    
endmodule

// @nc code=end
