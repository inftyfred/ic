//蕴涵约束、双向约束

class test;
	
	rand bit[3:0] a;
	rand bit[3:0] b;
	
	constraint con1 {a inside {[1:5]} -> b < 8;}
	constraint con2 {a < 4;}
	constraint con3 {a >= 0;}
endclass

module tb_implication;
	
	test t1;

	initial begin
		t1 = new;

		for(int i = 0; i < 10; i++) begin
			void'(t1.randomize());
			$display("random times %0d, a=%0d, b=%0d", i+1, t1.a, t1.b);
		end
		$display("finish");
		$finish;
	end

endmodule
