	// `include "rtl/router_io.sv"
    // `include "rtl/host_io.sv"
    // `include "rtl/router.sv"
    import uvm_pkg::*;
	`include "uvm_macros.svh"
    //`include "tb/interface/dut_interface.sv"
	// `include "tb/my_transaction.sv"
	// `include "tb/my_driver.sv"
	// `include "tb/my_monitor.sv"
	// `include "tb/my_sequence.sv"
	// `include "tb/my_sequencer.sv"
	// `include "tb/master_agent.sv"
	// `include "tb/my_env.sv"
	// `include "tb/my_test.sv"
	// `include "tb/my_transaction_da3.sv"
	// `include "tb/my_driver_count.sv"
	// `include "tb/my_test_type_da3.sv"
	// `include "tb/my_test_inst_da3.sv"
	// `include "tb/my_test_driver.sv"

module top;

    bit sys_clk;

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
		uvm_config_db#(virtual dut_interface)::set(null, "*.m_agent.*", "m_vif", inf);
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