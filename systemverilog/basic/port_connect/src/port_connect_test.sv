`timescale 1ns/100ps

// add module
module adder(input [3:0] ain, bin, output [3:0] out, co);
	assign {co, out} = ain + bin;
endmodule:adder

//sub module
module sub(input [3:0] ain, bin, output [3:0] out);
	assign out = ain - bin;
endmodule:sub

//regs module
module regs(input [3:0] in1, in2, input sel, en, output logic [3:0] result, input clk, rst_n);
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			result <= '0;
		end
		else begin
			if(en) begin
				if(sel) result <= in1;
				else	result <= in2;
			end
		end
	end
endmodule:regs

//top module
module port_connect_test();
	parameter simulation_cycle = 10;
	reg [3:0] ain, bin;
	reg		sel, en, rst_n, clk;
	wire [3:0] adder_out, sub_out, result;
	wire co;

	//using .name and .* port connection
	adder u1(.ain(ain), .bin(bin), .co(co), .out(adder_out));
	sub	u2(.ain, .bin, .out(sub_out));
	regs	u3(.in1(adder_out), .in2(sub_out), .*);

	initial begin
		ain = 0; bin = 0; sel = 0; en = 0; rst_n = 0;
		@(posedge clk);
		ain = 3; bin = 4; sel = 1; en = 1; rst_n = 1;
		@(posedge clk);
		en = 0;
		@(posedge clk);
		ain = 6; bin = 5; sel = 0; en = 1;
		@(posedge clk);
		en = 0;
		repeat(10)@(posedge clk);
		$finish;
	end

	initial begin
		$monitor("ain=%d \t bin=%d \t adder_out=%d \t sub_out=%d \t sel=%b \t en=%b \t result = %d", ain, bin, adder_out, sub_out, sel, en, result);	
	end
	
	initial begin
		clk = 0;
		forever begin
			#(simulation_cycle / 2)
				clk = ~clk;
		end
	end
	`ifdef FSDB
		initial begin
			$fsdbDumpfile("wave.fsdb");
			$fsdbDumpvars;
		end
	`endif
endmodule


