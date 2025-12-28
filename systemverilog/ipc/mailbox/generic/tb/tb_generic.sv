`timescale 1ns/1ns

class testA;
	int a;
	int i;
	mailbox m;

	function new(mailbox m1);
		this.m = m1;
	endfunction

	task tra_data();
		for(i = 0; i < 3; i++) begin
			if(m.num() == 2) begin
				$display("mailbox is full");
			end else begin
				a++;
				m.put(a);
				$display("[%0t], transmitter: value of a=%0d", $time, a);
			end
		end
	endtask

endclass:testA

class testB;
	int a;
	int i;
	mailbox m;

	function new(mailbox m2);
		this.m = m2;
	endfunction
	
	task rec_data();
		m.get(a);
		$display("[$0t], receiver:value of a=%0d", $time, a);
	endtask

endclass:testB

module tb_generic;

	testA a1;
	testB b1;
	mailbox mb = new(2);

	initial begin
		a1 = new(mb);
		b1 = new(mb);
		repeat(3) begin
			a1.tra_data();
			$display("------------------------------");
			b1.rec_data();
		end
	end

endmodule
