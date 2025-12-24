class test;
	rand int a;
	rand bit [2:0] b;
	constraint c1 {a >= 2; a <= 9;}

	function void display;
		int c;
		if(std::randomize(a, b))
			$display("using std randomize a=%0d, b=%d", a, b);
		if(randomize(a))
			$display("randomize(a) %0d", a);
		if(std::randomize(a))
			$display("using std randmize(a) %0d", a);
		if(std::randomize(b))
			$display("using std randmize(b) %0d", b);
		if(std::randomize(c) with {c > 1; c < 4;})
			$display("using std randomize(c) with constraint 1 < c < 4, c=%0d", c);
		if(this.randomize())
			$display("this randmize a=%0d, b=%d", a, b);
	endfunction

endclass

module tb_random;

	test t;

	initial begin
		t = new();
		repeat(3) 
		t.display();
	end

endmodule
