// @nc app=nowcoder id=296e1060c1734cf0a450ea58dd09d36c topic=311 question=5000679 lang=Verilog
// 2026-10-13 23:23:45
// https://www.nowcoder.com/practice/296e1060c1734cf0a450ea58dd09d36c?tpId=311&tqId=5000679
// [VL63] 并串转换

// @nc code=start

`timescale 1ns/1ns
module huawei5(
	input wire clk  ,
	input wire rst  ,
	input wire [3:0]d ,
	output wire valid_in ,
	output wire dout
	);

reg [3:0] d_reg;
reg [1:0] cnt;
reg dout_reg;
reg valid_in_reg;

assign dout = d_reg[3];
assign valid_in = valid_in_reg;

//*************code***********//
always @(posedge clk or negedge rst) begin
	if(!rst) begin
		d_reg <= 4'd0;
		dout_reg <= 0;
	end else begin
		if(cnt == 2'b11) begin
			d_reg <= d;
		end else begin
			d_reg <= d_reg << 1;
		end
	end
end

always @(posedge clk or negedge rst) begin
	if(!rst) begin
		cnt <= 2'b00;
	end else begin
		cnt <= cnt + 2'b01;
	end
end

always @(posedge clk or negedge rst) begin
	if(!rst) begin
		valid_in_reg <= 1'b0;
	end else begin
		if(cnt == 2'b11)
			valid_in_reg <= 1'b1;
		else
			valid_in_reg <= 1'b0;
	end
end

//*************code***********//

endmodule

// @nc code=end
