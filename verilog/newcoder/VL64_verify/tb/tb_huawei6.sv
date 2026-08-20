`timescale 1ns/1ns

module tb_huawei6;

    reg clk0;
    reg clk1;
    reg rst;
    reg sel;
    wire clk_out;

    integer fsdb_on;
    string wave_file;

    huawei6 dut (
        .clk0    (clk0),
        .clk1    (clk1),
        .rst     (rst),
        .sel     (sel),
        .clk_out (clk_out)
    );

    // 记录波形，配合 templete/scripts/run.sh 的 +FSDB 和 +WAVE_FILE 参数。
    initial begin
        fsdb_on = 0;
        if ($value$plusargs("FSDB=%d", fsdb_on) && fsdb_on) begin
            if (!$value$plusargs("WAVE_FILE=%s", wave_file))
                wave_file = "vl64_clock_switch.fsdb";
            $fsdbDumpfile(wave_file);
            $fsdbDumpvars(0, tb_huawei6);
        end
    end

    // clk0 为 clk1 的二倍频：clk0 周期 10ns，clk1 周期 20ns。
    initial begin
        clk0 = 1'b0;
        clk1 = 1'b0;
        fork
            forever #5 clk1 = ~clk1;
            forever #10 clk0 = ~clk0;
        join
    end

    // initial begin
    //     clk1 = 1'b0;
    //     forever #10 clk1 = ~clk1;
    // end

    // 复位释放后先选择 clk1，再切换到 clk0，再切回 clk1。
    initial begin
        rst = 1'b0;
        sel = 1'b0;

        #10;
        rst = 1'b1;
        $display("[%0t ns] release reset, select clk1", $time);

        // 等待 clk1 稳定输出一段时间。
        #53;
        sel = 1'b1;
        $display("[%0t ns] request switch to clk0", $time);

        // 观察切换到 clk0 后的输出。
        #67;
        sel = 1'b0;
        $display("[%0t ns] request switch to clk1", $time);

        // 观察切换回 clk1 后的输出。
        #73;
        $display("[%0t ns] waveform observation finished", $time);
        $finish;
    end

    // 超时保护，避免时钟进程导致仿真无法结束。
    initial begin
        #300;
        $display("[%0t ns] TEST FAILED: timeout", $time);
        $finish;
    end

endmodule
