module and_gate(
	input 	wire a,
	input 	wire b,
	input 	wire clk,
	input 	wire rst_n,
	output 	wire y
);

assign y = a && b;

endmodule
