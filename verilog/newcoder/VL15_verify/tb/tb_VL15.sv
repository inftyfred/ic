`timescale 1ns/1ps

// ======================================================================
// tb_VL15 —— [VL15] 优先编码器Ⅰ (encoder_83) 自检查 testbench
//
// DUT 规格（纯组合逻辑，无时钟、无复位）：
//   EI=0            -> {Y,GS,EO} = {3'b000, 0, 0}   编码器未使能，输出全 0
//   EI=1, I=8'h00   -> {Y,GS,EO} = {3'b000, 0, 1}   使能但无请求（EO 供级联）
//   EI=1, I!=8'h00  -> {Y,GS,EO} = {最高请求位编号, 1, 0}
//       优先级 I[7] > I[6] > ... > I[0]，Y 为请求位编号
//       （如仅 I[5] 请求 -> Y=3'b101；仅 I[0] 请求 -> Y=3'b001）
//
// 验证策略（组合 DUT，不设时钟）：
//   phase1  定向：题面真值表 10 行逐行核对 + 8 个单热点 + 边界向量
//   phase2  穷举：{EI, I} 全部 2 x 256 = 512 组合逐点比对
//   phase3  稳定性：输入保持不变时多点采样，输出必须恒定（防振荡）
//   phase4  随机：输入快速连续变化压力（含 EI 翻转），每次变化后比对
//   phase5  X 注入冒烟：casez 对 X 的行为题面未定义，只观察不判分
//
// golden 模型刻意不复刻 RTL 的 casez 优先级结构：
//   用“从低到高扫描、后写覆盖”的循环求最高请求位，避免与 RTL 同错；
//   另配三条与 golden 无关的不变量交叉验证：
//     inv1  GS == EI & |I                （GS 的独立定义）
//     inv2  EO == EI & ~|I               （EO 的独立定义）
//     inv3  GS=1 时 I[Y] 必须为 1，且所有高于 Y 的位必须为 0
//           （编码值真实有效 + 优先级无遗漏，双保险）
//
// 判定全部用 4 态 === / !== + $isunknown；默认只打印失败，
// +VERBOSE=1 逐笔打印；失败向量在总结里去重列出，便于直接定位。
//
// 运行选项（plusarg）：
//   +SEED=<n>       随机种子（复现失败用例，默认 1）
//   +N_RANDOM=<n>   phase4 随机笔数（默认 1000）
//   +VERBOSE=1      逐笔打印
//
// 波形：编译带 +define+FSDB 时自动 dump；优先识别 run.sh 传入的
//       +fsdbfile=（无则写 dump.fsdb），保证 scripts/verdi.sh 能在
//       fsdb_wave/ 下找到波形文件。
//
// 本 TB 覆盖不到的，诚实声明：
//   * 输入到输出的门级传输延迟 / 毛刺的物理时序 —— 需要门级网表仿真；
//     本 TB 用 1ns 稳定窗，只能验证功能与零延迟语义下的稳定。
//   * X 输入下的输出值：casez 表达式含 X 时落入 default，行为题面未
//     定义，phase5 只观察不判分。
//   * 输出端口位宽写窄这类编译期问题：功能仿真抓不到，应看编译 lint。
// ======================================================================

module tb_VL15;

    // ------------------------------------------------------------------
    // 参数
    // ------------------------------------------------------------------
    localparam int SETTLE_NS  = 1;           // 组合逻辑稳定等待
    localparam int N_RAND_DEF = 1000;        // 随机压力默认笔数
    localparam int N_STAB     = 8;           // 稳定性检查采样点数
    localparam int WD_NS      = 1_000_000;   // 看门狗（组合 DUT 远用不到）

    // ------------------------------------------------------------------
    // 接口信号
    // ------------------------------------------------------------------
    logic       EI;
    logic [7:0] I;
    wire  [2:0] Y;
    wire        GS, EO;

    encoder_83 dut (
        .I  (I),
        .EI (EI),
        .Y  (Y),
        .GS (GS),
        .EO (EO)
    );

    // ------------------------------------------------------------------
    // 统计 / 覆盖率
    // ------------------------------------------------------------------
    int  total_cnt, pass_cnt, fail_cnt, x_cnt, txn_id;
    int  gs_viol, eo_viol, enc_viol;         // 不变量违例细分
    int  n_random, seed_v, rng;
    bit  verbose;
    bit  seen_fail [0:511];                  // {EI,I} 9bit 索引 -> 失败向量去重
    int  cov_row   [0:9];                    // 题面真值表 10 行分箱
    int  cov_y     [0:7];                    // Y 编号分箱
    int  cov_ei    [0:1];
    int  cov_gs, cov_eo;

    // ------------------------------------------------------------------
    // 看门狗
    // ------------------------------------------------------------------
    initial begin : WATCHDOG
        #WD_NS;
        $display("[FATAL] watchdog timeout @%0t —— 仿真被强制结束", $time);
        $display("TEST FAILED");
        $finish;
    end

    // ==================================================================
    // golden 模型 —— 独立实现：从低到高扫描、后写覆盖 => 最高请求位胜出
    // 不复制 RTL 的 casez 结构，避免与 RTL 犯同一个错
    // ==================================================================
    function automatic logic [4:0] golden(input logic       ei_,
                                          input logic [7:0] i_);
        logic [2:0] y_;
        logic       gs_, eo_;
        y_ = 3'b000;
        if (!ei_) begin
            gs_ = 1'b0;  eo_ = 1'b0;                      // 未使能
        end else if (i_ == 8'h00) begin
            gs_ = 1'b0;  eo_ = 1'b1;                      // 使能无请求
        end else begin
            gs_ = 1'b1;  eo_ = 1'b0;
            for (int k = 0; k < 8; k++)
                if (i_[k]) y_ = k;                        // 后写覆盖 -> 最高位编号
        end
        return {y_, gs_, eo_};         // 5bit: [4:2]=Y, [1]=GS, [0]=EO
    endfunction

    // 题面真值表行号分箱：1=EI=0 行，2=使能无请求行，3..10=最高请求位 7..0
    function automatic int spec_row(input logic       ei_,
                                    input logic [7:0] i_);
        if (!ei_)        return 0;
        if (i_ == 8'h00) return 1;
        for (int k = 7; k >= 0; k--)
            if (i_[k]) return 2 + (7 - k);
        return 1;                                        // 不可达
    endfunction

    // 失败向量去重记录
    task automatic note_fail(input logic ei_, input logic [7:0] i_);
        seen_fail[{ei_, i_}] = 1'b1;
    endtask

    // ------------------------------------------------------------------
    // 检查点：golden 比对 + 三条独立不变量
    // ------------------------------------------------------------------
    task automatic chk(input string      tag,
                       input logic       ei_,
                       input logic [7:0] i_);
        logic [4:0] exp, got;    // {Y,GS,EO} 恰为 5bit，双方同宽同位序
        logic [2:0] yv;

        total_cnt++;  txn_id++;
        cov_ei[ei_]++;
        cov_row[spec_row(ei_, i_)]++;

        got = {Y, GS, EO};
        exp = golden(ei_, i_);

        if (!$isunknown(got)) begin
            cov_y[got[4:2]]++;
            if (got[1]) cov_gs++;
            if (got[0]) cov_eo++;
        end

        if ($isunknown(got)) begin
            x_cnt++;  fail_cnt++;  note_fail(ei_, i_);
            $display("[FAIL] %-14s EI=%b I=8'h%02h 输出含 X/Z: {Y,GS,EO}=%b @%0t",
                     tag, ei_, i_, got, $time);
            return;
        end

        if (got === exp) begin
            pass_cnt++;
            if (verbose)
                $display("[%4d] %-14s EI=%b I=8'h%02h -> Y=%b GS=%b EO=%b ok",
                         txn_id, tag, ei_, i_, got[4:2], got[1], got[0]);
        end else begin
            fail_cnt++;  note_fail(ei_, i_);
            $display("[FAIL] %-14s EI=%b I=8'h%02h got={Y=%b,GS=%b,EO=%b} 期望={Y=%b,GS=%b,EO=%b} @%0t",
                     tag, ei_, i_, got[4:2], got[1], got[0],
                     exp[4:2], exp[1], exp[0], $time);
        end

        // ---- inv1: GS == EI & |I ---------------------------------------
        if (got[1] !== (ei_ & (|i_))) begin
            gs_viol++;  fail_cnt++;  note_fail(ei_, i_);
            $display("[FAIL] %-14s inv1 GS违例 EI=%b I=8'h%02h GS=%b @%0t",
                     tag, ei_, i_, got[1], $time);
        end
        // ---- inv2: EO == EI & ~|I --------------------------------------
        if (got[0] !== (ei_ & (~|i_))) begin
            eo_viol++;  fail_cnt++;  note_fail(ei_, i_);
            $display("[FAIL] %-14s inv2 EO违例 EI=%b I=8'h%02h EO=%b @%0t",
                     tag, ei_, i_, got[0], $time);
        end
        // ---- inv3: GS=1 -> I[Y]=1 且更高位全 0 --------------------------
        if (got[1] === 1'b1) begin
            yv = got[4:2];
            if (i_[yv] !== 1'b1) begin
                enc_viol++;  fail_cnt++;  note_fail(ei_, i_);
                $display("[FAIL] %-14s inv3 编码值无效 I[Y=%0d]=%b EI=%b I=8'h%02h @%0t",
                         tag, yv, i_[yv], ei_, i_, $time);
            end
            for (int k = 7; k > yv; k--) begin
                if (i_[k] !== 1'b0) begin
                    enc_viol++;  fail_cnt++;  note_fail(ei_, i_);
                    $display("[FAIL] %-14s inv3 优先级遗漏 I[%0d]=1 但 Y=%0d EI=%b I=8'h%02h @%0t",
                             tag, k, yv, ei_, i_, $time);
                end
            end
        end
    endtask

    // 单笔：驱动 -> 稳定 -> 比对
    task automatic drive_chk(input logic       ei_,
                             input logic [7:0] i_,
                             input string      tag);
        EI = ei_;
        I  = i_;
        #(SETTLE_NS);
        chk(tag, ei_, i_);
    endtask

    // ------------------------------------------------------------------
    // 稳定性：输入保持不变，多个不均匀时间点采样，输出必须恒定
    // ------------------------------------------------------------------
    task automatic stability(input logic ei_, input logic [7:0] i_);
        logic [4:0] first, cur;
        drive_chk(ei_, i_, "stab.first");
        first = {Y, GS, EO};
        for (int s = 1; s <= N_STAB; s++) begin
            #(1 + s);                                // 不均匀间隔
            cur = {Y, GS, EO};
            total_cnt++;
            if (cur === first) begin
                pass_cnt++;
            end else begin
                fail_cnt++;  note_fail(ei_, i_);
                $display("[FAIL] stab.osc      EI=%b I=8'h%02h 输出振荡 %b -> %b @%0t",
                         ei_, i_, first, cur, $time);
            end
        end
    endtask

    // ------------------------------------------------------------------
    // X 注入冒烟：只观察，不做语义判定（casez 对 X 的行为题面未定义）
    // ------------------------------------------------------------------
    task automatic x_smoke();
        $display("--- phase5: X 注入冒烟（只观察不判分）---");
        EI = 1'b1;  I = 8'hxx;         #SETTLE_NS;
        $display("[info] EI=1 I=8'hxx        -> {Y,GS,EO}=%b", {Y, GS, EO});
        EI = 1'b1;  I = 8'b1010_xx01;  #SETTLE_NS;
        $display("[info] EI=1 I=8'b1010_xx01 -> {Y,GS,EO}=%b", {Y, GS, EO});
        EI = 1'bx;  I = 8'hA5;         #SETTLE_NS;
        $display("[info] EI=x I=8'hA5        -> {Y,GS,EO}=%b", {Y, GS, EO});
        EI = 1'b1;  I = 8'h00;         #SETTLE_NS;   // 恢复已知状态
    endtask

    // ==================================================================
    // 主流程
    // ==================================================================
    initial begin : MAIN
        logic [7:0] vi;
        logic       ve;

        total_cnt = 0;  pass_cnt = 0;  fail_cnt = 0;  x_cnt = 0;  txn_id = 0;
        gs_viol = 0;  eo_viol = 0;  enc_viol = 0;
        cov_gs = 0;  cov_eo = 0;
        n_random = N_RAND_DEF;  seed_v = 1;  verbose = 0;
        for (int s = 0; s < 512; s++) seen_fail[s] = 1'b0;
        for (int s = 0; s < 10;  s++) cov_row[s]  = 0;
        for (int s = 0; s < 8;   s++) cov_y[s]    = 0;
        cov_ei[0] = 0;  cov_ei[1] = 0;

`ifdef FSDB
        begin
            string fsdb_path;
            if ($value$plusargs("fsdbfile=%s", fsdb_path))
                $fsdbDumpfile(fsdb_path);
            else
                $fsdbDumpfile("dump.fsdb");
            $fsdbDumpvars(0, tb_VL15);
        end
