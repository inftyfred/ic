`timescale 1ns/1ns


module tb_VL7;

//dut input
reg clk , rst_n;
reg [7:0] a, b;
//dut output
wire [8:0] c;
//dut inst
data_minus u1(
	.clk(clk),
	.rst_n(rst_n),
	.a(a),
	.b(b),
	.c(c)
);

//sim
int total_cnt, pass_cnt, fail_cnt;

initial begin:CLOCK
	clk = 0;
	forever #5 clk = ~clk;
end

initial begin:MAIN
`ifdef FSDB
	$fsdbDumpfile("dump.fsdb");
	$fsdbDumpvars(0, tb_VL7);
`endif
	rst_n = 0;
	#10;
	rst_n = 1;
	#10;
	input_and_check(8'd5, 8'd6);
	input_and_check(8'd127, 8'd0);
	input_and_check(8'd125, 8'd127);
	#100
	$display("[finish] total test:%0d, pass:%0d, fail:%0d", total_cnt, pass_cnt, fail_cnt);
	$finish;
end


function bit [8:0] golden(bit [7:0] a_, b_);
	bit [8:0] c_;
	if(a_ > b_)
		c_ = a_ - b_;
	else	
		c_ = b_ - a_;
	return c_;
endfunction

task automatic set_input();
	input bit [7:0] a_, b_;
	@(posedge clk);
	a <= a_;
	b <= b_;
//	@(posedge clk);
endtask

task automatic check();
	input bit [7:0] a_, b_;
	bit [8:0] c_;
	c_ = golden(a_, b_);
	@(posedge clk);
	#1;
	if(c_ == c) begin
		pass_cnt = pass_cnt + 1;
		$display("[pass] output match expected:%0d", c);
	end else begin
		fail_cnt = fail_cnt + 1;
		$display("[fail] output:%0d unmatch expected:%0d", c, c_);
	end
endtask

task automatic input_and_check();
	input bit [7:0] a_, b_;
	total_cnt = total_cnt + 1;
	set_input(a_, b_);
	check(a_, b_);
endtask

endmodule

