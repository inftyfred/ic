`timescale 1ns/1ns

// VL60 握手式 CDC testbench
//
// data_driver 每隔若干 clk_a 周期发起一次请求；data_receiver 在 clk_b
// 域采样请求、锁存数据并返回应答。测试平台通过接收端的 data_r
//（题目模块没有对外导出接收数据端口）检查传输结果。
module tb_VL60;
    reg       clk_a;
    reg       clk_b;
    reg       rst_n;
    wire [3:0] data;
    wire       data_req;
    wire       data_ack;

    integer errors;
    integer transfers;
    integer fsdb_on;
    integer timeout;
    string  wave_file;

    data_driver u_driver (
        .clk_a    (clk_a),
        .rst_n    (rst_n),
        .data_ack (data_ack),
        .data     (data),
        .data_req (data_req)
    );

    data_receiver u_receiver (
        .clk_b    (clk_b),
        .rst_n    (rst_n),
        .data     (data),
        .data_req (data_req),
        .data_ack (data_ack)
    );

    // 两个不同频率、不同相位的时钟，覆盖多种采样相位。
    initial begin
        clk_a = 1'b0;
        #1;
        forever #5 clk_a = ~clk_a;       // 10 ns
    end

    initial begin
        clk_b = 1'b0;
        #3;
        forever #7 clk_b = ~clk_b;       // 14 ns
    end

    // 与 templete/scripts/run.sh 的 +FSDB=1 +WAVE_FILE=... 参数兼容。
    initial begin
        fsdb_on = 0;
        if ($value$plusargs("FSDB=%d", fsdb_on) && fsdb_on) begin
            if (!$value$plusargs("WAVE_FILE=%s", wave_file))
                wave_file = "wave_vl60.fsdb";
            $fsdbDumpfile(wave_file);
            $fsdbDumpvars(0, tb_VL60);
        end
    end

    task check_transfer;
        input [3:0] expected;
        begin
            // data_ack 在接收端锁存 data 的同一时刻由 NBA 更新，延迟
            // 一个 delta/时间单位后再观察层次化的 data_r。
            @(posedge data_ack);
            #1;
            transfers = transfers + 1;
            if (u_receiver.data_r === expected) begin
                $display("[%0t ns] [PASS] transfer %0d: data_r=%h expected=%h",
                         $time, transfers, u_receiver.data_r, expected);
            end else begin
                errors = errors + 1;
                $display("[%0t ns] [FAIL] transfer %0d: data_r=%h expected=%h",
                         $time, transfers, u_receiver.data_r, expected);
            end
            // 等待握手返回空闲，避免把同一笔请求重复计数。
            @(negedge data_ack);
        end
    endtask

    initial begin
        errors    = 0;
        transfers = 0;
        rst_n     = 1'b0;

        $display("============================================");
        $display(" VL60 handshake CDC testbench");
        $display(" clk_a=10ns, clk_b=14ns");
        $display("============================================");

        // 异步复位保持足够时间，随后在非时钟边沿释放。
        #23;
        rst_n = 1'b1;
        #2;

        // 题目设计的发送数据序列为 0,1,...,7,0,1。
        check_transfer(4'h0);
        check_transfer(4'h1);
        check_transfer(4'h2);
        check_transfer(4'h3);
        check_transfer(4'h4);
        check_transfer(4'h5);
        check_transfer(4'h6);
        check_transfer(4'h7);
        check_transfer(4'h0);
        check_transfer(4'h1);

        #20;
        if (data_req !== 1'b0 || data_ack !== 1'b0) begin
            errors = errors + 1;
            $display("[FAIL] handshake did not return idle: req=%b ack=%b",
                     data_req, data_ack);
        end else begin
            $display("[PASS] handshake returned idle");
        end

        $display("============================================");
        $display(" RESULT: transfers=%0d errors=%0d", transfers, errors);
        if (errors == 0)
            $display(" TEST PASSED");
        else
            $display(" TEST FAILED");
        $display("============================================");
        $finish;
    end

    initial begin
        timeout = 5000;
        if ($value$plusargs("TIMEOUT=%d", timeout)) begin end
        #(timeout);
        $display("[%0t ns] TEST FAILED: timeout", $time);
        $finish;
    end
endmodule
