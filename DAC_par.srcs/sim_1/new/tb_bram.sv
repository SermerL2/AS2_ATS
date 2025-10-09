`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.10.2025 13:43:34
// Design Name: 
// Module Name: tb_bram
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_bram;


  // ��������� ���������
  parameter RAM_WIDTH     = 32;
  parameter RAM_ADDR_BITS = 4;  // ��������� ��� �������� ������������
  parameter RAM_DEPTH     = 2**RAM_ADDR_BITS;
  parameter CLK_PERIOD    = 10;

  // ������� ���������
  logic                     clk_i;
  logic [RAM_ADDR_BITS-1:0] addr_a_i;
  logic [RAM_ADDR_BITS-1:0] addr_b_i;
  logic [RAM_WIDTH-1:0]     data_a_i;
  logic [RAM_WIDTH-1:0]     data_b_i;
  logic                     we_a_i;
  logic                     we_b_i;
  logic                     en_a_i;
  logic                     en_b_i;
  logic [RAM_WIDTH-1:0]     data_a_o;
  logic [RAM_WIDTH-1:0]     data_b_o;

  // ������� ������
  int cycle_count;

  // ��������� ������������ ������
  true_dual_port #(
    .RAM_WIDTH(RAM_WIDTH),
    .RAM_ADDR_BITS(RAM_ADDR_BITS)
  ) dut (
    .clk_i(clk_i),
    .addr_a_i(addr_a_i),
    .addr_b_i(addr_b_i),
    .data_a_i(data_a_i),
    .data_b_i(data_b_i),
    .we_a_i(we_a_i),
    .we_b_i(we_b_i),
    .en_a_i(en_a_i),
    .en_b_i(en_b_i),
    .data_a_o(data_a_o),
    .data_b_o(data_b_o)
  );

  // ��������� ��������� �������
  initial begin
    clk_i = 0;
    forever #(CLK_PERIOD/2) clk_i = ~clk_i;
  end

  // �������� ������� ������������
  initial begin
    // ������������� ��������
    initialize();
    
    $display("=== ������ ������������ BRAM ===");
    $display("�����: %0t", $time);
    
    // ���� 1: ������ ����� ���� A, ������ ����� ���� A
    $display("\n--- ���� 1: ������ � ������ ����� ���� A ---");
    test_write_read_port_a();
    
    // ���� 2: ������ ����� ���� B, ������ ����� ���� B
    $display("\n--- ���� 2: ������ � ������ ����� ���� B ---");
    test_write_read_port_b();
    
    // ���� 3: ������������� ������ ����� ������
    $display("\n--- ���� 3: ������������� ������ ������ A � B ---");
    test_simultaneous_ports();
    
    // ���� 4: �������� ������ � ���� ������
    $display("\n--- ���� 4: �������� ������ � ���� ������ ---");
    test_write_conflict();
    
    // ���� 5: ������������ ����������� ������
    $display("\n--- ���� 5: ������������ ����������� ������ ---");
    test_disabled_ports();
    
    $display("\n=== ������������ ��������� ===");
    $display("����� ������: %0d", cycle_count);
    $finish;
  end

  // ������� ������
  always @(posedge clk_i) begin
    cycle_count <= cycle_count + 1;
  end

  // ������ �������������
  task initialize();
    addr_a_i = '0;
    addr_b_i = '0;
    data_a_i = '0;
    data_b_i = '0;
    we_a_i   = '0;
    we_b_i   = '0;
    en_a_i   = '0;
    en_b_i   = '0;
    cycle_count = 0;
    wait_n_cycles(2);
  endtask

  // ������ �������� N ������
  task wait_n_cycles(int n);
    repeat(n) @(posedge clk_i);
  endtask

  // ����: ������ � ������ ����� ���� A
  task test_write_read_port_a();
    // ������ ������ ����� ���� A
    for (int i = 0; i < 4; i++) begin
      @(posedge clk_i);
      en_a_i   <= 1;
      we_a_i   <= 1;
      addr_a_i <= i;
      data_a_i <= i + 8'h10;
      $display("������ ����� ���� A: addr=%0d, data=0x%h", i, i + 8'h10);
    end
    
    // ���������� ������
    @(posedge clk_i);
    we_a_i <= 0;
    wait_n_cycles(1);
    
    // ������ ������ ����� ���� A
    for (int i = 0; i < 4; i++) begin
      @(posedge clk_i);
      en_a_i   <= 1;
      we_a_i   <= 0;
      addr_a_i <= i;
      wait_n_cycles(1);
      $display("������ ����� ���� A: addr=%0d, data=0x%h (��������� 0x%h)", 
               i, data_a_o, i + 8'h10);
      assert(data_a_o == i + 8'h10) else $error("������ ������ ����� A!");
    end
    
    @(posedge clk_i);
    en_a_i <= 0;
  endtask

  // ����: ������ � ������ ����� ���� B
  task test_write_read_port_b();
    // ������ ������ ����� ���� B
    for (int i = 4; i < 8; i++) begin
      @(posedge clk_i);
      en_b_i   <= 1;
      we_b_i   <= 1;
      addr_b_i <= i;
      data_b_i <= i + 8'h20;
      $display("������ ����� ���� B: addr=%0d, data=0x%h", i, i + 8'h20);
    end
    
    // ���������� ������
    @(posedge clk_i);
    we_b_i <= 0;
    wait_n_cycles(1);
    
    // ������ ������ ����� ���� B
    for (int i = 4; i < 8; i++) begin
      @(posedge clk_i);
      en_b_i   <= 1;
      we_b_i   <= 0;
      addr_b_i <= i;
      wait_n_cycles(1);
      $display("������ ����� ���� B: addr=%0d, data=0x%h (��������� 0x%h)", 
               i, data_b_o, i + 8'h20);
      assert(data_b_o == i + 8'h20) else $error("������ ������ ����� B!");
    end
    
    @(posedge clk_i);
    en_b_i <= 0;
  endtask

  // ����: ������������� ������ ������
  task test_simultaneous_ports();
    // ������������� ������ � ������ ������
    @(posedge clk_i);
    en_a_i   <= 1;
    en_b_i   <= 1;
    we_a_i   <= 1;
    we_b_i   <= 1;
    addr_a_i <= 10;
    addr_b_i <= 11;
    data_a_i <= 8'hAA;
    data_b_i <= 8'hBB;
    $display("������������� ������: A(addr=10)=0xAA, B(addr=11)=0xBB");
    
    @(posedge clk_i);
    we_a_i <= 0;
    we_b_i <= 0;
    wait_n_cycles(1);
    
    // ������������� ������ �� ������ �������
    @(posedge clk_i);
    addr_a_i <= 10;
    addr_b_i <= 11;
    wait_n_cycles(1);
    $display("������������� ������: A(addr=10)=0x%h, B(addr=11)=0x%h", 
             data_a_o, data_b_o);
    assert(data_a_o == 8'hAA) else $error("������ ������ ����� A!");
    assert(data_b_o == 8'hBB) else $error("������ ������ ����� B!");
    
    @(posedge clk_i);
    en_a_i <= 0;
    en_b_i <= 0;
  endtask

  // ����: �������� ������
  task test_write_conflict();
    // ������� ������ � ���� ����� � ����� ������
    @(posedge clk_i);
    en_a_i   <= 1;
    en_b_i   <= 1;
    we_a_i   <= 1;
    we_b_i   <= 1;
    addr_a_i <= 12;
    addr_b_i <= 12;  // ��� �� �����!
    data_a_i <= 8'hCC;
    data_b_i <= 8'hDD;
    $display("�������� ������: ��� ����� ����� � addr=12");
    $display("���� A: data=0xCC, ���� B: data=0xDD");
    
    @(posedge clk_i);
    we_a_i <= 0;
    we_b_i <= 0;
    wait_n_cycles(1);
    
    // ��������, ����� �������� ����������
    @(posedge clk_i);
    addr_a_i <= 12;
    wait_n_cycles(1);
    $display("��������� ���������: data=0x%h", data_a_o);
    // � �������� BRAM ��������� ��� ��������� ����� �������� �� ����������
    
    @(posedge clk_i);
    en_a_i <= 0;
    en_b_i <= 0;
  endtask

  // ����: ����������� �����
  task test_disabled_ports();
    // ������ ������
    @(posedge clk_i);
    en_a_i   <= 1;
    we_a_i   <= 1;
    addr_a_i <= 13;
    data_a_i <= 8'hEE;
    
    @(posedge clk_i);
    we_a_i <= 0;
    wait_n_cycles(1);
    
    // ������ � ����������� ������
    @(posedge clk_i);
    en_a_i   <= 0;  // ���� ��������!
    addr_a_i <= 13;
    wait_n_cycles(2);
    $display("������ � ����������� ������ A: data=0x%h", data_a_o);
    // ����� ������ ��������� ���������� ��������
    
    @(posedge clk_i);
    en_a_i <= 0;
  endtask

  // ���������� ���������
  always @(posedge clk_i) begin
    if (en_a_i && we_a_i)
      $display("[%0t] ������ PORT_A: addr=%0d, data=0x%h", 
               $time, addr_a_i, data_a_i);
    
    if (en_b_i && we_b_i)
      $display("[%0t] ������ PORT_B: addr=%0d, data=0x%h", 
               $time, addr_b_i, data_b_i);
  end

endmodule