module tb_select_coverage();

	bit [2:0] a;

	covergroup cg;
		option.per_instance = 1;
		c1: coverpoint a[1:0];
		c2: coverpoint a[0];
		c3: coverpoint a[2:1];
	endgroup

	cg cgrp;
	int seed;
	
	initial begin
		if($value$plusargs("seed=%d", seed)) begin
			$display("get seed from plusargs: seed=%0d", seed);
		end else begin
			seed = 100;
			$display("using default seed:seed=%0d", seed);
		end
	end

	initial begin
		cgrp = new();
		$display("init seed = %0d ", seed);
		for(int i = 0; i < 15; i++) begin
			a = $random(seed) & 3'b111;
			$display("seed = %0d, \n a=%b, ", seed, a);
			cgrp.sample();
			$display("coverage a[1:0] = %.2f, coverage a[0] = %.2f, coverage a[2:1] = %.2f",cgrp.c1.get_coverage(),cgrp.c2.get_coverage(),cgrp.c3.get_coverage());
			$display("avg coverage=%.2f", cgrp.get_inst_coverage());
		end

		$finish();
	end
	
	initial begin
		`ifdef FSDB
			$fsdbDumpfile("dump.fsdb");
			$fsdbDumpvars(0, tb_select_coverage, "+all");
		`endif
	end

endmodule
