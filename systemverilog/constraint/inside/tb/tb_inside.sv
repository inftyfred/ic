class test;

	rand bit [3:0] a;
	randc bit [3:0] b;
	constraint con1 {(a inside {[10:15]});}
	constraint con2 {!(b inside {[1:7]});}

endclass

module tb_inside;

	test t1;

	initial begin
		t1 = new;
		$display("before randomize(): a = %0d, b = %0d", t1.a, t1.b);
		for(int i = 0; i < 20; i++) begin
			void'(t1.randomize());
			$display("randomize times: %d, a=%d, b=%d", i+1, t1.a, t1.b);
		end
		$display("end...");
		$finish();
	end

endmodule
