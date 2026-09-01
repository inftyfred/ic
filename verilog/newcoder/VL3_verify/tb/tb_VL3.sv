`timescale 1ns/1ps

// ======================================================================
// tb_VL3 – Testbench for [VL3] 奇偶校验 (Parity Checker)
//
// DUT   : odd_sel
//         out = ^bus              // XOR-reduce 32 data bits
//         check = sel ? out       : ~out    // sel={1|0} → odd|even parity
//
// Strategy : purely combinational → drive values and sample immediately.
//             No pipeline / latency tracking required.
//
// Stimulus :
//   1. Single-line vectors (32×sel=0+1)        — tests each bit individually
//   2. Fixed corners (all-zero, all-ones, alt, known-random) × {sel=0,1}
//   3. Random sweep (500 vectors)               — broad coverage
// ======================================================================

module tb_VL3;

    // ------------------------------------------------------------------
    // Dummy clock (DUT has none, but @(posedge) needs something to sync on)
    // ------------------------------------------------------------------
    reg clk = 0;
    always #5 clk = ~clk;

    // ------------------------------------------------------------------
    // Bookkeeping
    // ------------------------------------------------------------------
    integer total_test;
    integer pass_cnt;
    integer fail_cnt;
    integer txn_id;

    reg  [31:0] bus = 32'd0;
    reg         sel = 1'b0;

    wire        check;

    // ------------------------------------------------------------------
    // DUT
    // ------------------------------------------------------------------
    odd_sel dut (.bus(bus), .sel(sel), .check(check));

    // ------------------------------------------------------------------
    // Golden model
    // ------------------------------------------------------------------
    function automatic bit golden(input [31:0] bv, input s);
        golden = s ? (^bv) : (~(^bv));
    endfunction

    // Single-point checker -------------------------------------------------
    task automatic chk(input string tag,
                       input int    exp_v,
                       input int    got_v,
                       input [31:0] bv,
                       input        s);
    begin
        total_test++;
        if (got_v === exp_v) begin
            pass_cnt++;
        end else begin
            fail_cnt++;
            $display("[FAIL] %-18s bus=%08h sel=%b expected=%d got=%d",
                     tag, bv, s, exp_v, got_v);
        end
    end
    endtask

    // Transaction runner ---------------------------------------------------
    task automatic run_txn(input [31:0] bv, input s);
        bit      exp, got;
        integer  status_char;
    begin
        txn_id++;
        exp = golden(bv, s);
        bus <= bv;
        sel <= s;
        @(negedge clk);     // wait one half-cycle for comb output to settle
        got = check;
        chk("txn", exp, got, bv, s);
        status_char = (exp === got) ? 80 : 33;  // 'P'/'!'
        $display("[%3d] bus=%08h sel=%b | exp=%0d  got=%0d  [%c]",
                 txn_id, bv, s, exp, got, status_char);
    end
    endtask

    // ------------------------------------------------------------------
    // Watchdog
    // ------------------------------------------------------------------
    initial begin : WATCHDOG
        #100_000;
        $display("FATAL: watchdog timeout – simulation aborted");
        $finish;
    end

    // ==================================================================
    // Main flow
    // ==================================================================
    initial begin : MAIN

        total_test = 0;
        pass_cnt   = 0;
        fail_cnt   = 0;
        txn_id     = 0;

`ifdef FSDB
        $fsdbDumpfile("dump.fsdb");
        $fsdbDumpvars(0, tb_VL3);
`endif

        $display("==========================================================");
        $display(" tb_VL3 : 奇偶校验 c = ^bus  sel={1|0}?{c}{~c}");
        $display("  32-bit bus  |  64 corner + 500 random txns");
        $display("==========================================================");

        // -- Phase 1: single-line isolation (32 bits) ---------------------
        $display("--- single-bit vectors ---");
        for (int i = 0; i < 32; i++) begin
            run_txn(32'(1) << i, 1'b1);
            run_txn(32'(1) << i, 1'b0);
        end

        // -- Phase 2: fixed corner cases ----------------------------------
        $display("--- corner cases ---");
        run_txn(32'h0000_0000, 1'b1);
        run_txn(32'h0000_0000, 1'b0);
        run_txn(32'hFFFF_FFFF, 1'b1);
        run_txn(32'hFFFF_FFFF, 1'b0);
        run_txn(32'hAAAA_AAAA, 1'b1);
        run_txn(32'hAAAA_AAAA, 1'b0);
        run_txn(32'h5555_5555, 1'b1);
        run_txn(32'h5555_5555, 1'b0);
        run_txn(32'h1234_5678, 1'b1);
        run_txn(32'h1234_5678, 1'b0);

        // -- Phase 3: randomized burst ------------------------------------
        $display("--- randomized burst (500 txns) ---");
        repeat (500)
            run_txn($urandom(), $urandom_range(1));

        // -- Final report ---------------------------------------------------
        $display("");
        $display("############################################################################");
        $display("# FINAL REPORT  |  total=%0d  pass=%0d  fail=%0d", total_test, pass_cnt, fail_cnt);
        $display("############################################################################");
        if (fail_cnt == 0) begin
            $display("TEST PASSED");
            $display("Simulation Finished Successfully");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end

endmodule
