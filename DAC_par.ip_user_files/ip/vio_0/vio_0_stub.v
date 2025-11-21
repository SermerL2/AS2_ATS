// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2.2 (win64) Build 4126759 Thu Feb  8 23:53:51 MST 2024
// Date        : Fri Nov 21 13:59:39 2025
// Host        : DESKTOP-630779O running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/projects/Vivado_Projects/AD9777_with_mult-main/AD9777_with_mult-main/DAC_par.gen/sources_1/ip/vio_0/vio_0_stub.v
// Design      : vio_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "vio,Vivado 2023.2.2" *)
module vio_0(clk, probe_in0, probe_in1, probe_in2, probe_in3, 
  probe_in4, probe_in5, probe_in6, probe_in7, probe_in8, probe_in9, probe_in10, probe_in11, 
  probe_in12, probe_in13, probe_in14, probe_out0, probe_out1, probe_out2, probe_out3, probe_out4, 
  probe_out5, probe_out6, probe_out7, probe_out8, probe_out9, probe_out10, probe_out11, 
  probe_out12, probe_out13, probe_out14, probe_out15, probe_out16, probe_out17, probe_out18, 
  probe_out19, probe_out20, probe_out21, probe_out22, probe_out23, probe_out24, probe_out25, 
  probe_out26, probe_out27, probe_out28, probe_out29, probe_out30)
/* synthesis syn_black_box black_box_pad_pin="probe_in0[0:0],probe_in1[0:0],probe_in2[0:0],probe_in3[0:0],probe_in4[0:0],probe_in5[0:0],probe_in6[0:0],probe_in7[0:0],probe_in8[0:0],probe_in9[0:0],probe_in10[0:0],probe_in11[0:0],probe_in12[0:0],probe_in13[15:0],probe_in14[0:0],probe_out0[0:0],probe_out1[15:0],probe_out2[2:0],probe_out3[31:0],probe_out4[31:0],probe_out5[31:0],probe_out6[31:0],probe_out7[31:0],probe_out8[31:0],probe_out9[31:0],probe_out10[31:0],probe_out11[31:0],probe_out12[31:0],probe_out13[15:0],probe_out14[31:0],probe_out15[31:0],probe_out16[31:0],probe_out17[31:0],probe_out18[0:0],probe_out19[0:0],probe_out20[31:0],probe_out21[31:0],probe_out22[31:0],probe_out23[31:0],probe_out24[31:0],probe_out25[31:0],probe_out26[31:0],probe_out27[31:0],probe_out28[3:0],probe_out29[0:0],probe_out30[0:0]" */
/* synthesis syn_force_seq_prim="clk" */;
  input clk /* synthesis syn_isclock = 1 */;
  input [0:0]probe_in0;
  input [0:0]probe_in1;
  input [0:0]probe_in2;
  input [0:0]probe_in3;
  input [0:0]probe_in4;
  input [0:0]probe_in5;
  input [0:0]probe_in6;
  input [0:0]probe_in7;
  input [0:0]probe_in8;
  input [0:0]probe_in9;
  input [0:0]probe_in10;
  input [0:0]probe_in11;
  input [0:0]probe_in12;
  input [15:0]probe_in13;
  input [0:0]probe_in14;
  output [0:0]probe_out0;
  output [15:0]probe_out1;
  output [2:0]probe_out2;
  output [31:0]probe_out3;
  output [31:0]probe_out4;
  output [31:0]probe_out5;
  output [31:0]probe_out6;
  output [31:0]probe_out7;
  output [31:0]probe_out8;
  output [31:0]probe_out9;
  output [31:0]probe_out10;
  output [31:0]probe_out11;
  output [31:0]probe_out12;
  output [15:0]probe_out13;
  output [31:0]probe_out14;
  output [31:0]probe_out15;
  output [31:0]probe_out16;
  output [31:0]probe_out17;
  output [0:0]probe_out18;
  output [0:0]probe_out19;
  output [31:0]probe_out20;
  output [31:0]probe_out21;
  output [31:0]probe_out22;
  output [31:0]probe_out23;
  output [31:0]probe_out24;
  output [31:0]probe_out25;
  output [31:0]probe_out26;
  output [31:0]probe_out27;
  output [3:0]probe_out28;
  output [0:0]probe_out29;
  output [0:0]probe_out30;
endmodule
