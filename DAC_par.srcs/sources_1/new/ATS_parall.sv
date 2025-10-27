typedef enum logic [3:0] {
    idle,
    manual,
    alignment,
    exposure
} mode_t;

module ATS_parall #(
    parameter int WIDTH = 32    // Signal width
)(
    input  logic clk,
    input  logic reset_n,

    input  logic [WIDTH-1:0] format_X,
    input  logic [WIDTH-1:0] format_Y,
    input  logic [WIDTH-1:0] value_X,
    input  logic [WIDTH-1:0] value_Y,
    
    input  logic             blank_on,
    input  logic             blank_off,
    
    input  logic [31:0]      k_nm_u_x,
    input  logic [31:0]      b_nm_u_x,
    
    input  logic [31:0]      k_u_cd_x,
    input  logic [31:0]      b_u_cd_x,
    
    input  logic [31:0]      k_nm_u_y,
    input  logic [31:0]      b_nm_u_y,
    
    input  logic [31:0]      k_u_cd_y,
    input  logic [31:0]      b_u_cd_y,
    
    input  mode_t mode,
    
    input  logic        valid_i,
    output logic        valid_o_x,
    output logic        valid_o_y,
    output logic [31:0] value_to_DAC_x,
    output logic [31:0] value_to_DAC_y,
    
    output logic blank_out
    );
    
    logic [WIDTH-1:0] x_in;
    logic [WIDTH-1:0] y_in;
    
    logic [WIDTH-1:0] x_stage_1;
    logic [WIDTH-1:0] y_stage_1;
    
    logic             ready_st2_x;
    logic             ready_st2_y;
    
    logic             valid_o_x_st1;
    logic             valid_o_y_st1;
    
    logic             valid_o_x_st2;
    logic             valid_o_y_st2;
    
    logic             valid_internal;
    logic             busy;
    logic             busy_r;
    
    assign valid_internal = valid_i && ~busy_r;
    
    assign valid_o_x = valid_o_x_st2;
    assign valid_o_y = valid_o_y_st2;
    
    always_comb begin
        case(mode)
            manual: begin x_in = value_X; y_in = value_Y; end
            alignment: begin x_in = format_X; y_in = format_Y; end
            default: begin x_in = 0; y_in = 0; end
        endcase
    end
    
    always_ff @(posedge clk) begin
        if (~reset_n) begin
            blank_out <= 1'b0;
        end
        else begin
            if (blank_on) blank_out <= 1'b1;
            if (blank_off)  blank_out <= 1'b0;
        end
    end
    
    always_ff @(posedge clk) begin
        if (~reset_n) begin
            busy <= 1'b0;
            busy_r <= 1'b0;
        end
        else begin
            if (valid_o_x_st2 && valid_o_y_st2) busy <= 1'b0;
            else if (valid_i) busy <= 1'b1;
            else  busy <= 1'b0;
            if (valid_o_x_st2 && valid_o_y_st2) busy_r <= 1'b0;
            else busy_r <= busy;
        end
    end
    
    fixed_point_linear #(.INTEGER_W(16), .FRACTIONAL_W(16)) fpl_x_1
    (
        .clk(clk),
        .rst_n(reset_n),
        
        .value_og(x_in),
        .k(k_nm_u_x),
        .b(b_nm_u_x),
        
        .valid_i(valid_internal),
        .ready_o(),
        
        .ready_i(ready_st2_x),
        .valid_o(valid_o_x_st1),
        .value_out(x_stage_1)
    );
    
    fixed_point_linear #(.INTEGER_W(16), .FRACTIONAL_W(16)) fpl_x_2
    (
        .clk(clk),
        .rst_n(reset_n),
        
        .value_og(x_stage_1),
        .k(k_u_cd_x),
        .b(b_u_cd_x),
        
        .valid_i(valid_o_x_st1),
        .ready_o(ready_st2_x),
        
        .ready_i(1'b1),
        .valid_o(valid_o_x_st2),
        .value_out(value_to_DAC_x)
    );
    
    fixed_point_linear #(.INTEGER_W(16), .FRACTIONAL_W(16)) fpl_y_1
    (
        .clk(clk),
        .rst_n(reset_n),
        
        .value_og(y_in),
        .k(k_nm_u_y),
        .b(b_nm_u_y),
        
        .valid_i(valid_internal),
        .ready_o(),
        
        .ready_i(ready_st2_y),
        .valid_o(valid_o_y_st1),
        .value_out(y_stage_1)
    );
    
    fixed_point_linear #(.INTEGER_W(16), .FRACTIONAL_W(16)) fpl_y_2
    (
        .clk(clk),
        .rst_n(reset_n),
        
        .value_og(y_stage_1),
        .k(k_u_cd_y),
        .b(b_u_cd_y),
        
        .valid_i(valid_o_y_st1),
        .ready_o(ready_st2_y),
        
        .ready_i(1'b1),
        .valid_o(valid_o_y_st2),
        .value_out(value_to_DAC_y)
    );
    
    
    
endmodule