`timescale 1ns/1ps

// ======================================================================
// tb_VL5 -- Testbench for [VL5] 位拆分与运算 (Nibble Extract & Add)
//
// DUT : data_cal
//       sel=0  : load d  into d_reg; out=0,   vld=0    (pipeline fill)
//       sel=1  : out=d_reg[3:0]+d_reg[7:4],  vld=1     (nibble 0+1)
//       sel=2  : out=d_reg[3:0]+d_reg[11:8], vld=1     (nibble 0+2)
//       sel=3  : out=d_reg[3:0]+d_reg[15:12],vld=1     (nibble 0+3)
//
// PIPELINE BEHAVIOR (critical!):
//   All regs update via NBA at posedge => results NOT visible until NEXT
//   posedge. This creates a TWO-CYCLE latency from input change:
//     Cycle E: d_in changes, sel changes           (regs capture)
//     Cycle E+1: regs hold new values, but outputs still old   (NBA pending)
//     Cycle E+2: outputs reflect new inputs            (NBA settled)
//
// GOLDEN MODEL strategy:
//   Mirror DUT internals EXACTLY — same always-block logic, same NBA.
//   After every @(posedge clk); #1 we compare dout/vout vs gold_out/gold_valid.
//   Because golden also uses non-blocking updates, gold_out lags by exactly
//   one cycle too, so BOTH models stay perfectly aligned.
// ===========================================================================

module tb_VL5;

    localparam CLK_HALF  = 5;   // half-period ns  (10 ns -> 100 MHz)

    integer total_test;
    integer pass_cnt;
    integer fail_cnt;
    integer txn_id;

    reg         clk     = 0;
    reg         rst_n   = 0;
    reg  [15:0] d_in    = 0;
    reg  [1:0]  sel     = 0;

    wire [4:0] dout;
    wire       vout;

    // ------------------------------------------------------------------
    // Clock generator
    // ------------------------------------------------------------------
    initial forever #(CLK_HALF) clk = ~clk;

    // ------------------------------------------------------------------
    // DUT
    // ------------------------------------------------------------------
    data_cal dut (
        .clk(clk),
        .rst(rst_n),          // RTL port named 'rst' (active-low level)
        .d(d_in),
        .sel(sel),
        .out(dout),
        .validout(vout)
    );

    // ==========================================================================
    // Golden model registers (exact mirror of DUT internal state)
    // ==========================================================================
    reg  [15:0] g_d_reg   = 16'd0;
    reg  [4:0]  g_out     = 5'd0;
    reg         g_vld     = 1'b0;

    // ==========================================================================
    // Monitoring process — mirrors DUT always block behaviour exactly
    // Uses same NBA semantics => results appear one cycle AFTER selection.
    // ==========================================================================
    initial begin : MON
        forever begin
            @(posedge clk);
            if (!rst_n) begin
                g_vld  <= 1'b0;
                g_d_reg <= 16'd0;
                g_out   <= 5'd0;
            end else begin
                case (sel)
                    2'b00: begin
                        g_vld  <= 1'b0;
                        g_d_reg <= d_in;
                        g_out   <= 5'd0;
                    end
                    2'b01: begin
                        g_vld  <= 1'b1;
                        g_out   <= g_d_reg[3:0] + g_d_reg[7:4];
                    end
                    2'b10: begin
                        g_vld  <= 1'b1;
                        g_out   <= g_d_reg[3:0] + g_d_reg[11:8];
                    end
                    2'b11: begin
                        g_vld  <= 1'b1;
                        g_out   <= g_d_reg[3:0] + g_d_reg[15:12];
                    end
                    default: begin
                        g_vld  <= 1'b0;
                        g_d_reg <= 16'd0;
                        g_out   <= 5'd0;
                    end
                endcase
            end
        end
    end

    // ==========================================================================
    // Helper functions & tasks
    // ==========================================================================

    // Compare actual vs golden at one point
    task automatic chk_single(input int lbl, input [4:0] act_o,
                                          input bit act_v,
                                          input [4:0] exp_o,
                                          input bit exp_v);
        total_test++;
        if ((act_o === exp_o) && (act_v === exp_v))
            pass_cnt++;
        else begin
            fail_cnt++;
            $display("[FAIL] lbl=%0d got=(%h,%b) expected=(%h,%b)",
                     lbl, act_o, act_v, exp_o, exp_v);
        end
    endtask

    // Assert reset low for n cycles then release
    task automatic do_rst(int n);
        rst_n <= 1'b0;
        repeat (n) @(posedge clk);
        rst_n <= 1'b1;
    endtask

    // Run N clock cycles, checking every tick against golden
    task automatic run_cycles(int n);
        integer i;
        for (i = 0; i < n; i++) begin
            @(posedge clk); #1;
            txn_id++;
            chk_single(i, dout, vout, g_out, g_vld);
            if ((i == 0) || (i == n - 1) || (fail_cnt > 0))
                $display("[%3d] c%0d out=%h vld=%b gold_o=%h gold_v=%b %s",
                         txn_id, i, dout, vout,
                         g_out, g_vld,
                         (dout===g_out && vout===g_vld) ? "PASS" : "FAIL");
        end
    endtask

    // ==========================================================================
    // Main flow
    // ==========================================================================
    initial begin : MAIN
        total_test = 0; pass_cnt = 0; fail_cnt = 0; txn_id = 0;

        `ifdef FSDB
            $fsdbDumpfile("dump.fsdb");
            $fsdbDumpvars(0, tb_VL5);
        `endif

        $display("==========================================================");
        $display(" tb_VL5 : 位拆分与运算 (Nibble Extract & Add)");
        $display("  sel={0|1|2|3} -> {load|nib0+1|nib0+2|nib0+3}");
        $display("==========================================================");

        // -- Phase 0: Power-on reset settled --------------------------------
        do_rst(6);
        $display("--- phase 0: reset settled ---");
        chk_single(0, dout, vout, g_out, g_vld);
        $display("[CHECK] settled  got=(%h,%b) gold=(%h,%b)%c\n",
                 dout, vout, g_out, g_vld,
                 (dout===g_out && vout===g_vld) ? 80 : 33);

        // -- Phase 1: Uniform sel runs (each mode steady-state) -------------
        $display("--- phase 1: uniform selects ---");

        $display("[run] sel=0 latch mode (4 cycles, out=0,vld=0)");
        sel  <= 2'd0;
        d_in <= 16'hDEAD;
        run_cycles(4);

        $display("[run] sel=1 nib0+nib1 (4 cycles)");
        sel  <= 2'd1;
        run_cycles(4);

        $display("[run] sel=2 nib0+nib2 (4 cycles)");
        sel  <= 2'd2;
        run_cycles(4);

        $display("[run] sel=3 nib0+nib3 (4 cycles)");
        sel  <= 2'd3;
        run_cycles(4);

        $display("");

        // -- Phase 2: Load -> Compute pipeline sequences --------------------
        // Key timing rule: after setting sel=E0, data, the FIRST useful
        // computation result appears at cycle E0+2 (not E0+1!) due to
        // two levels of non-blocking assignments in the pipeline.
        $display("--- phase 2: load->compute pipeline ---");

        // Case A: d=0x1234 => nib0=4, nib1=3, nib2=2, nib3=1
        $display("[seqA] d=0x1234 loaded then computed on sel=1..3");
        d_in <= 16'h1234; sel <= 2'd0;
        @(posedge clk); #1;   // C0: select=0 -> load d_in into d_reg; out=0,vld=0
        @(posedge clk); #1;   // C1: still sel=0 -> re-loads same d_reg; out=0,vld=0
                             //      (dummy cycle ensures d_reg has settled for next sel change)
        sel <= 2'd1;
        @(posedge clk); #1;   // C2: sel=1 -> d_reg holds 0x1234 (from C0/C1); out=0x4+0x3=7
        chk_single(10, dout, vout, g_out, g_vld);
        $display("[CHECK] seqA_sel1 got=(%h,%b) gold=(%h,%b)%c\n",
                 dout, vout, g_out, g_vld,
                 (dout===g_out && vout===g_vld) ? 80 : 33);

        sel <= 2'd2;
        @(posedge clk); #1;   // C3: sel=2 -> 0x4+0x2=6
        chk_single(11, dout, vout, g_out, g_vld);
        $display("[CHECK] seqA_sel2 got=(%h,%b) gold=(%h,%b)%c\n",
                 dout, vout, g_out, g_vld,
                 (dout===g_out && vout===g_vld) ? 80 : 33);

        sel <= 2'd3;
        @(posedge clk); #1;   // C4: sel=3 -> 0x4+0x1=5
        chk_single(12, dout, vout, g_out, g_vld);
        $display("[CHECK] seqA_sel3 got=(%h,%b) gold=(%h,%b)%c\n",
                 dout, vout, g_out, g_vld,
                 (dout===g_out && vout===g_vld) ? 80 : 33);

        // Reset between cases
        do_rst(1);

        // Case B: d=0xFEDC => nib0=C(12), nib1=D(13), nib2=E(14), nib3=F(15)
        // sel=1->12+13=25, sel=2->12+14=26, sel=3->12+15=27
        // All fit in 5-bit (max=31). Overflow test!
        $display("[seqB] d=0xFEDC overflow test (12+13..12+15)");
        d_in <= 16'hFEDC; sel <= 2'd0;
        @(posedge clk); #1;   // C0: select=0 -> load FEDC
        @(posedge clk); #1;   // C1: sel=0 again -> re-confirm d_reg; out still 0
        sel <= 2'd1;
        @(posedge clk); #1;   // C2: sel=1: 12+13=25
        sel <= 2'd2;
        @(posedge clk); #1;   // C3: sel=2: 12+14=26
        sel <= 2'd3;
        @(posedge clk); #1;   // C4: sel=3: 12+15=27
        chk_single(16, dout, vout, g_out, g_vld);
        $display("[CHECK] seqB_last got=(%h,%b) gold=(%h,%b)%c\n",
                 dout, vout, g_out, g_vld,
                 (dout===g_out && vout===g_vld) ? 80 : 33);

        // Case C: d=0x0000 -> all sums = 0
        $display("[seqC] d=0x0000 all zeros");
        do_rst(1);
        d_in <= 16'h0000; sel <= 2'd0;
        @(posedge clk); #1;   // C0: load 0
        @(posedge clk); #1;   // C1: sel=0 again -> confirm
        sel <= 2'd1;
        @(posedge clk); #1;   // C2: sel=1: 0+0=0
        sel <= 2'd2;
        @(posedge clk); #1;   // C3: sel=2: 0+0=0
        sel <= 2'd3;
        @(posedge clk); #1;   // C4: sel=3: 0+0=0
        chk_single(20, dout, vout, g_out, g_vld);
        $display("[CHECK] seqC_zero got=(%h,%b) gold=(%h,%b)%c\n",
                 dout, vout, g_out, g_vld,
                 (dout===g_out && vout===g_vld) ? 80 : 33);

        // Case D: d=0xFFFF -> nib0+nib1=15+15=30 (fits 5-bit)
        $display("[seqD] d=0xFFFF max nibbles (15+15=30)");
        do_rst(1);
        d_in <= 16'hFFFF; sel <= 2'd0;
        @(posedge clk); #1;   // C0: load FFFF
        @(posedge clk); #1;   // C1: sel=0 confirm
        sel <= 2'd3;
        @(posedge clk); #1;   // C2: sel=3: 15+15=30
        @(posedge clk); #1;   // C3: sel=3 steady
        chk_single(23, dout, vout, g_out, g_vld);
        $display("[CHECK] seqD_max  got=(%h,%b) gold=(%h,%b)%c\n",
                 dout, vout, g_out, g_vld,
                 (dout===g_out && vout===g_vld) ? 80 : 33);

        $display("");

        // -- Phase 3: Full computation matrix -------------------------------
        $display("--- phase 3: computation matrix ---");

        // Fixed d=0xABCD => nib0=C(12), nib1=D(13), nib2=B(11), nib3=A(10)
        d_in  <= 16'hABCD;
        sel   <= 2'd0;
        @(posedge clk); #1;   // C0: load
        @(posedge clk); #1;   // C1: ready — first computation result appears

        for (int si = 0; si <= 3; si++) begin
            sel <= si;
            @(posedge clk); #1;  // C(si+2): computation result
            chk_single(si * 10, dout, vout, g_out, g_vld);
            if ((si == 0) || (si == 3) || (fail_cnt > 0))
                $display("[CHECK] mat_sel%d out=%h vld=%b gold_o=%h gold_v=%b %s",
                         si, dout, vout, g_out, g_vld,
                         (dout===g_out && vout===g_vld) ? "PASS" : "FAIL");
        end

        $display("");

        // -- Phase 4: Mid-stream reset pulse -------------------------------
        dataflow_reset_pulse();
        $display("");

        // -- Phase 5: Random burst ------------------------------------------
        $display("--- phase 5: random burst (64 txns) ---");
        for (txn_id = 1; txn_id <= 64; txn_id++) begin
            // Alternate: even = load d_in, odd = compute
            if (txn_id % 2 == 0) begin
                d_in  <= $urandom_range(16'hFFFF);
                sel   <= 2'd0;
            end else begin
                sel <= $urandom_range(3);
            end
            @(posedge clk); #1;
            chk_single(txn_id, dout, vout, g_out, g_vld);
            if ((txn_id % 16 == 0) || (fail_cnt > 0))
                $display("[%03d] r%0d out=%h vld=%b gold_o=%h gold_v=%b %s",
                         txn_id, txn_id, dout, vout,
                         g_out, g_vld,
                         (dout===g_out && vout===g_vld) ? "PASS" : "FAIL");
        end

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

    // ==========================================================================
    // Phase 4: mid-stream async reset + recovery
    // ==========================================================================
    task automatic dataflow_reset_pulse();
        $display("--- phase 4: mid-stream reset pulse ---");

        // Stabilize: load d, compute
        d_in  <= 16'h0B12;
        sel   <= 2'd0;
        @(posedge clk); #1;   // C0: load 0x0B12
        @(posedge clk); #1;   // C1: sel=0 confirm
        sel   <= 2'd3;
        @(posedge clk); #1;   // C2: sel=3 -> nib0(2)+nib3(0xB)=13
        @(posedge clk); #1;   // C3: sel=3 steady

        // Inject async reset between edges
        @(negedge clk);
        rst_n <= 1'b0;         // async assert
        #0;                    // settle combinational
        chk_single(30, dout, vout, g_out, g_vld);
        $display("[CHECK] mid_reset  got=(%h,%b) gold=(%h,%b)%c\n",
                 dout, vout, g_out, g_vld,
                 (dout===g_out && vout===g_vld) ? 80 : 33);

        // Hold for clocks then release
        repeat (3) @(posedge clk);
        rst_n <= 1'b1;         // async deassert
        @(posedge clk); #1;    // one more cycle to clear everything

        // Quick restart verification
        d_in  <= 16'hCAFE;
        sel   <= 2'd0;
        @(posedge clk); #1;   // C0: load CAFEBABA
        @(posedge clk); #1;   // C1: sel=0 confirm
        sel   <= 2'd1;
        @(posedge clk); #1;   // C2: sel=1 -> 0xE+0xF=23
        @(posedge clk); #1;   // C3: sel=1 steady
        chk_single(35, dout, vout, g_out, g_vld);
        $display("[CHECK] recovery   got=(%h,%b) gold=(%h,%b)%c\n",
                 dout, vout, g_out, g_vld,
                 (dout===g_out && vout===g_vld) ? 80 : 33);
    endtask

endmodule
