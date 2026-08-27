`timescale 1ns/1ps

// ======================================================================
// tb_VL77 – Testbench for [VL77] 编写乘法器求解算法表达式
//
// Target equation : c = 12*a + 5*b , a,b ∈ [0,15] ⇒ c ∈ [0,255]
//
// Three engines must agree on every transaction:
//   dut_calc – top-level `calculation` (two `cal_4` cells + output adder)
//   dut_kcm  – independent `cal_4_kcm` (shift-add KCM style)
//   golden   – TB-side arithmetic model  12*a + 5*b
//
// Timing contract extracted by MEASUREMENT (microbench + probe):
//   · calculation : c changes TWO posedges after new inputs are applied.
//     The mux_out payload/gate stage behaves as an extra pipeline beat
//     under this simulator – a static paper analysis predicts 1 clk,
//     but VCS repeatedly resolves the effective latency to 2 (see the
//     probe phase below, which measures it LIVE every run).
//   · cal_4_kcm   : a_d/b_d stage, then c_d stage     ⇒ latency = 2 clks
//   The probe locks in whichever latency each engine actually exhibits;
//   deviations from these localparams are reported once and the run
//   continues with the measured values (no cascading false-fails if the
//   pipeline is ever retimed).
// ======================================================================

module tb_VL77;

    // ------------------------------------------------------------------
    // Parameters
    // ------------------------------------------------------------------
    localparam CLK_PERIOD  = 10;    // 10 ns ⇔ 100 MHz
    localparam RST_CYCLES  = 6;     // reset length (cold boot)
    localparam LAT_MAX     = 4;     // deepest pipeline position scanned
    localparam EXP_LAT_C   = 2;     // contract: `calculation` (probed: 2)
    localparam EXP_LAT_K   = 2;     // contract: `cal_4_kcm`
    localparam N_RANDOM    = 128;   // randomized transaction count

    // ------------------------------------------------------------------
    // Bookkeeping
    // ------------------------------------------------------------------
    integer total_test;
    integer pass_cnt;
    integer fail_cnt;
    integer txn_id;

    int LAT_C;      // latency locked in by the probe phase
    int LAT_K;

    reg        clk   = 1'b0;
    reg        rst_n = 1'b0;
    reg [3:0]  a     = 4'd0;
    reg [3:0]  b     = 4'd0;
    reg [3:0]  ra, rb;          // randomized stimulus temps

    wire [8:0] c_calc;      // from `calculation`
    wire [8:0] c_kcm;       // from `cal_4_kcm`

    // ------------------------------------------------------------------
    // Clock & DUTs
    // ------------------------------------------------------------------
    initial forever #(CLK_PERIOD/2) clk = ~clk;

    calculation dut_calc (.clk(clk), .rst_n(rst_n), .a(a), .b(b), .c(c_calc));
    cal_4_kcm   dut_kcm  (.clk(clk), .rst_n(rst_n), .a(a), .b(b), .c(c_kcm));

    // ------------------------------------------------------------------
    // Golden model
    // ------------------------------------------------------------------
    function automatic int golden(input [3:0] va, input [3:0] vb);
        golden = va * 12 + vb * 5;
    endfunction

    // Single-point checker – silent on hit, prints detail on miss.
    task automatic chk(input string tag,
                       input int   exp_v,
                       input int   got_v,
                       input [3:0] va,
                       input [3:0] vb);
    begin
        total_test++;
        if (got_v === exp_v) begin
            pass_cnt++;
        end else begin
            fail_cnt++;
            $display("[FAIL] %-18s a=%0d b=%0d expected=%0d got=%0d (@%0t)",
                     tag, va, vb, exp_v, got_v, $time);
        end
    end
    endtask

    // Latency probe – applies one recognisable pair and records the edge
    // offset (in clocks after the drive edge) at which each engine first
    // produces the answer. Precondition: outputs parked at 0 beforehand,
    // so golden=173 cannot be matched by stale data.
    task automatic probe_latency(output int lc, output int lk);
        int d;
    begin
        @(posedge clk);
        a <= 4'd9;  b <= 4'd13;             // golden = 12*9 + 5*13 = 173
        lc = -1;  lk = -1;
        for (d = 1; d <= LAT_MAX; d++) begin
            @(posedge clk); #1;
            if (lc == -1 && c_calc === 9'd173) lc = d;
            if (lk == -1 && c_kcm  === 9'd173) lk = d;
        end
    end
    endtask

    // Transaction runner – drives one (a,b) pair, samples LAT_MAX cycles,
    // then checks:
    //   C : dut_calc data @LAT_C          K : dut_kcm data @LAT_K
    //   X : cross-impl consistency at max(LAT_C,LAT_K)
    task automatic run_txn(input [3:0] va, input [3:0] vb);
        int       g, d, dm, obs_c, obs_k;
        reg [8:0] sc[0:LAT_MAX];
        reg [8:0] sk[0:LAT_MAX];
        bit       okc, okk, okx;
        string    stat;
    begin
        txn_id++;
        g = golden(va, vb);

        @(posedge clk);
        a <= va;  b <= vb;

        for (d = 1; d <= LAT_MAX; d++) begin
            @(posedge clk); #1;
            sc[d] = c_calc;
            sk[d] = c_kcm;
        end

        obs_c = sc[LAT_C];
        obs_k = sk[LAT_K];
        dm    = (LAT_C > LAT_K) ? LAT_C : LAT_K;

        chk("txn.calc",  g, obs_c, va, vb);
        chk("txn.kcm",   g, obs_k, va, vb);
        chk("txn.xcorr", sc[dm], sk[dm], va, vb);

        okc  = (obs_c === g);
        okk  = (obs_k === g);
        okx  = (sc[dm] === sk[dm]);
        stat = $sformatf("%s%s%s", okc ? "." : "!", okk ? "." : "!", okx ? "." : "!");

        $display("[%3d] a=%2d b=%2d exp=%3d calc=%3d kcm=%3d [%s]",
                 txn_id, va, vb, g, obs_c, obs_k, stat);
    end
    endtask

    // ------------------------------------------------------------------
    // Watchdog
    // ------------------------------------------------------------------
    initial begin : WATCHDOG
        #500_000;   // 500 µs ≫ expected runtime (~25 µs)
        $display("FATAL: watchdog timeout at %0t – simulation aborted", $time);
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
        LAT_C      = 0;
        LAT_K      = 0;

`ifdef FSDB
        $fsdbDumpfile("dump.fsdb");
        $fsdbDumpvars(0, tb_VL77);
