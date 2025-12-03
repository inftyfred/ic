`timescale	10ns/1ns
module tb_fulladder_32();

	reg		[31:0]		a;
	reg		[31:0]		b;
	reg					cin;
	reg 				clk;
	reg					rst_n;
	wire	[32:0]		out;

	parameter	CLK_PERIOD=10;

	fulladder_32 u1(
			.a(a),
			.b(b),
			.cin(cin),
			.out(out)
	);

	initial begin
		clk = 0;
		rst_n = 0;  // 初始复位状态
		#100 rst_n = 1;  // 100ns后释放复位
		forever begin
			#(CLK_PERIOD/2) clk = ~clk;
		end
	end
	
	integer seed;
	initial begin
		if(!$value$plusargs("seed=%d",seed)) begin
			seed = 100;
			$display("no seed,default Random function with the seed=%d", seed);
		end else begin
			$display("Random function with the seed=%d", seed);
		end
	end

	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			a = 32'b0;
			b = 32'b0;
			cin = 1'b0;
		end
		else begin
			a = $random(seed);
			b = $random(seed);
			cin = $random(seed) & 1'b1;
			$display("%0t adder_sum = %0d, a=%0d, b=%0d, cin=%0d", $time, out, a, b, cin);
		end
	end
	
	`ifdef FSDB
		initial begin
			$fsdbDumpfile("dump.fsdb");
			$fsdbDumpvars(0, tb_fulladder_32, "+all");
		end
	`endif

	// 测试控制：运行100个时钟周期后结束
	initial begin
		#(100*CLK_PERIOD)
		$display("%0t Test completed after 10000 clock cycles", $time);
		$finish;
	end


endmodule
