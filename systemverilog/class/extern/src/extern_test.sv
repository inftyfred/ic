class home;
	string switch;
	string fan = "OFF";

	extern function void display();

endclass:home

function void home::display();
	string switch = "OFF";
	$display("swicth: %0s, fan: %s", switch, fan);
endfunction:display

module exterrn_test();
	
	initial begin
		home h1 = new();
		h1.display();
	end

endmodule

