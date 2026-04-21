`timescale 1ns/1ps

module tb_uart;
    //===========================================================================
    // 参数定义
    //===========================================================================
    parameter CLK_FREQ   = 100_000_000;  // 100MHz
    parameter BAUDRATE   = 115200;
    parameter CLK_PERIOD = 10;           // 10ns = 100MHz

    // 计算bit周期（用于验证）
    parameter BIT_PERIOD_NS = 1_000_000_000 / BAUDRATE;  // ~8680ns

	parameter RECV_NBYTE = 2;
	parameter SEND_NBYTE = 2;

    //===========================================================================
    // 信号声明
    //===========================================================================
    logic clk;
    logic rst_n;
    logic rxd;
    logic txd;

    // TX信号
    logic send_en;
    logic [SEND_NBYTE*8-1:0] send_data;
    logic send_done;

    // RX信号
    logic recv_vld;
    logic [RECV_NBYTE*8-1:0] recv_data;  // RECV_NBYTE=2
    logic parity_err;

    // 测试控制
    integer test_num = 0;
    integer pass_count = 0;
    integer fail_count = 0;

    // 接收监控
    logic [15:0] expected_recv_data;

    //===========================================================================
    // DUT实例化
    //===========================================================================
    uart_top #(
        .CLK_FREQ  (CLK_FREQ),
        .BAUDRATE  (BAUDRATE),
        .PARITY    ("EVEN"),
        .SEND_NBYTE(SEND_NBYTE),
        .RECV_NBYTE(RECV_NBYTE)
    ) dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .rxd       (rxd),
        .send_en   (send_en),
        .send_data (send_data),
        .send_done (send_done),
        .txd       (txd),
        .recv_vld  (recv_vld),
        .recv_data (recv_data),
        .parity_err(parity_err)
    );

    //===========================================================================
    // 时钟生成
    //===========================================================================
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    //===========================================================================
    // 监控和报告
    //===========================================================================
    initial begin
        $display("==============================================");
        $display("       UART Module Testbench Started");
        $display("==============================================");
        $display("CLK_FREQ  = %0d Hz", CLK_FREQ);
        $display("BAUDRATE  = %0d bps", BAUDRATE);
        $display("BIT_PERIOD= %0d ns", BIT_PERIOD_NS);
        $display("==============================================");
    end

    // 接收完成监控
    always @(posedge clk) begin
        if (recv_vld) begin
            $display("[MONITOR] @%0t: RX Complete, data=0x%04h, parity_err=%b", 
                     $time, recv_data, parity_err);
        end
    end

    // 发送完成监控
    always @(posedge clk) begin
        if (send_done) begin
            $display("[MONITOR] @%0t: TX Complete", $time);
        end
    end

    //===========================================================================
    // 任务：系统复位
    //===========================================================================
    task automatic system_reset();
        begin
            $display("[TEST] System Reset...");
            rst_n = 0;
            send_en = 0;
            send_data = 8'h00;
            rxd = 1;  // UART空闲状态为高
            repeat(20) @(posedge clk);
            rst_n = 1;
            repeat(10) @(posedge clk);
            $display("[TEST] Reset Complete");
        end
    endtask

    //===========================================================================
    // 任务：发送一个字符（外部驱动到rxd）
    // 模拟外部设备发送数据到DUT的接收端
    //===========================================================================
    task automatic send_char_to_dut(input logic [7:0] data, input string parity_type = "EVEN");
        logic parity_bit;
        integer i;
        begin
            // 计算校验位
            if (parity_type == "NONE")
                parity_bit = 1'b0;
            else if (parity_type == "ODD")
                parity_bit = ~^data;
            else // EVEN
                parity_bit = ^data;

            $display("[DRIVE] @%0t: Sending char to DUT, data=0x%02h, parity=%b", $time, data, parity_bit);

            // 起始位 (1 bit period)
            rxd = 0;
            #(BIT_PERIOD_NS);

            // 数据位 (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                rxd = data[i];
                #(BIT_PERIOD_NS);
            end

            // 校验位（如果需要）
            if (parity_type != "NONE") begin
                rxd = parity_bit;
                #(BIT_PERIOD_NS);
            end

            // 停止位
            rxd = 1;
            #(BIT_PERIOD_NS);

            // 额外空闲时间
            #(BIT_PERIOD_NS / 2);
        end
    endtask

    //===========================================================================
    // 任务：等待接收完成并验证
    //===========================================================================
    task automatic wait_recv_and_check(input logic [15:0] expected_data);
        begin
            // 等待接收完成
            @(posedge recv_vld);
            #(CLK_PERIOD);

            if (recv_data === expected_data && !parity_err) begin
                $display("[PASS] Data match! Expected=0x%04h, Received=0x%04h", 
                         expected_data, recv_data);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] Data mismatch! Expected=0x%04h, Received=0x%04h, parity_err=%b", 
                         expected_data, recv_data, parity_err);
                fail_count = fail_count + 1;
            end
        end
    endtask

    //===========================================================================
    // 任务：通过DUT发送数据（内部发送）
    //===========================================================================
    task automatic dut_send(input logic [15:0] data);
        begin
            $display("[DRIVE] @%0t: Trigger DUT TX, data=0x%0h", $time, data);
            @(posedge clk);
            send_data = data;
            send_en = 1;
            @(posedge clk);
            send_en = 0;
            send_data = 8'h00;

            // 等待发送完成
            @(posedge send_done);
            #(CLK_PERIOD * 10);
        end
    endtask



task automatic measure_baud_rate();
    realtime t1, t2, period;
    
    $display("[TEST] Measuring TX baud rate...");
    
    fork
        // 线程1：触发发送
        begin
            dut_send(15'h5555);  // 0101_0101，方便观察
        end
        
        // 线程2：采样测量
        begin
            // 等待起始位下降沿
            @(negedge txd);
            t1 = $realtime;
            $display("[MEASURE] Start bit detected @ %0t", t1);
            
            // 跳过起始位，等待第一个数据位下降沿（bit0=1, bit1=0）
            // 8'h55 = 0101_0101，LSB first: 1->0->1->0...
            @(negedge txd);  // bit1的下降沿
            t2 = $realtime;
            
            period = ((t2 - t1) / 2);
            $display("[MEASURE] Edge1 @ %0t, Edge2 @ %0t", t1, t2);
            $display("[TEST] Measured bit period = %0d ns", period);
            $display("[TEST] Expected bit period = %0d ns ", BIT_PERIOD_NS );
            
            // 验证
            if ( (period - BIT_PERIOD_NS * 0.95 > 0) && (BIT_PERIOD_NS * 1.05 - period >0 )) begin
                $display("[PASS] Baud rate within 5%% tolerance");
                pass_count++;
            end else begin
                $display("[FAIL] Baud rate out of tolerance (measured=%0d, expected=%0d)", period, BIT_PERIOD_NS);
                fail_count++;
            end
        end
    join_any  // 任一线程完成就继续（通常是采样线程先完成）
    
    // 确保发送完成
    @(posedge send_done);  // 或者等待一段时间
    #(BIT_PERIOD_NS * 2);
endtask



    //===========================================================================
    // 主测试序列
    //===========================================================================
    initial begin
        //-------------------------------------------------
        // 测试1：基本复位测试
        //-------------------------------------------------
        test_num = 1;
        $display("\n[TEST %0d] Reset Test", test_num);
        system_reset();

        // 验证复位后状态
        if (txd === 1'b1 && recv_vld === 1'b0 && send_done === 1'b0) begin
            $display("[PASS] Reset state correct");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Reset state incorrect: txd=%b, recv_vld=%b, send_done=%b", 
                     txd, recv_vld, send_done);
            fail_count = fail_count + 1;
        end

        //-------------------------------------------------
        // 测试2：单字节接收测试
        //-------------------------------------------------
        test_num = 2;
        $display("\n[TEST %0d] Single Byte RX Test", test_num);
        system_reset();

        // 发送两个字节到DUT（RECV_NBYTE=2）
        fork
            begin
                send_char_to_dut(8'hA5);  // 第一个字节
                send_char_to_dut(8'h5A);  // 第二个字节
            end
            begin
                wait_recv_and_check(16'h5AA5);  // 注意：先收到的是低字节
            end
        join

        //-------------------------------------------------
        // 测试3：多帧接收测试
        //-------------------------------------------------
        test_num = 3;
        $display("\n[TEST %0d] Multi-frame RX Test", test_num);
        system_reset();

        repeat(3) begin
            fork
                begin
                    send_char_to_dut(8'h12);
                    send_char_to_dut(8'h34);
                end
                begin
                    wait_recv_and_check(16'h3412);
                end
            join
            #(BIT_PERIOD_NS * 4);
        end

        //-------------------------------------------------
        // 测试4：波特率测量测试
        //-------------------------------------------------
        test_num = 4;
        $display("\n[TEST %0d] Baud Rate Measurement", test_num);
        system_reset();
        measure_baud_rate();

        //-------------------------------------------------
        // 测试5：环回测试（TX->RX）
        //-------------------------------------------------
        test_num = 5;
        $display("\n[TEST %0d] Loopback Test (TX->RX)", test_num);
        system_reset();

        // 将TX输出连接到RX输入（外部环回）
        force rxd = txd;  // 这个会在initial块外持续驱动，需要特殊处理

        // 使用force/release进行环回
        fork
            begin
                // 发送端
                //repeat(3) begin
                    dut_send(16'hda55);
                    #(BIT_PERIOD_NS * 4);
                    dut_send(16'h1234);
                    #(BIT_PERIOD_NS * 4);
                    dut_send(16'h5678);
                    #(BIT_PERIOD_NS * 4);
                //end
            end
            begin
                // 接收端验证
                repeat(3) begin
                    @(posedge recv_vld);
                    #(CLK_PERIOD);
                    $display("[LOOPBACK] Received: 0x%04h", recv_data);
                end
            end
        join

		release rxd;

        //-------------------------------------------------
        // 测试6：边界值测试
        //-------------------------------------------------
        test_num = 6;
        $display("\n[TEST %0d] Boundary Value Test", test_num);
        system_reset();

        // 测试0x00（全0，偶校验位为0）
        fork
            begin send_char_to_dut(8'h00); send_char_to_dut(8'h00); end
            begin wait_recv_and_check(16'h0000); end
        join
        #(BIT_PERIOD_NS * 4);

        // 测试0xFF（全1，偶校验位为0，因为有8个1）
        fork
            begin send_char_to_dut(8'hFF); send_char_to_dut(8'hFF); end
            begin wait_recv_and_check(16'hFFFF); end
        join
        #(BIT_PERIOD_NS * 4);

        // 测试0x01（1个1，偶校验位为1）
        fork
            begin send_char_to_dut(8'h01); send_char_to_dut(8'h80); end
            begin wait_recv_and_check(16'h8001); end
        join
        #(BIT_PERIOD_NS * 4);

        //-------------------------------------------------
        // 测试7：奇偶校验错误测试
        //-------------------------------------------------
        test_num = 7;
        $display("\n[TEST %0d] Parity Error Detection Test", test_num);
        system_reset();

        // 发送带错误校验位的数据
        // 8'h55 = 0101_0101，偶校验应为0，我们故意发1
		fork
        begin
            logic [7:0] test_data = 8'h55;
            logic wrong_parity = 1'b1;  // 错误的校验位
            integer i;

            $display("[DRIVE] Sending data with wrong parity...");

            // 起始位
            rxd = 0;
            #(BIT_PERIOD_NS);

            // 数据位
            for (i = 0; i < 8; i = i + 1) begin
                rxd = test_data[i];
                #(BIT_PERIOD_NS);
            end

            // 错误的校验位
            rxd = wrong_parity;
            #(BIT_PERIOD_NS);

            // 停止位
            rxd = 1;
            #(BIT_PERIOD_NS);

            // 发送第二个字节（正确）完成帧
            send_char_to_dut(8'hAA);
        end
		
		begin
        @(posedge recv_vld);
        #(CLK_PERIOD);

        if (parity_err) begin
            $display("[PASS] Parity error detected correctly");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Parity error not detected");
            fail_count = fail_count + 1;
        end
		end
		join
        //-------------------------------------------------
        // 测试8：毛刺过滤测试（快速脉冲）
        //-------------------------------------------------
        test_num = 8;
        $display("\n[TEST %0d] Glitch Filtering Test", test_num);
        system_reset();

        // 发送一个窄脉冲（小于半个bit周期），应该被过滤
        rxd = 0;
        #(BIT_PERIOD_NS / 4);  // 短脉冲
        rxd = 1;
        #(BIT_PERIOD_NS);

        // 检查是否仍处于IDLE状态（没有开始接收）
        #(BIT_PERIOD_NS * 2);
        if (!recv_vld) begin
            $display("[PASS] Glitch filtered correctly");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Glitch caused false trigger");
            fail_count = fail_count + 1;
        end

        // 正常发送确保模块还能工作
        fork
            begin send_char_to_dut(8'h77); send_char_to_dut(8'h88); end
            begin wait_recv_and_check(16'h8877); end
        join

        //-------------------------------------------------
        // 测试9：连续发送测试（背靠背）
        //-------------------------------------------------
        test_num = 9;
        $display("\n[TEST %0d] Back-to-Back TX Test", test_num);
        system_reset();

        fork
            begin
                dut_send(16'h1111);
                dut_send(16'h2222);
                dut_send(16'h3333);
                dut_send(16'h4444);
            end
            begin
                // 监控TX输出
                repeat(4) begin
                    @(posedge send_done);
                    $display("[B2B] TX done at %0t", $time);
                end
            end
        join

        $display("[PASS] Back-to-back TX completed");
        pass_count = pass_count + 1;

        //-------------------------------------------------
        // 测试完成报告
        //-------------------------------------------------
        #(CLK_PERIOD * 100);
        test_num = 99;
        $display("\n==============================================");
        $display("           Test Summary");
        $display("==============================================");
        $display("Total Tests: %0d", pass_count + fail_count);
        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", fail_count);

        if (fail_count == 0)
            $display("\n*** ALL TESTS PASSED ***");
        else
            $display("\n*** SOME TESTS FAILED ***");

        $display("==============================================");

        $finish;
    end

    //===========================================================================
    // 超时保护
    //===========================================================================
    initial begin
        #(CLK_PERIOD * 1000_000);  // 10ms超时
        $display("[ERROR] Simulation timeout!");
        $display("Pass: %0d, Fail: %0d", pass_count, fail_count);
        $finish;
    end

    //===========================================================================
    // VCD波形转储
    //===========================================================================
    initial begin
        $dumpfile("tb_uart.vcd");
        $dumpvars(0, tb_uart);
    end

endmodule

