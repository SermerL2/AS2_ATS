`timescale 1ns/1ps

module tb_parallel_DAC_common;

    // Testbench signals
    logic        clk_in;
    logic        rst_n;
    logic [15:0] channel_X;
    logic [15:0] channel_Y;
    logic        valid_i;
    logic [3:0]  mode;
    
    // DUT outputs
    logic        clk_a_0;
    logic        clk_a_1;
    logic [15:0] out_data;
    
    // Clock generation
    always begin
        #5 clk_in = ~clk_in;
    end
    
    // Instantiate the DUT
    parallel_DAC_common dut (
        .clk_in   (clk_in),
        .rst_n    (rst_n),
        .channel_X(channel_X),
        .channel_Y(channel_Y),
        .valid_i  (valid_i),
        .mode     (mode),
        .clk_a_0  (clk_a_0),
        .clk_a_1  (clk_a_1),
        .out_data (out_data)
    );
    
    // Main test sequence
    initial begin
        // Initialize signals
        clk_in = 0;
        rst_n = 0;
        channel_X = 0;
        channel_Y = 0;
        valid_i = 0;
        mode = 0;
        
        // Wait for some time
        #25;
        
        // Release reset
        rst_n = 1;
        #10;
        
        // Test 1: Idle mode
        $display("\n=== Test 1: Idle Mode ===");
        mode = 0; // idle
        valid_i = 1;
        channel_X = 16'h1234;
        channel_Y = 16'h5678;
        #10;
        valid_i = 0;
        
        repeat(5) begin
            @(posedge clk_in);
            $display("Time=%0t: out_data=0x%h, clk_a_0=%b, clk_a_1=%b", 
                     $time, out_data, clk_a_0, clk_a_1);
        end
        
        // Test 2: Calibration mode
        $display("\n=== Test 2: Calibration Mode ===");
        mode = 1; // calibration
        valid_i = 1;
        channel_X = 16'hABCD;
        channel_Y = 16'hEF01;
        #10;
        valid_i = 0;
        
        repeat(9) begin  // Test 3 full cycles
            @(posedge clk_in);
            @(negedge clk_in);
            $display("Time=%0t: out_data=0x%h, clk_a_0=%b, clk_a_1=%b", 
                     $time, out_data, clk_a_0, clk_a_1);
        end
        
        // Test 3: Alignment mode (same as calibration)
        $display("\n=== Test 3: Alignment Mode ===");
        mode = 2; // alignment
        valid_i = 1;
        channel_X = 16'h1111;
        channel_Y = 16'h2222;
        #10;
        valid_i = 0;
        
        repeat(6) begin
            @(posedge clk_in);
            @(negedge clk_in);
            $display("Time=%0t: out_data=0x%h, clk_a_0=%b, clk_a_1=%b", 
                     $time, out_data, clk_a_0, clk_a_1);
        end
        
        // Test 4: Exposure mode (not implemented)
        $display("\n=== Test 4: Exposure Mode ===");
        mode = 3; // exposure
        valid_i = 1;
        channel_X = 16'h3333;
        channel_Y = 16'h4444;
        #10;
        valid_i = 0;
        
        repeat(3) begin
            @(posedge clk_in);
            @(negedge clk_in);
            $display("Time=%0t: out_data=0x%h, clk_a_0=%b, clk_a_1=%b", 
                     $time, out_data, clk_a_0, clk_a_1);
        end
        
        // Test 5: Valid signal control
        $display("\n=== Test 5: Valid Signal Control ===");
        mode = 1; // calibration
        valid_i = 0;
        channel_X = 16'hAAAA;
        channel_Y = 16'hBBBB;
        #10;
        valid_i = 0;
        
        repeat(3) begin
            @(posedge clk_in);
            $display("Time=%0t: valid_i=0, out_data=0x%h", $time, out_data);
        end
        
        valid_i = 1;
        #10;
        valid_i = 0;
        repeat(3) begin
            @(posedge clk_in);
            $display("Time=%0t: valid_i=1, out_data=0x%h", $time, out_data);
        end
        
        // End simulation
        $display("\n=== Simulation Complete ===");
        #100;
        $finish;
    end
    
    // Waveform dump for visualization
    initial begin
        $dumpfile("tb_parallel_DAC_common.vcd");
        $dumpvars(0, tb_parallel_DAC_common);
    end
    
endmodule