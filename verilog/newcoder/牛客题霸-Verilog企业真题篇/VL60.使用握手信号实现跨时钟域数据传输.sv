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
    
reg [2:0] cnt;

reg data_ack_reg0, data_ack_reg1, data_ack_reg2;
wire data_ack_rise;
assign data_ack_rise = data_ack_reg1 & ~data_ack_reg2;

always @(posedge clk_a or negedge rst_n) begin
	if(!rst_n) begin
		data_ack_reg0 <= 1'b0;
		data_ack_reg1 <= 1'b0;
		data_ack_reg2 <= 1'b0;
	end else begin
		data_ack_reg0 <= data_ack;
		data_ack_reg1 <= data_ack_reg0;
		data_ack_reg2 <= data_ack_reg1;
	end
end

always @(posedge clk_a or negedge rst_n) begin
	if(!rst_n) begin
		data <= 0;
		cnt <= 0;
	end else begin
		if(data_req) begin
			data <= data;
			cnt <= cnt;
		end else if(data_ack_rise) begin
			data <= (data == 7) ? 0 : data + 1;
			cnt <= 0;
		end else begin
			cnt <= cnt + 1;
		end
	end
end

always @(posedge clk_a or negedge rst_n) begin
	if(!rst_n) begin
		data_req <= 1'b0;
	end else begin
		if(cnt == 4) begin
			data_req <= 1'b1;
		end else if(data_ack_rise) begin
			data_req <= 1'b0;
		end
	end
end

endmodule

module data_receiver(
	input clk_b,
	input rst_n,
	input [3:0] data,
	input data_req,
	output reg data_ack
);

reg [3:0] data_reg;

reg data_req_reg0, data_req_reg1;
always @(posedge clk_b or negedge rst_n) begin
	if(!rst_n) begin
		data_req_reg0 <= 0;
		data_req_reg1 <= 0;
	end else begin
		data_req_reg0 <= data_req;
		data_req_reg1 <= data_req_reg0;
	end
end

always @(posedge clk_b or negedge rst_n) begin
	if(!rst_n) begin
		data_ack <= 1'b0;
		data_reg <= 0;
	end else begin
		if(data_req_reg1) begin
			data_reg <= data;
			data_ack <= 1'b1;
		end else begin
			data_ack <= 1'b0;
		end
	end
end

endmodule


// @nc code=end
