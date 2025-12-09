// testbench.sv - 手动采样版本
module testbench;
    logic a, b, cin;
    logic sum, cout;
    
    logic clk = 0;
    always #5 clk = ~clk;
    
    // DUT
    full_adder dut(.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));
    
    // 覆盖组（无采样事件）
    covergroup cg_adder;
        option.per_instance = 1;
        coverpoint a;
        coverpoint b;
        coverpoint cin;
        cross_cases: cross a, b, cin;
    endgroup
    
    cg_adder cg_inst = new();
    
    initial begin
        integer i;
        
        $display("=== 开始全加器测试 ===");
        
        // 产生激励并手动采样
        for (i = 0; i < 5; i++) begin
            @(posedge clk);
            a = $random;
            b = $random;
            cin = $random;
            
            #1; // 等待DUT输出稳定
            
            // 手动采样覆盖组
            cg_inst.sample();
            
            $display("测试 %0d: a=%b, b=%b, cin=%b => sum=%b, cout=%b",
                     i+1, a, b, cin, sum, cout);
        end
        
        // 显示覆盖率
        $display("\n=== 覆盖率报告 ===");
        $display("总测试次数: %0d", i);
        $display("实例覆盖率: %0.2f%%", cg_inst.get_inst_coverage());
        $display("覆盖点 a: %0.2f%%", cg_inst.a.get_coverage());
        $display("覆盖点 b: %0.2f%%", cg_inst.b.get_coverage());
        $display("覆盖点 cin: %0.2f%%", cg_inst.cin.get_coverage());
        $display("交叉覆盖率: %0.2f%%", cg_inst.cross_cases.get_coverage());
        
        // 解释全局覆盖率
        $display("\n注：全局覆盖率 $get_coverage() = %0.2f%% 包含代码覆盖率", 
                 $get_coverage());
        $display("（如行覆盖、分支覆盖等），而功能覆盖率显示为0是因为采样时机问题");
        
        $finish;
    end
endmodule
//// testbench.sv
//module testbench;
//    logic a, b, cin;
//    logic sum, cout;
//    
//    logic clk = 0;
//    always #5 clk = ~clk;
//    
//    // DUT
//    full_adder dut(.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));
//    
//    // 覆盖组
//    covergroup cg_adder @(posedge clk);
//        option.per_instance = 1;
//        coverpoint a;
//        coverpoint b;
//        coverpoint cin;
//        cross_cases: cross a, b, cin;
//    endgroup
//    
//    cg_adder cg_inst = new();
//    
//    initial begin
//        integer i;
//        
//        $display("=== 开始全加器测试 ===");
//        
//        // 在时钟上升沿前赋值
//        for (i = 0; i < 20; i++) begin
//            // 在时钟上升沿前设置信号
//            @(negedge clk);  // 等待时钟下降沿
//            #1;              // 下降沿后一小段时间
//            a = $random;
//            b = $random;
//            cin = $random;
//            
//            // 等待时钟上升沿（覆盖组在这里采样）
//            @(posedge clk);
//            #1; // 等待DUT输出稳定
//            
//            $display("测试 %0d: a=%b, b=%b, cin=%b => sum=%b, cout=%b",
//                     i+1, a, b, cin, sum, cout);
//        end
//        
//        display_coverage_report();
//        $finish;
//    end
//    
//    task display_coverage_report();
//        $display("\n=== 覆盖率报告 ===");
//        $display("实例覆盖率: %0.2f%%", cg_inst.get_inst_coverage());
//        $display("交叉覆盖率: %0.2f%%", cg_inst.cross_cases.get_coverage());
//    endtask
//endmodule
//module tb_fulladder;
//    // 测试信号
//    logic a, b, cin;
//    logic sum, cout;
//    
//    // 时钟
//    logic clk = 0;
//    always #5 clk = ~clk;
//    
//    // DUT实例化
//    full_adder dut(
//        .a(a),
//        .b(b),
//        .cin(cin),
//        .sum(sum),
//        .cout(cout)
//    );
//    
//    // 1. 定义覆盖组
//    covergroup cg_adder @(posedge clk);
//        // 输入信号覆盖点
//        coverpoint a {
//            bins zero = {0};
//            bins one = {1};
//        }
//        
//        coverpoint b {
//            bins zero = {0};
//            bins one = {1};
//        }
//        
//        coverpoint cin {
//            bins zero = {0};
//            bins one = {1};
//        }
//        
//        // 交叉覆盖：所有输入组合
//        cross_cases: cross a, b, cin;
//    endgroup
//    
//    // 2. 实例化覆盖组
//    cg_adder cg_inst = new();
//    
//    // 测试主程序
//    initial begin
//        integer i;
//        
//        $display("=== 开始全加器测试 ===");
//        
//        // 产生随机激励
//        for (i = 0; i < 20; i++) begin
//            @(posedge clk);
//            a = $random;
//            b = $random;
//            cin = $random;
//            
//            #1; // 等待DUT输出稳定
//            
//            $display("测试 %0d: a=%b, b=%b, cin=%b => sum=%b, cout=%b",
//                     i+1, a, b, cin, sum, cout);
//        end
//        
//        // 3. 使用get_inst_coverage()显示覆盖率
//        display_coverage_report();
//        
//        $finish;
//    end
//    
//    // 显示覆盖率报告的任务
//    task display_coverage_report();
//        real inst_coverage;
//        real cp_a_coverage, cp_b_coverage, cp_cin_coverage;
//        real cross_coverage;
//        
//        $display("\n=== 覆盖率报告 ===");
//        
//        // 获取实例覆盖率
//        inst_coverage = cg_inst.get_inst_coverage();
//        $display("覆盖组实例覆盖率: %0.2f%%", inst_coverage);
//        
//        // 获取各个覆盖点的覆盖率
//        cp_a_coverage = cg_inst.a.get_inst_coverage();
//        cp_b_coverage = cg_inst.b.get_inst_coverage();
//        cp_cin_coverage = cg_inst.cin.get_inst_coverage();
//        
//        $display("覆盖点 'a' 覆盖率: %0.2f%%", cp_a_coverage);
//        $display("覆盖点 'b' 覆盖率: %0.2f%%", cp_b_coverage);
//        $display("覆盖点 'cin' 覆盖率: %0.2f%%", cp_cin_coverage);
//        
//        // 获取交叉覆盖率
//        cross_coverage = cg_inst.cross_cases.get_inst_coverage();
//        $display("交叉覆盖率: %0.2f%%", cross_coverage);
//        
//        // 使用$get_coverage获取整体覆盖率
//        $display("\n--- 使用$get_coverage函数 ---");
//        $display("整体覆盖率: %0.2f%%", $get_coverage());
//    endtask
//endmodule
