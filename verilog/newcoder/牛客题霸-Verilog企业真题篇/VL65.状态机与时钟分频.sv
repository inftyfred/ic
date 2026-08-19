// @nc app=nowcoder id=25d694a351b748d9808065beb6120025 topic=311 question=5000681 lang=Verilog
// 2026-08-19 01:24:20
// https://www.nowcoder.com/practice/25d694a351b748d9808065beb6120025?tpId=311&tqId=5000681
// [VL65] 状态机与时钟分频

// @nc code=start

`timescale 1ns/1ns

module huawei7(
	input wire clk  ,
	input wire rst  ,
	output reg clk_out
);

//*************code***********//
parameter S_0 = 4'b0001;
parameter S_1 = 4'b0010;
parameter S_2 = 4'b0100;
parameter S_3 = 4'b1000;

reg [3:0] cur_state, next_state;


always @(*) begin
	case(cur_state)
		S_0:next_state = S_1;
		S_1:next_state = S_2;
		S_2:next_state = S_3;
		S_3:next_state = S_0;
		default: next_state = S_0;
	endcase
end

always @(posedge clk or negedge rst) begin
	if(!rst) begin
		cur_state <= S_0;
	end else begin
		cur_state <= next_state;
	end
end

always @(posedge clk or negedge rst) begin
	if(!rst) begin
		clk_out <= 0;
	end else begin
		case(cur_state) 
			S_0:clk_out <= 1;
			default:clk_out <= 0;
		endcase
	end
end

//*************code***********//
endmodule

// @nc code=end
