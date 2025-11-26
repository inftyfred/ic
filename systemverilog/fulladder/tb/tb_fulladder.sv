//`include "driver.sv"

class driver;
	virtual adder vinf;
	function new(virtual adder vinf);
		this.vinf = vinf;
	endfunction

	task run();
		repeat(10) begin
			vinf.a_in = $random;
			vinf.b_in = $random;
			vinf.c_in = $random;
			$display;
			$display("input of fulladder: a_in=%0b, b_in=%0b, c_in=%0b", vinf.a_in, vinf.b_in, vinf.c_in);
			#5;
			$display("output of fulladder: sum_out=%0b, carry_out=%0b", vinf.sum_out, vinf.carry_out);
		end
	endtask

endclass


module tb_fulladder(adder inf);
	driver drv;
	
	initial begin
		drv = new(inf);
		drv.run();
	end

endmodule
