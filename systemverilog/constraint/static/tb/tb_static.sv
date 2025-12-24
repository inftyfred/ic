class test;
	
	rand bit[3:0] a;

	constraint con1{a == 1;}
		
endclass

class test_static;
	
	rand bit[3:0] a;

	static constraint con1{a == 1;}

endclass

module tb_static;

	test t1, t2;
	test_static t1_static, t2_static;
	parameter RANDOM_TIMES = 10;

	initial begin
		t1 = new;
		t2 = new;
		t1_static = new;
		t2_static = new;
		for(int i = 0; i < RANDOM_TIMES; i++) begin
			if(i == (RANDOM_TIMES/2)) begin
				t1.con1.constraint_mode(0);
				t1_static.con1.constraint_mode(0);
				#1 $display("close t1 and t1_static constraint");
			end
			void'(t1.randomize());
			void'(t2.randomize());
			void'(t1_static.randomize());
			void'(t2_static.randomize());
			#1 $display("random times:%0d, t1:a=%0d, t2:a=%0d \t t1_static:a=%0d, t2_static:a=%0d", i+1, t1.a, t2.a, t1_static.a, t2_static.a);
		end
		$finish;
	end

endmodule
