module tb_bins();
	
	bit [2:0] a, b, c, d, e, f, g;
	bit [2:0] value1[$] = '{1, 2, 3, 4, 5, 0, 5};
	bit [2:0] value2[$] = '{1, 3, 4, 2, 1, 0, 2};
	bit [2:0] value3[$] = '{1, 2, 4, 5, 7, 0, 1};
	bit [2:0] value4[$] = '{2, 2, 3, 3, 3, 3, 1};
	bit [2:0] value5[$] = '{1, 2, 4, 4, 3, 4, 5};
	bit [2:0] value6[$] = '{1, 5, 4, 5, 3, 4, 5};

	covergroup cg;
		option.per_instance = 1;
		c1: coverpoint a {bins bin1 = {1}; bins bin2 = {3};} //显示bins
		c2: coverpoint b {bins tran1 = (1 => 2); bins tran2 = (3 => 4);} //单值转换
		c3: coverpoint c {bins tran1 = (1 => 3 => 4 => 2);} //转换序列
		c4: coverpoint d {bins tran1 = (1,2 => 3,4); bins tran2 = (5, 6 => 0, 7);}//转换集合
		c5: coverpoint e {bins tran1 = (2[*2]); bins tran2 = (3[* 4:6]);}//连续重复 重复范围
		c6: coverpoint f {bins tran1 = (1=>4[->3]=>5);} //跳转重复
		c7: coverpoint g {bins tran1 = (5[= 3:4]);} //非连续重复
	endgroup

	cg cg_inst;

	initial begin
		cg_inst = new();
		$display("begin...");
		foreach(value1[i]) begin
			a = value1[i]; b = value1[i]; c = value2[i];
			d = value3[i]; e = value4[i]; f = value5[i];
			g = value6[i];
			cg_inst.sample();
			$display("a=%d, b=%d, c=%d, d=%d, e=%d, f=%d, g=%d", a, b, c, d, e, f, g);
			$display("coverage a = %.2f, coverage b = %.2f, coverage c = %.2f, coverage d = %.2f", cg_inst.c1.get_coverage(), cg_inst.c2.get_coverage(), cg_inst.c3.get_coverage(), cg_inst.c4.get_coverage());
			$display("coverage e = %.2f, coverage f = %.2f, coverage g = %.2f", cg_inst.c5.get_coverage(), cg_inst.c6.get_coverage(), cg_inst.c7.get_coverage());
			$display("avg coverage = %.2f", cg_inst.get_inst_coverage());
		end
		$display("end...");
		$finish();
	end


	initial begin
		`ifdef FSDB
			$fsdbDumpfile("dump.fsdb");
			$fsdbDumpvars(0, tb_bins, "+all");
		`endif
	end


endmodule
