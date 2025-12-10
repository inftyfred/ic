module fulladder(ain, bin, cin, sum, carry);
	
	input 	[1:0]	 	ain;
	input	[1:0]		bin;
	input				cin;
	output	[1:0]		sum;
	output				carry;

	assign {carry, sum} = ain + bin + cin;

endmodule
