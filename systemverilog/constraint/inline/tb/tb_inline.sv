class test;
	
	rand bit[3:0] a;

	constraint con1 {a < 10;}

endclass

module tb_inline;

	test t1;
	int check;
	initial begin
		t1 = new;
		for(int i = 0; i < 2; i++) begin
			if(t1.randomize()) begin
				$display("times:%0d, random success, a=%0d", i+1, t1.a);
			end
			check = t1.randomize() with {a == 9;};
			if(check) begin
				$display("times:%0d, random success with inline constraint(a==9), a=%0d", i+1, t1.a);
			end else begin
				$display("times:%0d,random failed with inline constraint(a==9)", i+1);
			end
			check = t1.randomize() with {a == 5;};
			if(check) begin
				$display("times:%0d, random success with inline constraint(a==5), a=%0d", i+1, t1.a);
			end else begin
				$display("times:%0d, random failed with inline constraint(a==5)", i+1);
			end
		end
	end

endmodule
