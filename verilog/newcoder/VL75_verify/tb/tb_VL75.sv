`timescale 1ns/1ns

module tb_VL75;

    parameter DATA_W = 8;

    // ------------------------------------------------------------------
    // DUT interface
    // ------------------------------------------------------------------
    logic [DATA_W-1:0]   A, B;
    logic                vld_in;
    logic                clk;
    logic                rst_n;

    wire  [DATA_W*2-1:0] lcm_out;
    wire  [DATA_W-1:0]   mcd_out;
    wire                 vld_out;

    int total_test;
    int pass_cnt;
    int fail_cnt;

    // ==================================================================
    // DUT
    // ==================================================================
    lcm #(.DATA_W(DATA_W)) dut (
        .A(A),
        .B(B),
        .vld_in(vld_in),
        .rst_n(rst_n),
        .clk(clk),
        .lcm_out(lcm_out),
        .mcd_out(mcd_out),
        .vld_out(vld_out)
    );

    // ==================================================================
    // Clock  (10 ns period, 50% duty)
    // ==================================================================
    initial begin clk = 0; forever #5 clk = ~clk; end

    initial begin
        `ifdef FSDB
            $fsdbDumpfile("dump.fsdb");
            $fsdbDumpvars(0, tb_VL75);
        `endif
    end

    // ==================================================================
    // Reference: brute-force LCM & GCD
    // ==================================================================
    function automatic void ref_gcd_lcm(
            input  [DATA_W-1:0] x, y,
            output logic [DATA_W*2-1:0] r_lcm,
            output logic [DATA_W-1:0]   r_gcd);
        automatic integer a, b, tmp;

        if (x == '0 || y == '0) begin
            r_lcm = '0;
            r_gcd = (x == '0 && y == '0) ? '0 : ((x == '0) ? y : x);
            return;
        end
        a = x;  b = y;
        while (b != 0) begin tmp = b; b = a % b; a = tmp; end
        r_gcd = a;
        r_lcm = (x * y) / a;
    endfunction

    // ==================================================================
    // Helper – run ONE test transaction
    //   1. Drive A, B + pulse vld_in for 1 positive-edge clock
    //   2. Wait for vld_out (with manual timeout counting)
    //   3. Compare against reference
    // ==================================================================
    task run_one_test(input string nm,
                      input [DATA_W-1:0] ina, inb,
                      input [DATA_W*2-1:0] exp_lcm, exp_gcd);
        integer i;
        bit     ok;

        // ── 1. present inputs, single-cycle vld pulse ───────────────
        @(negedge clk);
        A      <= ina;
        B      <= inb;
        vld_in <= 1'b1;
        @(posedge clk);             // FSM latches, IDLE -> S/DONE
        @(negedge clk);
        vld_in <= 1'b0;

        // ── 2. poll vld_out up to MAX_ITERATIONS cycles ─────────────
        for (i = 0; i < 200; i++) begin    // 200 clocks = 2 μs
            @(posedge clk);
            if (vld_out) break;             // found it!
        end
        
        if (!vld_out) begin                 // timed out
            $display("[%s] TIMEOUT (>2 μs)", nm);
            $display("       A=%0d  B=%0d", ina, inb);
            fail_cnt++; total_test++;
            return;                         // skip comparison on timeout
        end

        // ── 3. compare ──────────────────────────────────────────────
        @(posedge clk);                   // advance past the assertion edge

        total_test++;
        ok = (exp_lcm === lcm_out && exp_gcd === mcd_out);

        if (ok) begin
            $display("[%s] PASS | A=%0d B=%0d → LCM:%0d GCD:%0d",
                     nm, ina, inb, exp_lcm, exp_gcd);
            pass_cnt++;
        end else begin
            $display("[%s] FAIL | A=%0d B=%0d", nm, ina, inb);
            $display("       got    lcm=%0d gcd=%0d", lcm_out, mcd_out);
            $display("       expect lcm=%0d gcd=%0d", exp_lcm, exp_gcd);
            fail_cnt++;
        end
    endtask

    // ==================================================================
    // Main stimulus
    // ==================================================================
    initial begin
        A          <= 0;
        B          <= 0;
        vld_in     <= 0;
        rst_n      <= 0;
        total_test  = 0;
        pass_cnt    = 0;
        fail_cnt    = 0;

        #100;
        rst_n <= 1;
        @(negedge clk);
        #10;

        // ---- Group 1: Basic ----------------------------------------
        $display("\n============================================");
        $display("  Group 1 - Basic normal cases");
        $display("============================================");
        run_one_test("basic_01",  48, 18,  144, 6);
        run_one_test("basic_02",  18, 36,  36,  18);
        run_one_test("basic_03",  8,  6,   24,  2);

        // ---- Group 2: Edge cases (both non-zero) -------------------
        $display("\n============================================");
        $display("  Group 2 - Edge cases");
        $display("============================================");
        run_one_test("equal_odd",     7,   7,   7,   7);
        run_one_test("coprime",       5,   7,   35,  1);
        run_one_test("pow2_a",        16,  8,   16,  8);
        run_one_test("pow2_b",        8,   16,  16,  8);
        run_one_test("one_vs_large",  1,   99,  99,  1);
        run_one_test("large_vs_one",  99,  1,   99,  1);
        run_one_test("max_same",      255, 255, 255, 255);
        run_one_test("two_primes",    7,   11,  77,  1);
        run_one_test("big_small",     255, 3,   255, 3);
        run_one_test("same_pow2",     16,  16,  16,  16);

        // ---- Group 3: Wide output (>8 bits) ------------------------
        $display("\n============================================");
        $display("  Group 3 - Wide LCM output");
        $display("============================================");
        run_one_test("w_coprime_1",   17,  19,   323,   1);
        run_one_test("w_coprime_2",   29,  31,   899,   1);
        run_one_test("w_coprime_3",   97,  89,   8633,  1);
        run_one_test("w_prod_1",      100, 99,   9900,  1);
        run_one_test("w_halfprod",    127, 129,  16383, 1);

        // ---- Group 4: Zero inputs (the previously broken cases!) ---
        $display("\n============================================");
        $display("  Group 4 - Zero input handling");
        $display("============================================");
        run_one_test("zero_A",     8'd0,  8'd5,   0,   5);
        run_one_test("zero_B",     8'd12, 8'd0,   0,   12);
        run_one_test("zero_AB",    8'd0,  8'd0,   0,   0);

        // ---- Group 5: Random burst (batch 1) -----------------------
        $display("\n============================================");
        $display("  Group 5 - Random stress 1 (50)");
        $display("============================================");
        $srandom(12345);
        random_burst("r1", 50);

        // ---- Group 6: Random burst (batch 2) -----------------------
        $display("");
        $display("============================================");
        $display("  Group 6 - Random stress 2 (50)");
        $display("============================================");
        $srandom(67890);
        random_burst("r2", 50);

        // ---- Summary ------------------------------------------------
        $display("\n############################################################################");
        $display("# RESULTS  |  DATA_W=%0d  total=%0d  pass=%0d  fail=%0d              #",
                  DATA_W, total_test, pass_cnt, fail_cnt);
        $display("############################################################################");
        if (fail_cnt == 0) $display("** ALL TESTS PASSED **");
        else               $display("** %0d TEST(S) FAILED **", fail_cnt);

        $finish;
    end

    // ==================================================================
    // Random burst helper
    // ==================================================================
    task automatic random_burst(string pfx, integer cnt);
        integer i;
        logic [7:0] ra, rb;
        logic [DATA_W*2-1:0] el;
        logic [DATA_W-1:0] eg;
        string nm;

        for (i = 0; i < cnt; i++) begin
            ra = $urandom_range(0, 255);
            rb = $urandom_range(0, 255);

            ref_gcd_lcm(ra, rb, el, eg);
            nm = $sformatf("%s_%0d", pfx, i);
            run_one_test(nm, ra, rb, el, eg);
        end
    endtask

endmodule
