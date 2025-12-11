// тип режим работы
module parallel_DAC_common(
    input logic clk_in,
    input logic rst_n,
    
    input logic [15:0] channel_X,
    input logic [15:0] channel_Y,
    
    input logic valid_i,
    input mode_t mode,
    
    output logic        clk_a_0, //(sel_1_0)
    output logic        clk_a_1, //(sel_1_1)
    
    output logic        done,
    
    output logic [15:0] out_data  // шина данных на выход
    );
    
    logic [1:0] sel_r;
    //logic [15:0] data;
    logic proccess;
    
    // инкрементация и сброс счетчика
    always_ff @(negedge clk_in) begin
        if (!rst_n) begin
            sel_r <= 2'd0;
            proccess <= 1'b0;
        end else begin
            if (valid_i && mode != idle) begin proccess <= 1'b1; sel_r <= sel_r + 2'd1; end
            if (proccess) begin
                if (sel_r > 2'd1) begin proccess <= 1'b0; sel_r <= 2'd0; end
                else begin sel_r <= sel_r + 2'd1; end
            end
        end
    end
    
    always_ff @(posedge clk_in) begin
        if (!rst_n) begin
            done <= 1'b0;
        end else begin
            if (sel_r > 2'd1) begin done <= 1'b1; end
            if (done) done <= 1'b0;
        end
    end
    
    // мультиплексирование входных данных на выход (в зависимости от счетчика)
//    always_comb begin
//        case(sel_r)
//            3'd1: data = channel_X;
//            3'd2: data = channel_Y;
//            default: data = 16'b0;
//        endcase
//    end
    
    // передача данных с мультиплексора на выход
    always_ff @(posedge clk_in) begin
        if(!rst_n) begin
            out_data <= 'd0;
        end else begin
            if (sel_r == 0) out_data <= channel_X;
            else if (sel_r == 1) out_data <= channel_Y;
            else out_data <= 16'b0;
        end
    end
    
    // логическая схема управление сигналами sel и sync
    // в зависимости от режима при совпадении счетчика с нужным числом переключается synq
    // или на sync прокидывается сигнал с AS4M
    // при совпадении счетчика с нужным числом переключается нужный sel
    always_comb begin
        case(mode)
            idle: begin
                clk_a_0 = 1'b0;
                clk_a_1 = 1'b0;
            end
            calibration, alignment: begin
                clk_a_0 = (sel_r == 2'd1);
                clk_a_1 = (sel_r == 2'd2);
            end
            exposure: begin
                // this will be a subject to change
            end
        endcase
    end
    
endmodule
