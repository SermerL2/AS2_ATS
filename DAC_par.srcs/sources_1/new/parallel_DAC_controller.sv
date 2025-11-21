`timescale 1ns / 1ps

// "subject to change" CTRL+F for parts of code marked for changes

// модуль передачи данных от систем AS2 и ATS на соответствующие ЦАПы
module parallel_DAC_controller #(     
    parameter DATA_WIDTH = 16    // ЦАП AD9777 является параллельным и 16 битным на канал
)(
    input logic      in_clk,
    input logic      in_reset,
    
    // входные данные с систем AS2 и ATS
    input logic [DATA_WIDTH-1:0] in_data_AS2_x,  // AS2 координата X
    input logic [DATA_WIDTH-1:0] in_data_AS2_y,  // AS2 координата Y
    input logic [DATA_WIDTH-1:0] in_data_ATS_x,  // ATS координата X
    input logic [DATA_WIDTH-1:0] in_data_ATS_y,  // ATS координата Y
    
    input  logic        valid_i,   // 
    input  logic        sync_exp,  // входной сигнал переключения sync с AS4M
    input  mode_t       mode,      // режим работы
    output logic        AS2_ATS_set,
    
    output logic        sel_1_0,  // сигнал передачи данных AS2_x на соответствующие регистры
    output logic        sel_1_1,  // сигнал передачи данных AS2_y на соответствующие регистры
    output logic        sel_2_0,  // сигнал передачи данных ATS_x на соответствующие регистры
    output logic        sel_2_1,  // сигнал передачи данных ATS_y на соответствующие регистры
    output logic        sync,     // входной сигнал sync
    output logic [15:0] out_data  // шина данных на выход
);

    logic [15:0] data;
    logic [2:0] sel_r;  // счетчик для переключения между системами и координатами
    logic allow_proccess;
    
    logic             valid_internal;
    logic             busy;
    logic             busy_r;
    
    assign valid_internal = valid_i && ~busy_r;
    // управление сигналами busy и busy_r для формирования valid_internal
    always_ff @(posedge in_clk) begin
        if (~in_reset) begin
            busy <= 1'b0;
            busy_r <= 1'b0;
        end
        else begin
            if (valid_i) busy <= 1'b1;
            else if (~allow_proccess) busy <= 1'b0;
            else  busy <= 1'b0;
            if (allow_proccess || valid_i) busy_r <= busy;
            else busy_r <= 1'b0;
        end
    end
    
    // инкрементация и сброс счетчика
    always_ff @(posedge in_clk) begin
        if (!in_reset) begin
            sel_r <= 3'd0;
            allow_proccess <= 1'b0;
        end else begin
            if (valid_internal) allow_proccess <= 1'b1;
            if (allow_proccess || valid_internal) begin
                if (sel_r > 3'd4) begin sel_r <= 3'd0; allow_proccess<= 1'b0; end
                else begin sel_r <= sel_r + 3'd1; end
            end
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

    // логическая схема управление сигналами sel и sync
    // в зависимости от режима при совпадении счетчика с нужным числом переключается synq
    // или на sync прокидывается сигнал с AS4M
    // при совпадении счетчика с нужным числом переключается нужный sel
    always_comb begin
        case(mode)
            idle: begin
                sel_1_0 = 1'b0;
                sel_1_1 = 1'b0;
                sel_2_0 = 1'b0;
                sel_2_1 = 1'b0;
                AS2_ATS_set = 1'b0;
                sync = 1'b0; 
            end
            calibration, alignment: begin
                sel_1_0 = (sel_r == 3'b001);
                sel_1_1 = (sel_r == 3'b010);
                sel_2_0 = (sel_r == 3'b011);
                sel_2_1 = (sel_r == 3'b100);
                AS2_ATS_set = (sel_r == 3'b101);
                sync = (sel_r == 3'b101);
            end
            exposure: begin
                // this will be a subject to change
            end
        endcase
    end

endmodule