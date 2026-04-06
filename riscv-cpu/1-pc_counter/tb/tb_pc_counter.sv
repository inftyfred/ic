`timescale 1ns/1ps

module tb_pc_counter();

parameter AW = 32;

logic			clk;
logic			rst_n;
logic			jump_en;
logic [AW-1:0] 	jump_addr;
logic [AW-1:0] 	pc_pointer;
logic			start;

pc_counter #(
	.AW 	(AW) 
	)u1_pc_counter(
		.clk			(clk),
	    .rst_n			(rst_n),
        .jump_en		(jump_en),
        .jump_addr		(jump_addr),
        .pc_pointer		(pc_pointer)
);

always #5 clk=~clk;

initial begin
	clk = 1'b0;
	rst_n = 1'b0;
	jump_en = 1'b0;
	jump_addr = 'h0;
	start = 1'b0;
	#1000;
	rst_n = 1'b1;
	#5000;
	generate_jump(4096);
	#6000;
	generate_jump(2048);
	#1000;
	$finish;
end

task generate_jump(
	input logic [AW-1:0] addr
);
	begin
	@(posedge clk);
	jump_en = 1'b1;
	jump_addr = addr;
	@(posedge clk);
	jump_en = 1'b0;
	jump_addr = 'h0;
	end

endtask

//initial begin
//	`ifdef FSDB
//		$fsdbDumpfile("dump.fsdb");
//		$fsdbDumpvars(0, tb_pc_counter, "+all");
//	`endif
//end

endmodule
