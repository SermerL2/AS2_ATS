`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/27/2025 03:59:16 PM
// Design Name: 
// Module Name: test_wrapper
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module test_wrapper #(    
    parameter DATA_WIDTH = 32     
)  (
        input logic GCLK,
        input logic OTG_RESETN
    );
    
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
    
    logic [DATA_WIDTH-1:0] wdatax;
    logic [DATA_WIDTH-1:0] wdatay;
                             
    logic [DATA_WIDTH-1:0] kx_u; 
    logic [DATA_WIDTH-1:0] bx_u;
                             
    logic [DATA_WIDTH-1:0] kx_c;
    logic [DATA_WIDTH-1:0] bx_c; 
                             
    logic [DATA_WIDTH-1:0] ky_u; 
    logic [DATA_WIDTH-1:0] by_u; 
                            
    logic [DATA_WIDTH-1:0] ky_c; 
    logic [DATA_WIDTH-1:0] by_c;  
    
    logic [DATA_WIDTH-1:0] format_X;
    logic [DATA_WIDTH-1:0] format_Y;     
    logic [DATA_WIDTH-1:0] value_X;     
    logic [DATA_WIDTH-1:0] value_Y;      
                                     
    logic             blank_on;      
    logic             blank_off;         
                                     
    logic [DATA_WIDTH-1:0]      k_nm_u_x;
    logic [DATA_WIDTH-1:0]      b_nm_u_x;
                                     
    logic [DATA_WIDTH-1:0]      k_u_cd_x;
    logic [DATA_WIDTH-1:0]      b_u_cd_x;
                                     
    logic [DATA_WIDTH-1:0]      k_nm_u_y;
    logic [DATA_WIDTH-1:0]      b_nm_u_y;
                                     
    logic [DATA_WIDTH-1:0]      k_u_cd_y;
    logic [DATA_WIDTH-1:0]      b_u_cd_y;
                                     
    mode_t      mode_ATS;                
                                     
    logic       valid_i;                 
                                     
    logic blank_out;           
    
    logic sync_exp;
                     
    logic sel_1_0;   
    logic sel_1_1;       
    logic sel_2_0;       
    logic sel_2_1;       
    logic sync;       
    logic [15:0] data_out;
                          
    logic [15:0] reg_map_calib;
    logic AS2_ATS_ready_o;
        

    AS2_ATS DUT(
        .clk(GCLK),          
        .rst_n(OTG_RESETN),                
                  
        .valid_spi(valid_spi),    
        .spi_pkg(spi_pkg),      
        .select_ss(select_ss),    
          
        .out_sclk(out_sclk),     
        .out_ss_0(out_ss_0),     
        .out_ss_1(out_ss),     
        .out_ss_2(out_ss_2),     
        .out_sdio(out_sdio),     
        .out_busy(out_busy),     
        .out_data_went(out_data_went),
        
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
        
        .mode_ATS(mode_ATS),
        
        .valid_i(valid_i), 
        .blank_out(blank_out),
        
        .sync_exp(sync_exp),         
           
        .sel_1_0(sel_1_0),        
        .sel_1_1(sel_1_1),        
        .sel_2_0(sel_2_0),        
        .sel_2_1(sel_2_1),        
        .sync(sync),           
        .data_out(data_out),
        
        .reg_map_calib(reg_map_calib),        
        .AS2_ATS_ready_o(AS2_ATS_ready_o)           
    );
    
    vio_0 vio_0(
        .clk(GCLK),
        .probe_in0(out_sclk),
        .probe_in1(out_ss_0),
        .probe_in2(out_ss_1),
        .probe_in3(out_ss_2),
        .probe_in4(out_sdio),
        .probe_in5(out_busy),
        .probe_in6(out_data_went),
        .probe_in7(blank_out),
        .probe_in8(sel_1_0),
        .probe_in9(sel_1_1),
        .probe_in10(sel_2_0),
        .probe_in11(sel_2_1),
        .probe_in12(sync),
        .probe_in13(data_out),
        .probe_in14(AS2_ATS_ready_o),  // update
        
        .probe_out0(valid_spi),
        .probe_out1(spi_pkg),
        .probe_out2(select_ss),
        .probe_out3(wdatax),
        .probe_out4(wdatay),
        .probe_out5(kx_u),
        .probe_out6(bx_u),
        .probe_out7(kx_c),
        .probe_out8(bx_c),
        .probe_out9(ky_u),
        .probe_out10(by_u),
        .probe_out11(ky_c),
        .probe_out12(by_c),
        .probe_out13(reg_map_calib), // update
        .probe_out14(format_X),
        .probe_out15(format_Y),
        .probe_out16(value_X),
        .probe_out17(value_Y),
        .probe_out18(blank_on),
        .probe_out19(blank_off),
        .probe_out20(k_nm_u_x),
        .probe_out21(b_nm_u_x),
        .probe_out22(k_u_cd_x),
        .probe_out23(b_u_cd_x),
        .probe_out24(k_nm_u_y),
        .probe_out25(b_nm_u_y),
        .probe_out26(k_u_cd_y),
        .probe_out27(b_u_cd_y),
        .probe_out28(mode_ATS),
        .probe_out29(valid_i),
        .probe_out30(sync_exp)
    );
    
    ila_0 ila_0(
        .clk(GCLK),
        .probe0(sel_1_0),
        .probe1(sel_1_1),
        .probe2(sel_2_0),
        .probe3(sel_2_1),
        .probe4(sync),
        .probe5(data_out)
    );
endmodule
