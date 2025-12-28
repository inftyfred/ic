`timescale 1ns/1ns
module tb_wait_order;

	event e1;
	event e2;
	event e3;

	initial begin
		fork 
			begin
				#3
				->e2;
				$display("e2 was triggered");
			end
	
			begin 
				#6
				->e1;
				$display("e1 was triggered");
			end
	
			begin 
				#10
				->e3;
				$display("e3 was triggered");
			end
		join
	end

	initial begin
		$display("wait event...");
		wait_order(e2, e1, e3)
			$display("order right:e2->e1->e3");
		else
			$display("order error");
	end

endmodule
