`timescale 1ns / 1ps

module top#(       
    parameter FIFO_DEPTH = 16,
    parameter DATA_WIDTH = 32,
    parameter DATA_WIDTH_XY = 16,
    parameter START_NUMBER = 0    
)(
    input  logic        clk,
    input  logic        rst,
    input  logic [DATA_WIDTH_XY-1:0] wdatax,
    input  logic [DATA_WIDTH_XY-1:0] wdatay,
    
    input  logic [DATA_WIDTH-1:0] kx_u,
    input  logic [DATA_WIDTH-1:0] bx_u,
    
    input  logic [DATA_WIDTH-1:0] kx_c,
    input  logic [DATA_WIDTH-1:0] bx_c,
    
    input  logic [DATA_WIDTH-1:0] ky_u,
    input  logic [DATA_WIDTH-1:0] by_u,
    
    input  logic [DATA_WIDTH-1:0] ky_c,
    input  logic [DATA_WIDTH-1:0] by_c,
    input  logic [1:0]  start,

    output logic [DATA_WIDTH-1:0] c_data_x, 
    output logic [DATA_WIDTH-1:0] c_data_y,
    output logic  c_valid_x,
    output logic  c_valid_y
);

    logic                  u_ready_x;
    logic                  u_valid_x;
    logic                  u_ready_y;
    logic                  u_valid_y;
    logic [DATA_WIDTH-1:0] u_data_x;
    logic [DATA_WIDTH-1:0] u_data_y;
    logic  wvalid;
    logic [3:0] counter;
   always_ff @(posedge clk or negedge rst) begin
        if(!rst) begin
            wvalid <= 'd0;
        end else if (counter == 4'd10) begin
            wvalid <= 1'b1;
            end else wvalid <= 1'b0;
    end 
    always_ff @(posedge clk or negedge rst) begin
        if(!rst) begin
            counter <= 'b0;
        end else if (counter == 4'd10) begin
            counter <= 3'b0; 
        end else if (start == 2'b01) begin
            counter <= counter + 1'b1;
        end
    end

fixed_point_linear mult_u_x (
    .clk(clk),
    .rst_n(rst),
    
    .value_og({wdatax,16'b0}),
    .k(kx_u),
    .b(bx_u),
    .valid_i(wvalid),
    .ready_o(),
    
    .ready_i(u_ready_x),
    .valid_o(u_valid_x),
    .value_out(u_data_x)
);
fixed_point_linear mult_code_x (
    .clk(clk),
    .rst_n(rst),
    
    .value_og(u_data_x),
    .k(kx_c),
    .b(bx_c),
    .valid_i(u_valid_x),
    .ready_o(u_ready_x),
    
    .ready_i(1'b1),
    .valid_o(c_valid_x),
    .value_out(c_data_x)
);
fixed_point_linear mult_u_y (
    .clk(clk),
    .rst_n(rst),
    
    .value_og({wdatay,16'b0}),
    .k(ky_u),
    .b(by_u),
    .valid_i(wvalid),
    .ready_o(),
    
    .ready_i(u_ready_y),
    .valid_o(u_valid_y),
    .value_out(u_data_y)
);
fixed_point_linear mult_code_y (
    .clk(clk),
    .rst_n(rst),
    
    .value_og(u_data_y),
    .k(ky_c),
    .b(by_c),
    .valid_i(u_valid_y),
    .ready_o(u_ready_y),
    
    .ready_i(1'b1),
    .valid_o(c_valid_y),
    .value_out(c_data_y)
);

endmodule