
function bit[3:0] sum(bit a, bit b); 
	int c;
	c = a + b;

	return c;

endfunction

class val;
	bit[1:0] a;
	bit[1:0] b;
endclass


module tb_cross_coverage();

	val v;
	
	covergroup cg;
		option.per_instance = 1;
		c1: coverpoint v.a;
		c2: coverpoint v.b;
		c3: coverpoint sum(v.a, v.b);
	endgroup

	cg cgrp;
	int seed;

	initial begin
		cgrp = new();
		v = new();
		for(int i = 0; i < 15; i++) begin
			v.a = $random(seed) & 2'b11;
			v.b = $random(seed) & 2'b11;
			$display("seed = %0d, \n a=%d, b=%d", seed, v.a, v.b);
			cgrp.sample();
			$display("coverage v.a = %.2f, coverage v.b = %.2f, coverage sum of a and b=%.2f",cgrp.c1.get_coverage(),cgrp.c2.get_coverage(),cgrp.c3.get_coverage());
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
