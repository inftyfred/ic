`timescale 1ns/1ns

module tb_ali16;

    // ============================================================
    // DUT ports
    // ============================================================
    reg  clk;
    reg  rst_n;
    reg  d;
    wire dout;

    // ============================================================
    // Statistics & waveform
    // ============================================================
    integer errors;
    integer total_chk;
    integer pass_cnt;
    integer fsdb_on;
    string  wave_file;

    // ============================================================
    // DUT instantiation
    // ============================================================
    ali16 dut (
        .clk  (clk),
        .rst_n(rst_n),
        .d    (d),
        .dout (dout)
    );

    // ============================================================
    // Clock generator — period = 10 ns (100 MHz)
    // ============================================================
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // ============================================================
    // FSDB dump support (matching templete/run.sh +FSDB/+WAVE_FILE)
    // ============================================================
    initial begin
        fsdb_on = 0;
        if ($value$plusargs("FSDB=%d", fsdb_on) && fsdb_on) begin
            if (!$value$plusargs("WAVE_FILE=%s", wave_file))
                wave_file = "wave_vl74.fsdb";
            $fsdbDumpfile(wave_file);
            $fsdbDumpvars(0, tb_ali16);
        end
    end

    // ============================================================
    // Check helpers
    // ============================================================
    task chk_dout;
        input expected;
        input [80*8-1:0] name;
        begin
            total_chk = total_chk + 1;
            if (dout === expected) begin
                pass_cnt = pass_cnt + 1;
                $display("[PASS] chk-%0d %s: dout=%b", total_chk, name, dout);
            end else begin
                errors = errors + 1;
                $display("[FAIL] chk-%0d %s: dout=%b, expected=%b",
                         total_chk, name, dout, expected);
            end
        end
    endtask

    // ============================================================
    // Timeout protection
    // ============================================================
    initial begin
        #500;
        $display("[%0t ns] TEST FAILED: timeout exceeded", $time);
        $finish;
    end

    // ============================================================
    // Main test flow
    // ============================================================
    initial begin
        $display("============================================");
        $display(" VL74 Async-Reset Synchronous-Release testbench");
        $display(" Module: ali16");
        $display(" Verifies: async reset / sync release behavior");
        $display("============================================");

        errors     = 0;
        total_chk  = 0;
        pass_cnt   = 0;

        // ---- Initialize ----
        clk       = 1'b0;
        rst_n     = 1'b0;
        d         = 1'b0;

        // Wait in reset state
        #20;

        // ========================================================
        // Test 1 — Reset state: rst_n=0 forces dout=0
        // Regardless of what d does, dout must be 0
        // ========================================================
        $display("");
        $display("--- Test 1: reset state ---");
        d = 1'b1;          // try toggling d while in reset
        @(posedge clk);    // wait cycle
        chk_dout(1'b0, "reset-state-d=1");
        d = 1'b0;
        @(posedge clk);
        chk_dout(1'b0, "reset-state-d=0");

        // ========================================================
        // Test 2 — Sync release sequence
        // After rst_n goes high, it takes 4 positive edges before
        // dout can follow d due to the synchronizer chain depth.
        // ========================================================
        $display("");
        $display("--- Test 2: sync release sequence ---");
        @(negedge clk);
        #2;
        rst_n = 1'b0;       // start in reset
        @(negedge clk);
        #2;
        rst_n = 1'b1;       // release reset


        // Cycle 1: r_flag=1, r_flag_d keeps old value → dout=0
        @(posedge clk);
        chk_dout(1'b0, "sync-rel-cycle-1");

        // Cycle 2: r_flag_d scheduled but not yet effective → dout=0
        @(posedge clk);
        chk_dout(1'b0, "sync-rel-cycle-2");

        // Cycle 3: still propagating through synchronizer → dout=0
        @(posedge clk);
        chk_dout(1'b0, "sync-rel-cycle-3");

        // Cycle 4: finally dout=d enabled
        d = 1'b1;
        @(posedge clk);
        chk_dout(1'b1, "sync-rel-cycle-4-data");

        // ========================================================
        // Test 3 — Normal data propagation after sync release
        // dout should follow d immediately after sync release
        // ========================================================
        $display("");
        $display("--- Test 3: normal data propagation ---");
        d = 1'b0;
        @(posedge clk);
        chk_dout(1'b0, "data-prop-0");

        d = 1'b1;
        @(posedge clk);
        chk_dout(1'b1, "data-prop-1");

        d = 1'b0;
        @(posedge clk);
        chk_dout(1'b0, "data-prop-0-again");

        d = 1'b1;
        @(posedge clk);
        chk_dout(1'b1, "data-prop-1-final");

        // ========================================================
        // Test 4 — Re-assert reset during operation
        // dout should immediately go to 0 when rst_n=0
        // ========================================================
        $display("");
        $display("--- Test 4: re-assert reset ---");
        d = 1'b1;
        @(negedge clk);
        #2;
        rst_n = 1'b0;      // assert reset
        @(posedge clk);     // should see dout=0
        chk_dout(1'b0, "reset-reassert-cycle-1");

        // Keep rst_n=0, toggle d — dout should stay 0
        d = 1'b0;
        @(posedge clk);
        chk_dout(1'b0, "reset-held-d=0");

        d = 1'b1;
        @(posedge clk);
        chk_dout(1'b0, "reset-held-d=1");

        // ========================================================
        // Test 5 — Second release cycle with different data
        // Need 4 cycles after release for dout to become active
        // ========================================================
        $display("");
        $display("--- Test 5: second release cycle ---");
        @(negedge clk);
        #2;
        rst_n = 1'b1;       // release again


        // Cycles 1-3: sync period, dout=0
        @(posedge clk);
        chk_dout(1'b0, "2nd-release-cycle-1");

        @(posedge clk);
        chk_dout(1'b0, "2nd-release-cycle-2");

        @(posedge clk);
        chk_dout(1'b0, "2nd-release-cycle-3");

        // Cycle 4+: normal operation with new d pattern
        d = 1'b1;
        @(posedge clk);
        chk_dout(1'b1, "2nd-release-d=1");

        d = 1'b0;
        @(posedge clk);
        chk_dout(1'b0, "2nd-release-d=0");

        d = 1'b1;
        @(posedge clk);
        chk_dout(1'b1, "2nd-release-d=1-final");

        // ========================================================
        // Test 6 — Rapid reset/release stress (short hold)
        // Verify that even short reset pulses work correctly
        // ========================================================
        $display("");
        $display("--- Test 6: rapid reset/release ---");
        d = 1'b1;
        @(negedge clk);
        #2;
        rst_n = 1'b0;       // assert
        @(negedge clk);
        #2;
        rst_n = 1'b1;       // release after just 2 clock periods

        // All these need to handle 4-cycle delay after release
        @(posedge clk);
        chk_dout(1'b0, "rapid-rel-cycle-1");

        @(posedge clk);
        chk_dout(1'b0, "rapid-rel-cycle-2");

        @(posedge clk);
        chk_dout(1'b0, "rapid-rel-cycle-3");

        @(posedge clk);
        chk_dout(1'b1, "rapid-rel-cycle-4-active");

        @(posedge clk);
        chk_dout(1'b1, "rapid-rel-cycle-5-stable");

        // ========================================================
        // Summary
        // ========================================================
        $display("");
        $display("============================================");
        $display(" Checks: %0d total | %0d passed | %0d failed",
                 total_chk, pass_cnt, errors);
        if (errors == 0)
            $display(" RESULT: TEST PASSED");
        else
            $display(" RESULT: TEST FAILED");
        $display("============================================");
        $display("[%0t ns] done", $time);
        $finish;
    end

endmodule
