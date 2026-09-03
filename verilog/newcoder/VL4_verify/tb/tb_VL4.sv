`timescale 1ns/1ns


module tb_VL4;

reg [7:0] d;
reg clk, rst;

reg input_grant;
reg [10:0] out;

initial begin : CLOCK
	clk = 0;
	forever begin
		#5 clk = ~clk;
	end
end

multi_sel mul_u1 (
.d(d) ,
.clk(clk),
.rst(rst),
.input_grant(input_grant),
.out(out)
);


initial begin : MAIN
	`ifdef FSDB
		$fsdbDumpfile("dump.fsdb");
		$fsdbDumpvars(0, tb_VL4);
	`endif
	d = 0;
	rst = 0;
	#10;
	rst = 1;
	#10;
	d = 143;
	#50;
	d = 7;
	#50;
	d = 6;
	#20;
	d = 128;
	#20;
	d = 129;
	#50;
	d = 251;
	#100;
	$finish;
end

endmodule
