module top();
	adder inf();

	tb_fulladder test(inf);

	fulladder dut(.a_in(inf.a_in), .b_in(inf.b_in), .c_in(inf.c_in), .sum_out(inf.sum_out), .carry_out(inf.carry_out));

endmodule
