module tb_event;

	event e;

	initial begin
		$display("触发事件");
		->e;
	end

	initial begin
		$display("wait event e");
		wait(e.triggered);
		$display("using wait for e triggered");
	end

	initial begin
		$display("wait event e");
		@e;
		$display("using @ for e triggered");
	end

endmodule
