`timescale 1ns/1ns
module tb_implication;

	bit a, b, valid, clk;

	always #5 clk = ~clk;

	initial begin
		valid = 1; a = 1; b = 1;
		#15 a = 1; b = 0;
		#10 b = 1;
		#13 b = 0;
		#10 a = 0; b = 1;
		valid = 0;
		#15 a = 1; b = 0;
		#100 $finish;
	end

	property p1;
		@(posedge clk) valid |-> (a ##3 b);
	endproperty

	a1:assert property(p1)
		$info("pass");
	else
		$info("fail");
	
	initial begin
		`ifdef FSDB 
			$fsdbDumpfile("dump.fsdb");
			$fsdbDumpvars(0, tb_implication, "+all");
			$fsdbDumpSVA;
		`endif
	end

endmodule
