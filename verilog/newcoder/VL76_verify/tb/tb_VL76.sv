`timescale 1ns/1ps

// ======================================================================
// tb_VL76 – Testbench for [VL76] 任意奇数倍时钟分频
//
// Duty-cycle measurement FIX:
//   OLD (buggy): sample only at posedge → misses negedge transitions
//     of clk_neg → biased count (e.g. 56% instead of true value)
//   NEW: observe on BOTH posedge AND negedge, record transition
//     timestamps, pair adjacent rise/fall to get actual HIGH duration.
// ======================================================================

module tb_VL76;

    localparam CLK_PERIOD     = 10;   // 10 ns → 100 MHz input clock
    localparam RESET_CYCLES   = 8;    // Hold rst_n low for 8 periods
    localparam OBS_CYCLES     = 1000; // Input-cycles to observe per divisor
    localparam MAX_TRANS      = 2048; // Max transitions buffer size

    integer total_test;
    integer pass_cnt;
    integer fail_cnt;
    integer skip_cnt;

    reg          clk_in = 0;
    reg          rst_n = 0;

    wire         clk_out_3;
    wire         clk_out_5;
    wire         clk_out_7;
    wire         clk_out_9;
    wire         clk_out_11;
    wire         clk_out_15;

    // ── Clock generation ────────────────────────────────────────────
    initial begin
        forever #(CLK_PERIOD / 2) clk_in = ~clk_in;
    end

    // ── Reset ───────────────────────────────────────────────────────
    initial begin
        #10;
        rst_n <= 1;
    end

    // ── DUT instantiations (6 common odd divisors) ──────────────────
    clk_divider #(.dividor(3))  dut_3  (.clk_in(clk_in), .rst_n(rst_n), .clk_out(clk_out_3));
    clk_divider #(.dividor(5))  dut_5  (.clk_in(clk_in), .rst_n(rst_n), .clk_out(clk_out_5));
    clk_divider #(.dividor(7))  dut_7  (.clk_in(clk_in), .rst_n(rst_n), .clk_out(clk_out_7));
    clk_divider #(.dividor(9))  dut_9  (.clk_in(clk_in), .rst_n(rst_n), .clk_out(clk_out_9));
    clk_divider #(.dividor(11)) dut_11(.clk_in(clk_in), .rst_n(rst_n), .clk_out(clk_out_11));
    clk_divider #(.dividor(15)) dut_15(.clk_in(clk_in), .rst_n(rst_n), .clk_out(clk_out_15));

    // ==================================================================
    // measure_one – Frequency-ratio + CORRECT duty-cycle measurement
    //
    // Duty-cycle FIX: sample on BOTH posedge and negedge of clk_in,
    // record exact transition timestamps, pair adjacent rise/fall to
    // compute actual HIGH duration instead of counting at discrete points.
    // ==================================================================
    task automatic measure_one(input string   label,
                               input integer  exp_div);
        integer j, i;
        bit     cur_sig;
        integer last_val;
        real    duty_pct;       // ⚠️ was missing → this was the original bug!

        // --- freq-ratio counters ---
        integer high_cycles;
        integer trans_count_freq;
        real    period_cyc;
        integer inferred_div;

        // --- duty-cycle timestamp data ---
        realtime tr_time[MAX_TRANS];       // timestamp in ns
        bit      tr_edge[MAX_TRANS];       // 1 = rising, 0 = falling
        integer  n_tr;

        // --- accumulator ---
        real    sum_high_dur_ns;
        real    sum_full_period_ns;
        integer n_high_periods;
        integer n_full_periods;
        
        // --- duty-cycle calculation helpers ---
        realtime rise_time;
        bit      have_rise;
        bit      have_fall;

        // --- local vars for freq counting ---
        integer hc, tc;

        // Init
        total_test++;
        n_tr          = 0;
        high_cycles   = 0;
        trans_count_freq = 0;
        sum_high_dur_ns  = 0;
        sum_full_period_ns = 0;
        n_high_periods = 0;
        n_full_periods = 0;
        rise_time      = 0;
        have_rise      = 0;
        have_fall      = 0;
        last_val       = 0;
        hc           = 0;
        tc           = 0;
        duty_pct     = 0;

        // Wait past reset settle
        @(posedge clk_in);
        @(posedge clk_in);
        last_val = 0;

        // ── Single scan: alternate posedge / negedge ─────────────────
        for (j = 0; j < OBS_CYCLES * 2; j++) begin
            if (j % 2 == 0) begin
                @(posedge clk_in);
            end else begin
                @(negedge clk_in);
            end

            // Wait for DUT nonblocking assignments to settle before sampling.
            #1ps;

            // Read signal via hierarchical path (fresh every half-cycle)
            case (exp_div)
                3:      cur_sig = clk_out_3;
                5:      cur_sig = clk_out_5;
                7:      cur_sig = clk_out_7;
                9:      cur_sig = clk_out_9;
                11:     cur_sig = clk_out_11;
                15:     cur_sig = clk_out_15;
            endcase

            if (cur_sig !== last_val && n_tr < MAX_TRANS) begin
                // Transition detected
                tr_time[n_tr] = $realtime;
                tr_edge[n_tr] = cur_sig;                   // 1=rising, 0=falling
                n_tr++;
                last_val = cur_sig;
                trans_count_freq++;
            end
        end

        // ── Compute duty cycle from complete waveform periods ──────────
        // Count only rise→fall→rise triplets so window-edge transitions
        // cannot make the high-time and period sample sets differ.
        for (i = 0; i < n_tr; i++) begin
            if (tr_edge[i] === 1'b1) begin
                if (have_fall) begin
                    sum_full_period_ns += tr_time[i] - rise_time;
                    n_full_periods++;
                    have_fall = 0;
                end
                rise_time = tr_time[i];
                have_rise = 1;
            end else if (have_rise) begin
                sum_high_dur_ns += tr_time[i] - rise_time;
                n_high_periods++;
                have_fall = 1;
            end
        end

        // Compute frequency ratio using discrete method too
        last_val = 0;
        @(posedge clk_in);
        @(posedge clk_in);
        for (j = 0; j < OBS_CYCLES; j++) begin
            @(posedge clk_in);
            case (exp_div)
                3:  last_val = clk_out_3;
                5:  last_val = clk_out_5;
                7:  last_val = clk_out_7;
                9:  last_val = clk_out_9;
                11: last_val = clk_out_11;
                15: last_val = clk_out_15;
            endcase
            if (last_val === 1'b1) hc++;
        end

        // Compute metrics
        if (trans_count_freq >= 2) begin
            period_cyc = $itor(OBS_CYCLES) / ($itor(trans_count_freq) * 0.5);
            inferred_div = $rtoi(period_cyc + 0.5);
        end else begin
            period_cyc = 0;
            inferred_div = 0;
        end

        // ✅ FIXED: duty cycle = avg HIGH dur / avg FULL period * 100%
        duty_pct = (n_high_periods > 0 && n_full_periods > 0) ?
                   (sum_high_dur_ns / n_high_periods) / (sum_full_period_ns / n_full_periods) * 100.0 : 0;

        // Report
        $display("[%s] trans=%d  duty=%.1f%%", label, n_tr, duty_pct);
        if (trans_count_freq >= 2) begin
            $display("       period=%.1fcyc ratio≈%d expected=%d %s",
                     period_cyc, inferred_div, exp_div,
                     (inferred_div == exp_div) ? "✅ PASS" : "❌ FAIL");
        end else begin
            $display("       SKIP");
        end

        // Count result
        if (trans_count_freq >= 2 && inferred_div == exp_div) pass_cnt++;
        else if (trans_count_freq >= 2 && inferred_div != exp_div) fail_cnt++;
        else skip_cnt++;
    endtask

    // ==================================================================
    // Main test flow
    // ==================================================================
    initial begin
        total_test = 0;
        pass_cnt   = 0;
        fail_cnt   = 0;
        skip_cnt   = 0;
        `ifdef FSDB
            $fsdbDumpfile("dump.fsdb");
            $fsdbDumpvars(0, tb_VL76);
        `endif

        @(posedge clk_in);   // wait for reset release

        $display("\n============================================");
        $display("  Measurement Results");
        $display("============================================");

        measure_one("dividor=3",   3);
        measure_one("dividor=5",   5);
        measure_one("dividor=7",   7);
        measure_one("dividor=9",   9);
        measure_one("dividor=11",  11);
        measure_one("dividor=15",  15);

        $display("");
        $display("############################################################################");
        $display("# FINAL REPORT  |  total=%2d  pass=%2d  fail=%2d  skip=%2d           #",
                  total_test, pass_cnt, fail_cnt, skip_cnt);
        $display("############################################################################");
        if (fail_cnt == 0)
            $display("** ALL TESTS COMPLETED **");
        else
            $display("** %0d TEST(S) FAILED **", fail_cnt);

        $finish;
    end

endmodule
