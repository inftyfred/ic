module task_func_test();
	
	task ref_test(ref int a);
		a = a + 1;
	endtask

	function void disp(int x);
		$display("DISP: %d", x);
	endfunction


	initial begin
		int a = 10;
		#10 $display("a = %d", a);
		#20 ref_test(a);
		#30 $display("a = %d", a);
		disp(a);
	end

endmodule
