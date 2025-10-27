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
    
    input  logic [DATA_WIDTH-1:0] kx_u,
    input  logic [DATA_WIDTH-1:0] bx_u,
    
    input  logic [DATA_WIDTH-1:0] kx_c,
    input  logic [DATA_WIDTH-1:0] bx_c,
    
    input  logic [DATA_WIDTH-1:0] ky_u,
    input  logic [DATA_WIDTH-1:0] by_u,
    
    input  logic [DATA_WIDTH-1:0] ky_c,
    input  logic [DATA_WIDTH-1:0] by_c,
    
    input  logic [1:0] mode_AS2,
    
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
    
    input  mode_t      mode_ATS,
    
    input  logic       valid_i,
    
    output logic blank_out,    

    // Parallel DAC interface
    input  logic sync_exp,
    input  logic mode_parall,
    
    output logic sel_1_0,
    output logic sel_1_1,
    output logic sel_2_0,
    output logic sel_2_1,
    output logic sync,
    output logic [15:0] data_out,
    
    // register map signals
    output logic ATS_rdy,
    output logic AS2_rdy
    );
    
    logic [31:0] data_AS2_x_DAC;
    logic [31:0] data_AS2_y_DAC;
    logic [31:0] data_ATS_x_DAC;
    logic [31:0] data_ATS_y_DAC;    
    
    logic [15:0] data_AS2_x_DAC_t;
    logic [15:0] data_AS2_y_DAC_t;
    logic [15:0] data_ATS_x_DAC_t;
    logic [15:0] data_ATS_y_DAC_t;
    
    logic AS2_x_rdy;
    logic AS2_y_rdy;
    logic ATS_x_rdy;
    logic ATS_y_rdy;
    
    assign data_AS2_x_DAC_t = data_AS2_x_DAC[31:16];
    assign data_AS2_y_DAC_t = data_AS2_y_DAC[31:16];
    assign data_ATS_x_DAC_t = data_ATS_x_DAC[31:16];
    assign data_ATS_y_DAC_t = data_ATS_y_DAC[31:16];
    
    assign ATS_rdy = ATS_x_rdy && ATS_y_rdy;
    assign AS2_rdy = AS2_x_rdy && AS2_y_rdy;
    
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
        .in_data_AS2_x(data_AS2_x_DAC_t),
        .in_data_AS2_y(data_AS2_y_DAC_t),
        .in_data_ATS_x(data_ATS_x_DAC_t),
        .in_data_ATS_y(data_ATS_y_DAC_t),
        
        .sync_exp(sync_exp),
        .mode(mode_parall),     
                 
        .sel_1_0(sel_1_0),         
        .sel_1_1(sel_1_1),         
        .sel_2_0(sel_2_0),         
        .sel_2_1(sel_2_1),         
        .sync(sync),     
        .out_data(data_out)         
    );
    
    top as2(
        .clk(clk),
        .rst(rst_n),
        .wdatax(wdatax),
        .wdatay(wdatay),
        
        .kx_u(kx_u),
        .bx_u(bx_u),
        
        .kx_c(kx_c),
        .bx_c(bx_c),
        
        .ky_u(ky_u),
        .by_u(by_u),
        
        .ky_c(ky_c),
        .by_c(by_c),
        
        .start(mode_AS2),
        
        .c_data_x(data_AS2_x_DAC),
        .c_data_y(data_AS2_y_DAC),
        .c_valid_x(AS2_x_rdy),
        .c_valid_y(AS2_y_rdy)
    );
    
    ATS_parall ATS(
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
        
        .mode(mode_ATS),
        
        .valid_i(valid_i),
        .valid_o_x(ATS_x_rdy),
        .valid_o_y(ATS_y_rdy),
        .value_to_DAC_x(data_ATS_x_DAC),
        .value_to_DAC_y(data_ATS_y_DAC),
        
        .blank_out(blank_out)
    );
    
endmodule
