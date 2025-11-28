virtual class A;
	
	int a, b, c;
	pure virtual function void disp();
	pure virtual task sum();

endclass:A

class B extends A;
	
	virtual function void disp();
		a = 10;
		$display("1.Value of a = %0d, b = %0d, c = %0d", a, b, c);
	endfunction:disp
	
	virtual task sum();
		c = a + b;
		$display("2.Value of a = %0d, b = %0d, c = %0d", a, b, c);
	endtask:sum

endclass:B

module pure_virtual_test();
	
	initial begin
		B b1 = new();
		b1.a = 10;
		b1.disp();
		b1.sum();
	end

endmodule:pure_virtual_test


