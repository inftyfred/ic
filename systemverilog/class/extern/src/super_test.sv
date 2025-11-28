class base_class;
	string fan, switch;

	function void display();
		switch = "ON";
		$display("Here using super keyword");
		$write("switch is %s \n", switch);
	endfunction:display

endclass:base_class

class sub_class extends base_class;
	string fan = "ON";

	function void display();
		super.display();
		$write("that's why fan is %s \n", fan);
	endfunction:display

endclass:sub_class


module super_test;

	sub_class s1;
	initial begin
		s1 = new();
		s1.display();
	end

endmodule:super_test
