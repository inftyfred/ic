`timescale 1ns/1ps

// ======================================================================
// tb_VL6_v2 —— [VL6] 多功能数据处理器 (data_select) 改进版自检查 TB
//
// DUT 规格：c(9bit signed) 在 posedge clk 打一拍输出
//   select=00 -> a   01 -> b   10 -> a+b   11 -> a-b      rst_n=0 -> c=0
//   a/b 为 8bit signed，结果落在 [-256,255]，必须用满 9bit
//
// 相对 tb_VL6.sv 的主要改进
//   1) 【修 bug】原 input_check 声明顺序是 (a_,b_,sel)，调用却按 (sel,a_,b_)
//      传参，形参位置错位：select 实际取的是第三个实参的低 2bit
//      （例 input_check(2'b00,12,13) 真正驱动的是 sel=01,a=0,b=12）。
//      参考模型用的也是错位后的值，所以永远"pass"——测试意图全部落空。
//      现全部改为**按名连接**，彻底消除位置错位的风险。
//   2) 【修 bug】get_expect 的加减分支引用的是模块级信号 a/b（DUT 输入），
//      而不是自己的形参，参考模型与被测对象共享数据源。现 golden 只用入参。
//   3) 输出端口接 `wire` 而非 `reg`；比对统一用 4 态 `===`，加 $isunknown 检查。
//   4) 采样时刻显式对齐：驱动用 NBA，沿后 #1 再采样，避开 Active/NBA 竞争。
//   5) 新增相位：冷复位清零 → 释放 → 定向边界角 → select 切换 → 非复位毛刺
//      → 全流水线背靠背 stream → 随机 burst → 运行中异步复位 → 可选全遍历。
//   6) 补边界数据（±128/±127、需借第 9 位的和差）、X/Z 检查、输出稳定性检查。
//   7) 看门狗 + 可复现随机（+SEED）+ 功能覆盖率矩阵 + PASS/FAIL 总结。
//
// 运行选项（plusarg）
//   +SEED=<n>        随机种子（复现失败用例）
//   +N_RANDOM=<n>    随机 burst 笔数（默认 300）
//   +VERBOSE=1       逐笔打印
//   +FULL_SWEEP=1    穷举 4*256*256=262144 组合（约 5ms 仿真时间）
//
// 注意：scripts/compile.sh 会自动收录 tb/ 下所有 *.sv|*.v。要把本版当默认
//       testbench，请把旧文件改名移出，例如
//       mv tb/tb_VL6.sv tb/tb_VL6.sv.bak
// ======================================================================

module tb_VL6_v2;

    // ------------------------------------------------------------------
    // 参数
    // ------------------------------------------------------------------
    localparam int CLK_PERIOD    = 10;          // 10ns -> 100MHz
    localparam int RST_CYCLES    = 3;           // 冷复位长度
    localparam int LAT           = 1;           // DUT 输出流水线深度（打一拍）
    localparam int N_RAND_DEF    = 300;         // 随机 burst 默认笔数
    localparam int N_STREAM      = 200;         // 背靠背 stream 笔数
    localparam int WD_NS         = 200_000_000; // 看门狗，覆盖全遍历场景

    // 8bit signed 边界角：最小/最大、±1、以及会产生进位借位的组合
    localparam int   NCORN       = 8;
    localparam logic signed [7:0] CORNER [0:NCORN-1] =
        '{-128, -127, -16, -1, 0, 1, 126, 127};

    // ------------------------------------------------------------------
    // 接口信号
    // ------------------------------------------------------------------
    logic              clk;
    logic              rst_n;
    logic signed [7:0] a;
    logic signed [7:0] b;
    logic [1:0]        select;
    wire  signed [8:0] c;                       // DUT 输出接 net

    data_select dut (
        .clk    (clk),
        .rst_n  (rst_n),
        .a      (a),
        .b      (b),
        .select (select),
        .c      (c)
    );

    // ------------------------------------------------------------------
    // 统计 / 覆盖率
    // ------------------------------------------------------------------
    int   total_cnt, pass_cnt, fail_cnt, x_cnt, txn_id;
    int   n_random;
    int   full_sweep;
    bit   verbose;
    int   seed_v;

    int   cov_op   [0:3];                       // 每种运算命中次数
    int   cov_sign [0:3][0:2];                  // 运算 x 结果符号(负/零/正)
    int   cov_ext  [0:3];                       // 结果超出 8bit（用到第 9 位）
    int   cov_a    [0:255];                     // 操作数 a 取值分布
    int   cov_b    [0:255];                     // 操作数 b 取值分布

    typedef struct {
        bit [1:0]          sel;
        logic signed [7:0] ae;
        logic signed [7:0] be;
    } txn_t;

    // ------------------------------------------------------------------
    // 时钟
    // ------------------------------------------------------------------
    initial begin : CLOCK
        clk = 1'b0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // ------------------------------------------------------------------
    // 看门狗：防止 scoreboard 挂死导致仿真永不结束
    // ------------------------------------------------------------------
    initial begin : WATCHDOG
        #WD_NS;
        $display("[FATAL] watchdog timeout @%0t (total=%0d) —— 仿真被强制结束",
                 $time, total_cnt);
        $display("TEST FAILED");
        $finish;
    end

    // ==================================================================
    // golden model —— 只依赖入参，绝不引用 DUT 侧信号
    // ==================================================================
    function automatic logic signed [8:0] golden(input bit [1:0] sel,
                                                 input logic signed [7:0] ae,
                                                 input logic signed [7:0] be);
        logic signed [8:0] x, y;
        x = ae;                                  // 8 -> 9bit 符号扩展
        y = be;
        case (sel)
            2'b00   : return x;
            2'b01   : return y;
            2'b10   : return x + y;
            2'b11   : return x - y;
            default : return '0;
        endcase
    endfunction

    // 结果符号分箱
    function automatic int sgn_idx(input logic signed [8:0] v);
        if ($isunknown(v)) return 1;             // 归入 zero 箱，另有 X 检查
        if (v < 0)         return 0;
        if (v == 0)        return 1;
        return 2;
    endfunction

    // ------------------------------------------------------------------
    // 比对一个检查点（静默通过，失败打印细节）
    // ------------------------------------------------------------------
    task automatic chk(input string           tag,
                       input bit [1:0]        sel,
                       input logic signed [7:0] ae,
                       input logic signed [7:0] be,
                       input logic signed [8:0] got);
        logic signed [8:0] exp;
        bit [7:0]          ua, ub;
        exp = golden(sel, ae, be);

        total_cnt++;
        cov_op[sel]++;
        cov_sign[sel][sgn_idx(exp)]++;
        if (exp > 9'sd127 || exp < -9'sd128) cov_ext[sel]++;
        ua = ae;  ub = be;
        cov_a[ua]++;  cov_b[ub]++;

        if ($isunknown(got)) begin
            x_cnt++;
            fail_cnt++;
            $display("[FAIL] %-14s sel=%02b a=%4d b=%4d got=X/Z exp=%5d @%0t",
                     tag, sel, ae, be, exp, $time);
            return;
        end

        if (got === exp) begin
            pass_cnt++;
            if (verbose)
                $display("[%4d] sel=%02b a=%4d b=%4d c=%5d ok",
                         txn_id, sel, ae, be, exp);
        end else begin
            fail_cnt++;
            $display("[FAIL] %-14s sel=%02b a=%4d b=%4d got=%5d exp=%5d @%0t",
                     tag, sel, ae, be, got, exp, $time);
        end
    endtask

    // 独立检查点：只看数值本身（复位清零 / 稳定性）
    task automatic chk_val(input string            tag,
                           input logic signed [8:0] got,
                           input logic signed [8:0] exp);
        total_cnt++;
        if ($isunknown(got)) begin
            x_cnt++;  fail_cnt++;
            $display("[FAIL] %-14s got=X/Z @%0t", tag, $time);
        end else if (got === exp) begin
            pass_cnt++;
        end else begin
            fail_cnt++;
            $display("[FAIL] %-14s got=%0d exp=%0d @%0t", tag, got, exp, $time);
        end
    endtask

    // ------------------------------------------------------------------
    // 复位：异步置位 -> 保持 n 拍 -> 沿后安全释放
    // ------------------------------------------------------------------
    task automatic do_reset(input int n = RST_CYCLES, input bit cold = 1);
        rst_n    = 1'b0;                        // blocking：立即生效（异步复位）
        select   <= 2'b00;
        a        <= '0;
        b        <= '0;
        repeat (n) @(posedge clk);
        #1;
        chk_val(cold ? "reset.async" : "reset.mid", c, '0);
        rst_n = 1'b1;                           // 在沿后 #1 释放，避免恢复时间竞争
        @(posedge clk); #1;
        chk_val(cold ? "reset.release" : "reset.recover", c, '0);
    endtask

    // ------------------------------------------------------------------
    // 单笔：驱动 -> 下一沿 DUT 锁存 -> 沿后 #1 采样 -> 比对
    // stable=1 时额外检查周期中点输出未变化（寄存器输出必须稳定）
    // ------------------------------------------------------------------
    task automatic one(input bit [1:0]           sel,
                       input logic signed [7:0]  ae,
                       input logic signed [7:0]  be,
                       input string              tag    = "txn",
                       input bit                 stable = 1);
        logic signed [8:0] s_edge, s_mid;
        txn_id++;
        @(posedge clk);
        select <= sel;  a <= ae;  b <= be;

        @(posedge clk); #1;                     // 本沿锁入，NBA 落地后取值
        s_edge = c;
        chk(tag, sel, ae, be, s_edge);

        if (stable) begin
            #(CLK_PERIOD / 2 - 1);              // 走到周期中点
            s_mid = c;
            txn_id++;
            chk_val($sformatf("%s.stable", tag), s_mid, s_edge);
        end
    endtask

    // ------------------------------------------------------------------
    // 背靠背 stream：每拍喂一笔，验证全速率吞吐（无气泡也不串数据）
    // scoreboard 用 FIFO 与流水线深度对齐
    // ------------------------------------------------------------------
    task automatic stream(input int n, input string tag = "stream");
        txn_t q [$];
        txn_t t;
        for (int i = 0; i < n + LAT; i++) begin
            @(posedge clk);
            #1;
            if (q.size() > 0) begin             // 本沿采到的是上一拍驱动的激励
                t = q.pop_front();
                txn_id++;
                chk($sformatf("%s[%0d]", tag, i), t.sel, t.ae, t.be, c);
            end
            if (i < n) begin
                t.sel = $urandom_range(3);      // int -> bit[1:0] 取低 2bit
                t.ae  = $urandom;               // int -> 8bit 截断，含符号位
                t.be  = $urandom;
                select <= t.sel;  a <= t.ae;  b <= t.be;
                q.push_back(t);
            end
        end
    endtask

    // ==================================================================
    // 主流程
    // ==================================================================
    initial begin : MAIN
        bit [1:0]           sl;                 // 临时激励，避免位置传参错位
        logic signed [7:0]  av, bv;

        total_cnt  = 0;   pass_cnt = 0;  fail_cnt = 0;
        x_cnt      = 0;   txn_id   = 0;
        n_random   = N_RAND_DEF;
        full_sweep = 0;   verbose  = 0;
        seed_v     = 1;

`ifdef FSDB
        $fsdbDumpfile("dump.fsdb");
        $fsdbDumpvars(0, tb_VL6_v2);
