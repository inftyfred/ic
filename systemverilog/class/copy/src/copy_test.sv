class base_class;

	string c;
	int d;

	function new();
		c = "test";
		d = 1;
	endfunction:new

	function void disp();
		$display("\t c=%0s, \t d=%0d", c, d);
	endfunction:disp

	function void deep(base_class copy); //copy
		this.c = copy.c;
		this.d = copy.d;
	endfunction:deep

endclass:base_class

module copy_test();
	base_class b1;
	base_class b2;
	
	initial begin
		b1 = new();
		b2 = new();
		b2.deep(b1); //deep copy
		$display();
		$display("b1 contents before:");
		b1.disp();
		$display("b2 contents before:");
		b2.disp();
		b1.c = "b1 test";
		b2.c = "b2 test";

		$display("b1 contents after:");
		b1.disp();
		$display("b2 contents after:");
		b2.disp();
		$display();
	end

endmodule:copy_test

