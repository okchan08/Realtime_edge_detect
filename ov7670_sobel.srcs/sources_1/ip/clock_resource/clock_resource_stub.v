// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.2 (lin64) Build 1909853 Thu Jun 15 18:39:10 MDT 2017
// Date        : Wed Jan  9 19:43:09 2019
// Host        : yoshiki-FMVA77JRY running 64-bit Ubuntu 18.04.1 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/yoshiki/xilinx/nexys4/ov7670_filter/vivado2/ov7670_sobel/ov7670_sobel.srcs/sources_1/ip/clock_resource/clock_resource_stub.v
// Design      : clock_resource
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clock_resource(clk_12MHz, clk_148_5MHz, clk_100MHz, clk_6MHz, 
  clk_24MHz, reset, locked, clk_in1)
/* synthesis syn_black_box black_box_pad_pin="clk_12MHz,clk_148_5MHz,clk_100MHz,clk_6MHz,clk_24MHz,reset,locked,clk_in1" */;
  output clk_12MHz;
  output clk_148_5MHz;
  output clk_100MHz;
  output clk_6MHz;
  output clk_24MHz;
  input reset;
  output locked;
  input clk_in1;
endmodule
