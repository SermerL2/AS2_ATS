`timescale 1ns / 1ps

module top#(       
    parameter FIFO_DEPTH = 16,
    parameter DATA_WIDTH = 32,
    parameter START_NUMBER = 0    
)(
    input  logic        clk,
    input  logic        rst_n,
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
    
    output logic  valid_o,
    input  logic  ready_i,
    output logic [15:0] data_out

);

 logic [31:0]  in_data;
 logic  in_valid;
    logic                  u_ready;
    logic                  u_valid;
    logic [DATA_WIDTH-1:0] u_data;
    
    logic                  c_ready;
    logic                  c_valid;
    logic [DATA_WIDTH-1:0] c_data;  

    
    logic [DATA_WIDTH-1:0] k_u;
    logic [DATA_WIDTH-1:0] b_u;
    
    logic [DATA_WIDTH-1:0] k_c;
    logic [DATA_WIDTH-1:0] b_c;
    
    logic [DATA_WIDTH-1:0] wdata;
    logic  wvalid;
    logic  store_valid;
    logic  done; 
    
    assign data_out = in_data[15:0];
    assign valid_o = in_valid;
    
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        store_valid <= 1'b0;
        done<= 1'b0;
    end else begin
        if (validx && validy) begin
            store_valid <= validy;
            done <= validy;
        end else if (!validx && !validy && u_valid) begin
            done <= store_valid;
            store_valid <=1'b0;
        end
    end
end

always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
        wdata <= '0;
        k_u <= '0;
        b_u <= '0;
        k_c <= '0;
        b_c <= '0;
        wvalid <= 1'b0;
    end else if (validx) begin
        wdata <= wdatax;
        k_u <= kx_u;
        b_u <= bx_u;
        wvalid <= validx;
    end else if (u_valid) begin
        if (store_valid) begin
            wdata <= wdatay;
            k_u <= ky_u;
            b_u <= by_u;
            k_c <= kx_c;
            b_c <= bx_c;
            wvalid <= u_valid;
        end else if (done) begin
            k_c <= ky_c;
            b_c <= by_c;
        end
    end else begin
        wdata <= '0;
        wvalid <= 1'b0;
    end
end
 
    fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(FIFO_DEPTH)
    ) fifo_inst (
        .clk(clk),
        .reset_n(rst_n),
        .s_axis_tdata(in_data),
        .s_axis_tvalid(in_valid),
        .s_axis_tready(ready_i),
    
        .m_axis_tdata({wdata[31:16],c_data[31:16]}),
        .m_axis_tvalid(c_valid),
        .m_axis_tready(c_ready)
    );

fixed_point_linear mult_u (
    .clk(clk),
    .rst_n(rst_n),
    
    .value_og({wdata[15:0],16'b0}),
    .k(k_u),
    .b(b_u),
    .valid_i(wvalid),
    .ready_o(wready),
    
    .ready_i(u_ready),
    .valid_o(u_valid),
    .value_out(u_data)
);
fixed_point_linear mult_code (
    .clk(clk),
    .rst_n(rst_n),
    
    .value_og(u_data),
    .k(k_c),
    .b(b_c),
    .valid_i(u_valid),
    .ready_o(u_ready),
    
    .ready_i(c_ready),
    .valid_o(c_valid),
    .value_out(c_data)
);


endmodule