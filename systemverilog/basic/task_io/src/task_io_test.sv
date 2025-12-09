module task_io_test();

	task T3(input [7:0] a, b, output bit [7:0] c);
		c = a + b;
	endtask

	initial begin
		reg [7:0] a, b, c;
		a = 10; b = 11;
		T3(a, b, c);
		$display("a=%d, b=%d, c=%d", a, b, c);
	end

endmodule
