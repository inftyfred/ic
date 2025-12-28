`timescale 1ns/1ns
module tb_put;

	semaphore s1 = new(6);
	
	initial begin
		$display("In first initial block:time:%0t", $time);
		s1.get(4);
		$display("get 4 keys from s1 time:%0t", $time);
		#4;
		s1.put(2);
		$display("return 2 keys in s1 time:%0t", $time);
		#20
		$display("still using 2 keys:%0t", $time);
		#100
		s1.put(2);
		$display("return all keys in s1, time : %0t", $time);
	end

	initial begin
		$display("In second initial block: time:%0t", $time);
		#1;
		s1.get(5);
		$display("get 5 keys from s1, time:%0t", $time);
		#5;
		s1.put(3);
		$display("return 3 keys in s1, time:%0t", $time);
		#20
		$display("still using 2 keys, time:%0t", $time);
		#50
		s1.put(2);
		$display("return all keys in s1, time:%0t", $time);
	end

endmodule
