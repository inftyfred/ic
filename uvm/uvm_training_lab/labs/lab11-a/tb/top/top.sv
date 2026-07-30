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

	// 生成复位信号
    initial begin
        inf.reset_n = 1'b0;
        repeat(5) @(posedge sys_clk);
        inf.reset_n = 1'b1;

        // 写解锁寄存器  modport dut(input clk, input wr_n, address, inout data);
        // ----------------- 解锁操作 -----------------
		// force inf_host.address = 16'h0100;
		// force inf_host.data    = 16'hFFFF;
		// force inf_host.wr_n    = 1'b0;      // 写使能
		// @(posedge sys_clk);                 // DUT 在上升沿采样
		// force inf_host.wr_n    = 1'b1;      // 结束写周期

		// // 释放 force，恢复为后续 UVM 驱动（若无其他驱动，信号将保持高阻）
		// release inf_host.address;
		// release inf_host.data;
		// release inf_host.wr_n;
    end

	initial begin
		uvm_config_db#(virtual dut_interface)::set(null, "uvm_test_top", "top_if", inf);
		uvm_config_db#(int)::set(null, "*.m_seqr.*", "item_num", item_num);
		run_test();
	end

	initial begin
		`ifdef FSDB
			$fsdbDumpfile("dump.fsdb");
			$fsdbDumpvars(0, top, "+all");
		`endif
	end

endmodule