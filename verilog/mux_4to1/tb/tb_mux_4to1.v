`timescale 1ns/1ns
module tb_mux_4to1();

	reg a, b, c, d;
	reg [1:0] sel;
	wire out;

	mux_4to1 u1 (.a(a), .b(b), .c(c), .d(d), .sel(sel), .out(out));

	initial begin
		a = 1; b = 0; c = 1; d = 0;
		sel = 2'b00;
		#200
		sel = 2'b01;
		#200
		sel = 2'b11;
		#200
		sel = 2'b10;
		#200
		c = 0; a = 0; c = 0; d = 1;
		#200
		sel = 2'b00;
		#200
		sel = 2'b01;
		#200
		sel = 2'b10;
		#200
		sel = 2'b11;
	end

`ifdef FSDB
	initial begin
		$fsdbDumpfile("mux.fsdb");
		$fsdbDumpvars();
	end
`endif

endmodule
