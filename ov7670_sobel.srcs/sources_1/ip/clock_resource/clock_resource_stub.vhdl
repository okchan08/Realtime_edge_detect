-- Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2017.2 (lin64) Build 1909853 Thu Jun 15 18:39:10 MDT 2017
-- Date        : Wed Jan  9 19:43:09 2019
-- Host        : yoshiki-FMVA77JRY running 64-bit Ubuntu 18.04.1 LTS
-- Command     : write_vhdl -force -mode synth_stub
--               /home/yoshiki/xilinx/nexys4/ov7670_filter/vivado2/ov7670_sobel/ov7670_sobel.srcs/sources_1/ip/clock_resource/clock_resource_stub.vhdl
-- Design      : clock_resource
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a100tcsg324-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clock_resource is
  Port ( 
    clk_12MHz : out STD_LOGIC;
    clk_148_5MHz : out STD_LOGIC;
    clk_100MHz : out STD_LOGIC;
    clk_6MHz : out STD_LOGIC;
    clk_24MHz : out STD_LOGIC;
    reset : in STD_LOGIC;
    locked : out STD_LOGIC;
    clk_in1 : in STD_LOGIC
  );

end clock_resource;

architecture stub of clock_resource is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk_12MHz,clk_148_5MHz,clk_100MHz,clk_6MHz,clk_24MHz,reset,locked,clk_in1";
begin
end;
