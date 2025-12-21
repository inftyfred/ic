module tb_cross_coverage();

	bit a, b;

	covergroup cg;
		option.per_instance = 1;
		c1: coverpoint a;
		c2: coverpoint b;
		c3: cross a, b;
	endgroup

	cg cgrp;
	int seed;

	initial begin
		cgrp = new();
		for(int i = 0; i < 15; i++) begin
			a = $random(seed) & 1'b1;
			b = $random(seed) & 1'b1;
			$display("seed = %0d, \n a=%d, b=%d", seed, a, b);
			cgrp.sample();
			$display("coverage a = %.2f, coverage b = %.2f, coverage a and b = %.2f",cgrp.c1.get_coverage(), cgrp.c2.get_coverage(), cgrp.c3.get_coverage());
			$display("avg coverage=%.2f", cgrp.get_inst_coverage());
		end

		//$finish();
	end

	initial begin
		if($value$plusargs("seed=%d", seed)) begin
			$display("get seed from plusargs: seed=%0d", seed);
		end else begin
			seed = 100;
			$display("using default seed:seed=%0d", seed);
		end
	end
	
	initial begin
		`ifdef FSDB
			$fsdbDumpfile("dump.fsdb");
			$fsdbDumpvars(0, tb_cross_coverage, "+all");
		`endif
	end


endmodule
