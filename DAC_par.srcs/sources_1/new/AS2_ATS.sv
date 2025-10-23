`timescale 1ns / 1ps

module AS2_ATS #(    
    parameter DATA_WIDTH = 32     
)(
    // General
    input  logic        clk,
    input  logic        rst_n,
    
    // SPI
    input  logic        valid_spi,
    input  logic [15:0] spi_pkg,
    input  logic [2:0]  select_ss,

    output logic        out_sclk,
    output logic        out_ss_0,
    output logic        out_ss_1,  
    output logic        out_ss_2,  
    output logic        out_sdio,  
    output logic        out_busy,  
    output logic        out_data_went,
    
    // AS2
    input  logic [DATA_WIDTH-1:0] wdatax,
    input  logic [DATA_WIDTH-1:0] wdatay,
    input  logic        validx,
    input  logic        validy,
    
    input  logic [DATA_WIDTH-1:0] kx_u,
    input  logic [DATA_WIDTH-1:0] bx_u,
    
    input  logic [DATA_WIDTH-1:0] kx_c,
    input  logic [DATA_WIDTH-1:0] bx_c,
    
    input  logic [DATA_WIDTH-1:0] ky_u,
    input  logic [DATA_WIDTH-1:0] by_u,
    
    input  logic [DATA_WIDTH-1:0] ky_c,
    input  logic [DATA_WIDTH-1:0] by_c,
    
    output  logic       wready,
    
    //ATS
    input  logic [DATA_WIDTH-1:0] format_X,
    input  logic [DATA_WIDTH-1:0] format_Y,
    input  logic [DATA_WIDTH-1:0] value_X,
    input  logic [DATA_WIDTH-1:0] value_Y,
    
    input  logic             blank_on,
    input  logic             blank_off,
    
    input  logic [DATA_WIDTH-1:0]      k_nm_u_x,
    input  logic [DATA_WIDTH-1:0]      b_nm_u_x,
    
    input  logic [DATA_WIDTH-1:0]      k_u_cd_x,
    input  logic [DATA_WIDTH-1:0]      b_u_cd_x,
    
    input  logic [DATA_WIDTH-1:0]      k_nm_u_y,
    input  logic [DATA_WIDTH-1:0]      b_nm_u_y,
    
    input  logic [DATA_WIDTH-1:0]      k_u_cd_y,
    input  logic [DATA_WIDTH-1:0]      b_u_cd_y,
    
    input  mode_t mode,
    
    input  logic [3:0]  valid_i,
    
    output logic blank_out,
    


    // Parallel DAC interface
    output logic sel_1_0,
    output logic sel_1_1,
    output logic sel_2_0,
    output logic sel_2_1,
    output logic [15:0] data_out
    );
    
    logic AS2_ATS_select;
    logic valid_i_parallel;
    logic valid_o_ATS;
    logic valid_o_AS2;
    
    logic [15:0] data_from_AS2;
    logic [31:0] data_from_ATS;
    logic [15:0] data_to_DAC;
    
    logic ready_i_AS2;
    logic ready_i_ATS;
    
    assign valid_i_parallel = AS2_ATS_select ? valid_o_ATS : valid_o_AS2;
    assign data_to_DAC = AS2_ATS_select ? data_from_ATS[31:16] : data_from_AS2;
    
    assign ready_i_AS2 = ~AS2_ATS_select;
    assign ready_i_ATS = AS2_ATS_select;
    
    spi_controller spic(
        .in_clk(clk),             
        .in_reset(rst_n),           
        .in_start(valid_spi),           
        .in_data(spi_pkg),
        .select_ss(select_ss),         
                          
        .out_sclk(out_sclk),
        .out_ss_0(out_ss_0),           
        .out_ss_1(out_ss_1),           
        .out_ss_2(out_ss_2),           
        .out_sdio(out_sdio),           
        .out_busy(out_busy),           
        .out_data_went(out_data_went)       
    );
    
    parallel_DAC_controller pDACc(
        .in_clk(clk),             
        .in_reset(rst_n),           
        .in_data(data_to_DAC),
        .valid(valid_i_parallel),              
                 
        .sel_1_0(sel_1_0),         
        .sel_1_1(sel_1_1),         
        .sel_2_0(sel_2_0),         
        .sel_2_1(sel_2_1),         
        .AS2_r(AS2_ATS_select),           
        .out_data(data_out)         
    );
    
    top as2(
        .clk(clk),
        .rst_n(rst_n),
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
        
        .valid_o(valid_o_AS2),
        .ready_i(ready_i_AS2),
        .data_out(data_from_AS2)
    );
    
    ATS_main ATS(
        .clk(clk),
        .reset_n(rst_n),
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
        .ready_i(ready_i_ATS),
        .valid_o(valid_o_ATS),
        .value_to_DAC(data_from_ATS),
        
        .blank_out(blank_out)
    );
    
endmodule
