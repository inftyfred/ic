`timescale 1ns/1ps

// ======================================================================
// tb_VL2 -- Testbench for [VL2] Async-reset series T flip-flop
//
// DUT : Tff_2
//         q0 <= q0 ^ data     (internal staging register)
//         q  <= q  ^ q0       (output; uses NEW q0 due to NBA ordering)
//         Async active-low reset: !rst => q0=0, q=0
//
// Golden model runs in parallel via MON process:
//   - At each posedge: if(rst) update, else clear
//   - This matches the DUT behavior where negedge-rst clears async,
//     and posedge sees rst=0 as well.
// ===========================================================================

module tb_VL2;

    localparam CLK_HALF   = 5;   // half-period ns  (10 ns -> 100 MHz)
    localparam RST_CYCLES = 6;  // reset hold cycles
    localparam SETTLE     = 5;  // post-reset golden sync

    integer total_test;
    integer pass_cnt;
    integer fail_cnt;
    integer txn_id;

    reg        clk  = 0;
    reg        rst  = 0;
    reg        data = 0;

    wire       check;

    initial forever #(CLK_HALF) clk = ~clk;

    Tff_2 dut (.data(data), .clk(clk), .rst(rst), .q(check));

    // ---- Golden model registers ----
    reg  g_q0 = 1'b0;
    reg  g_q  = 1'b0;

    // Monitoring process mirrors DUT: updates on every posedge
    initial begin : MON
        forever begin
            @(posedge clk);
            if (!rst) begin
                g_q0 <= 1'b0;
                g_q  <= 1'b0;
            end else begin
                g_q0 <= g_q0 ^ data;
                g_q  <= g_q ^ g_q0;
            end
        end
    end

    // Helper functions & tasks
    task automatic do_check(input int lbl, input bit actual, input bit gold);
        string lbl_str;
        total_test++;
        if (actual === gold)
            pass_cnt++;
        else begin
            fail_cnt++;
            $sformatf(lbl_str, "cycle[%0d]", lbl);
            $display("[FAIL] %-18s got=%b expected=%b", lbl_str, actual, gold);
        end
    endtask

    function automatic bit gold_q();
        gold_q = g_q;
    endfunction

    task automatic do_reset(int n);
        rst <= 1'b0;
        repeat (n) @(posedge clk);
        rst <= 1'b1;
    endtask

    task automatic run_n_cycles(int n);
        integer i;
        for (i = 0; i < n; i++) begin
            @(posedge clk); #1;
            txn_id++;
            do_check(i, check, gold_q());
            if ((i == 0) || (i == n - 1) || (fail_cnt > 0))
                $display("[%3d] t%0d got=%b gold=%b %s",
                         txn_id, i, check, gold_q(),
                         (check === gold_q()) ? "PASS" : "FAIL");
        end
    endtask

    // ==========================================================================
    // Main flow
    // ==========================================================================
    initial begin : MAIN
        total_test = 0; pass_cnt = 0; fail_cnt = 0; txn_id = 0;

        `ifdef FSDB
            $fsdbDumpfile("dump.fsdb");
            $fsdbDumpvars(0, tb_VL2);
        `endif

        $display("==========================================================");
        $display(" tb_VL2 : Async-reset series T-flip-flop (Tff_2)");
        $display("  q0<=q0^data | q<=q^q0  async=!rst");
        $display("==========================================================");

        // Phase 0: power-on reset settled
        do_reset(RST_CYCLES);
        repeat (SETTLE) @(posedge clk);

        $display("--- phase 0: reset settled ---");
        do_check(0, check, gold_q());
        $display("[CHECK] settled   got=%b gold=%b %c\n",
                 check, gold_q(), (check===gold_q())?80:33);

        // Phase 1: DATA=0 constant (q stays 0)
        $display("--- phase 1: DATA=0 ---");
        data <= 1'b0;
        @(posedge clk); #1;
        txn_id++;
        do_check(1, check, gold_q());
        $display("[CHECK] zero      got=%b gold=%b %c\n",
                 check, gold_q(), (check===gold_q())?80:33);

        // Phase 2: DATA=1 constant (div-by-4 freq pattern)
        $display("--- phase 2: DATA=1 (transient+steady) ---");
        data <= 1'b1;
        run_n_cycles(8);
        $display("");

        // Phase 3: transitions
        $display("--- phase 3: transitions ---");

        // 0->1 transition
        data <= 1'b0;
        @(posedge clk); #1;  // t=0
        data <= 1'b1;
        @(posedge clk); #1;  // t=1
        @(posedge clk); #1;  // t=2
        @(posedge clk); #1;  // t=3 steady
        txn_id++;
        do_check(3, check, gold_q());
        $display("[CHECK] rise-steady got=%b gold=%b %c\n",
                 check, gold_q(), (check===gold_q())?80:33);

        // 1->0 transition
        data <= 1'b0;
        @(posedge clk); #1;  // t=0
        @(posedge clk); #1;  // t=1
        @(posedge clk); #1;  // t=2
        @(posedge clk); #1;  // t=3 steady
        txn_id++;
        do_check(7, check, gold_q());
        $display("[CHECK] fall-steady got=%b gold=%b %c\n",
                 check, gold_q(), (check===gold_q())?80:33);

        // Phase 4: Fixed corner patterns
        $display("--- phase 4: corners ---");

        $display("[run] all-zeros (6 cycles)");
        data <= 1'b0;
        @(posedge clk); #1; @(posedge clk); #1; @(posedge clk); #1;
        @(posedge clk); #1; @(posedge clk); #1; @(posedge clk); #1;
        do_check(4'd5, check, gold_q());
        $display("[CHECK] cz.5      got=%b gold=%b %c\n",
                 check, gold_q(), (check===gold_q())?80:33);

        $display("[run] 0-1-0-1 alternating");
        data <= 1'b0; @(posedge clk); #1;
        data <= 1'b1; @(posedge clk); #1;
        data <= 1'b0; @(posedge clk); #1;
        data <= 1'b1; @(posedge clk); #1;
        do_check(4'd3, check, gold_q());
        $display("[CHECK] alt.3     got=%b gold=%b %c\n",
                 check, gold_q(), (check===gold_q())?80:33);

        $display("[run] all-ones (5 cycles)");
        data <= 1'b1; @(posedge clk); #1;
        data <= 1'b1; @(posedge clk); #1;
        data <= 1'b1; @(posedge clk); #1;
        data <= 1'b1; @(posedge clk); #1;
        data <= 1'b1; @(posedge clk); #1;
        do_check(4'd4, check, gold_q());
        $display("[CHECK] on.4      got=%b gold=%b %c\n",
                 check, gold_q(), (check===gold_q())?80:33);

        $display("[run] single-pulse 0-0-0-1-0-0-0");
        data <= 1'b0; @(posedge clk); #1;
        data <= 1'b0; @(posedge clk); #1;
        data <= 1'b0; @(posedge clk); #1;
        data <= 1'b1; @(posedge clk); #1;
        data <= 1'b0; @(posedge clk); #1;
        data <= 1'b0; @(posedge clk); #1;
        data <= 1'b0; @(posedge clk); #1;
        do_check(4'd6, check, gold_q());
        $display("[CHECK] sp.6      got=%b gold=%b %c\n",
                 check, gold_q(), (check===gold_q())?80:33);

        $display("[run] mixed {F,5,A,9} -> data={1,1,0,1}");
        data <= 1'b1; @(posedge clk); #1;
        data <= 1'b1; @(posedge clk); #1;
        data <= 1'b0; @(posedge clk); #1;
        data <= 1'b1; @(posedge clk); #1;
        do_check(4'd3, check, gold_q());
        $display("[CHECK] mix.3     got=%b gold=%b %c\n",
                 check, gold_q(), (check===gold_q())?80:33);

        $display("");

        // Phase 5: mid-stream reset (sync-style: hold rst low across posedge)
        // Both DUT and MON agree: rst=0 at posedge => clear
        $display("--- phase 5: mid-stream reset ---");

        // Stabilize first
        data <= 1'b0;
        repeat (4) @(posedge clk); #1;   // q=0 steady

        // Assert reset across one posedge (both DUT & MON see rst=0 at posedge)
        rst <= 1'b0;                     // schedule low
        @(posedge clk);                  // this edge catches rst=0 -> clear
        #1;
        do_check(5, check, gold_q());
        $display("[CHECK] sync-reset got=%b gold=%b %c\n",
                 check, gold_q(), (check===gold_q())?80:33);

        // Release and verify restart
        rst <= 1'b1;
        repeat (SETTLE) @(posedge clk);

        data <= 1'b1;
        @(posedge clk); #1;  // t=1
        @(posedge clk); #1;  // t=2
        @(posedge clk); #1;  // t=3 steady: data(t-1)^data(t-2)=1^0=1
        txn_id++;
        do_check(6, check, gold_q());
        $display("[CHECK] recovery   got=%b gold=%b %c\n",
                 check, gold_q(), (check===gold_q())?80:33);

        // Phase 6: random burst
        $display("--- phase 6: random burst (128 txns) ---");
        for (txn_id = 1; txn_id <= 128; txn_id++) begin
            data <= $urandom_range(1);
            @(posedge clk); #1;
            do_check(txn_id, check, gold_q());
            if ((txn_id % 32 == 0) || (fail_cnt > 0))
                $display("[%03d] r%0d got=%b gold=%b %s",
                         txn_id, txn_id, check, gold_q(),
                         (check === gold_q()) ? "PASS" : "FAIL");
        end

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
