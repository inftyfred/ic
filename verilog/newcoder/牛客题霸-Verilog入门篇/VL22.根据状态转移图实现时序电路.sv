// @nc app=nowcoder id=e405fe8975e844c3ab843d72f168f9f4 topic=301 question=5000591 lang=Verilog
// 2026-09-22 21:33:17
// https://www.nowcoder.com/practice/e405fe8975e844c3ab843d72f168f9f4?tpId=301&tqId=5000591
// [VL22] 根据状态转移图实现时序电路

// @nc code=start

`timescale 1ns/1ns

module seq_circuit(
   input                C   ,
   input                clk ,
   input                rst_n,
 
   output   wire        Y   
);

reg q1, q0;

assign Y = (q1 & q0) | (q1 & C);

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		q0 <= 1'b0;
	end else begin
		q0 <= (q0 & ~C) | (~q1 & C);
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		q1 <= 1'b0;
	end else begin
		q1 <= (q0 & ~C) | (q1 & C);
	end
end

endmodule

// @nc code=end
