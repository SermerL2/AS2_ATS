`timescale 1ns / 1ps

module parallel_DAC_controller #(     
    parameter FIFO_DEPTH = 4,
    parameter DATA_WIDTH = 16,
    parameter START_NUMBER = 4       
)(
    input logic      in_clk,
    input logic      in_reset,
    input logic [DATA_WIDTH-1:0] in_data,
    input logic      valid,

    output logic        ready,
    output logic        sel_1_0,
    output logic        sel_1_1,
    output logic        sel_2_0,
    output logic        sel_2_1,
    output logic        AS2_r,
    output logic [15:0] out_data
);

    logic [15:0] data;
    logic [2:0] sel_r;
    logic ready_reg;
    
    assign data [15:0] = in_data[15:0];

    // Ready signal logic - delays next value change by 1 clock cycle

    // Output data register
    always_ff @(posedge in_clk or negedge in_reset) begin
        if(!in_reset) begin
            out_data <= 'd0;
        end else begin
            if (valid) begin
                out_data <= data;
            end 
        end
    end
    
    // Selection logic - now gated with ready signal
    always_ff @(posedge in_clk) begin
        if (!in_reset) begin
            sel_r <= 'b0;
            AS2_r <= 1'b0;
        end else if (valid) begin
            sel_r <= sel_r + 1'b1;
        end if(sel_r == 3'b010) begin
            AS2_r <= 1'b1;
        end else if(sel_r == 3'b100) begin
            sel_r <= 'b0;
            AS2_r <= 1'b0;
        end
    end

    assign sel_1_0 = (sel_r == 3'b001);
    assign sel_1_1 = (sel_r == 3'b010);
    assign sel_2_0 = (sel_r == 3'b011);
    assign sel_2_1 = (sel_r == 3'b100);

endmodule