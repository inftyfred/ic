class test;
	
	rand bit[4:0] array1 [5];
	rand bit[4:0] array2 [5];

	constraint con1 {foreach(array1[i]) {
						array1[i] == i+1;
					//foreach(array2[i])
						array2[i] == i;}
	}

endclass

module tb_foreach;

	test t1;
	initial begin
		t1 = new;
		for(int i = 0; i < 10; i++) begin
			void'(t1.randomize());
			$display("random times:%0d, array1=%0p, array2=%0p", i+1, t1.array1, t1.array2);
		end
		$finish;
	end

endmodule
