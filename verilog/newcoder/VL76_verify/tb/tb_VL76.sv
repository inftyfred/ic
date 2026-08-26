`timescale 1ns/1ps

// ======================================================================
// tb_VL76 – Testbench for [VL76] 任意奇数倍时钟分频
//
// DUT algorithm analysis:
//   • cnt increments on POS EDGE → 0→1→…→CNT_MAX→0 over N periods
//     CNT_MAX = N−1, HALF = floor((N−1)/2)
//   • clk_pos (posedge):  set 1 at cnt==HALF, set 0 at cnt==CNT_MAX
//   • clk_neg (negedge):  same thresholds but sampled one half-cycle later;
//     because cnt is already incremented, negedge sees shifted value.
//   • clk_out = clk_pos | clk_neg  →  combined waveform
//
// The dual-edge sampling creates two non-overlapping phases that stitch
// together into an approximately correct N-divider with ~60% duty cycle.
// ======================================================================

module tb_VL76;

    // ── Configuration ────────────────────────────────────────────────
    localparam CLK_PERIOD     = 10;   // 10 ns → 100 MHz input clock
    localparam RESET_CYCLES   = 8;    // Hold rst_n = 0 for 8 periods
    localparam OBS_CYCLES     = 200;  // Observation cycles per divisor

    integer total_test;
    integer pass_cnt;
    integer fail_cnt;
    integer skip_cnt;

    // ── Signals ──────────────────────────────────────────────────────
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
        #10;                      // release after one clock period
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
    // measure_one – measure frequency ratio for ONE divisor
    // Key: re-read hierarchical path EACH CYCLE to get fresh values.
    // Do NOT pass signal as parameter — it gets captured once at call time.
    // ==================================================================
    task automatic measure_one(input string label,
                               input integer exp_div);
        integer j;
        integer trans_count;
        integer high_cycles;
        integer low_cycles;
        integer last_val;
        real    period_cyc;
        integer inferred_div;
        bit     cur_sig;

        total_test++;
        trans_count  = 0;
        high_cycles  = 0;
        low_cycles   = 0;

        // Wait past reset settle
        @(posedge clk_in);
        @(posedge clk_in);

        // Sample each posedge — re-read hierarchical path every cycle
        for (j = 0; j < OBS_CYCLES; j++) begin
            @(posedge clk_in);

            case (exp_div)
                3:      cur_sig = clk_out_3;
                5:      cur_sig = clk_out_5;
                7:      cur_sig = clk_out_7;
                9:      cur_sig = clk_out_9;
                11:     cur_sig = clk_out_11;
                15:     cur_sig = clk_out_15;
            endcase

            if (cur_sig === 1'b1) high_cycles++; else low_cycles++;

            if (cur_sig !== last_val) begin
                trans_count++;
                last_val = cur_sig;
            end
        end

        $display("[%s] hi=%-3d lo=%-3d trans=%-4d",
                 label, high_cycles, low_cycles, trans_count);

        if (trans_count >= 2 && (high_cycles + low_cycles) > 0) begin
            period_cyc = $itor(high_cycles + low_cycles) / 
                         ($itor(trans_count) * 0.5);
            inferred_div = $rtoi(period_cyc + 0.5);

            $display("       period=%.1f cyc  ratio≈%2d  expected=%2d",
                     period_cyc, inferred_div, exp_div);

            if (inferred_div == exp_div) begin
                pass_cnt++;
            end else begin
                $display("       ⚠️ MISMATCH %d vs %d",
                         inferred_div, exp_div);
                fail_cnt++;
            end
        end else begin
            $display("       ❌ SKIP – only %d transition(s)", trans_count);
            skip_cnt++;
        end
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

        // Wait for reset release
        @(posedge clk_in);

        // ── Measure frequency ratio & duty cycle for each divisor ───
        $display("\n============================================");
        $display("  Frequency Ratio & Duty Cycle Measurement");
        $display("============================================");

        measure_one("dividor=3",   3);
        measure_one("dividor=5",   5);
        measure_one("dividor=7",   7);
        measure_one("dividor=9",   9);
        measure_one("dividor=11",  11);
        measure_one("dividor=15",  15);

        // ── Summary ---------------------------------------------------
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
