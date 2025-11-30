`timescale 1ns/10ps

module tb_syncfifo;
    // Parameters
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 9;
    parameter CLK_PERIOD = 10;  // 100MHz
    
    // Testbench Signals
    reg                     fifo_rst;
    reg                     clock;
    reg                     read_enable;
    reg                     write_enable;
    reg    [DATA_WIDTH-1:0] write_data;
    wire   [DATA_WIDTH-1:0] read_data;
    wire                    full;
    wire                    empty;
    wire   [ADDR_WIDTH-1:0] fifo_counter;
    
    // Test variables
    integer i;
    integer error_count;
    integer test_case;
    reg [DATA_WIDTH-1:0] expected_data;
    reg [DATA_WIDTH-1:0] written_data [0:1023];  // Store written data for verification
    
    // Instantiate DUT
    syncfifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_syncfifo (
        .fifo_rst(fifo_rst),
        .clock(clock),
        .read_enable(read_enable),
        .write_enable(write_enable),
        .write_data(write_data),
        .read_data(read_data),
        .full(full),
        .empty(empty),
        .fifo_counter(fifo_counter)
    );
    
    // Clock generation
    initial begin
        clock = 0;
        forever #(CLK_PERIOD/2) clock = ~clock;
    end
    
    // Test sequence
    initial begin
        // Initialize
        initialize();
        error_count = 0;
        test_case = 0;
        
        $display("=== Starting Synchronous FIFO Testbench ===");
        $display("Time: %0t", $time);
        
        // Test Case 1: Reset Test
        test_case = 1;
        $display("\n=== Test Case %0d: Reset Test ===", test_case);
        reset_test();
        
        // Test Case 2: Single Write-Read Test
        test_case = 2;
        $display("\n=== Test Case %0d: Single Write-Read Test ===", test_case);
        single_write_read_test();
        
        // Test Case 3: Multiple Write then Read Test
        test_case = 3;
        $display("\n=== Test Case %0d: Multiple Write then Read Test ===", test_case);
        multiple_write_then_read_test();
        
        // Test Case 4: Simultaneous Read-Write Test
        test_case = 4;
        $display("\n=== Test Case %0d: Simultaneous Read-Write Test ===", test_case);
        simultaneous_read_write_test();
        
        // Test Case 5: Full FIFO Test
        test_case = 5;
        $display("\n=== Test Case %0d: Full FIFO Test ===", test_case);
        full_fifo_test();
        
        // Test Case 6: Empty FIFO Test
        test_case = 6;
        $display("\n=== Test Case %0d: Empty FIFO Test ===", test_case);
        empty_fifo_test();
        
        // Test Case 7: Random Operation Test
        test_case = 7;
        $display("\n=== Test Case %0d: Random Operation Test ===", test_case);
        random_operation_test();
        
        // Summary
        $display("\n=== Test Summary ===");
        $display("Total test cases: %0d", test_case);
        $display("Total errors: %0d", error_count);
        if (error_count == 0) begin
            $display("*** ALL TESTS PASSED ***");
        end else begin
            $display("*** SOME TESTS FAILED ***");
        end
        
        #100 $finish;
    end
    
    // Initialize all signals
    task initialize;
        begin
            fifo_rst = 1;
            read_enable = 0;
            write_enable = 0;
            write_data = 0;
            #(CLK_PERIOD * 2);
            fifo_rst = 0;
            #(CLK_PERIOD * 2);
        end
    endtask
    
    // Test Case 1: Reset Test
    task reset_test;
        begin
            // Apply reset
            fifo_rst = 1;
            #(CLK_PERIOD);
            
            // Check reset values
            if (empty !== 1'b1) begin
                $display("ERROR: empty should be 1 after reset, got %b", empty);
                error_count = error_count + 1;
            end
            
            if (full !== 1'b0) begin
                $display("ERROR: full should be 0 after reset, got %b", full);
                error_count = error_count + 1;
            end
            
            if (fifo_counter !== 0) begin
                $display("ERROR: fifo_counter should be 0 after reset, got %d", fifo_counter);
                error_count = error_count + 1;
            end
            
            // Release reset
            fifo_rst = 0;
            #(CLK_PERIOD);
            
            $display("Reset test completed");
        end
    endtask
    
    // Test Case 2: Single Write-Read Test
    task single_write_read_test;
        begin
            // Write one data
            write_data = 8'hA5;
            write_enable = 1;
            #(CLK_PERIOD);
            write_enable = 0;
            
            // Check after write
            #CLK_PERIOD; // small delay for signal update
			if (empty !== 1'b0) begin
                $display("ERROR: empty should be 0 after write, got %b", empty);
                error_count = error_count + 1;
            end
            
            if (fifo_counter !== 1) begin
                $display("ERROR: fifo_counter should be 1 after write, got %d", fifo_counter);
                error_count = error_count + 1;
            end
            // Read the data
            read_enable = 1;
            #(CLK_PERIOD);
            read_enable = 0;
            
            // Check read data
            if (read_data !== 8'hA5) begin
                $display("ERROR: read_data mismatch. Expected 8'hA5, got 8'h%h", read_data);
                error_count = error_count + 1;
            end
            
            // Check after read
            #(CLK_PERIOD);
            if (empty !== 1'b1) begin
                $display("ERROR: empty should be 1 after read, got %b", empty);
                error_count = error_count + 1;
            end
            
            if (fifo_counter !== 0) begin
                $display("ERROR: fifo_counter should be 0 after read, got %d", fifo_counter);
                error_count = error_count + 1;
            end
            
            $display("Single write-read test completed");
        end
    endtask
    
    // Test Case 3: Multiple Write then Read Test
    task multiple_write_then_read_test;
        integer i;
        begin
            $display("Writing 10 data items...");
            
            // Write 10 data items
            for (i = 0; i < 10; i = i + 1) begin
                write_enable = 1;
                write_data = i + 8'h10;
                written_data[i] = i + 8'h10;
                #(CLK_PERIOD);
            end
            write_enable = 0;
            
            // Check counter
            #1;
            if (fifo_counter !== 10) begin
                $display("ERROR: fifo_counter should be 10, got %d", fifo_counter);
                error_count = error_count + 1;
            end
            
            $display("Reading 10 data items...");
            
            // Read 10 data items
            for (i = 0; i < 10; i = i + 1) begin
                read_enable = 1;
                #(CLK_PERIOD);
                read_enable = 0;
                
                expected_data = written_data[i];
                if (read_data !== expected_data) begin
                    $display("ERROR: Data mismatch at read %0d. Expected 8'h%h, got 8'h%h", 
                             i, expected_data, read_data);
                    error_count = error_count + 1;
                end else begin
                    $display("Read %0d: 8'h%h - OK", i, read_data);
                end
                
                #(CLK_PERIOD);
            end
            
            // Check empty after all reads
            #1;
            if (empty !== 1'b1) begin
                $display("ERROR: empty should be 1 after all reads, got %b", empty);
                error_count = error_count + 1;
            end
            
            $display("Multiple write-then-read test completed");
        end
    endtask
    
    // Test Case 4: Simultaneous Read-Write Test
    task simultaneous_read_write_test;
        integer i;
        begin
            // First write some data
            for (i = 0; i < 5; i = i + 1) begin
                write_enable = 1;
                write_data = i + 8'h20;
                written_data[i] = i + 8'h20;
                #(CLK_PERIOD);
            end
            write_enable = 0;
            read_enable = 0;
            
            $display("Testing simultaneous read-write...");
            
            // Simultaneous read and write for 10 cycles
            for (i = 0; i < 10; i = i + 1) begin
                write_enable = 1;
                read_enable = 1;
                write_data = i + 8'h30;
                written_data[i] = i + 8'h30;
                #(CLK_PERIOD);
                
                // Counter should remain constant during simultaneous R/W
                if (i > 0) begin  // Skip first cycle due to pipeline
                    if (fifo_counter !== 5) begin
                        $display("ERROR: fifo_counter should remain 5 during simultaneous R/W, got %d", fifo_counter);
                        error_count = error_count + 1;
                    end
                end
            end
            
            write_enable = 0;
            read_enable = 0;
            #(CLK_PERIOD);
            
            $display("Simultaneous read-write test completed");
        end
    endtask
    
    // Test Case 5: Full FIFO Test
    task full_fifo_test;
        integer i;
        reg [DATA_WIDTH-1:0] last_written;
		integer fifo_depth;
        begin
			reset_test();
            $display("Testing FIFO full condition...");
            
            // Calculate FIFO depth (2^ADDR_WIDTH)
            fifo_depth = 1 << ADDR_WIDTH;
            
            // Write until full
            for (i = 0; i < fifo_depth; i = i + 1) begin
                write_enable = 1;
                write_data = i;
                last_written = i;
                #(CLK_PERIOD);
                
                if (full && i < fifo_depth - 1) begin
                    $display("ERROR: full asserted too early at count %0d", i);
                    error_count = error_count + 1;
                end
            end
            
            write_enable = 0;
            //#(CLK_PERIOD);
            
            // Check full flag
            if (full !== 1'b1) begin
                $display("ERROR: full should be 1, got %b", full);
                error_count = error_count + 1;
            end
            
            if (fifo_counter !== 511) begin
                $display("ERROR: fifo_counter should be %0d, got %0d", 511, fifo_counter);
                error_count = error_count + 1;
            end
           
		   
            // Try to write when full (should be ignored)
            write_data = 8'hFF;
            write_enable = 1;
            #(CLK_PERIOD);
            write_enable = 0;
            
            // Read one data to verify the last written data is correct
            read_enable = 1;
            #(CLK_PERIOD);
            read_enable = 0;
            
            if (read_data !== 0) begin
                $display("ERROR: Data corruption. Expected 8'h%h, got 8'h%h", 0, read_data);
                error_count = error_count + 1;
            end
            
            $display("Full FIFO test completed");
        end
    endtask
    
    // Test Case 6: Empty FIFO Test
    task empty_fifo_test;
        begin
            $display("Testing FIFO empty condition...");
            
            // Ensure FIFO is empty
            if (!empty) begin
                // Read until empty
                while (!empty) begin
                    read_enable = 1;
                    #(CLK_PERIOD);
                    read_enable = 0;
                    #(CLK_PERIOD);
                end
            end
            
            // Check empty flag
            if (empty !== 1'b1) begin
                $display("ERROR: empty should be 1, got %b", empty);
                error_count = error_count + 1;
            end
            
            // Try to read when empty (should be ignored)
            read_enable = 1;
            #(CLK_PERIOD);
            read_enable = 0;
            
            // Data should be unchanged (or don't care)
            $display("Empty FIFO test completed");
        end
    endtask
    
    // Test Case 7: Random Operation Test
    task random_operation_test;
        integer i;
        integer write_count, read_count;
        begin
            $display("Testing random operations...");
            
            write_count = 0;
            read_count = 0;
            
            for (i = 0; i < 100; i = i + 1) begin
                // Random operations
                write_enable = $random;
                read_enable = $random;
                
                if (write_enable && !full) begin
                    write_data = $random;
                    write_count = write_count + 1;
                end
                
                #(CLK_PERIOD);
                
                // Monitor for errors
                if (full && empty) begin
                    $display("ERROR: Both full and empty asserted at time %0t", $time);
                    error_count = error_count + 1;
                end
                
                if (fifo_counter > (1 << ADDR_WIDTH)) begin
                    $display("ERROR: fifo_counter overflow at time %0t", $time);
                    error_count = error_count + 1;
                end
            end
            
            write_enable = 0;
            read_enable = 0;
            
            $display("Random operation test completed");
            $display("  Random writes: %0d", write_count);
            $display("  Random reads: %0d", read_count);
        end
    endtask
    
    // Monitor
    always @(posedge clock) begin
        if (write_enable && !full) begin
            $display("Time %0t: WRITE data=8'h%h, counter=%0d", $time, write_data, fifo_counter);
        end
        
        if (read_enable && !empty) begin
            $display("Time %0t: READ data=8'h%h, counter=%0d", $time, read_data, fifo_counter);
        end
        
        if (full) begin
            $display("Time %0t: FIFO FULL", $time);
        end
        
        if (empty) begin
            $display("Time %0t: FIFO EMPTY", $time);
        end
    end
    
    // Waveform dump (for debugging)
    initial begin
        $fsdbDumpfile("syncfifo.fsdb");
        $fsdbDumpvars();
    end
    
endmodule
