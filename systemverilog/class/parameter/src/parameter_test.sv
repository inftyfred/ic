class data #(parameter a, type team = string);
	
	bit [a - 1: 0] d;
	team c;

	function new();
		d = 20;
		c = "test";
	endfunction:new

	function void disp();
		$display("d=%0d, c=%0s", d, c);
	endfunction

endclass:data

module parameter_test();
	data #(4) d1;
	
	initial begin
		d1 = new();	
		d1.disp();
	end

endmodule

