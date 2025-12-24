class test;
	
	rand bit[3:0] a;
	rand bit[3:0] b;

	constraint con1 {a > 5;}
	constraint con2 {soft b > 5;}

endclass

module tb_soft;

	test t1;
	int check;
	initial begin
		t1 = new;
		check = (t1.randomize());
		if(check) begin
			$display("default random success, a=%0d, b=%0d", t1.a, t1.b);
		end else begin
			$display("default random failed, a=%0d, b=%0d", t1.a, t1.b);
		end
		check = t1.randomize() with {b == 4;};
		if(check) begin
			$display("random success with inline constraint(b==4), a=%0d, b=%0d", t1.a, t1.b);
		end else begin
			$display("random failed with inline constraint(b==4), a=%0d, b=%0d", t1.a, t1.b);
		end
		check = t1.randomize() with {a == 10;};//using a==4 will report error!!!
		if(check) begin
			$display("random success with inline constraint(a==4), a=%0d, b=%0d", t1.a, t1.b);
		end else begin
			$display("random success with inline constraint(a==4), a=%0d, b=%0d", t1.a, t1.b);
		end

		#100;
		$finish;
	end
	
endmodule
