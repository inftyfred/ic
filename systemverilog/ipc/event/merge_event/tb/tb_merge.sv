
module tb_merge;

	event e1, e2;

	initial begin
		fork 
			#50 ->e1;
			#100 ->e2;
			#10 //e2 = e1;
			begin
				$display($time, "\t waiting for e1");
				wait(e1.triggered);
				$display($time, "\t e1 was triggered");
			end

			begin
				$display($time, "\t waiting for e2");
				wait(e2.triggered);
				$display($time, "\t e2 was triggered");
			end
		join
	end

endmodule
