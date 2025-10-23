typedef enum logic [3:0] {
    idle,
    manual,
    alignment,
    exposure
} mode_t;

module ATS_main #(
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
    
    input  logic [3:0]  valid_i,
    input  logic        ready_i,
    output logic        valid_o,
    output logic [31:0] value_to_DAC,
    
    output logic blank_out
    );
    
    logic [3:0]       valid_save;
    
    logic  process;
    logic  busy;
    mode_t mode_r;
    
    logic [WIDTH-1:0] value_nm_voltage;
    logic [31:0]      k_nm_voltage;
    logic [31:0]      b_nm_voltage;
    logic             valid_i_nm_voltage;
    logic             ready_o_nm_voltage;
    logic             valid_o_nm_voltage;
    logic [WIDTH-1:0] value_voltage_code;
    
    logic        ready_o_delay_k_b;
    logic        valid_o_delay_k_b;
    logic [63:0] second_stage_k_b;
    logic [63:0] second_stage_k_b_delay;
    
    logic             ready_stage_2;
    logic             valid_o_stage_2;
    logic [WIDTH-1:0] value_code_DAC;
    
    logic enable_pipe;
    
    logic             fifo_ready_o;
    logic             fifo_valid_o;
    logic [WIDTH-1:0] fifo_code_DAC_out;
    
    assign valid_o = fifo_valid_o;
    assign value_to_DAC = fifo_code_DAC_out;
    
    always_ff @(posedge clk) begin
        if (~reset_n) begin
            //ready_o <= 1'b0;
            valid_save <= 4'b0;
            
            process <= 1'b0;
            busy <= 1'b0;
            mode_r <= idle;
            
            value_nm_voltage <= {WIDTH * {1'b0}};
            k_nm_voltage <= 31'b0;
            b_nm_voltage <= 31'b0;
            valid_i_nm_voltage <= 1'b0;
            
            second_stage_k_b <= 63'b0;
            
            enable_pipe <= 1'b0;
        end
        else begin
            if (valid_i[0] && ~busy) begin valid_save[0] = 1'b1; end
            if (valid_i[1] && ~busy) begin valid_save[1] = 1'b1; end
            if (valid_i[2] && ~busy) begin valid_save[2] = 1'b1; end
            if (valid_i[3] && ~busy) begin valid_save[3] = 1'b1; end
            if (~busy) mode_r <= mode;
            case(mode_r)
                idle: enable_pipe <= 1'b0;
                manual: begin
                    enable_pipe <= 1'b1;
                    if (valid_save[2]) begin // && ~valid_save[0] && ~valid_save[1]
                        process <= 1'b1; busy <= 1'b1;
                        value_nm_voltage <= value_X; k_nm_voltage <= k_nm_u_x; b_nm_voltage <= b_nm_u_x; //value_X_reg
                        second_stage_k_b <= {k_u_cd_x, b_u_cd_x};
                        if (ready_o_nm_voltage && valid_o_nm_voltage) begin valid_save[2] <= 1'b0; process <= 1'b0; end
                        if (~process) valid_i_nm_voltage <= 1'b1;
                        else valid_i_nm_voltage <= 1'b0;
                    end
                    else if (valid_save[3]) begin // && ~valid_save[0] && ~valid_save[1]
                        process <= 1'b1; busy <= 1'b1;
                        value_nm_voltage <= value_Y; k_nm_voltage <= k_nm_u_y; b_nm_voltage <= b_nm_u_y; //value_Y_reg
                        second_stage_k_b <= {k_u_cd_y, b_u_cd_y};
                        if (ready_o_nm_voltage && valid_o_nm_voltage) begin valid_save[3] <= 1'b0; process <= 1'b0; end
                        if (~process) valid_i_nm_voltage <= 1'b1;
                        else valid_i_nm_voltage <= 1'b0;
                    end
                    else begin process <= 1'b0; busy <= 1'b0; end
                    //if (ready_o_nm_voltage) valid_i_nm_voltage <= 1'b0;
                end
                alignment: begin
                    enable_pipe <= 1'b1;
                    if (valid_save[0]) begin
                        process <= 1'b1; busy <= 1'b1;
                        value_nm_voltage <= format_X >> 1; k_nm_voltage <= k_nm_u_x; b_nm_voltage <= b_nm_u_x;
                        second_stage_k_b <= {k_u_cd_x, b_u_cd_x};
                        if (ready_o_nm_voltage && valid_o_nm_voltage) begin valid_save[0] <= 1'b0; process <= 1'b0; end
                        if (~process) valid_i_nm_voltage <= 1'b1;
                        else valid_i_nm_voltage <= 1'b0;
                    end
                    else if (valid_save[1]) begin
                        process <= 1'b1; busy <= 1'b1;
                        value_nm_voltage <= format_Y >> 1; k_nm_voltage <= k_nm_u_y; b_nm_voltage <= b_nm_u_y;
                        second_stage_k_b <= {k_u_cd_y, b_u_cd_y};
                        if (ready_o_nm_voltage && valid_o_nm_voltage) begin valid_save[1] <= 1'b0; process <= 1'b0; end
                        if (~process) valid_i_nm_voltage <= 1'b1;
                        else valid_i_nm_voltage <= 1'b0;
                    end
                    else begin process <= 1'b0; busy <= 1'b0; end
                    //if (ready_o_nm_voltage) valid_i_nm_voltage <= 1'b0; new comment 2.0
                end
            endcase
        end
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
    
    fixed_point_linear #(.INTEGER_W(16), .FRACTIONAL_W(16)) fpl_stage_1
    (
        .clk(clk),
        .rst_n(reset_n),
        
        .value_og({value_nm_voltage}),
        .k(k_nm_voltage),
        .b(b_nm_voltage),
        
        .valid_i(valid_i_nm_voltage),
        .ready_o(ready_o_nm_voltage),
        
        .ready_i(ready_stage_2),
        .valid_o(valid_o_nm_voltage),
        .value_out(value_voltage_code)
    );
    
    signal_delay #(.WIDTH(64), .N(5)) delay_k_b
    (
        .clk(clk),
        .rst_n(reset_n),
        
        .data_in(second_stage_k_b),  
        .valid_in(valid_i_nm_voltage), 
        .ready_out(ready_o_delay_k_b),
         
        .data_out(second_stage_k_b_delay), 
        .valid_out(valid_o_delay_k_b),
        .ready_in(ready_stage_2) 
    );
    
        fixed_point_linear #(.INTEGER_W(16), .FRACTIONAL_W(16)) fpl_stage_2
    (
        .clk(clk),
        .rst_n(reset_n),
        
        .value_og(value_voltage_code),
        .k(second_stage_k_b_delay[63:32]),
        .b(second_stage_k_b_delay[31:0]),
        
        .valid_i(valid_o_nm_voltage && valid_o_delay_k_b),
        .ready_o(ready_stage_2),
        
        .ready_i(fifo_ready_o),
        .valid_o(valid_o_stage_2),
        .value_out(value_code_DAC)
    );
    
    fifo_1 #(.DATA_WIDTH(32), .DEPTH(10)) fifo
    (
        .clk_i(clk),
        .rst_i(reset_n),
        
        .write_data_i(value_code_DAC),
        .valid_i(valid_o_stage_2),
        .ready_o(fifo_ready_o),
        
        .ready_i(enable_pipe && ready_i),
        .valid_o(fifo_valid_o),
        .read_data_o(fifo_code_DAC_out)
    );
    
endmodule
