`timescale 1ns/1ps
`include "../src/define.sv"

module tb_riscv_top;

parameter	FILE	=`FILE;
parameter	AW		=`AW;
parameter	DW		=`DW;

logic			clk;
logic			rst_n;
logic	[31:0]	tmp;
logic	[31:0]	x3;
logic	[31:0]	x26;
logic	[31:0]	x27;

assign	x3  = tb_riscv_top.u1_riscv_inst.u1_register_inst.regs[3];
assign	x26 = tb_riscv_top.u1_riscv_inst.u1_register_inst.regs[26];
assign	x27 = tb_riscv_top.u1_riscv_inst.u1_register_inst.regs[27];

riscv #(
	.FILE(FILE),
	.AW		(AW),
	.DW		(DW)
) u1_riscv_inst (
	.clk	(clk)		,
	.rst_n	(rst_n)		
);

always #5 clk = ~clk;

initial begin
	clk = 1'b0;
	rst_n = 1'b0;
	tmp	= 'h0;
	#1000;
	rst_n = 1'b1;
	#10000;
	$finish;
end

initial begin
	forever begin
		tmp = x3;
		$display("x3:test[%0d]", x3);
		@(posedge clk);
		if(tmp != x3)
			$display("tmp=%0d,x3:test[%0d]",tmp, x3);
		else if(x26 == 32'h1) begin
			repeat(10) @(posedge clk);
			if(x27 == 32'h1) begin
				$display("\n");
				repeat(3) $display("***************************");
				$display("\n");
				$display("%s", `FILE, "test passed !!!");
				$display("\n");
				repeat(3) $display("***************************");
				$display("\n");
				for(int i = 0; i < 32; i++) begin
					$display("regs[%d] = %d", i, tb_riscv_top.u1_riscv_inst.u1_register_inst.regs[i]);
				end	
			end
			else begin
				$display("\n");
				repeat(3) $display("***************************");
				$display("\n");
				$display("%s", `FILE, "test failed !!!");
				$display("\n");
				repeat(3) $display("***************************");
				$display("the failed test case is test[%d]", x3);
				for(int i = 0; i < 32; i++) begin
					$display("regs[%d] = %d", i, tb_riscv_top.u1_riscv_inst.u1_register_inst.regs[i]);
				end	
			end
		end
		else begin
				repeat(1) $display("***************************");
				$display("\n");
				$display("pass test[%0d]", x3);
				$display("\n");
				repeat(1) $display("***************************");
		end
	end
end


endmodule
