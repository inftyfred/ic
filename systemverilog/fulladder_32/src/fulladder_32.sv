
module fulladder_32(a, b, cin, out);

	input 	[31:0]	a;
	input 	[31:0]	b;
	input			cin;
	output	[32:0]	out;

	assign	out = a + b + cin;

endmodule