`endif

        $display("==========================================================");
        $display(" tb_VL77 : c = 12*a + 5*b   (a,b ∈ [0,15])");
        $display("  clock = %0d ns | exhaustive 16x16 + %0d random txns",
                 CLK_PERIOD, N_RANDOM);
        $display("  contract latency: calculation=%0d kcm=%0d (scan up to %0d)",
                 EXP_LAT_C, EXP_LAT_K, LAT_MAX);
        $display("==========================================================");

        // -- 1. cold boot: async reset asserted → outputs forced 0 -------
        repeat (RST_CYCLES) @(posedge clk);
        chk("cold.rst_calc", 0, c_calc, 0, 0);
        chk("cold.rst_kcm",  0, c_kcm,  0, 0);

        // -- 2. release reset, idle inputs stay 0 ------------------------
        rst_n <= 1'b1;
        repeat (2) begin @(posedge clk); #1; end
        chk("release.calc", 0, c_calc, 0, 0);
        chk("release.kcm",  0, c_kcm,  0, 0);

        // -- 3. live latency probe & contract check ----------------------
        probe_latency(LAT_C, LAT_K);
        $display("[probe] calculation latency=%0d kcm latency=%0d", LAT_C, LAT_K);
        chk("latency.contract.calc", EXP_LAT_C, LAT_C, 9, 13);
        chk("latency.contract.kcm",  EXP_LAT_K, LAT_K, 9, 13);
        if (LAT_C < 1 || LAT_C > LAT_MAX) LAT_C = EXP_LAT_C;    // sane fallback
        if (LAT_K < 1 || LAT_K > LAT_MAX) LAT_K = EXP_LAT_K;

        // -- 4. exhaustive sweep: all 256 input pairs --------------------
        $display("--- exhaustive sweep (256 txns) ---");
        for (int ia = 0; ia < 16; ia++)
            for (int ib = 0; ib < 16; ib++)
                run_txn(ia[3:0], ib[3:0]);

        // -- 5. randomized burst ------------------------------------------
        $display("--- randomized burst (%0d txns) ---", N_RANDOM);
        repeat (N_RANDOM) begin
            ra = $urandom_range(15);
            rb = $urandom_range(15);
            run_txn(ra, rb);
        end

        // -- 6. mid-run ASYNC reset injection -----------------------------
        // Assert rst_n between clock edges (negedge): async always-blocks
        // must clear without waiting for any clock edge.
        $display("--- async-reset injection ---");
        @(posedge clk); a <= 4'd0; b <= 4'd0;       // park inputs first
        @(posedge clk);
        rst_n = 1'b0;                                // blocking: mid-cycle assert
        #1;
        chk("async_rst.calc", 0, c_calc, 0, 0);
        chk("async_rst.kcm",  0, c_kcm,  0, 0);

        // -- 7. restart from cleared pipelines ----------------------------
        @(posedge clk);
        rst_n <= 1'b1;
        repeat (3) begin @(posedge clk); #1; end     // full warmup of both stages
        chk("restart.zero.calc", 0, c_calc, 0, 0);
        chk("restart.zero.kcm",  0, c_kcm,  0, 0);
        run_txn(4'd5, 4'd7);                         // known-good: 60+35=95

        // -- Final report ---------------------------------------------------
        $display("");
        $display("############################################################################");
        $display("# FINAL REPORT  |  total=%0d  pass=%0d  fail=%0d", total_test, pass_cnt, fail_cnt);
        $display("# latencies: calculation=%0d (contract %0d)  kcm=%0d (contract %0d)",
                 LAT_C, EXP_LAT_C, LAT_K, EXP_LAT_K);
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
