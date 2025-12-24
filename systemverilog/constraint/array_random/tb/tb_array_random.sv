class test;
	rand bit [4:0] a [2:0][3:0];
	constraint cons1 {foreach(a[i,j]) a[i][j] < 10;}

endclass

module tb_array_random;

	test t1;

	initial begin
		t1 = new();
		$display("befor randomize()");
		$display("array a: %0p", t1.a);
		for(int i = 0; i < 5; i++) begin
			void'(t1.randomize());
			$display("Iteration = %0d, Array = %0p", i, t1.a);
		end
	end

endmodule
