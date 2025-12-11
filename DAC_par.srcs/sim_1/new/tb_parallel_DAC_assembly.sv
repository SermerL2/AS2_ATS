`timescale 1ns/1ps

module tb_parallel_DAC_assembly;

    // Testbench signals
    logic clk_in;
    logic rst_n;
    logic [15:0] in_data_AS2_x;
    logic [15:0] in_data_AS2_y;
    logic [15:0] in_data_ATS_x;
    logic [15:0] in_data_ATS_y;
    logic valid_i;
    logic sync_exp;
    logic [3:0] mode;
    logic AS2_ATS_set;
    logic clk_1_0;
    logic clk_1_1;
    logic clk_2_0;
    logic clk_2_1;
    logic sync;
    logic [15:0] out_data;
    
    // Mode definitions
    localparam IDLE        = 4'd0;
    localparam CALIBRATION = 4'd1;
    localparam ALIGNMENT   = 4'd2;
    localparam EXPOSURE    = 4'd3;
    
    // Clock generation
    always begin
        #5 clk_in = ~clk_in;
    end
    
    // Instantiate DUT
    parallel_DAC_assembly dut (
        .clk_in(clk_in),
        .rst_n(rst_n),
        .in_data_AS2_x(in_data_AS2_x),
        .in_data_AS2_y(in_data_AS2_y),
        .in_data_ATS_x(in_data_ATS_x),
        .in_data_ATS_y(in_data_ATS_y),
        .valid_i(valid_i),
        .sync_exp(sync_exp),
        .mode(mode),
        .AS2_ATS_set(AS2_ATS_set),
        .clk_1_0(clk_1_0),
        .clk_1_1(clk_1_1),
        .clk_2_0(clk_2_0),
        .clk_2_1(clk_2_1),
        .sync(sync),
        .out_data(out_data)
    );
    
    // Main test sequence
    initial begin
        // Initialize all signals
        clk_in = 0;
        rst_n = 0;
        in_data_AS2_x = 16'h0000;
        in_data_AS2_y = 16'h0000;
        in_data_ATS_x = 16'h0000;
        in_data_ATS_y = 16'h0000;
        valid_i = 0;
        sync_exp = 0;
        mode = IDLE;
        
        #20; // Wait
        
        // Release reset
        rst_n = 1;
        #10;
        
        $display("\n=== Test 1: Idle Mode ===");
        mode = IDLE;
        valid_i = 1;
        in_data_AS2_x = 16'hAAAA;
        in_data_AS2_y = 16'h5555;
        in_data_ATS_x = 16'h1111;
        in_data_ATS_y = 16'h2222;
        #10;
        valid_i = 0;
        
        repeat(5) @(posedge clk_in);
        
        $display("Time=%0t: out_data=0x%h, clk_1_0=%b, clk_1_1=%b, clk_2_0=%b, clk_2_1=%b", 
                 $time, out_data, clk_1_0, clk_1_1, clk_2_0, clk_2_1);
        
        $display("\n=== Test 2: Calibration Mode ===");
        mode = CALIBRATION;
        valid_i = 1;
        #10;
        valid_i = 0;
        
        // Expected sequence: AS2 cycles first, then ATS
        repeat(12) begin
            @(posedge clk_in);
            @(negedge clk_in);
            $display("Time=%0t: out_data=0x%h, clk_1_0=%b, clk_1_1=%b, clk_2_0=%b, clk_2_1=%b, AS2_ATS_set=%b", 
                     $time, out_data, clk_1_0, clk_1_1, clk_2_0, clk_2_1, AS2_ATS_set);
        end
        
        $display("\n=== Test 3: Alignment Mode ===");
        mode = ALIGNMENT;
        valid_i = 1;
        in_data_AS2_x = 16'h3333;
        in_data_AS2_y = 16'h4444;
        in_data_ATS_x = 16'h5555;
        in_data_ATS_y = 16'h6666;
        #10;
        valid_i = 0;
        
        repeat(9) begin
            @(posedge clk_in);
            @(negedge clk_in);
            $display("Time=%0t: out_data=0x%h, clk_1_0=%b, clk_1_1=%b, clk_2_0=%b, clk_2_1=%b", 
                     $time, out_data, clk_1_0, clk_1_1, clk_2_0, clk_2_1);
        end
        
        $display("\n=== Test 4: Exposure Mode ===");
        mode = EXPOSURE;
        valid_i = 1;
        #10;
        valid_i = 0;
        
        repeat(6) begin
            @(posedge clk_in);
            @(negedge clk_in);
            $display("Time=%0t: out_data=0x%h", $time, out_data);
        end
        
        $display("\n=== Test 5: Valid Signal Test ===");
        mode = CALIBRATION;
        valid_i = 0;  // Stop the counter
        
        repeat(3) @(posedge clk_in);
        $display("Time=%0t: valid_i=0, out_data=0x%h", $time, out_data);
        
        valid_i = 1;  // Resume
        #10;
        valid_i = 0;
        repeat(3) @(posedge clk_in);
        $display("Time=%0t: valid_i=1, out_data=0x%h", $time, out_data);
        
        $display("\n=== Simulation Complete ===");
        #100 $finish;
    end
    
    // Waveform dump
    initial begin
        $dumpfile("tb_parallel_DAC_assembly.vcd");
        $dumpvars(0, tb_parallel_DAC_assembly);
    end
    
endmodule