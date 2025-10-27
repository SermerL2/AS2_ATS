`timescale 1ns / 1ps

typedef enum logic [0:0] {
    alignment_dac = 0,
    exposure_dac = 1
} mode_DAC_t;

module parallel_DAC_controller #(     
    parameter FIFO_DEPTH = 4,
    parameter DATA_WIDTH = 16,
    parameter START_NUMBER = 4       
)(
    input logic      in_clk,
    input logic      in_reset,
    input logic [DATA_WIDTH-1:0] in_data_AS2_x,
    input logic [DATA_WIDTH-1:0] in_data_AS2_y,
    input logic [DATA_WIDTH-1:0] in_data_ATS_x,
    input logic [DATA_WIDTH-1:0] in_data_ATS_y,
    
    input  logic        sync_exp,
    input  mode_DAC_t   mode,
    
    output logic        sel_1_0,
    output logic        sel_1_1,
    output logic        sel_2_0,
    output logic        sel_2_1,
    output logic        sync,
    output logic [15:0] out_data
);

    logic [15:0] data;
    logic [2:0] sel_r;
    
    always_ff @(posedge in_clk) begin
        if (!in_reset) begin
            sel_r <= 3'd0;
        end else begin
            if (sel_r > 3'd4) sel_r <= 3'd0;
            else sel_r <= sel_r + 3'd1;
        end
    end

    always_comb begin
        case(sel_r)
            3'd0: data = in_data_AS2_x;
            3'd1: data = in_data_AS2_y;
            3'd2: data = in_data_ATS_x;
            3'd3: data = in_data_ATS_y;
            default: data = 16'b0;
        endcase
    end

    // Output data register
    always_ff @(posedge in_clk or negedge in_reset) begin
        if(!in_reset) begin
            out_data <= 'd0;
        end else begin
            out_data <= data;
        end
    end

    assign sel_1_0 = (sel_r == 3'b001);
    assign sel_1_1 = (sel_r == 3'b010);
    assign sel_2_0 = (sel_r == 3'b011);
    assign sel_2_1 = (sel_r == 3'b100);
    assign sync    = mode ? sync_exp : (sel_r == 3'b101);

endmodule