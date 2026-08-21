// @nc app=nowcoder id=9f7c92635b5f49579e8e38fd8c8450d7 topic=311 question=5000687 lang=Verilog
// 2026-08-20 23:07:28
// https://www.nowcoder.com/practice/9f7c92635b5f49579e8e38fd8c8450d7?tpId=311&tqId=5000687
// [VL69] 脉冲同步器（快到慢）

// @nc code=start

`timescale 100ps/100ps

module pulse_detect(
	input 				clka	, 
	input 				clkb	,   
	input 				rst_n		,
	input				sig_a		,

	output  		 	sig_b
);

reg	sig_a_d0, sig_a_d1;
reg sig_a_d2, sig_a_d3, sig_a_d4;
wire sig_a_rise;

assign sig_a_rise = sig_a & ~sig_a_d0;

always @(posedge clka or negedge rst_n) begin
	if(!rst_n) begin
		sig_a_d0 <= 0;
	end else begin
		sig_a_d0 <= sig_a;
	end
end

always @(posedge clka or negedge rst_n) begin
	if(!rst_n) begin
		sig_a_d1 <= 0;
	end else begin
		if(sig_a_rise)
			sig_a_d1 <= ~sig_a_d1;
		else 
			sig_a_d1 <= sig_a_d1;
	end
end

always @(posedge clkb or negedge rst_n) begin
	if(!rst_n) begin
		sig_a_d2 <= 0;
		sig_a_d3 <= 0;
		sig_a_d4 <= 0;
	end else begin
		sig_a_d2 <= sig_a_d1;
		sig_a_d3 <= sig_a_d2;
		sig_a_d4 <= sig_a_d3;
	end
end

assign sig_b = sig_a_d4 ^ sig_a_d3;
    
endmodule

// @nc code=end
