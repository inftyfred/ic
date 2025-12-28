//`define BLOCK
module tb_block;

	event e1;

	initial begin
		$display($time, "e1 is triggering");
		`ifdef BLOCK
			->e1;//block event
		`else
			->>e1;//unblock event
		`endif
	end

	initial begin
		$display($time, "waiting for e1 using wait");
		wait(e1.triggered);
		$display($time, "e1 was triggered(wait)");
	end

	initial begin
		$display($time, "waiting for e1 using @");
		@e1;
		$display($time, "e1 was triggered(@)");
	end

endmodule
