class base;
	
	static int team;

	function new();
		team++;
	endfunction:new

	static function void disp();
		$display("team=%0d", team);
	endfunction:disp

endclass:base

module static_test();

	base b[3];

	initial begin
		$display();
		foreach(b[i]) begin
			b[i] = new();
		end

		$display("\t contents of team");
		b[2].disp();
		$display();
	end

endmodule:static_test

