`timescale 1ns / 1ps

module AS2_ATS_tb;

    // Parameters
    parameter DATA_WIDTH = 32;
    
    // General
    logic        clk;
    logic        rst_n;
    
    // SPI
    logic        valid_spi;
    logic [15:0] spi_pkg;
    logic [2:0]  select_ss;

    logic        out_sclk;
    logic        out_ss_0;
    logic        out_ss_1;  
    logic        out_ss_2;  
    logic        out_sdio;  
    logic        out_busy;  
    logic        out_data_went;
    
    // AS2
    logic [DATA_WIDTH-1:0] wdatax;
    logic [DATA_WIDTH-1:0] wdatay;
    logic        validx;
    logic        validy;
    
    logic [DATA_WIDTH-1:0] kx_u;
    logic [DATA_WIDTH-1:0] bx_u;
    
    logic [DATA_WIDTH-1:0] kx_c;
    logic [DATA_WIDTH-1:0] bx_c;
    
    logic [DATA_WIDTH-1:0] ky_u;
    logic [DATA_WIDTH-1:0] by_u;
    
    logic [DATA_WIDTH-1:0] ky_c;
    logic [DATA_WIDTH-1:0] by_c;
    
    logic       wready;
    
    // ATS
    logic [DATA_WIDTH-1:0] format_X;
    logic [DATA_WIDTH-1:0] format_Y;
    logic [DATA_WIDTH-1:0] value_X;
    logic [DATA_WIDTH-1:0] value_Y;
    
    logic             blank_on;
    logic             blank_off;
    
    logic [DATA_WIDTH-1:0] k_nm_u_x;
    logic [DATA_WIDTH-1:0] b_nm_u_x;
    
    logic [DATA_WIDTH-1:0] k_u_cd_x;
    logic [DATA_WIDTH-1:0] b_u_cd_x;
    
    logic [DATA_WIDTH-1:0] k_nm_u_y;
    logic [DATA_WIDTH-1:0] b_nm_u_y;
    
    logic [DATA_WIDTH-1:0] k_u_cd_y;
    logic [DATA_WIDTH-1:0] b_u_cd_y;
    
    typedef enum logic [3:0] {
        idle,
        manual,
        alignment,
        exposure
    } mode_t;
    mode_t mode;
    
    logic [3:0]  valid_i;
    
    logic blank_out;

    // Parallel DAC interface
    logic sel_1_0;
    logic sel_1_1;
    logic sel_2_0;
    logic sel_2_1;
    logic [15:0] data_out;

    // Instantiate DUT
    AS2_ATS #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        
        // SPI
        .valid_spi(valid_spi),
        .spi_pkg(spi_pkg),
        .select_ss(select_ss),
        .out_sclk(out_sclk),
        .out_ss_0(out_ss_0),
        .out_ss_1(out_ss_1),
        .out_ss_2(out_ss_2),
        .out_sdio(out_sdio),
        .out_busy(out_busy),
        .out_data_went(out_data_went),
        
        // AS2
        .wdatax(wdatax),
        .wdatay(wdatay),
        .validx(validx),
        .validy(validy),
        .kx_u(kx_u),
        .bx_u(bx_u),
        .kx_c(kx_c),
        .bx_c(bx_c),
        .ky_u(ky_u),
        .by_u(by_u),
        .ky_c(ky_c),
        .by_c(by_c),
        .wready(wready),
        
        // ATS
        .format_X(format_X),
        .format_Y(format_Y),
        .value_X(value_X),
        .value_Y(value_Y),
        .blank_on(blank_on),
        .blank_off(blank_off),
        .k_nm_u_x(k_nm_u_x),
        .b_nm_u_x(b_nm_u_x),
        .k_u_cd_x(k_u_cd_x),
        .b_u_cd_x(b_u_cd_x),
        .k_nm_u_y(k_nm_u_y),
        .b_nm_u_y(b_nm_u_y),
        .k_u_cd_y(k_u_cd_y),
        .b_u_cd_y(b_u_cd_y),
        .mode(mode),
        .valid_i(valid_i),
        .blank_out(blank_out),
        
        // Parallel DAC interface
        .sel_1_0(sel_1_0),
        .sel_1_1(sel_1_1),
        .sel_2_0(sel_2_0),
        .sel_2_1(sel_2_1),
        .data_out(data_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz clock
    end

    // Reset generation
    initial begin
        rst_n = 0;
        #20 rst_n = 1;
    end

    // Initialize all inputs
    initial begin
        // SPI inputs
        valid_spi = 0;
        spi_pkg = 16'h0000;
        select_ss = 3'b000;
        
        // AS2 inputs
        wdatax = 32'h0000_0000;
        wdatay = 32'h0000_0000;
        validx = 0;
        validy = 0;
        kx_u = 32'h0000_0000;
        bx_u = 32'h0000_0000;
        kx_c = 32'h0000_0000;
        bx_c = 32'h0000_0000;
        ky_u = 32'h0000_0000;
        by_u = 32'h0000_0000;
        ky_c = 32'h0000_0000;
        by_c = 32'h0000_0000;
        
        // ATS inputs
        format_X = 32'h0000_0000;
        format_Y = 32'h0000_0000;
        value_X = 32'h0000_0000;
        value_Y = 32'h0000_0000;
        blank_on = 0;
        blank_off = 0;
        k_nm_u_x = 32'h0000_0000;
        b_nm_u_x = 32'h0000_0000;
        k_u_cd_x = 32'h0000_0000;
        b_u_cd_x = 32'h0000_0000;
        k_nm_u_y = 32'h0000_0000;
        b_nm_u_y = 32'h0000_0000;
        k_u_cd_y = 32'h0000_0000;
        b_u_cd_y = 32'h0000_0000;
        mode = manual;
        valid_i = 4'b0000;
        
        // Wait for reset to complete
        #30;
        // AS2 inputs
        wdatax = 32'hD2345603;
        wdatay = 32'hDEA80003; 
        validx = 1;
        validy = 1;
        kx_u= 32'h00020001;
        bx_u= 32'h00010001;
        kx_c= 32'h00030001;
        bx_c= 32'h00020001;
        ky_u= 32'h00020000;
        by_u= 32'h00010000;
        ky_c= 32'h00030000;
        by_c= 32'h00020000;
        
        
        // ATS inputs
        format_X = 32'h0001_0000;
        format_Y = 32'h0001_0000;
        value_X = 32'h0001_0000;
        value_Y = 32'h0001_0000;
        blank_on = 1;
        blank_off = 0;
        k_nm_u_x = 32'h0001_0000;
        b_nm_u_x = 32'h0001_0000;
        k_u_cd_x = 32'h0002_0000;
        b_u_cd_x = 32'h0001_0000;
        k_nm_u_y = 32'h0003_0000;
        b_nm_u_y = 32'h0001_0000;
        k_u_cd_y = 32'h0004_0000;
        b_u_cd_y = 32'h0001_0000;
        mode = manual;
        valid_i = 4'b1100;
        
        #10;
        // AS2 inputs
        validx = 0;
        validy = 0;
        valid_i = 4'b0000;
        #35;
        #1000;
        // AS2 inputs
        wdatax = 32'h99990111;
        wdatay = 32'h88880171;
        validx = 1;
        validy = 1;
        kx_u= 32'h00020002;
        bx_u= 32'h00010002;
        kx_c= 32'h00030002;
        bx_c= 32'h00020002;
        ky_u= 32'h00029900;
        by_u= 32'h00019900;
        ky_c= 32'h00039900;
        by_c= 32'h00029900;
        #10;
        // AS2 inputs
        validx = 0;
        validy = 0;
        #35;
        #20;
        #1000;  
        // AS2 inputs
        validx = 1;
        wdatax = 32'h98765432;
        #10;
        // AS2 inputs
        validx = 0; 
        #55;
        #10;
        #300;
        // AS2 inputs
        validy = 1;  
        wdatay = 32'h12310012;
        #10;
        // AS2 inputs
        validy = 0;
        #300 
        
        #1000;
        #3000;
        #3000;
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        // Add your test cases here
        
        // Example test case
        // valid_spi = 1;
        // spi_pkg = 16'hABCD;
        // select_ss = 3'b001;
        // #10;
        // valid_spi = 0;
        
        // Monitor signals
        $monitor("Time = %0t: data_out = %h, out_busy = %b", $time, data_out, out_busy);
        
        // Simulation duration
        #1000;
        $finish;
    end

    // Add additional test logic here as needed

endmodule