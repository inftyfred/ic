//`define USE_THIS

class base_class;
	string fan = "OFF";
	string switch = "ON";

	function void open_electricity();
		string fan = "ON";
		string switch = "OFF";
		`ifdef USE_THIS
		this.fan = fan;
		this.switch = switch;
		$display("inside class mothod: switch is %0s, fan is %0s", this.switch, this.fan);
		`else
		fan = fan;
		switch = switch;
		$display("inside class mothod: switch is %0s, fan is %0s", switch, fan);
		`endif
	endfunction	

endclass

module test();

	base_class a;

	initial begin
		a = new();

		a.open_electricity();
		$display("outside class: switch is %0s, fan is %0s", a.switch, a.fan);
	end

endmodule
