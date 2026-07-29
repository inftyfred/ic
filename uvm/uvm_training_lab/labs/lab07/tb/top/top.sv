import uvm_pkg::*;
`include "uvm_macros.svh"

module top;

    bit sys_clk;
	int item_num = 5;

    dut_interface inf(sys_clk);

    router_io inf_router(sys_clk);
	host_io inf_host(sys_clk);

	router dut(.io(inf_router.dut), .host(inf_host.dut));

    assign inf_router.reset_n = inf.reset_n;
	assign inf_router.frame_n = inf.frame_n;
	assign inf_router.valid_n = inf.valid_n;
	assign inf_router.din	  = inf.din;

	assign inf.dout	  	= inf_router.dout;
	assign inf.busy_n  	= inf_router.busy_n;
	assign inf.valido_n	= inf_router.valido_n;
	assign inf.frameo_n	= inf_router.frameo_n;


	initial begin
		sys_clk = 1'b0;
		forever begin
			#10 sys_clk = ~sys_clk;
		end
	end

	initial begin
		uvm_config_db#(virtual dut_interface)::set(null, "uvm_test_top", "top_if", inf);
		uvm_config_db#(int)::set(null, "*.m_seqr.*", "item_num", item_num);
		run_test();
	end

	// initial begin
	// 	$wlfdumpvars();
	// end

	initial begin
		`ifdef FSDB
			$fsdbDumpfile("dump.fsdb");
			$fsdbDumpvars(0, top, "+all");
		`endif
	end

endmodule