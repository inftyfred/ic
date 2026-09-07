`timescale 1ns/1ps

// ======================================================================
// tb_VL7_v2 —— [VL7] 求两个数的差值 (data_minus) 改进版自检查 TB
//
// DUT 规格：a/b 为 **无符号** 8bit，c(9bit) 在 posedge clk 打一拍输出
//   rst_n=0        -> c = 0（异步清零）
//   a > b          -> c = a - b
//   a <= b         -> c = b - a
//   即 c = |a - b|，取值域 [0,255] ⇒ **c[8] 恒为 0**
//
// 相对 tb_VL7.sv 的主要改进
//   1) 覆盖量：原 tb 只有 3 个向量（(5,6)(127,0)(125,127)），且 a/b 全部
//      < 128 —— 恰好避开本题最致命的边界。本版默认 **穷举 256x256=65536**
//      全部组合，另加定向角点 / 对称性 / 全速率流水 / 中途异步复位。
//   2) golden 用 9bit 有符号独立写法（先减后取绝对值），不复刻 RTL 的
//      "比较 + 两分支" 结构，避免与 RTL 犯同一个错。
//   3) 新增两条本题专属不变量：c[8] 必须为 0；|a-b| + min(a,b) == max(a,b)。
//   4) 新增对称性检查 c(a,b) == c(b,a)（抓 if 分支条件写反/漏 else）。
//   5) 复位全程可证：复位期间清 0、释放后保持 0、a/b 先给确定值再释放，
//      不会像原 tb 那样让 X 悄悄流进 DUT 再被覆盖掉。
//   6) 比对统一 4 态 === + $isunknown（原 `c_ == c` 遇到 X 会误判方向）；
//      golden 返回值由 2 态 bit 改 4 态 logic，X 不再被静默转成 0。
//   7) 函数加 automatic；调用全部按名连接，杜绝 VL6 那种形参位置错位。
//   8) 补看门狗、+SEED 可复现随机、覆盖率矩阵、PASS/FAIL 总结；
//      修掉原 `#100` 后漏分号（语法上被解析成 #100 $display(...)）。
//   9) 默认只打印失败（穷举时 65536 行日志不现实），+VERBOSE=1 逐笔打印。
//
// 本版（以及任何功能 tb）覆盖不到的，诚实声明：
//   * 输出端口"写窄一位"（reg [7:0] c）：仿真里抓不到 —— VCS 会把 actual 多出
//     的 c[8] 补 0（不是 Z），而本题 |a-b|<=255 本来就用不到第 9 位，功能上
//     完全正确。这类只能在编译期看：make compile ARGS="+lint=PCWM"，
//     否则它只是一条 Warning-[PCWM-W]（用 .c 隐式连接时会直接 Error-[IPCWM]）。
//   * a/b 端口上的 setup/hold 违例：需要门级/带 SDF 的时序仿真，行为级 tb 只能
//     通过 phase6 的 timing.hold 近似验证"输出不穿透"。
//
// 运行选项（plusarg）
//   +SEED=<n>        随机种子（复现失败用例）
//   +N_RANDOM=<n>    随机 burst 笔数（默认 500）
//   +NO_SWEEP=1      跳过穷举 65536（只跑定向 + 流水 + 随机，快速冒烟）
//   +VERBOSE=1       逐笔打印
//
// 注意：scripts/compile.sh 会自动收录 tb/ 下所有 *.sv|*.v。要把本版当默认
//       testbench，请把旧文件改名移出，例如
//       mv tb/tb_VL7.sv tb/tb_VL7.sv.bak
// ======================================================================

