`timescale 1ns/1ns

module tb_huawei8;

    // ============================================================
    // DUT ports
    // ============================================================
    reg  [3:0] A;
    reg  [3:0] B;
    wire [4:0] OUT;

    // ============================================================
    // Statistics
    // ============================================================
    integer errors     = 0;
    integer total_chk  = 0;
    integer pass_cnt   = 0;

    // ============================================================
    // DUT instantiation
    // ============================================================
    huawei8 dut (
        .A  (A),
        .B  (B),
        .OUT(OUT)
    );

    // ============================================================
    // Waveform dump: +FSDB=1 enables fsdb recording
    // ============================================================
    integer fsdb_on;
    string  wave_file;
    initial begin
        fsdb_on = 0;
        if ($value$plusargs("FSDB=%d", fsdb_on) && fsdb_on) begin
            if (!$value$plusargs("WAVE_FILE=%s", wave_file))
                wave_file = "wave_huawei8.fsdb";
            $fsdbDumpfile(wave_file);
            $fsdbDumpvars(0, tb_huawei8);
        end
    end

    // ============================================================
    // Timeout protection
    // ============================================================
    initial begin
        integer timeout;
        if (!$value$plusargs("TIMEOUT=%d", timeout))
            timeout = 500000;
        #(timeout);
        $display("[%0t ns] TIMEOUT exceeded", $time);
        $display("TEST FAILED");
        $finish;
    end

    // ============================================================
    // Check helper: apply inputs, wait for combinational settle,
    // then verify output against reference (A + B).
    // ============================================================
    task chk_add;
        input [3:0] a;
        input [3:0] b;
        input [4:0] exp;
        begin
            A = a;
            B = b;
            #2;   // allow combinational logic to settle
            total_chk = total_chk + 1;
            if (OUT === exp) begin
                pass_cnt = pass_cnt + 1;
                $display("[PASS] chk-%0d : %0d + %0d = %0d (expected %0d)",
                         total_chk, a, b, OUT, exp);
            end else begin
                errors = errors + 1;
                $display("[FAIL] chk-%0d : %0d + %0d = %0d, expected %0d",
                         total_chk, a, b, OUT, exp);
            end
        end
    endtask

    // ============================================================
    // Loop variables (Verilog-2001: must be declared outside
    // initial block since tasks cannot declare locals)
    // ============================================================
    integer i;
    integer j;
    integer k;

    // ============================================================
    // Test flow
    // ============================================================
    initial begin
        $display("============================================");
        $display(" VL66 Carry-Lookahead Adder testbench");
        $display("   4-bit CLA: OUT = A + B");
        $display("============================================");

        // ---- Initialisation ----
        A = 4'b0;
        B = 4'b0;

        // ========================================================
        // Test 1 — Basic cases
        // ========================================================
        $display("");
        $display("--- Test 1: Basic cases ---");
        chk_add(4'd0,  4'd0,  5'd0);
        chk_add(4'd0,  4'd1,  5'd1);
        chk_add(4'd1,  4'd0,  5'd1);
        chk_add(4'd1,  4'd1,  5'd2);
        chk_add(4'd3,  4'd5,  5'd8);
        chk_add(4'd7,  4'd8,  5'd15);

        // ========================================================
        // Test 2 — Boundary cases (carry propagation)
        // ========================================================
        $display("");
        $display("--- Test 2: Boundary cases ---");
        chk_add(4'd15, 4'd1,  5'd16);   // max + 1 = overflow
        chk_add(4'd15, 4'd15, 5'd30);   // max + max
        chk_add(4'd8,  4'd8,  5'd16);   // MSB + MSB
        chk_add(4'd7,  4'd9,  5'd16);   // carry propagation through all bits
        chk_add(4'd10, 4'd5,  5'd15);   // no carry

        // ========================================================
        // Test 3 — Exhaustive sweep (all 256 combinations)
        // ========================================================
        $display("");
        $display("--- Test 3: Exhaustive sweep (256 cases) ---");
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                chk_add(i[3:0], j[3:0], (i + j));
            end
        end

        // ========================================================
        // Test 4 — Random stress test
        // ========================================================
        $display("");
        $display("--- Test 4: Random stress test (100 cases) ---");
        for (k = 0; k < 100; k = k + 1) begin
            A = $random % 16;
            B = $random % 16;
            #2;
            total_chk = total_chk + 1;
            if (OUT === (A + B)) begin
                pass_cnt = pass_cnt + 1;
                $display("[PASS] chk-%0d : %0d + %0d = %0d",
                         total_chk, A, B, OUT);
            end else begin
                errors = errors + 1;
                $display("[FAIL] chk-%0d : %0d + %0d = %0d, expected %0d",
                         total_chk, A, B, OUT, (A + B));
            end
        end

        // ========================================================
        // Summary
        // ========================================================
        $display("");
        $display("============================================");
        $display(" Checks: %0d total | %0d passed | %0d failed",
                 total_chk, pass_cnt, errors);
        if (errors == 0) begin
            $display(" RESULT: TEST PASSED");
        end else begin
            $display(" RESULT: TEST FAILED");
        end
        $display("============================================");
        $display("[%0t ns] waveform observation finished", $time);
        $finish;
    end

endmodule
