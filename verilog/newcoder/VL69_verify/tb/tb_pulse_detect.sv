`timescale 1ns/1ps

module tb_pulse_detect;
    reg  clka;
    reg  clkb;
    reg  rst_n;
    reg  sig_a;
    wire sig_b;

    integer errors;
    integer pulse_count;
    integer fsdb_on;
    string  wave_file;

    pulse_detect dut (
        .clka  (clka),
        .clkb  (clkb),
        .rst_n (rst_n),
        .sig_a (sig_a),
        .sig_b (sig_b)
    );

    // 快时钟周期 4 ns，慢时钟周期 10 ns。
    initial begin
        clka = 1'b0;
        forever #2 clka = ~clka;
    end

    initial begin
        clkb = 1'b0;
        forever #5 clkb = ~clkb;
    end

    always @(posedge sig_b) begin
        pulse_count = pulse_count + 1;
        $display("[%0t ns] [INFO] synchronized pulse #%0d", $time, pulse_count);
    end

    initial begin
        fsdb_on = 0;
        if ($value$plusargs("FSDB=%d", fsdb_on) && fsdb_on) begin
            if (!$value$plusargs("WAVE_FILE=%s", wave_file))
                wave_file = "wave_vl69.fsdb";
            $fsdbDumpfile(wave_file);
            $fsdbDumpvars(0, tb_pulse_detect);
        end
    end

    task source_pulse;
        begin
            // 保证 sig_a 在一个 clka 上升沿被采到，且每次只产生一个上升沿。
            @(negedge clka);
            sig_a = 1'b1;
            @(negedge clka);
            sig_a = 1'b0;
        end
    endtask

    task wait_source_gap;
        input integer cycles;
        integer k;
        begin
            for (k = 0; k < cycles; k = k + 1)
                @(posedge clka);
        end
    endtask

    task check_count;
        input integer expected;
        input [160*8-1:0] name;
        begin
            if (pulse_count == expected)
                $display("[PASS] %0s: pulse_count=%0d", name, pulse_count);
            else begin
                errors = errors + 1;
                $display("[FAIL] %0s: pulse_count=%0d, expected=%0d",
                         name, pulse_count, expected);
            end
        end
    endtask

    initial begin
        errors      = 0;
        pulse_count = 0;
        rst_n       = 1'b0;
        sig_a       = 1'b0;

        $display("============================================");
        $display(" VL69 pulse synchronizer testbench");
        $display("============================================");

        #12;
        if (sig_b !== 1'b0) begin
            errors = errors + 1;
            $display("[FAIL] reset: sig_b=%b, expected 0", sig_b);
        end else
            $display("[PASS] reset: sig_b=0");

        rst_n = 1'b1;
        wait_source_gap(3);

        $display("--- Test 1: single pulse ---");
        source_pulse();
        wait_source_gap(12);
        check_count(1, "single pulse");

        $display("--- Test 2: phase-varied single pulses ---");
        source_pulse();
        wait_source_gap(11);
        source_pulse();
        wait_source_gap(12);
        check_count(3, "phase varied");

        $display("--- Test 3: separated pulse burst ---");
        source_pulse();
        wait_source_gap(8);
        source_pulse();
        wait_source_gap(8);
        source_pulse();
        wait_source_gap(14);
        check_count(6, "separated burst");

        // 复位后内部 toggle 与同步链清零，验证可重新工作。
        $display("--- Test 4: reset and restart ---");
        rst_n = 1'b0;
        #3;
        rst_n = 1'b1;
        wait_source_gap(3);
        source_pulse();
        wait_source_gap(12);
        check_count(7, "restart after reset");

        $display("");
        $display("============================================");
        if (errors == 0)
            $display(" RESULT: TEST PASSED (%0d pulses observed)", pulse_count);
        else
            $display(" RESULT: TEST FAILED (%0d errors)", errors);
        $display("============================================");
        $finish;
    end

    initial begin
        #1000;
        $display("[FAIL] TEST FAILED: timeout");
        $finish;
    end
endmodule