module tb_VL7_v2;

    // ------------------------------------------------------------------
    // 参数
    // ------------------------------------------------------------------
    localparam int CLK_PERIOD = 10;             // 10ns -> 100MHz
    localparam int RST_CYCLES = 3;              // 冷复位长度
    localparam int LAT        = 1;              // DUT 输出流水线深度
    localparam int N_RAND_DEF = 500;            // 随机 burst 默认笔数
    localparam int N_STREAM   = 300;            // 背靠背 stream 笔数
    localparam int WD_NS      = 300_000_000;    // 看门狗
    localparam int SETUP_SLACK = 200;           // 沿前驱动余量，单位 0.01ns

    // 无符号 8bit 边界角：0/1 与 127/128 交界（有符号误判必炸）、254/255
    localparam int   NCORN = 9;
    localparam logic [7:0] CORNER [0:NCORN-1] =
        '{8'd0, 8'd1, 8'd2, 8'd126, 8'd127, 8'd128, 8'd129, 8'd254, 8'd255};

    // ------------------------------------------------------------------
    // 接口信号
    // ------------------------------------------------------------------
    logic       clk;
    logic       rst_n;
    logic [7:0] a;
    logic [7:0] b;
    wire  [8:0] c;                              // DUT 输出接 net

    data_minus dut (
        .clk   (clk),
        .rst_n (rst_n),
        .a     (a),
        .b     (b),
        .c     (c)
    );

    // ------------------------------------------------------------------
    // 统计 / 覆盖率
    // ------------------------------------------------------------------
    int  total_cnt, pass_cnt, fail_cnt, x_cnt, txn_id;
    int  inv_viol, msb_viol;                    // 不变量违例细分
    int  n_random;
    int  no_sweep;                              // +NO_SWEEP=1 置位
    int  do_sweep;                              // 本 run 是否跑穷举
    bit  verbose;
    int  seed_v;

    int  cov_res  [0:4];                        // 结果分箱: 0/1-7/8-127/128-254/255
    int  cov_quad [0:3];                        // a,b 是否 >=128 的四象限
    int  cov_br   [0:2];                        // 分支: a>b / a<b / a==b
    int  cov_a    [0:255];
    int  cov_b    [0:255];

    typedef struct {
        logic [7:0] av;
        logic [7:0] bv;
    } txn_t;

    // ------------------------------------------------------------------
    // 时钟
    // ------------------------------------------------------------------
    initial begin : CLOCK
        clk = 1'b0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // ------------------------------------------------------------------
    // 看门狗
    // ------------------------------------------------------------------
    initial begin : WATCHDOG
        #WD_NS;
        $display("[FATAL] watchdog timeout @%0t (total=%0d) —— 仿真被强制结束",
                 $time, total_cnt);
        $display("TEST FAILED");
        $finish;
    end

    // ==================================================================
    // golden model —— 独立写法：9bit 有符号减法后取绝对值
    // 不复制 RTL 的 "if(a>b) ... else ..." 结构，避免同错
    // ==================================================================
    function automatic logic [8:0] golden(input logic [7:0] av,
                                          input logic [7:0] bv);
        logic signed [8:0] x, y, d;
        x = {1'b0, av};                         // 0..255 落在 9bit 有符号正半轴
        y = {1'b0, bv};
        d = x - y;                              // 范围 [-255,255]，不溢出
        if (d < 0) d = -d;
        return d;                               // 位型直接返回，无需类型转换
    endfunction

    // 结果分箱
    function automatic int res_bin(input logic [8:0] v);
        if (v == 0)     return 0;
        if (v < 8)      return 1;
        if (v < 128)    return 2;
        if (v < 255)    return 3;
        return 4;
    endfunction

    // ------------------------------------------------------------------
    // 一个检查点：golden 比对 + 本题专属不变量
    // ------------------------------------------------------------------
    task automatic chk(input string     tag,
                       input logic [7:0] av,
                       input logic [7:0] bv,
                       input logic [8:0] got);
        logic [8:0] exp, lo, hi, rec;
        exp = golden(av, bv);
        total_cnt++;

        cov_res[res_bin(exp)]++;
        cov_quad[{av[7], bv[7]}]++;
        cov_br[(av > bv) ? 0 : ((av < bv) ? 1 : 2)]++;
        cov_a[av]++;  cov_b[bv]++;

        if ($isunknown(got)) begin
            x_cnt++;  fail_cnt++;
            $display("[FAIL] %-13s a=%3d b=%3d got=X/Z exp=%3d @%0t",
                     tag, av, bv, exp, $time);
            return;
        end

        if (got === exp) pass_cnt++;
        else begin
            fail_cnt++;
            $display("[FAIL] %-13s a=%3d b=%3d got=%3d exp=%3d @%0t",
                     tag, av, bv, got, exp, $time);
        end
        if (verbose && !$isunknown(got))
            $display("[%4d] a=%3d b=%3d c=%3d%s", txn_id, av, bv, got,
                     (got === exp) ? " ok" : " BAD");

        // ---- 不变量 1：|a-b| 不会超过 255，故 c[8] 必须为 0 -------------
        if (got[8] === 1'b1) begin
            msb_viol++;  fail_cnt++;
            $display("[FAIL] %-13s c[8]=1 非法 a=%3d b=%3d got=%3d @%0t",
                     tag, av, bv, got, $time);
        end
        // ---- 不变量 2：差 + 小操作数 == 大操作数 ------------------------
        lo = (av < bv) ? av : bv;
        hi = (av < bv) ? bv : av;
        rec = {1'b0, lo} + got;
        if (rec !== {1'b0, hi}) begin
            inv_viol++;  fail_cnt++;
            $display("[FAIL] %-13s 不变量 |a-b|+min!=max a=%3d b=%3d got=%3d @%0t",
                     tag, av, bv, got, $time);
        end
    endtask

    // 独立数值检查点（复位清零 / 输出稳定性）
    task automatic chk_val(input string tag,
                           input logic [8:0] got,
                           input logic [8:0] exp);
        total_cnt++;
        if ($isunknown(got)) begin
            x_cnt++;  fail_cnt++;
            $display("[FAIL] %-13s got=X/Z @%0t", tag, $time);
        end else if (got === exp) begin
            pass_cnt++;
        end else begin
            fail_cnt++;
            $display("[FAIL] %-13s got=%0d exp=%0d @%0t", tag, got, exp, $time);
        end
    endtask

    // ------------------------------------------------------------------
    // 复位：异步置位 -> 保持 n 拍 -> 沿后安全释放
    // 原 tb 用 #10 对齐复位沿（撞上 negedge，靠运气），这里全部沿对齐
    // ------------------------------------------------------------------
    task automatic do_reset(input int n = RST_CYCLES, input bit cold = 1);
        rst_n  = 1'b0;                          // blocking：立即生效（异步）
        a      <= 8'd0;                         // 先给确定值，别让 X 流进 DUT
        b      <= 8'd0;
        repeat (n) @(posedge clk);
        #1;
        chk_val(cold ? "reset.async" : "reset.mid", c, '0);
        rst_n = 1'b1;                           // 沿后 #1 释放，避开恢复竞争
        @(posedge clk); #1;
        chk_val(cold ? "reset.release" : "reset.recover", c, '0);
    endtask

    // ------------------------------------------------------------------
    // 时序契约探针：证明 c 确实"打了一拍"，而不是组合直通
    // 在沿后 3ns 改输入、4ns 处立刻看输出：寄存器型必须纹丝不动，
    // 组合型会立刻跟上新值 —— 原 tb 每 2 拍才动一次输入，两种实现都能过。
    // ------------------------------------------------------------------
    task automatic check_registered();
        logic [8:0] hold;
        one(.av(8'd200), .bv(8'd37), .tag("reg.pre"), .stable(0));  // c = 163
        hold = c;
        @(posedge clk);
        #3;                                    // 沿后 3ns，仍在同一周期内
        a <= 8'd7;  b <= 8'd9;                 // 中途改激励
        #1;
        chk_val("timing.hold", c, hold);       // 输出不得跟随组合逻辑穿透
        @(posedge clk); #1;                    // 到下一个沿才更新
        chk("timing.update", 8'd7, 8'd9, c);
    endtask

    // ------------------------------------------------------------------
    // 异步复位专项探针：在两个时钟沿**之间**拉低 rst_n，不等下一个沿就必须
    // 看到 c 清零 —— 只有真异步复位（always @(posedge clk or negedge rst_n)）
    // 能过；写成同步复位就会被这里抓出来。原 tb 完全没有复位相关的检查。
    // 前置条件：注入前 c 必须非 0，否则该检查就是空判定。
    // ------------------------------------------------------------------
    task automatic async_probe(input int n = 2);
        logic [8:0] pre;
        one(.av(8'd200), .bv(8'd37), .tag("async.pre"), .stable(0));
        pre = c;                                   // 此刻位于沿后 1ns，值已稳定
        total_cnt++;
        if ((pre !== '0) && !$isunknown(pre)) pass_cnt++;
        else begin
            fail_cnt++;
            $display("[FAIL] async.pre    探针失效：注入前 c=%0d（应非 0）@%0t",
                     pre, $time);
        end
        rst_n = 1'b0;                              // 沿间置位，距下一沿还很远
        #1;
        chk_val("async.clear", c, '0);             // 必须靠异步复位清零
        repeat (n) @(posedge clk);
        #1;
        chk_val("async.hold", c, '0);              // 复位期间时钟沿不得改写
        rst_n = 1'b1;                              // 沿后释放，避开恢复竞争
        @(posedge clk); #1;                        // 出复位后第一个沿重新锁存
        chk_val("async.recover", c, pre);          // 必须恢复成同一激励的正常值
    endtask

    // ------------------------------------------------------------------
    // 单笔：驱动 -> 下一沿锁存 -> 沿后 #1 采样 -> 比对
    // stable=1 时额外检查周期中点输出未变化（寄存器输出必须稳定）
    // ------------------------------------------------------------------
    task automatic one(input logic [7:0] av,
                       input logic [7:0] bv,
                       input string      tag    = "txn",
                       input bit         stable = 1);
        logic [8:0] s_edge, s_mid;
        txn_id++;
        @(posedge clk);
        a <= av;  b <= bv;                      // NBA：下一沿才被 DUT 采到

        @(posedge clk); #1;                     // 本沿锁入，等 NBA 落地
        s_edge = c;
        chk(tag, av, bv, s_edge);

        if (stable) begin
            #(CLK_PERIOD / 2 - 1);              // 走到周期中点
            s_mid = c;
            txn_id++;
            chk_val($sformatf("%s.stable", tag), s_mid, s_edge);
        end
    endtask

    // ------------------------------------------------------------------
    // 沿前驱动变体：在时钟沿前 2ns 就把数据稳住，验证 DUT 确实在沿上锁存
    // 沿前值（抓锁存器化 / 双沿误触发）
    // ------------------------------------------------------------------
    task automatic one_setup(input logic [7:0] av, input logic [7:0] bv,
                             input string tag = "setup");
        txn_id++;
        @(posedge clk);
        #(CLK_PERIOD - 0.01 * SETUP_SLACK);     // 距下一沿 2ns
        a <= av;  b <= bv;
        @(posedge clk); #1;                     // 该沿锁存 -> 立即采样
        chk(tag, av, bv, c);
    endtask

    // ------------------------------------------------------------------
    // 对称性：c(a,b) 必须等于 c(b,a)
    // ------------------------------------------------------------------
    task automatic sym(input logic [7:0] av, input logic [7:0] bv);
        logic [8:0] c1, c2;
        txn_id += 2;
        @(posedge clk);  a <= av;  b <= bv;
        @(posedge clk); #1;  c1 = c;
        @(posedge clk);  a <= bv;  b <= av;
        @(posedge clk); #1;  c2 = c;
        chk("sym.forward", av, bv, c1);
        chk("sym.reverse", bv, av, c2);
        chk_val($sformatf("sym.equal(%0d,%0d)", av, bv), c1, c2);
    endtask

    // ------------------------------------------------------------------
    // 背靠背全速率 stream：每拍喂一笔，FIFO scoreboard 与流水深度对齐
    // ------------------------------------------------------------------
    task automatic stream(input int n, input string tag = "stream");
        txn_t q [$];
        txn_t t;
        for (int i = 0; i < n + LAT; i++) begin
            @(posedge clk);
            #1;
            if (q.size() > 0) begin             // 本沿采到的是上一拍的激励
                t = q.pop_front();
                txn_id++;
                chk($sformatf("%s[%0d]", tag, i), t.av, t.bv, c);
            end
            if (i < n) begin
                t.av = $urandom;                // int -> 8bit 截断
                t.bv = $urandom;
                a <= t.av;  b <= t.bv;
                q.push_back(t);
            end
        end
    endtask

    // ==================================================================
    // 主流程
    // ==================================================================
    initial begin : MAIN
        logic [7:0] av, bv;                     // 临时激励（避免位置传参错位）

        total_cnt = 0;  pass_cnt = 0;   fail_cnt = 0;
        x_cnt     = 0;  txn_id   = 0;
        inv_viol  = 0;  msb_viol = 0;
        n_random  = N_RAND_DEF;
        no_sweep  = 0;  do_sweep = 0;  verbose = 0;
        seed_v    = 1;

`ifdef FSDB
        $fsdbDumpfile("dump.fsdb");
        $fsdbDumpvars(0, tb_VL7_v2);
`endif

        void'($value$plusargs("SEED=%d",       seed_v));
        void'($value$plusargs("N_RANDOM=%d",   n_random));
        void'($value$plusargs("NO_SWEEP=%d",   no_sweep));
        do_sweep = (no_sweep == 0) ? 1 : 0;     // +NO_SWEEP=1 -> 跳过穷举
        verbose  = $test$plusargs("VERBOSE") ? 1 : 0;
        if (n_random <= 0) n_random = N_RAND_DEF;
        void'($urandom(seed_v));                // 固定种子，失败可复现

        $display("================================================================");
        $display(" tb_VL7_v2 : data_minus  c = |a - b|  (a,b unsigned 8bit)");
        $display(" clk=%0dns rst=%0dcyc lat=%0d | seed=%0d rnd=%0d stream=%0d",
                 CLK_PERIOD, RST_CYCLES, LAT, seed_v, n_random, N_STREAM);
        $display(" exhaustive 256x256 = %0s", do_sweep ? "ON" : "OFF");
        $display("================================================================");

        // ---- 1. 冷复位：复位期间与释放后输出必须为 0 ---------------------
        do_reset(RST_CYCLES, 1);

        // ---- 2. 原 tb 的 3 条定向用例（保留，验证等价意图）--------------
        $display("--- phase2: legacy vectors from tb_VL7.sv ---");
        one(.av(8'd5),   .bv(8'd6),   .tag("legacy1"));   // |5-6|   = 1
        one(.av(8'd127), .bv(8'd0),   .tag("legacy2"));   // |127-0| = 127
        one(.av(8'd125), .bv(8'd127), .tag("legacy3"));   // |125-127|= 2

        // ---- 3. 边界角点：127/128 交界是本题最容易翻车的地方 -------------
        $display("--- phase3: corner x corner (%0d txns) ---",
                 NCORN * NCORN);
        for (int i = 0; i < NCORN; i++)
            for (int j = 0; j < NCORN; j++)
                one(.av(CORNER[i]), .bv(CORNER[j]), .tag("corner"));

        // ---- 4. 单点极值：最大差、最小差、对角线 -------------------------
        $display("--- phase4: extreme difference ---");
        one(.av(8'd255), .bv(8'd0),   .tag("max_diff"));   // 255（用满 8bit）
        one(.av(8'd0),   .bv(8'd255), .tag("max_diff_r")); // 255（反向）
        one(.av(8'd128), .bv(8'd127), .tag("sign_edge"));  //   1
        one(.av(8'd127), .bv(8'd128), .tag("sign_edge_r")); //  1
        one(.av(8'd0),   .bv(8'd0),   .tag("zero"));       //   0
        one(.av(8'd255), .bv(8'd255), .tag("zero_max"));   //   0（对角线）
        one(.av(8'd1),   .bv(8'd0),   .tag("lsb"));        //   1
        one(.av(8'd0),   .bv(8'd1),   .tag("lsb_r"));      //   1

        // ---- 5. 对称性：交换 a/b 结果必须一致 ---------------------------
        $display("--- phase5: symmetry |a-b| == |b-a| ---");
        for (int i = 0; i < NCORN; i++)
            for (int j = 0; j < NCORN; j++)
                sym(CORNER[i], CORNER[j]);
        for (int i = 0; i < 40; i++) begin
            av = $urandom_range(255);
            bv = $urandom_range(255);
            sym(av, bv);
        end

        // ---- 6. 时序契约：打一拍 + 沿前驱动 -----------------------------
        $display("--- phase6: timing contract (1-clk latency, pre-edge) ---");
        check_registered();
        for (int i = 0; i < NCORN; i++) begin
            one_setup(CORNER[i], 8'd128, "setup_a");
            one_setup(8'd128, CORNER[i], "setup_b");
        end

        // ---- 7. 背靠背全速率 stream ------------------------------------
        $display("--- phase7: back-to-back stream (%0d txns, 1/clk) ---", N_STREAM);
        stream(N_STREAM, "stream");

        // ---- 8. 随机 burst（含中途异步复位注入）-------------------------
        $display("--- phase8: randomized burst (%0d txns) ---", n_random);
        for (int i = 0; i < n_random; i++) begin
            if (i > 0 && (i % 60) == 0) begin
                $display("--- 运行中注入异步复位 ---");
                async_probe(2);
            end
            av = $urandom;                      // int -> 8bit 截断
            bv = $urandom;
            one(.av(av), .bv(bv), .tag("rand"), .stable(0));
        end

        // ---- 9. 穷举 256 x 256 -----------------------------------------
        if (do_sweep) begin
            $display("--- phase9: exhaustive 65536 combinations ---");
            for (int i = 0; i < 256; i++) begin
                av = i[7:0];
                if ((i % 64) == 0)
                    $display("    sweep a=%0d ... (%0d checks so far)", i, total_cnt);
                for (int j = 0; j < 256; j++) begin
                    bv = j[7:0];
                    one(.av(av), .bv(bv), .tag("sweep"), .stable(0));
                end
            end
        end

        report();
    end

    // ------------------------------------------------------------------
    // 覆盖率 + 总结
    // ------------------------------------------------------------------
    task automatic report();
        int na, nb, hit;
        na = 0;  nb = 0;
        for (int i = 0; i < 256; i++) begin
            if (cov_a[i] > 0) na++;
            if (cov_b[i] > 0) nb++;
        end
        hit = 0;
        for (int i = 0; i < 5; i++) if (cov_res[i]  > 0) hit++;
        for (int i = 0; i < 4; i++) if (cov_quad[i] > 0) hit++;
        for (int i = 0; i < 3; i++) if (cov_br[i]   > 0) hit++;

        $display("");
        $display("---------------- functional coverage ----------------");
        $display("  result bins   =0:%0d  1-7:%0d  8-127:%0d  128-254:%0d  ==255:%0d",
                 cov_res[0], cov_res[1], cov_res[2], cov_res[3], cov_res[4]);
        $display("  a/b quadrant  lo-lo:%0d  lo-hi:%0d  hi-lo:%0d  hi-hi:%0d",
                 cov_quad[0], cov_quad[1], cov_quad[2], cov_quad[3]);
        $display("  branch        a>b:%0d  a<b:%0d  a==b:%0d",
                 cov_br[0], cov_br[1], cov_br[2]);
        $display("  operand values hit: a=%0d/256  b=%0d/256", na, nb);
        $display("  bins covered: %0d/12%s", hit, (hit == 12) ? " (full)" : " (GAP!)");
        for (int i = 0; i < 4; i++)
            if (cov_quad[i] == 0)
                $display("  [WARN] 象限 %0d 未覆盖：a/b 越过 128 的场景缺失", i);

        $display("");
        $display("############################################################");
        $display("# FINAL REPORT | total=%0d pass=%0d fail=%0d x/z=%0d",
                 total_cnt, pass_cnt, fail_cnt, x_cnt);
        $display("#   其中不变量违例: c[8]!=0 -> %0d   差+min!=max -> %0d",
                 msb_viol, inv_viol);
        $display("############################################################");
        if (fail_cnt == 0) begin
            $display("TEST PASSED");
            $display("Simulation Finished Successfully");
        end else begin
            $display("TEST FAILED  (%0d 处不一致, 用 +SEED=%0d 可复现)",
                     fail_cnt, seed_v);
        end
        $finish;
    endtask

endmodule
