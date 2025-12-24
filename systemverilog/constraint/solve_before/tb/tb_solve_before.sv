class with_solve_before;

	rand bit 		a;
	rand bit[3:0] 	b;

	constraint con1 {a == 1 -> b == 1;
					solve a before b;
	}

endclass

class without_solve_before;
	
	rand bit 		a;
	rand bit[3:0]	b;

	constraint con1 {a==1 -> b==1;}

endclass


module tb_solve_before;

	with_solve_before    wsb1;
	without_solve_before wsb2;
	initial begin
		wsb1 = new;
		wsb2 = new;
		$display("without solve before:");
		for(int i = 0; i < 32; i++) begin
			void'(wsb2.randomize());
			$display("random times:%0d, a=%0d, b=%0d", i+1, wsb2.a, wsb2.b);
		end
		$display("with solve before:");
		for(int i = 0; i < 10; i++) begin
			void'(wsb1.randomize());
			$display("random times:%0d, a=%0d, b=%0d", i+1, wsb1.a, wsb1.b);
		end

		$finish;
	end

endmodule

