
class test;

	rand bit [3:0] a;
	rand bit [3:0] b;

	constraint con1 {a dist {1:=30};} //[2:5]:=60, [6:15]:= 10};}
	constraint con2 {b dist {1:/50, [2:5]:/80};}

endclass

module tb_dist;

	test t1;

	initial begin 
		t1 = new;

		for(int i = 0; i < 10; i++) begin
			void'(t1.randomize());
			$display("random times: %0d, a = %0d, b = %0d", i+1, t1.a, t1.b);
		end
		$display("finish");
		$finish;
	end

endmodule
