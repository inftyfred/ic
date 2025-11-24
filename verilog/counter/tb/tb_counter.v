module tb_counter();

reg 		clk,rst;
wire	[5:0]	counter;

counter u1(clk,rst,counter);

always #(5) clk = ~clk;

initial begin
	clk <= 0;
	rst <= 0;
	#20;
	rst <= 1;
	#50;
	if(counter != 5)
		$display("Failure 1: the counter should be 5 but it is %d",counter);
  else
  	$display("You gotta the right result!");
	$finish;
end

`ifdef FSDB
initial begin
	$fsdbDumpfile("tb_counter.fsdb");
	$fsdbDumpvars;
end
`endif
endmodule

