module parallel_DAC_assembly #(     
    parameter DATA_WIDTH = 16    // ??? AD9777 ???????? ???????????? ? 16 ?????? ?? ?????
)(
    input logic clk_in,
    input logic rst_n,
    
    // ??????? ?????? ? ?????? AS2 ? ATS
    input logic [DATA_WIDTH-1:0] in_data_AS2_x,  // AS2 ?????????? X
    input logic [DATA_WIDTH-1:0] in_data_AS2_y,  // AS2 ?????????? Y
    input logic [DATA_WIDTH-1:0] in_data_ATS_x,  // ATS ?????????? X
    input logic [DATA_WIDTH-1:0] in_data_ATS_y,  // ATS ?????????? Y
    
    input  logic        valid_i,
    input  logic        sync_exp,
    input  logic  [3:0] mode,
    output logic        AS2_ATS_set,
    
    output logic        clk_1_0,
    output logic        clk_1_1,
    output logic        clk_2_0,
    output logic        clk_2_1,
    output logic        sync,   
    output logic [15:0] out_data
    
    );

    logic AS2_done;
    logic ATS_done;
    
    logic [15:0] out_data_AS2;
    logic [15:0] out_data_ATS;
    
    assign AS2_ATS_set = ATS_done;
    
    always_comb begin
        case (mode)
            calibration, alignment: begin
                sync = AS2_ATS_set;
            end
            exposure: begin
                sync = sync_exp;
            end
            default: begin
                sync = 1'b0; 
            end
        endcase 
    end
    
    always_comb begin
        if (clk_1_0 || clk_1_1) out_data <= out_data_AS2;
        else if (clk_2_0 || clk_2_1) out_data <= out_data_ATS;
        else out_data <= 15'b0;
    end
    
    parallel_DAC_common AS2(
        .clk_in(clk_in),
        .rst_n(rst_n),
        
        .channel_X(in_data_AS2_x),
        .channel_Y(in_data_AS2_y),
        
        .valid_i(valid_i),
        .mode(mode),
        
        .clk_a_0(clk_1_0),
        .clk_a_1(clk_1_1),
        
        .done(AS2_done),
        .out_data(out_data_AS2)
    );
    
    parallel_DAC_common ATS(
        .clk_in(clk_in),
        .rst_n(rst_n),
        
        .channel_X(in_data_ATS_x),
        .channel_Y(in_data_ATS_y),
        
        .valid_i(AS2_done),
        .mode(mode),
        
        .clk_a_0(clk_2_0),
        .clk_a_1(clk_2_1),
        
        .done(ATS_done),
        .out_data(out_data_ATS)
    );
    
endmodule
