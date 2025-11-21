// тип режим работы
typedef enum logic [3:0] {
    idle,       // простой системы
    calibration,
    alignment,  // режим юстировки
    exposure    // режим экспонирования
} mode_t;       

// модуль преобразования данных из нм в код ЦАП системы ATS
module ATS_parall #(
    parameter int WIDTH = 32    // Signal width
)(
    input  logic clk,
    input  logic reset_n,
    
    // входные данные задаваемых значений в нм (задаются в формате Q16.16)
    input  logic [WIDTH-1:0] format_X, // передача формата с AS4M (при экспонировании)
    input  logic [WIDTH-1:0] format_Y, // передача формата с AS4M (при экспонировании)
    input  logic [WIDTH-1:0] value_X,  // передача значения с регистровой карты
    input  logic [WIDTH-1:0] value_Y,  // передача значения с регистровой карты
    
    // сигналы управления бланкировщиком (с регистровой карты)
    input  logic             blank_on,
    input  logic             blank_off,
    
    // коэфициенты преобразования входных данных
    input  logic [31:0]      k_nm_u_x,  // угловой коэфициент значения данных OX из нм в напряжение
    input  logic [31:0]      b_nm_u_x,  // коэфициент сдвига значения данных OX из нм в напряжение
    
    input  logic [31:0]      k_u_cd_x,  // угловой коэфициент значения данных OX из напряжения в код ЦАП
    input  logic [31:0]      b_u_cd_x,  // коэфициент сдвига значения данных OX из напряжения в код ЦАП
    
    input  logic [31:0]      k_nm_u_y,  // угловой коэфициент значения данных OY из нм в напряжение
    input  logic [31:0]      b_nm_u_y,  // коэфициент сдвига значения данных OY из нм в напряжение
    
    input  logic [31:0]      k_u_cd_y,  // угловой коэфициент значения данных OY из напряжения в код ЦАП
    input  logic [31:0]      b_u_cd_y,  // коэфициент сдвига значения данных OY из напряжения в код ЦАП
    
    // режим работы (с регистровой карты)
    input  mode_t mode,
    
    // сигналы взаимодействия с регистровой карто1
    input  logic        valid_i,    // данные на вход преобразования обновились
    output logic        valid_o_x,  // данные на выходе преобразования OX переданы на ЦАП
    output logic        valid_o_y,  // данные на выходе преобразования OY переданы на ЦАП
    
    // выходные данные на ЦАП
    output logic [31:0] value_to_DAC_x,
    output logic [31:0] value_to_DAC_y,
    
    // сигнал управления бланкировщиком (на аналоговую схему коммутации)
    output logic blank_out
    );
    
    // данные для обработки (принимают либо format либо value)
    logic [WIDTH-1:0] x_in;
    logic [WIDTH-1:0] y_in;
    
    // результаты 1-го этапа преобразования (из нм в напряжение)
    logic [WIDTH-1:0] x_stage_1;
    logic [WIDTH-1:0] y_stage_1;
    
    // сигналы готовности данных на выходе 2-го этапа преобразование (из напряжения в код ЦАП)
    logic             ready_st2_x;
    logic             ready_st2_y;
    
    // сигналы обновления данных на входе 1-го этапа преобразование (из нм в напряжение)
    logic             valid_o_x_st1;
    logic             valid_o_y_st1;
    
    // сигналы обновления данных на входе 2-го этапа преобразование (из нм в напряжение)
    logic             valid_o_x_st2;
    logic             valid_o_y_st2;
    
    // сигналы формирования однотактного сигнала, сигнализирующего об обновлении данных на входк
    logic             valid_internal;
    logic             busy;
    logic             busy_r;
    
    assign valid_internal = valid_i && ~busy_r;
    
    assign valid_o_x = valid_o_x_st2;
    assign valid_o_y = valid_o_y_st2;
    
    // выбор входных данных в зависимости от режима работы
    always_comb begin
        case(mode)
            alignment: begin x_in = value_X; y_in = value_Y; end
            exposure: begin x_in = format_X; y_in = format_Y; end
            default: begin x_in = 0; y_in = 0; end
        endcase
    end
    
    // управление бланкировщиком
    always_ff @(posedge clk) begin
        if (~reset_n) begin
            blank_out <= 1'b0;
        end
        else begin
            if (blank_on) blank_out <= 1'b1;
            if (blank_off)  blank_out <= 1'b0;
        end
    end
    
    // управление сигналами busy и busy_r для формирования valid_internal
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
    
    // набор из 4-х умножителей (2 умножителя на 2 координаты)
    
    fixed_point_linear #(.INTEGER_W(16), .FRACTIONAL_W(16)) fpl_x_1
    (
        .clk(clk),
        .rst_n(reset_n),
        
        .value_og(x_in),  // входное значение X (в нм)
        .k(k_nm_u_x),     // угловой коэфициент 1-го этапа
        .b(b_nm_u_x),     // коэфициент сдвига 1-го этапа
        
        .valid_i(valid_internal),  // сигнал об обновлении входных данных (разрешает работу 1-го этапа)
        .ready_o(),                // сигнал о готовности принять данные (не используется)
        
        .ready_i(ready_st2_x),     // сигнал о готовности принять данные от 2-го этапа умножения
        .valid_o(valid_o_x_st1),   // сигнал о готовности данных на выходе умножителя
        .value_out(x_stage_1)      // выходное значение X (в В)
    );
    
    fixed_point_linear #(.INTEGER_W(16), .FRACTIONAL_W(16)) fpl_x_2
    (
        .clk(clk),
        .rst_n(reset_n),
        
        .value_og(x_stage_1),  // входное значение X (в В)
        .k(k_u_cd_x),          // угловой коэфициент 2-го этапа
        .b(b_u_cd_x),          // коэфициент сдвига 2-го этапа
        
        .valid_i(valid_o_x_st1),  // сигнал о готовности данных на выходе 1-го этапа (разрешает работу 2-го этапа)
        .ready_o(ready_st2_x),    // сигнал о готовности принять данные
        
        .ready_i(1'b1),              // сигнал о готовности принять данные от следующего этапа (его нет, поэтому постоянно отправляем данные на выход)
        .valid_o(valid_o_x_st2),     // сигнал о готовности данных на выходе умножителя
        .value_out(value_to_DAC_x)   // выходное значение X (код ЦАП)
    );
    
    fixed_point_linear #(.INTEGER_W(16), .FRACTIONAL_W(16)) fpl_y_1
    (
        .clk(clk),
        .rst_n(reset_n),
        
        .value_og(y_in),  // входное значение Y (в нм)
        .k(k_nm_u_y),     // угловой коэфициент 1-го этапа
        .b(b_nm_u_y),     // коэфициент сдвига 1-го этапа
        
        .valid_i(valid_internal),  // сигнал об обновлении входных данных (разрешает работу 1-го этапа)
        .ready_o(),                // сигнал о готовности принять данные (не используется)
        
        .ready_i(ready_st2_y),     // сигнал о готовности принять данные от 2-го этапа умножения
        .valid_o(valid_o_y_st1),   // сигнал о готовности данных на выходе умножителя
        .value_out(y_stage_1)      // выходное значение Y (в В)
    );
    
    fixed_point_linear #(.INTEGER_W(16), .FRACTIONAL_W(16)) fpl_y_2
    (
        .clk(clk),
        .rst_n(reset_n),
        
        .value_og(y_stage_1),  // входное значение Y (в В)
        .k(k_u_cd_y),          // угловой коэфициент 2-го этапа
        .b(b_u_cd_y),          // коэфициент сдвига 2-го этапа
        
        .valid_i(valid_o_y_st1),  // сигнал о готовности данных на выходе 1-го этапа (разрешает работу 2-го этапа)
        .ready_o(ready_st2_y),    // сигнал о готовности принять данные
        
        .ready_i(1'b1),              // сигнал о готовности принять данные от следующего этапа (его нет, поэтому постоянно отправляем данные на выход)
        .valid_o(valid_o_y_st2),     // сигнал о готовности данных на выходе умножителя
        .value_out(value_to_DAC_y)   // выходное значение Y (код ЦАП)
    );
    
endmodule