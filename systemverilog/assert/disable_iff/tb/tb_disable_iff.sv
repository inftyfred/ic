`timescale 1ns/1ns
module tb_disable_iff;
	
	reg a, b, clk, rst_n;
	wire y;

	and_gate u1(
		.a(a),
		.b(b),
		.clk(clk),
		.rst_n(rst_n),
		.y(y)
	);

	always #5 clk = ~clk;

	initial begin
		rst_n <= 0;
		a <= 1;
		b <= 1;
		clk <= 1;
		#20;
		rst_n <= 1;
		repeat(10) begin
			a <= $random() & 1'b1;
			b <= $random() & 1'b1;
			#12;
		end
		#50;
		$finish;
	end

	property p1;
		@(posedge clk) disable iff(!rst_n) a && b;//在复位生效时禁止assert
	endproperty

	a1:assert property(p1)
		$display("time:%0t, assert success: a=%0d, b=%0d, y=%0d", $time, a, b, y);
	else
		$display("time:%0t, assert fail: a=%0d, b=%0d, y=%0d", $time, a, b, y);

	initial begin
		`ifdef FSDB
			$fsdbDumpfile("dump.fsdb");
			$fsdbDumpvars(0, tb_disable_iff, "+all");
			$fsdbDumpSVA;
		`endif
	end

endmodule
