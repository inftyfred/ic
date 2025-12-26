`timescale 1ns/10ps
module tb_concurrent;

	reg clk;
	bit a, b, c;
	parameter CLK_PERIOD = 10;

	initial begin 
		clk = 0;
		forever #(CLK_PERIOD / 2) clk = ~clk;
	end

	sequence sq1;
		@(posedge clk) (a == 1 && b == 1);
	endsequence
	
	property ppt1;
		sq1;
	endproperty
	
	assert property (ppt1)
		$display("%0t, assert success a=%0d, b=%0d, c=%0d", $time, a, b, c);
	else
		$display("%0t, assert failed a=%0d, b=%0d, c=%0d", $time, a, b, c);

	initial begin
		for(int i = 0; i < 100; i++) begin
			a = $random() & 1'b1;
			b = $random() & 1'b1;
			c = $random() & 1'b1;
			#1;
		end
		#10;
		$finish;
	end
	
	initial begin
		`ifdef FSDB
			$fsdbDumpfile("dump.fsdb");
			$fsdbDumpvars(0, tb_concurrent, "+all");
			$fsdbDumpSVA;
		`endif
	end

endmodule
