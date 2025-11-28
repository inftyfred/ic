`define REWRITE
class parent;

	string a = "parent";
	int b = 10;

	virtual function void disp();
		$display("a=%0s", a);
		$display("b=%0d", b);
	endfunction:disp

endclass:parent

class son extends parent;
	string a = "son";
	string b = 100;
	`ifdef REWRITE
	function void disp();
		$display("son: a=%0s", a);
		$display("son: b=%0d", b);
	endfunction:disp
	`endif

endclass:son

module virtual_test();
	
	initial begin
		son s1 = new();
		s1.disp();
	end

endmodule:virtual_test

