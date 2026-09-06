`timescale 1ns/1ns


module tb_VL6;

//input
reg clk, rst_n;
reg signed [7:0] a, b;
reg [1:0] select;
//output
reg signed [8:0] c;

//sim
bit signed [7:0] a_, b_;
bit [1:0] sel;
bit [15:0] total;
bit [15:0] pass;
bit [15:0] fail;


//dut
data_select u1(
	.clk(clk),
	.rst_n(rst_n),
	.a(a),
	.b(b),
	.select(select),
	.c(c)
);


initial begin : CLOCK
	clk = 0;
	forever #5 clk = ~clk;
end

initial begin : MAIN
	`ifdef FSDB
		$fsdbDumpfile("dump.fsdb");
		$fsdbDumpvars(0, tb_VL6);
	`endif
	reset(1);
	#10;
	a_ = $random();
	b_ = $random();
	sel = $random();
	input_check(sel, a_, b_);
	input_check(2'b00, 12, 13);
	input_check(2'b00, 14, 13);
	input_check(2'b00, 15, 13);
	input_check(2'b01, 16, 13);
	input_check(2'b01, 15, 13);
	input_check(2'b01, 5, 13);
	input_check(2'b11, 15, 13);
	input_check(2'b11, 5, 17);
	input_check(2'b11, 15, -13);
	input_check(2'b11, -15, 13);
	input_check(2'b10, -13, 13);
	input_check(2'b10, -11, 13);
	input_check(2'b10, -15, 18);
	#100;
	$display("[finish] total test:%0d, pass:%0d, fail %0d", total, pass, fail);
	$finish;
end


task automatic reset(input bit n);
	rst_n = 0;
	repeat(n) @(posedge clk);
	rst_n = 1;
endtask

task automatic set_input();
	input bit [1:0] sel;
	input bit signed [7:0] a_;
	input bit signed [7:0] b_;

	@(posedge clk);
	a <= a_;
	b <= b_;
	select <= sel;
	@(posedge clk);

endtask

function bit signed [8:0] get_expect(bit [1:0] sel, bit signed [7:0] a_, bit signed [7:0] b_);

if(sel == 2'b00)
	return a_;
else if(sel == 2'b01)
	return b_;
else if(sel == 2'b10)
	return a + b;
else 
	return a - b;

endfunction

task automatic check();
	input bit [1:0] sel;
	input bit signed [7:0] a_;
	input bit signed [7:0] b_;
	bit signed [8:0] c_;

	c_ = get_expect(sel, a_, b_);
	total = total + 1;
	@(posedge clk);
	if(c_ == c) begin
		pass = pass + 1;
		$display("[pass] output expected:%0d", c);
	end else begin
		fail = fail + 1;
		$display("[error] output:%0d,but expexted:%0d",c, c_);
	end
	@(posedge clk);

endtask

task automatic input_check();
	
	input bit [1:0] sel;     
	input bit signed [7:0] a_;
	input bit signed [7:0] b_;
	bit signed [8:0] c_;
	
	set_input(sel, a_, b_);
	check(sel, a_, b_);

endtask

endmodule


