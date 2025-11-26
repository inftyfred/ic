module fulladder(input a_in, b_in, c_in, output carry_out, sum_out);

	assign sum_out = a_in ^ b_in ^ c_in;
	assign carry_out = (a_in & b_in) | (a_in & c_in) | (b_in & c_in);

endmodule
