module struct_union_test();

	typedef struct packed {
		logic [15:0] sa;
		logic [15:0] da;
		logic [31:0] data;
	}packet_st;

	union packed {
		packet_st pst;
		bit [63:0] bit_slice;
		bit [7:0][7:0] byte_slice;
	}packet_un;

	initial begin
		packet_un.pst.sa = '1;
		packet_un.pst.da = 16'h1234;
		packet_un.pst.data = 16'h33;
		$display("packet.sa = %h \t packet.data = %h", packet_un.pst.sa, packet_un.pst.data);
		$display("bit_slice = %h \t byte_slice[7] = %h", packet_un.bit_slice, packet_un.byte_slice[7]);
	end

endmodule
