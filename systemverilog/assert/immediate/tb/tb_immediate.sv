`timescale 1ns/10ps
module tb_immediate;

	reg a,b,c;
	wire carry, out;
	reg clk;
	reg [15:0] count;
	parameter CLK_PERIOD = 10;

	initial begin
		count = 0;
		clk = 0;
		forever #(CLK_PERIOD / 2) clk = ~clk;
	end

	fulladder u1(
		.a_in(a),
		.b_in(b),
		.c_in(c),
		.carry_out(carry),
		.sum_out(out)
	);

	initial begin
		for(int i = 0; i < 10; i++) begin
			a = $random() & 1'b1;
			b = $random() & 1'b1;
			c = $random() & 1'b1;
			#1 $display("%0t a(%0b) + b(%0b) + c(%0b) = sum(%0b), carry(%0b)", $time, a, b, c, out, carry);
		end
	end

	always@(posedge clk) begin
		assert (a == 0 && b == 0) 
			$display("assert success: a=%0d, b=%0d", a, b);
		else 
			$info("assert failed, expect:a=0, b=0");
//		assert(a == 0 && b == 1)
//			$display("assert: a=%0d, b=%0d", a, b);
//		else 
//			$info("assert failed, expect:a=0,b=1");
//		assert(a == 1 && b == 0)
//			$display("assert: a=%0d, b=%0d", a, b);
//		else 
//			$info("assert failed, expect:a=1,b=0");
//		assert(a == 1 && b == 1)
//			$display("assert: a=%0d, b=%0d", a, b);
//		else
//			$info("assert failed,expect:a=1,b=1");
	end

	initial begin
		`ifdef FSDB
			$fsdbDumpfile("dump.fsdb");
			$fsdbDumpvars(0, tb_immediate, "+all");
			$fsdbDumpSVA;
		`endif
		#1000;
		$finish;
	end

endmodule