`endif

        void'($value$plusargs("SEED=%d",      seed_v));
        void'($value$plusargs("N_RANDOM=%d",  n_random));
        void'($value$plusargs("FULL_SWEEP=%d", full_sweep));
        verbose = $test$plusargs("VERBOSE") ? 1 : 0;
        if (n_random <= 0) n_random = N_RAND_DEF;
        void'($urandom(seed_v));               // 固定种子，失败可复现

        $display("================================================================");
        $display(" tb_VL6_v2 : data_select  c = sel(a | b | a+b | a-b)");
        $display(" clk=%0dns rst=%0d cyc lat=%0d | seed=%0d rnd=%0d stream=%0d",
                 CLK_PERIOD, RST_CYCLES, LAT, seed_v, n_random, N_STREAM);
        $display(" full_sweep=%0d verbose=%0d", full_sweep, verbose);
        $display("================================================================");

        // ---- 1. 冷复位：复位期间与释放后输出必须为 0 ---------------------
        do_reset(RST_CYCLES, 1);

        // ---- 2. 定向角点：边界操作数 x 全部 select -----------------------
        $display("--- phase2: corner x select (%0d txns) ---",
                 NCORN * NCORN * 4);
        for (int s = 0; s < 4; s++) begin
            sl = s[1:0];
            for (int i = 0; i < NCORN; i++)
                for (int j = 0; j < NCORN; j++)
                    one(.sel(sl), .ae(CORNER[i]), .be(CORNER[j]), .tag("corner"));
        end

        // ---- 3. 关键算术边界：必须借第 9 位的和/差 -----------------------
        $display("--- phase3: 9bit extension cases ---");
        one(.sel(2'b10), .ae(-8'sd128), .be(-8'sd128), .tag("min+min"));   // -256
        one(.sel(2'b10), .ae( 8'sd127), .be( 8'sd127), .tag("max+max"));   //  254
        one(.sel(2'b11), .ae( 8'sd127), .be(-8'sd128), .tag("max-min"));   //  255
        one(.sel(2'b11), .ae(-8'sd128), .be( 8'sd127), .tag("min-max"));   // -255
        one(.sel(2'b11), .ae(-8'sd128), .be(-8'sd128), .tag("sub.eq"));    //    0
        one(.sel(2'b10), .ae( 8'sd127), .be(-8'sd127), .tag("cancel"));    //    0
        one(.sel(2'b00), .ae(-8'sd128), .be( 8'sd127), .tag("sext.a"));    // -128
        one(.sel(2'b01), .ae( 8'sd127), .be(-8'sd128), .tag("sext.b"));    // -128

        // ---- 4. 操作数固定、只切 select：验证四路 mux 互不干扰 -----------
        $display("--- phase4: select sweep @ a=-100 b=37 ---");
        for (int r = 0; r < 3; r++)
            for (int s = 0; s < 4; s++) begin
                sl = s[1:0];
                one(.sel(sl), .ae(-8'sd100), .be(8'sd37), .tag("sel_sweep"));
            end

        // ---- 5. 只切操作数、select 不动：验证运算通路 --------------------
        $display("--- phase5: operand sweep @ select held ---");
        for (int s = 0; s < 4; s++) begin
            sl = s[1:0];
            for (int i = 0; i < NCORN; i++)
                one(.sel(sl), .ae(CORNER[i]), .be(8'sd5), .tag("op_a"), .stable(0));
            for (int i = 0; i < NCORN; i++)
                one(.sel(sl), .ae(8'sd5), .be(CORNER[i]), .tag("op_b"), .stable(0));
        end

        // ---- 6. 背靠背全速率 stream -------------------------------------
        $display("--- phase6: back-to-back stream (%0d txns, 1/clk) ---", N_STREAM);
        stream(N_STREAM, "stream");

        // ---- 7. 随机 burst ----------------------------------------------
        $display("--- phase7: randomized burst (%0d txns) ---", n_random);
        for (int i = 0; i < n_random; i++) begin
            if (i > 0 && (i % 60) == 0) begin
                $display("--- 运行中插入异步复位 ---");
                do_reset(2, 0);                 // 中途复位 + 恢复检查
            end
            sl = $urandom_range(3);
            av = $urandom;                      // 截断到 8bit，含随机符号位
            bv = $urandom;
            one(.sel(sl), .ae(av), .be(bv), .tag("rand"), .stable(0));
        end

        // ---- 8. 可选全遍历 ----------------------------------------------
        if (full_sweep) begin
            $display("--- phase8: exhaustive 4 x 256 x 256 ---");
            for (int s = 0; s < 4; s++) begin
                sl = s[1:0];
                for (int i = 0; i < 256; i++) begin
                    av = i[7:0];
                    for (int j = 0; j < 256; j++) begin
                        bv = j[7:0];
                        one(.sel(sl), .ae(av), .be(bv), .tag("sweep"), .stable(0));
                    end
                end
            end
        end

        // ---- 报告 --------------------------------------------------------
        report();
    end

    // ------------------------------------------------------------------
    // 覆盖率 + 总结
    // ------------------------------------------------------------------
    task automatic report();
        int na, nb, hit;
        string opname [0:3];
        opname[0] = "a";  opname[1] = "b";  opname[2] = "a+b";  opname[3] = "a-b";

        for (int i = 0; i < 256; i++) begin
            if (cov_a[i] > 0) na++;
            if (cov_b[i] > 0) nb++;
        end

        $display("");
        $display("---------------- functional coverage ----------------");
        $display("  op      count   neg   zero    pos   >8bit");
        for (int s = 0; s < 4; s++)
            $display("  %4s  %7d  %5d  %5d  %5d  %6d",
                     opname[s], cov_op[s], cov_sign[s][0], cov_sign[s][1],
                     cov_sign[s][2], cov_ext[s]);
        $display("  operand values hit: a=%0d/256  b=%0d/256", na, nb);
        hit = 0;
        for (int s = 0; s < 4; s++)
            for (int k = 0; k < 3; k++)
                if (cov_sign[s][k] > 0) hit++;
        $display("  op x sign bins covered: %0d/12%s", hit,
                 (hit == 12) ? " (full)" : " (GAP!)");
        for (int s = 0; s < 4; s++)
            if ((s >= 2) && (cov_ext[s] == 0))   // 只有加减通路才需要第 9 位
                $display("  [WARN] op %s 未覆盖到需要第 9 位的结果", opname[s]);

        $display("");
        $display("############################################################");
        $display("# FINAL REPORT | total=%0d pass=%0d fail=%0d x/z=%0d",
                 total_cnt, pass_cnt, fail_cnt, x_cnt);
        $display("############################################################");
        if (fail_cnt == 0) begin
            $display("TEST PASSED");
            $display("Simulation Finished Successfully");
        end else begin
            $display("TEST FAILED  (%0d 处不一致, 种子 +SEED=%0d 可复现)",
                     fail_cnt, seed_v);
        end
        $finish;
    endtask

endmodule
