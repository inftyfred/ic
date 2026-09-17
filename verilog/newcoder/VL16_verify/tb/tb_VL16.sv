`timescale 1ns/1ps

// ======================================================================
// tb_VL16 —— [VL16] 8-3 优先编码器级联实现 16-4 优先编码器
//
// DUT 接口：A[15:0]、EI -> L[3:0]、GS、EO
// 规格：
//   EI=0           -> {L,GS,EO} = {0000,0,0}
//   EI=1, A=0      -> {L,GS,EO} = {0000,0,1}
//   EI=1, A!=0     -> L 为最高优先级置位位的编号，GS=1，EO=0
//   A[15] 优先级最高，A[0] 优先级最低；A[15:8] 优先于 A[7:0]
//
// 验证内容：
//   1) 穷举 EI x A 的全部 2 x 65536 = 131072 个组合；
//   2) golden 使用独立的最高置位位扫描，不复制 DUT 级联结构；
//   3) 检查 GS/EO、编码位有效性和优先级不变量；
//   4) 定向边界、保持稳定性、随机输入压力、X 输入观察；
//   5) 默认只打印失败，+VERBOSE=1 可逐笔打印。
// ======================================================================

module tb_VL16;

    localparam int SETTLE_NS  = 1;
    localparam int N_RANDOM   = 1000;
    localparam int N_STAB     = 6;
    localparam int WD_NS      = 2_000_000;

    logic        EI;
    logic [15:0] A;
    wire  [3:0]  L;
    wire         GS, EO;

    encoder_164 dut (
        .A  (A),
        .EI (EI),
        .L  (L),
        .GS (GS),
        .EO (EO)
    );

    int total_cnt, pass_cnt, fail_cnt, x_cnt;
    int txn_id, gs_viol, eo_viol, enc_viol;
    int seed_v, rng;
    bit verbose;
    bit seen_fail [0:131071];

    initial begin : WATCHDOG
        #WD_NS;
        $display("[FATAL] watchdog timeout @%0t", $time);
        $display("TEST FAILED");
        $finish;
    end

    // 独立 golden：从低位到高位扫描，后写入的更高位覆盖前值
    function automatic logic [5:0] golden(input logic        ei_,
                                          input logic [15:0] a_);
        logic [3:0] l_;
        logic       gs_, eo_;
        l_ = 4'b0000;
        if (!ei_) begin
            gs_ = 1'b0;
            eo_ = 1'b0;
        end else if (a_ == 16'h0000) begin
            gs_ = 1'b0;
            eo_ = 1'b1;
        end else begin
            gs_ = 1'b1;
            eo_ = 1'b0;
            for (int k = 0; k < 16; k++)
                if (a_[k]) l_ = k;
        end
        return {l_, gs_, eo_};
    endfunction

    task automatic note_fail(input logic ei_, input logic [15:0] a_);
        seen_fail[{ei_, a_}] = 1'b1;
    endtask

    task automatic check(input string tag,
                         input logic        ei_,
                         input logic [15:0] a_);
        logic [5:0] got, exp;
        logic [3:0] lv;

        total_cnt++;
        txn_id++;
        got = {L, GS, EO};
        exp = golden(ei_, a_);

        if ($isunknown(got)) begin
            x_cnt++;
            fail_cnt++;
            note_fail(ei_, a_);
            $display("[FAIL] %-12s EI=%b A=16'h%04h got X/Z=%b @%0t",
                     tag, ei_, a_, got, $time);
            return;
        end

        if (got === exp) begin
            pass_cnt++;
            if (verbose)
                $display("[%5d] %-12s EI=%b A=16'h%04h -> L=%b GS=%b EO=%b ok",
                         txn_id, tag, ei_, a_, got[5:2], got[1], got[0]);
        end else begin
            fail_cnt++;
            note_fail(ei_, a_);
            $display("[FAIL] %-12s EI=%b A=16'h%04h got={L=%b,GS=%b,EO=%b} exp={L=%b,GS=%b,EO=%b} @%0t",
                     tag, ei_, a_, got[5:2], got[1], got[0],
                     exp[5:2], exp[1], exp[0], $time);
        end

        // GS = EI & any input request
        if (got[1] !== (ei_ & (|a_))) begin
            gs_viol++;
            fail_cnt++;
            note_fail(ei_, a_);
            $display("[FAIL] %-12s GS invariant violated EI=%b A=16'h%04h GS=%b",
                     tag, ei_, a_, got[1]);
        end

        // EO = EI & no input request
        if (got[0] !== (ei_ & (~|a_))) begin
            eo_viol++;
            fail_cnt++;
            note_fail(ei_, a_);
            $display("[FAIL] %-12s EO invariant violated EI=%b A=16'h%04h EO=%b",
                     tag, ei_, a_, got[0]);
        end

        // GS=1 时，L 指向的输入必须为 1，且更高位不能为 1
        if (got[1] === 1'b1) begin
            lv = got[5:2];
            if (a_[lv] !== 1'b1) begin
                enc_viol++;
                fail_cnt++;
                note_fail(ei_, a_);
                $display("[FAIL] %-12s L=%0d does not point to active A bit, A=16'h%04h",
                         tag, lv, a_);
            end
            for (int k = 15; k > lv; k--) begin
                if (a_[k] !== 1'b0) begin
                    enc_viol++;
                    fail_cnt++;
                    note_fail(ei_, a_);
                    $display("[FAIL] %-12s higher-priority A[%0d]=1 but L=%0d A=16'h%04h",
                             tag, k, lv, a_);
                end
            end
        end
    endtask

    task automatic drive_check(input logic        ei_,
                               input logic [15:0] a_,
                               input string       tag);
        EI = ei_;
        A  = a_;
        #SETTLE_NS;
        check(tag, ei_, a_);
    endtask

    task automatic stability(input logic ei_, input logic [15:0] a_);
        logic [5:0] first, cur;
        drive_check(ei_, a_, "stable.first");
        first = {L, GS, EO};
        for (int s = 1; s <= N_STAB; s++) begin
            #(s + 1);
            cur = {L, GS, EO};
            total_cnt++;
            if (cur === first)
                pass_cnt++;
            else begin
                fail_cnt++;
                note_fail(ei_, a_);
                $display("[FAIL] stable.osc EI=%b A=16'h%04h %b -> %b",
                         ei_, a_, first, cur);
            end
        end
    endtask

    task automatic x_smoke();
        $display("--- X smoke（只观察，不计入功能判分）---");
        EI = 1'b1; A = 16'hxxxx; #SETTLE_NS;
        $display("[info] EI=1 A=16'hxxxx -> {L,GS,EO}=%b", {L, GS, EO});
        EI = 1'bx; A = 16'hA55A; #SETTLE_NS;
        $display("[info] EI=x A=16'hA55A -> {L,GS,EO}=%b", {L, GS, EO});
        EI = 1'b1; A = 16'h0000; #SETTLE_NS;
    endtask

    task automatic report();
        int nf;
        logic [16:0] key;
        logic [5:0] exp;

        nf = 0;
        $display("");
        $display("============================================================");
        $display("# FINAL REPORT | total=%0d pass=%0d fail=%0d x/z=%0d",
                 total_cnt, pass_cnt, fail_cnt, x_cnt);
        $display("# invariant violations: GS=%0d EO=%0d encoding=%0d",
                 gs_viol, eo_viol, enc_viol);
        for (int s = 0; s < 131072; s++) begin
            if (seen_fail[s]) begin
                key = s;
                exp = golden(key[16], key[15:0]);
                $display("# fail vector: EI=%b A=16'h%04h expected {L=%b,GS=%b,EO=%b}",
                         key[16], key[15:0], exp[5:2], exp[1], exp[0]);
                nf++;
            end
        end
        $display("# unique fail vectors=%0d", nf);
        $display("============================================================");
        if (fail_cnt == 0) begin
            $display("TEST PASSED");
            $display("Simulation Finished Successfully");
        end else begin
            $display("TEST FAILED (%0d failures, +SEED=%0d)", fail_cnt, seed_v);
        end
        $finish;
    endtask

    initial begin : MAIN
        logic [15:0] av;
        logic        ev;

        total_cnt = 0;
        pass_cnt  = 0;
        fail_cnt  = 0;
        x_cnt     = 0;
        txn_id    = 0;
        gs_viol   = 0;
        eo_viol   = 0;
        enc_viol  = 0;
        seed_v    = 1;
        verbose   = 1'b0;
        for (int s = 0; s < 131072; s++)
            seen_fail[s] = 1'b0;

`ifdef FSDB
        begin
            string fsdb_path;
            if ($value$plusargs("fsdbfile=%s", fsdb_path))
                $fsdbDumpfile(fsdb_path);
            else
                $fsdbDumpfile("dump.fsdb");
            $fsdbDumpvars(0, tb_VL16);
        end
