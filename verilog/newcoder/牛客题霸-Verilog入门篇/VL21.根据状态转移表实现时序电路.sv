// @nc app=nowcoder id=455c911bee0741bf8544a75d958425f7 topic=301 question=5000590 lang=Verilog
// 2026-09-21 22:04:39
// https://www.nowcoder.com/practice/455c911bee0741bf8544a75d958425f7?tpId=301&tqId=5000590
// [VL21] 根据状态转移表实现时序电路

// @nc code=start

`timescale 1ns/1ns

module seq_circuit(
      input                A   ,
      input                clk ,
      input                rst_n,
 
      output   wire        Y   
);

reg q1, q0, Y_r;

assign Y = q1 & q0;//Y_r;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
			Y_r <= 1'b0;
            q0 <= 1'b0;
            q1 <= 1'b0;
	end else begin
		q0 	<= ~q0;
		q1 	<= A ^ q1 ^ q0;
		//Y_r <= q1 & q0; 应该使用组合逻辑赋值
	end
end

endmodule

// @nc code=end
