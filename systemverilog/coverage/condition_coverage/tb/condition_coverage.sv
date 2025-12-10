`timescale 10ns/1ns
class myclass;

	rand logic [2:0] a;
	rand logic [2:0] b;
	rand logic	     c;

endclass

module condition_coverage();

	parameter CLK_PERIOD = 10;

	reg			clk;
	myclass mc1 = new();

	covergroup cgrp; //@(posedge clk);
		option.per_instance = 1;
		c1: coverpoint mc1.a iff(mc1.c == 'b1) {
			bins b1 = {0};
			bins b2 = {2};
			bins b3 = {4};
			bins b4 = {6};
		}
		c2: coverpoint mc1.b iff(mc1.c == 'b0) {
			bins b1 = {1};
			bins b2 = {3};
			bins b3 = {5};
			bins b4 = {7};
		}
	endgroup
	cgrp cp = new();

	initial begin
		forever begin
			#(CLK_PERIOD / 2) clk = ~clk;
		end
	end

	initial begin

		for(int i = 0; i < 15; i++) begin
			void '(mc1.randomize());
			#1;
			cp.sample();
			$display("a=%d, b=%d, c=%d, coverage=%.2f %%", mc1.a, mc1.b, mc1.c, cp.get_inst_coverage());
			$display("coverage c1=%.2f %% \t coverage c2=%.2f %%", cp.c1.get_coverage(), cp.c2.get_coverage());
			if(cp.get_inst_coverage() > 99) begin
				cp.stop();
				$display("coverage=%.2f %%, sample stop!", cp.get_inst_coverage());
			end
		end

		$finish();
	end

	initial begin
		`ifdef FSDB
			$fsdbDumpfile("dump.fsdb");
			$fsdbDumpvars(0, condition_coverage, "+all");
		`endif
	end

endmodule
