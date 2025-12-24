
class test;
	
	rand bit[3:0] a;
	rand bit[3:0] b;
	rand bit[3:0] c;

	constraint con1 {if(a inside {[4:8]}) { 
						b == 1;
						c == 2;}
					else {					
						b >= 5;
						c == 5;}
	}

endclass

module tb_ifelse;
	
	test t1;

	initial begin
		t1 = new;
		for(int i = 0; i < 10; i++) begin
			void'(t1.randomize());
			$display("random times %0d a=%0d, b=%0d, c=%0d", i+1, t1.a, t1.b, t1.c);	
		end
		$finish;
	end

endmodule
