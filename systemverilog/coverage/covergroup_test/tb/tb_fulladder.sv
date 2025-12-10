module tb_fulladder();

	reg		[1:0]		ain;
	reg		[1:0]		bin;
	reg					cin;
	wire	[1:0]		sum;
	wire				carry;

	covergroup cgrp;
		coverpoint ain;
		coverpoint bin;
		coverpoint cin;
	endgroup
	cgrp cg = new();

	fulladder u1(
		.ain(ain),
		.bin(bin),
		.cin(cin),
		.sum(sum),
		.carry(carry)
	);

	integer	SEED;
	initial begin
		if(!$value$plusargs("SEED=%d", SEED)) begin
			SEED = 50;
			$display("no SEED plusargs, using defualt:SEED=%0d", SEED);
		end else begin
			$display("using plusargs SEED=%0d", SEED);
		end
	end

	initial begin
	//	cg = new();
		ain = 2'b0;
		bin = 2'b0;
		cin = 1'b0;
		#100
		repeat(3) begin
			ain = 2'b10; //$random(SEED) & 2'b11;
			bin = $random(SEED) & 2'b11;
			cin = $random(SEED) & 1'b1;
			#2;
			cg.sample();
			$display("now: ain=%0d, bin=%0d, cin=%0d, sum=%0d, carry=%0d", ain, bin, cin, sum, carry);
			$display("覆盖点 a: %0.2f%%", cg.ain.get_coverage());
	        $display("覆盖点 b: %0.2f%%", cg.bin.get_coverage());
    	    $display("覆盖点 c: %0.2f%%", cg.cin.get_coverage());

			//$display("coverage = %.2f %%", cg.get_inst_coverage());
			#100;
			//ain = ain + 1'b1;
		end

		$display("\n=== 覆盖率报告 ===");
        $display("总测试次数: 10");
        $display("实例覆盖率: %0.2f%%", cg.get_inst_coverage());
        $display("覆盖点 a: %0.2f%%", cg.ain.get_coverage());
        $display("覆盖点 b: %0.2f%%", cg.bin.get_coverage());
        $display("覆盖点 c: %0.2f%%", cg.cin.get_coverage());
//        $display("覆盖点 cin: %0.2f%%", cg.cin.get_coverage());
 //       $display("交叉覆盖率: %0.2f%%", cg_inst.cross_cases.get_coverage());
	end

	initial begin
		$fsdbDumpfile("dump.fsdb");
		$fsdbDumpvars(0, tb_fulladder, "+all");
	end

endmodule
