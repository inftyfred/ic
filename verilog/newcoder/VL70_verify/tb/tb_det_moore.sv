`timescale 1ns/1ns

module tb_det_moore;

    // ============================================================
    // DUT ports
    // ============================================================
    reg  clk;
    reg  rst_n;
    reg  din;
    wire Y;

    // ============================================================
    // Statistics & waveform
    // ============================================================
    integer errors;
    integer hit_count;
    integer fsdb_on;
    string  wave_file;

    parameter IDLE = 5'b0_0001;
    parameter S1   = 5'b0_0010;
    parameter S2   = 5'b0_0100;
    parameter S3   = 5'b0_1000;
    parameter S4   = 5'b1_0000;

    // ============================================================
    // DUT instantiation
    // ============================================================
    det_moore dut (
        .clk  (clk),
        .rst_n(rst_n),
        .din  (din),
        .Y    (Y)
    );

    // ============================================================
    // Clock generator — period = 10 ns
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
                wave_file = "wave_vl70.fsdb";
            $fsdbDumpfile(wave_file);
            $fsdbDumpvars(0, tb_det_moore);
        end
    end

    // ============================================================
    // Hit counter — counts rising-edge pulses on Y
    // Each rising edge (0→1) on Y signifies one "11011" detection
    // completed. The FSM enters state S4 once per full detection.
    // ============================================================
    reg  Y_old;
    initial begin
        Y_old     = 1'b0;
        hit_count = 0;
        forever @(posedge clk) begin
            if (Y === 1'b1 && Y_old === 1'b0) begin
                hit_count = hit_count + 1;
                $display("[%0t ns] [HIT #%0d] synchronized pulse detected",
                         $time, hit_count);
            end
            Y_old = Y;
        end
    end

    // ============================================================
    // Utility: feed a vector of bits, one per clock cycle
    // LSB = first bit sent (bit[0] goes out first)
    // Setup on negedge to ensure din stable before posedge sampling
    // ============================================================
    task feed_bits;
        input integer n;       // number of bits
        input [63:0] bits;     // bit[0] = first to send
        integer i;
        begin
            for (i = 0; i < n; i = i + 1) begin
                @(negedge clk);    // setup on negedge
                din   = bits[i];   // set din for next posedge
                @(posedge clk);    // sample on posedge
            end
        end
    endtask

    // ============================================================
    // Helper: assert hit count matches expected value
    // Waits enough cycles for all pending detections to settle
    // ============================================================
    task expect_hits;
        input integer expected;
        input [160*8-1:0] name;
        begin
            wait_source_gap(5);
            if (hit_count == expected)
                $display("[PASS] %s: hit_count=%0d", name, hit_count);
            else begin
                errors = errors + 1;
                $display("[FAIL] %s: hit_count=%0d, expected=%0d",
                         name, hit_count, expected);
            end
        end
    endtask

    // Wait N cycles with din=0
    task wait_source_gap;
        input integer ncyc;
        integer k;
        begin
            din = 1'b0;
            for (k = 0; k < ncyc; k = k + 1)
                @(posedge clk);
        end
    endtask

    // ============================================================
    // Test flow
    // ============================================================

    initial begin
        $display("============================================");
        $display(" VL70 Moore sequence detector testbench");
        $display(" Pattern: 11011 | Output type: Moore (state S4)");
        $display(" State encoding: one-hot {S4,S3,S2,S1,IDLE}");
        $display("============================================");

        errors      = 0;
        hit_count   = 0;
        rst_n       = 1'b0;
        din         = 1'b0;

        // ---- Hold reset long enough ----
        #30;
        if (Y !== 1'b0) begin
            errors = errors + 1;
            $display("[FAIL] Reset: Y=%b, expected 0", Y);
        end else
            $display("[PASS] Reset: Y=0");

        rst_n = 1'b1;
        wait_source_gap(3);

        // ========================================================
        // Test 1 — Single correct detection: "11011"
        // Path:  IDLE→S1→S2→S3→S4(Y! hit#1)→IDLE
        // Expected: 1 hit total
        // ========================================================
        $display("");
        $display("--- Test 1: single '11011' ---");
        feed_bits(5, 5'b1_1011);
        expect_hits(1, "single 11011");

        // ========================================================
        // Test 2 — Two adjacent detections (10 bits = 2x11011)
        // Expected: 2 hits total
        // ========================================================
        $display("");
        $display("--- Test 2: two adjacent detections ---");
        feed_bits(5, 5'b1_1011);
        expect_hits(2, "two adjacent");

        // ========================================================
        // Test 3 — Interrupted sequence then fresh detection
        // Bits "11010": partial completion, gap, then full "11011"
        // Expected: 3 hits total
        // ========================================================
        $display("");
        $display("--- Test 3: interrupted then fresh detection ---");
        feed_bits(5, 5'b1_1010);
        wait_source_gap(2);
        feed_bits(5, 5'b1_1011);
        expect_hits(3, "interrupted then detect");

        // ========================================================
        // Test 4 — All-zeros stream: no new hits
        // Every '0' keeps us in IDLE (IDLE+0→IDLE)
        // Expected: still 3 hits
        // ========================================================
        $display("");
        $display("--- Test 4: all-zeros ---");
        feed_bits(16, 16'h0000);
        expect_hits(3, "all zeros");

        // ========================================================
        // Test 5 — Partial prefix stress: alternating 1,0
        // 1→S1, 0→IDLE toggles between IDLE↔S1
        // No path reaches S3/S4, no extra hits
        // Expected: still 3 hits
        // ========================================================
        $display("");
        $display("--- Test 5: partial-prefix stress ---");
        feed_bits(20, 20'h55555);
        expect_hits(3, "partial prefixes");

        // ========================================================
        // Test 6 — Three sequential "11011" back-to-back (15 bits)
        // Each group independently enters S4 once = 3 hits
        // Total expected: 6
        // Packed as: 27|(27<<5)|(27<<10) = 28539 = 0x6F7B
        // ========================================================
        $display("");
        $display("--- Test 6: three sequential 11011 ---");
        feed_bits(15, 15'h6F7B);
        expect_hits(6, "triple seq");

        // ========================================================
        // Test 7 — Overlapping chain: "11011011011" (11 bits)
        // Full pattern: 1,1,0,1,1,0,1,1,0,1,1
        // Positions 1-5 complete first "11011" → 1 detection
        // Position 6-10 contains partial overlap
        // Only 1 additional detection observed within available bits
        // ========================================================
        $display("");
        $display("--- Test 7: overlapping chain ---");
        feed_bits(11, 11'h6DF);
        expect_hits(7, "overlap chain");

        // ========================================================
        // Test 8 — Reset and re-detect: one clean "11011"
        // Expected: +1 hit → 8 total
        // ========================================================
        $display("");
        $display("--- Test 8: reset and re-detect ---");
        rst_n = 1'b0;
        @(posedge clk);
        rst_n = 1'b1;
        wait_source_gap(3);
        feed_bits(5, 5'b1_1011);
        expect_hits(8, "restart after reset");

        // ========================================================
        // Summary
        // ========================================================
        $display("");
        $display("============================================");
        if (errors == 0)
            $display(" RESULT: TEST PASSED (%0d total hits observed)",
                     hit_count);
        else
            $display(" RESULT: TEST FAILED (%0d mismatches)", errors);
        $display("============================================");
        $display("[%0t ns] done", $time);
        $finish;
    end

    // Timeout protection
    initial begin
        #20000;
        $display("[FAIL] TEST FAILED: timeout reached 20000 ns");
        $finish;
    end

endmodule
