`timescale 1ns/1ns

module tb_mux4_1;

    // ---------- DUT 端口 ----------
    reg  [1:0] d0, d1, d2, d3;
    reg  [1:0] sel;
    wire [1:0] mux_out;

    // ---------- 统计 ----------
    integer errors = 0;
    integer cycle  = 0;

    // ---------- DUT 例化 ----------
    mux4_1 u_mux4_1 (
        .d0      (d0),
        .d1      (d1),
        .d2      (d2),
        .d3      (d3),
        .sel     (sel),
        .mux_out (mux_out)
    );

    // ---------- 波形 dump: 运行脚本传入 +FSDB=1 时记录 fsdb ----------
    integer fsdb_on;
    string  wave_file;
    initial begin
        fsdb_on = 0;
        if ($value$plusargs("FSDB=%d", fsdb_on) && fsdb_on) begin
            if (!$value$plusargs("WAVE_FILE=%s", wave_file))
                wave_file = "wave.fsdb";
            $fsdbDumpfile(wave_file);
            $fsdbDumpvars(0, tb_mux4_1);
        end
    end

    // ---------- 超时保护 ----------
    initial begin
        integer timeout;
        if (!$value$plusargs("TIMEOUT=%d", timeout))
            timeout = 1000000;
        #(timeout);
        $display("TIMEOUT: simulation exceeded %0d ns", timeout);
        $display("TEST FAILED");
        $finish;
    end

    // ---------- 检查任务: 给定 sel 与期望值 ----------
    task apply_and_check;
        input [1:0] sel_v;
        input [1:0] exp_v;
        begin
            sel = sel_v;
            #10;
            cycle = cycle + 1;
            if (mux_out !== exp_v) begin
                errors = errors + 1;
                $display("[FAIL] cycle %0d : sel=%b, mux_out=%b, expect=%b",
                         cycle, sel, mux_out, exp_v);
            end else begin
                $display("[PASS] cycle %0d : sel=%b, mux_out=%b",
                         cycle, sel, mux_out);
            end
        end
    endtask

    // ---------- 主测试流程 ----------
    initial begin
        $display("========== VL1 mux4_1 testbench start ==========");

        // 第一组: 按题目状态转换表赋值
        // d0=11, d1=10, d2=01, d3=00
        // sel=11->d0, sel=10->d1, sel=01->d2, sel=00->d3
        d0 = 2'b11; d1 = 2'b10; d2 = 2'b01; d3 = 2'b00;
        apply_and_check(2'b00, d3);   // expect 00
        apply_and_check(2'b01, d2);   // expect 01
        apply_and_check(2'b10, d1);   // expect 10
        apply_and_check(2'b11, d0);   // expect 11

        // 第二组: 换一组数据再次全遍历
        #20;
        d0 = 2'b00; d1 = 2'b01; d2 = 2'b10; d3 = 2'b11;
        apply_and_check(2'b00, d3);   // expect 11
        apply_and_check(2'b01, d2);   // expect 10
        apply_and_check(2'b10, d1);   // expect 01
        apply_and_check(2'b11, d0);   // expect 00

        // 第三组: 随机数据全遍历
        #20;
        d0 = 2'b10; d1 = 2'b11; d2 = 2'b00; d3 = 2'b01;
        apply_and_check(2'b00, d3);   // expect 01
        apply_and_check(2'b01, d2);   // expect 00
        apply_and_check(2'b10, d1);   // expect 11
        apply_and_check(2'b11, d0);   // expect 10

        #20;
        if (errors == 0) begin
            $display("========================================");
            $display("TEST PASSED: all %0d checks ok", cycle);
        end else begin
            $display("========================================");
            $display("TEST FAILED: %0d/%0d checks failed", errors, cycle);
        end
        $finish;
    end

endmodule