`endif

        if (!$value$plusargs("SEED=%d", seed_v)) seed_v = 1;
        verbose = $test$plusargs("VERBOSE");
        rng = $urandom(seed_v);

        $display("============================================================");
        $display(" tb_VL16 : 16-4 priority encoder by two cascaded 8-3 encoders");
        $display(" exhaustive combinations: 2 x 65536 = 131072");
        $display(" seed=%0d verbose=%0d", seed_v, verbose);
        $display("============================================================");

        // 定向边界：禁用、无请求、单热点、上下半区交界和多热点
        $display("--- directed tests ---");
        drive_check(1'b0, 16'h0000, "dir.disable0");
        drive_check(1'b0, 16'hFFFF, "dir.disable1");
        drive_check(1'b1, 16'h0000, "dir.no_req");
        drive_check(1'b1, 16'h0001, "dir.bit0");
        drive_check(1'b1, 16'h0002, "dir.bit1");
        drive_check(1'b1, 16'h0080, "dir.bit7");
        drive_check(1'b1, 16'h0100, "dir.bit8");
        drive_check(1'b1, 16'h8000, "dir.bit15");
        drive_check(1'b1, 16'h00FF, "dir.low_all");
        drive_check(1'b1, 16'hFF00, "dir.high_all");
        drive_check(1'b1, 16'hFFFF, "dir.all");
        drive_check(1'b1, 16'h8101, "dir.multi");
        drive_check(1'b1, 16'h7FFF, "dir.upper_edge");
        drive_check(1'b1, 16'h8001, "dir.cross_edge");

        // 全组合穷举
        $display("--- exhaustive EI x A ---");
        for (int e = 0; e < 2; e++) begin
            ev = (e == 0) ? 1'b0 : 1'b1;
            for (int v = 0; v < 65536; v++) begin
                av = v;
                drive_check(ev, av, "sweep");
            end
        end

        // 保持稳定性
        $display("--- stability tests ---");
        stability(1'b0, 16'h0000);
        stability(1'b1, 16'h0000);
        stability(1'b1, 16'h0001);
        stability(1'b1, 16'h00FF);
        stability(1'b1, 16'h8000);
        stability(1'b1, 16'hFFFF);

        // 随机输入压力
        $display("--- random tests (%0d) ---", N_RANDOM);
        for (int r = 0; r < N_RANDOM; r++) begin
            ev = ($urandom_range(3) != 0);
            av = $urandom();
            drive_check(ev, av, "random");
        end

        x_smoke();
        report();
    end

endmodule
