-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2023.2.2 (win64) Build 4126759 Thu Feb  8 23:53:51 MST 2024
-- Date        : Mon Oct 27 16:27:42 2025
-- Host        : DESKTOP-630779O running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               c:/projects/Vivado_Projects/AD9777_with_mult-main/AD9777_with_mult-main/DAC_par.gen/sources_1/ip/vio_0/vio_0_stub.vhdl
-- Design      : vio_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z020clg484-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity vio_0 is
  Port ( 
    clk : in STD_LOGIC;
    probe_in0 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe_in1 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe_in2 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe_in3 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe_in4 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe_in5 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe_in6 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe_in7 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe_in8 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe_in9 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe_in10 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe_in11 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe_in12 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe_in13 : in STD_LOGIC_VECTOR ( 15 downto 0 );
    probe_in14 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe_in15 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe_out0 : out STD_LOGIC_VECTOR ( 0 to 0 );
    probe_out1 : out STD_LOGIC_VECTOR ( 15 downto 0 );
    probe_out2 : out STD_LOGIC_VECTOR ( 2 downto 0 );
    probe_out3 : out STD_LOGIC_VECTOR ( 31 downto 0 );
    probe_out4 : out STD_LOGIC_VECTOR ( 31 downto 0 );
    probe_out5 : out STD_LOGIC_VECTOR ( 31 downto 0 );
    probe_out6 : out STD_LOGIC_VECTOR ( 31 downto 0 );
    probe_out7 : out STD_LOGIC_VECTOR ( 31 downto 0 );
    probe_out8 : out STD_LOGIC_VECTOR ( 31 downto 0 );
    probe_out9 : out STD_LOGIC_VECTOR ( 31 downto 0 );
    probe_out10 : out STD_LOGIC_VECTOR ( 31 downto 0 );
    probe_out11 : out STD_LOGIC_VECTOR ( 31 downto 0 );
    probe_out12 : out STD_LOGIC_VECTOR ( 31 downto 0 );
    probe_out13 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    probe_out14 : out STD_LOGIC_VECTOR ( 31 downto 0 );
    probe_out15 : out STD_LOGIC_VECTOR ( 31 downto 0 );
    probe_out16 : out STD_LOGIC_VECTOR ( 31 downto 0 );
    probe_out17 : out STD_LOGIC_VECTOR ( 31 downto 0 );
    probe_out18 : out STD_LOGIC_VECTOR ( 0 to 0 );
    probe_out19 : out STD_LOGIC_VECTOR ( 0 to 0 );
    probe_out20 : out STD_LOGIC_VECTOR ( 31 downto 0 );
    probe_out21 : out STD_LOGIC_VECTOR ( 31 downto 0 );
    probe_out22 : out STD_LOGIC_VECTOR ( 31 downto 0 );
    probe_out23 : out STD_LOGIC_VECTOR ( 31 downto 0 );
    probe_out24 : out STD_LOGIC_VECTOR ( 31 downto 0 );
    probe_out25 : out STD_LOGIC_VECTOR ( 31 downto 0 );
    probe_out26 : out STD_LOGIC_VECTOR ( 31 downto 0 );
    probe_out27 : out STD_LOGIC_VECTOR ( 31 downto 0 );
    probe_out28 : out STD_LOGIC_VECTOR ( 3 downto 0 );
    probe_out29 : out STD_LOGIC_VECTOR ( 0 to 0 );
    probe_out30 : out STD_LOGIC_VECTOR ( 0 to 0 );
    probe_out31 : out STD_LOGIC_VECTOR ( 0 to 0 )
  );

end vio_0;

architecture stub of vio_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,probe_in0[0:0],probe_in1[0:0],probe_in2[0:0],probe_in3[0:0],probe_in4[0:0],probe_in5[0:0],probe_in6[0:0],probe_in7[0:0],probe_in8[0:0],probe_in9[0:0],probe_in10[0:0],probe_in11[0:0],probe_in12[0:0],probe_in13[15:0],probe_in14[0:0],probe_in15[0:0],probe_out0[0:0],probe_out1[15:0],probe_out2[2:0],probe_out3[31:0],probe_out4[31:0],probe_out5[31:0],probe_out6[31:0],probe_out7[31:0],probe_out8[31:0],probe_out9[31:0],probe_out10[31:0],probe_out11[31:0],probe_out12[31:0],probe_out13[1:0],probe_out14[31:0],probe_out15[31:0],probe_out16[31:0],probe_out17[31:0],probe_out18[0:0],probe_out19[0:0],probe_out20[31:0],probe_out21[31:0],probe_out22[31:0],probe_out23[31:0],probe_out24[31:0],probe_out25[31:0],probe_out26[31:0],probe_out27[31:0],probe_out28[3:0],probe_out29[0:0],probe_out30[0:0],probe_out31[0:0]";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "vio,Vivado 2023.2.2";
begin
end;