`endif

        if (!$value$plusargs("SEED=%d",     seed_v))   seed_v   = 1;
        if (!$value$plusargs("N_RANDOM=%d", n_random)) n_random = N_RAND_DEF;
        verbose = $test$plusargs("VERBOSE");
        if (n_random <= 0) n_random = N_RAND_DEF;
        rng = $urandom(seed_v);                        // 固定种子，失败可复现

        $display("================================================================");
        $display(" tb_VL15 : encoder_83 8-3 优先编码器Ⅰ（纯组合）");
        $display(" EI=0 -> {Y,GS,EO}={000,0,0} | EI=1,I=00 -> {000,0,1}");
        $display(" EI=1,I!=00 -> {最高请求位编号,1,0}  优先级 I[7]>...>I[0]");
        $display(" seed=%0d n_random=%0d verbose=%0d", seed_v, n_random, verbose);
        $display("================================================================");

        // ---- phase1: 题面真值表定向 -----------------------------------
        $display("--- phase1: 定向（真值表 10 行 + 单热点 + 边界）---");
        drive_chk(1'b0, 8'h00, "dir.ei0_row1");        // 行1：未使能
        drive_chk(1'b0, 8'hFF, "dir.ei0_row1");
        drive_chk(1'b0, 8'hA5, "dir.ei0_row1");
        drive_chk(1'b1, 8'h00, "dir.no_req_row2");     // 行2：使能无请求
        for (int k = 0; k < 8; k++)                    // 行3..10：单热点
            drive_chk(1'b1, 8'h01 << k, $sformatf("dir.hot%0d", k));
        drive_chk(1'b1, 8'hFF, "dir.all_req");
        drive_chk(1'b1, 8'hFE, "dir.edge_fe");
        drive_chk(1'b1, 8'h7F, "dir.edge_7f");
        drive_chk(1'b1, 8'h03, "dir.pair10");
        drive_chk(1'b1, 8'h81, "dir.pair87");

        // ---- phase2: 穷举 {EI, I} --------------------------------------
        $display("--- phase2: 穷举 {EI,I} 2x256=512 组合 ---");
        for (int e = 0; e < 2; e++) begin
            ve = (e == 0) ? 1'b0 : 1'b1;
            for (int v = 0; v < 256; v++) begin
                vi = v;
                drive_chk(ve, vi, "sweep");
            end
        end

        // ---- phase3: 稳定性 --------------------------------------------
        $display("--- phase3: 输入保持不变，多点采样防振荡 ---");
        stability(1'b0, 8'h00);
        stability(1'b0, 8'hFF);
        stability(1'b1, 8'h00);
        stability(1'b1, 8'h01);        // 特征向量：值可以错，但必须稳定
        stability(1'b1, 8'hFF);

        // ---- phase4: 随机压力 ------------------------------------------
        $display("--- phase4: 随机快速变化压力 %0d 笔（EI 3/4 概率置 1）---",
                 n_random);
        for (int r = 0; r < n_random; r++) begin
            ve = ($urandom_range(3) != 0);             // 偏向 EI=1
            vi = $urandom();                           // int -> 8bit 截断
            drive_chk(ve, vi, "rand");
        end

        // ---- phase5: X 冒烟 --------------------------------------------
        x_smoke();

        report();
    end

    // ------------------------------------------------------------------
    // 覆盖率 + 总结
    // ------------------------------------------------------------------
    task automatic report();
        int         nf, row_hit;
        logic [8:0] key;
        logic [4:0] gexp;

        row_hit = 0;
        for (int s = 0; s < 10; s++)
            if (cov_row[s] > 0) row_hit++;

        $display("");
        $display("---------------- functional coverage ----------------");
        $display("  真值表 10 行命中: %0d/10 %s",
                 row_hit, (row_hit == 10) ? "(full)" : "(GAP!)");
        $display("  Y 编号分箱: 0:%0d 1:%0d 2:%0d 3:%0d 4:%0d 5:%0d 6:%0d 7:%0d",
                 cov_y[0], cov_y[1], cov_y[2], cov_y[3],
                 cov_y[4], cov_y[5], cov_y[6], cov_y[7]);
        $display("  EI=0:%0d  EI=1:%0d  |  GS=1:%0d  EO=1:%0d",
                 cov_ei[0], cov_ei[1], cov_gs, cov_eo);

        nf = 0;
        $display("");
        $display("############################################################");
        $display("# FINAL REPORT | total=%0d pass=%0d fail=%0d x/z=%0d",
                 total_cnt, pass_cnt, fail_cnt, x_cnt);
        $display("#   不变量违例: GS->%0d  EO->%0d  编码/优先级->%0d",
                 gs_viol, eo_viol, enc_viol);
        for (int s = 0; s < 512; s++) begin
            if (seen_fail[s]) begin
                key  = s;
                gexp = golden(key[8], key[7:0]);
                $display("#   失败向量: EI=%b I=8'h%02h  期望 {Y=%b,GS=%b,EO=%b}",
                         key[8], key[7:0], gexp[4:2], gexp[1], gexp[0]);
                nf++;
            end
        end
        $display("############################################################");
        if (fail_cnt == 0) begin
            $display("TEST PASSED");
            $display("Simulation Finished Successfully");
        end else begin
            $display("TEST FAILED  (%0d 处不一致, 涉及 %0d 个输入向量, +SEED=%0d 可复现随机)",
                     fail_cnt, nf, seed_v);
        end
        $finish;
    endtask

endmodule
