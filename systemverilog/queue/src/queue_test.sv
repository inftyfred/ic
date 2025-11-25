module queue_test();
	
	int j = 2;
	int q[$] = {0, 1, 3, 6};
	int b[$] = {4, 5};

	function void disp();
		$display("-------------------");
		foreach(q[i]) begin
			$display("INDEX: %d value: %d", i, q[i]);
		end
	endfunction

	typedef struct packed {
		logic [15:0] sa;
		logic [15:0] da;
		logic [31:0] data;
	}packet_t;

	union packed {
		packet_t data_packet;
		logic [63:0] bit_slice;
		logic [7:0][7:0] byte_slice;
	}u_dreg;

	initial begin
		disp();
		q.insert(1, j);
		disp();
		q.delete(1);
		disp();
		q.push_front(7);
		disp();
		q.push_front(7);
		disp();
		j = q.pop_back();
		disp();
		$display(j);
		$display($size(q));
//		q.delete();
		$display(q.size());
	end

endmodule
