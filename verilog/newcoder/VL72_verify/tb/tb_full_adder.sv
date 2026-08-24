`timescale 1ns/1ns

module tb_full_adder;

    // ============================================================
    // DUT ports
    // ============================================================
    reg  A;
    reg  B;
    reg  Ci;
    wire S;
    wire Co;

    // ============================================================
    // Statistics & waveform
    // ============================================================
    integer errors;
    integer total_tests;
    integer pass_cnt;
    integer fsdb_on;
    string  wave_file;

    // ============================================================
    // DUT instantiation — both half adder and full adder are in scope
    // ============================================================
    add_full dut (
        .A  (A),
        .B  (B),
        .Ci (Ci),
        .S  (S),
        .Co (Co)
    );

    // ============================================================
    // FSDB dump support (matching templete/run.sh +FSDB/+WAVE_FILE)
    // ============================================================
    initial begin
        fsdb_on = 0;
        if ($value$plusargs("FSDB=%d", fsdb_on) && fsdb_on) begin
            if (!$value$plusargs("WAVE_FILE=%s", wave_file))
                wave_file = "wave_vl72.fsdb";
            $fsdbDumpfile(wave_file);
            $fsdbDumpvars(0, tb_full_adder);
        end
    end

    // ============================================================
    // Check helpers
    // ============================================================
    task chk_add;
        input  [1:0] exp_sum;  // {Co, S}
        input  [3:0] a_b_ci;   // {A, B, Ci}
        input  [80*8-1:0] name;
        begin
            total_tests = total_tests + 1;
            if ({Co, S} === exp_sum) begin
                pass_cnt = pass_cnt + 1;
                $display("[PASS] chk-%0d %s: %b+%b+Ci(%b) = %b (%d+%d+%d=%d)",
                         total_tests, name, A, B, Ci,
                         {Co,S}, A, B, Ci, exp_sum[1]*2 + exp_sum[0]);
            end else begin
                errors = errors + 1;
                $display("[FAIL] chk-%0d %s: %b+%b+Ci(%b) => S=%b Co=%b, expected %b",
                         total_tests, name, A, B, Ci, S, Co, exp_sum);
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
    // Main test flow — exhaustive enumeration of all 8 input combos
    // ============================================================
    initial begin
        $display("============================================");
        $display(" VL72 Full Adder testbench");
        $display(" Verifies: A + B + Ci → {Co, S}");
        $display(" Truth table: see below each check");
        $display("============================================");

        errors     = 0;
        total_tests = 0;
        pass_cnt   = 0;

        // ---- Enumerate all 8 combinations ----
        $display("");
        $display("--- Row 0: A=0 B=0 Ci=0, expect S=0 Co=0 ---");
        A = 0; B = 0; Ci = 0; #10;
        chk_add(2'b00, 3'b000, "{0,0,0}");

        $display("");
        $display("--- Row 1: A=0 B=0 Ci=1, expect S=1 Co=0 ---");
        A = 0; B = 0; Ci = 1; #10;
        chk_add(2'b01, 3'b001, "{0,0,1}");

        $display("");
        $display("--- Row 2: A=0 B=1 Ci=0, expect S=1 Co=0 ---");
        A = 0; B = 1; Ci = 0; #10;
        chk_add(2'b01, 3'b010, "{0,1,0}");

        $display("");
        $display("--- Row 3: A=0 B=1 Ci=1, expect S=0 Co=1 ---");
        A = 0; B = 1; Ci = 1; #10;
        chk_add(2'b10, 3'b011, "{0,1,1}");

        $display("");
        $display("--- Row 4: A=1 B=0 Ci=0, expect S=1 Co=0 ---");
        A = 1; B = 0; Ci = 0; #10;
        chk_add(2'b01, 3'b100, "{1,0,0}");

        $display("");
        $display("--- Row 5: A=1 B=0 Ci=1, expect S=0 Co=1 ---");
        A = 1; B = 0; Ci = 1; #10;
        chk_add(2'b10, 3'b101, "{1,0,1}");

        $display("");
        $display("--- Row 6: A=1 B=1 Ci=0, expect S=0 Co=1 ---");
        A = 1; B = 1; Ci = 0; #10;
        chk_add(2'b10, 3'b110, "{1,1,0}");

        $display("");
        $display("--- Row 7: A=1 B=1 Ci=1, expect S=1 Co=1 ---");
        A = 1; B = 1; Ci = 1; #10;
        chk_add(2'b11, 3'b111, "{1,1,1}");

        // ========================================================
        // Summary
        // ========================================================
        $display("");
        $display("============================================");
        $display(" Checks: %0d total | %0d passed | %0d failed",
                 total_tests, pass_cnt, errors);
        if (errors == 0)
            $display(" RESULT: TEST PASSED");
        else
            $display(" RESULT: TEST FAILED");
        $display("============================================");
        $display("[%0t ns] done", $time);
        $finish;
    end

endmodule
