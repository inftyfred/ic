`timescale 1ns/1ns
module tb_try_get;

	semaphore s1 = new(10);

	initial begin
		$display("expect get 4 keys,time:%0t", $time);
		if(s1.try_get(4)) begin
			$display("get 4 keys success, time:%0t", $time);
			#20;
			s1.put(2);
			$display("return 2 keys in s1, time:%0t", $time);
			#100;
			s1.put(2);
			$display("return all keys in s1, time:%0t", $time);
		end else begin
			$display("get 4 keys failed, time:%0t", $time);
		end
	end

	initial begin
		#1;
		$display("expect get 9 keys, time:%0t", $time);
		if(s1.try_get(9)) begin
			$display("get 9 keys success, time:%0t", $time);
			#100;
			s1.put(9);
			$display("return all keys in s1, time:%0t", $time);
		end else begin
			$display("get 9 keys failed, time:%0t", $time);
		end
	end

endmodule
