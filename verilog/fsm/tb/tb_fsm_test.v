`timescale 1ns/10ps
module tb_fsm_test();

    // Inputs
    reg in;
    reg clk;
    reg rst_n;
    
    // Outputs
    wire out;
    wire [2:0] state;
    
    // Instantiate the Unit Under Test (UUT)
    fsm_test uut (
        .in(in),
        .out(out),
        .state(state),
        .clk(clk),
        .rst_n(rst_n)
    );
    
    // Clock generation
    always #5 clk = ~clk;
    
    // Test sequence
    initial begin
        // Initialize inputs
        clk = 0;
        rst_n = 0;
        in = 0;
        
        // Apply reset
        #10;
        rst_n = 1;
        
        // Test case 1: Simple sequence
        $display("Test case 1: Simple sequence");
        in = 1; #10; // s0 -> s1
        in = 1; #10; // s1 -> s2  
        in = 1; #10; // s2 -> s3
        in = 0; #10; // s3 -> s4
        in = 0; #10; // s4 -> s5
        in = 1; #10; // s5 -> s6
        in = 0; #10; // s6 -> s7 (should output 1)
        in = 0; #10; // s7 -> s0
        
        // Test case 2: Reset during operation
        $display("Test case 2: Reset test");
        in = 1; #10; // s0 -> s1
        in = 1; #10; // s1 -> s2
        rst_n = 0; #10; // Should reset to s0
        rst_n = 1;
        
        // Test case 3: Multiple paths to s0
        $display("Test case 3: Multiple reset paths");
        in = 1; #10; // s0 -> s1
        in = 0; #10; // s1 -> s0
        in = 1; #10; // s0 -> s1
        in = 1; #10; // s1 -> s2
        in = 0; #10; // s2 -> s0
        
        // Test case 4: Stay in s3
        $display("Test case 4: Stay in s3");
        in = 1; #10; // s0 -> s1
        in = 1; #10; // s1 -> s2
        in = 1; #10; // s2 -> s3
        in = 1; #10; // s3 -> s3
        in = 1; #10; // s3 -> s3
        in = 0; #10; // s3 -> s4
        
        // Test case 5: Path through s6->s2
        $display("Test case 5: Path s6->s2");
        // Get to s6
        in = 1; #10; // s0 -> s1
        in = 1; #10; // s1 -> s2
        in = 1; #10; // s2 -> s3
        in = 0; #10; // s3 -> s4
        in = 0; #10; // s4 -> s5
        in = 1; #10; // s5 -> s6
        in = 1; #10; // s6 -> s2
        
        // Monitor final state
        #20;
        $display("Simulation finished");
        $display("Final state: %d, Output: %b", state, out);
        $finish;
    end
    
    // Monitor to track state changes
    always @(posedge clk) begin
        $display("Time: %0t, State: %d, Input: %b, Output: %b", 
                 $time, state, in, out);
    end
    
    // Check output condition (out should be 1 only in state s7)
    always @(posedge clk) begin
        if (out && state !== 3'd7) begin
            $display("ERROR: Output is 1 but state is not s7 (state=%d)", state);
        end
        if (state == 3'd7 && !out) begin
            $display("ERROR: State is s7 but output is not 1");
        end
    end
    
endmodule
