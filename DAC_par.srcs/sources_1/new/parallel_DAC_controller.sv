`timescale 1ns / 1ps

// тип режим работы выставлени€ данных
typedef enum logic [0:0] {
    alignment_dac = 0,  // юстировка (данные на выходе посто€нно обновл€ютс€ благодар€ переключению sync)
    exposure_dac = 1    // экспонирование (данные на выходе обновл€ютс€ по синхросигналу с системы AS4M)
} mode_DAC_t;

// модуль передачи данных от систем AS2 и ATS на соответствующие ÷јѕы
module parallel_DAC_controller #(     
    parameter DATA_WIDTH = 16    // ÷јѕ AD9777 €вл€етс€ параллельным и 16 битным на канал
)(
    input logic      in_clk,
    input logic      in_reset,
    
    // входные данные с систем AS2 и ATS
    input logic [DATA_WIDTH-1:0] in_data_AS2_x,  // AS2 координата X
    input logic [DATA_WIDTH-1:0] in_data_AS2_y,  // AS2 координата Y
    input logic [DATA_WIDTH-1:0] in_data_ATS_x,  // ATS координата X
    input logic [DATA_WIDTH-1:0] in_data_ATS_y,  // ATS координата Y
    
    input  logic        sync_exp,  // входной сигнал переключени€ sync с AS4M
    input  mode_DAC_t   mode,      // режим работы
    
    output logic        sel_1_0,  // сигнал передачи данных AS2_x на соответствующие регистры
    output logic        sel_1_1,  // сигнал передачи данных AS2_y на соответствующие регистры
    output logic        sel_2_0,  // сигнал передачи данных ATS_x на соответствующие регистры
    output logic        sel_2_1,  // сигнал передачи данных ATS_y на соответствующие регистры
    output logic        sync,     // входной сигнал sync
    output logic [15:0] out_data  // шина данных на выход
);

    logic [15:0] data;
    logic [2:0] sel_r;  // счетчик дл€ переключени€ между системами и координатами
    
    // инкрементаци€ и сброс счетчика
    always_ff @(posedge in_clk) begin
        if (!in_reset) begin
            sel_r <= 3'd0;
        end else begin
            if (sel_r > 3'd4) sel_r <= 3'd0;
            else sel_r <= sel_r + 3'd1;
        end
    end

    // мультиплексирование входных данных на выход (в зависимости от счетчика)
    always_comb begin
        case(sel_r)
            3'd0: data = in_data_AS2_x;
            3'd1: data = in_data_AS2_y;
            3'd2: data = in_data_ATS_x;
            3'd3: data = in_data_ATS_y;
            default: data = 16'b0;
        endcase
    end

    // передача данных с мультиплексора на выход
    always_ff @(posedge in_clk or negedge in_reset) begin
        if(!in_reset) begin
            out_data <= 'd0;
        end else begin
            out_data <= data;
        end
    end

    // логическа€ схема управление сигналами sel и sync
    assign sel_1_0 = (sel_r == 3'b001);  // при совпадении счетчика с нужным числом переключаетс€ нужный sel
    assign sel_1_1 = (sel_r == 3'b010);  // при совпадении счетчика с нужным числом переключаетс€ нужный sel
    assign sel_2_0 = (sel_r == 3'b011);  // при совпадении счетчика с нужным числом переключаетс€ нужный sel
    assign sel_2_1 = (sel_r == 3'b100);  // при совпадении счетчика с нужным числом переключаетс€ нужный sel
    assign sync    = mode ? sync_exp : (sel_r == 3'b101);  // в зависимости от режима
                                                           // при совпадении счетчика с нужным числом переключаетс€ synq
                                                           // или на sync прокидываетс€ сигнал с AS4M

endmodule