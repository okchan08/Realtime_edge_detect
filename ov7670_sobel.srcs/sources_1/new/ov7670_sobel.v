`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/01/05 22:45:53
// Design Name: 
// Module Name: ov7670_sobel
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


module ov7670_sobel(
        input wire CLK,
        input wire pclk,
        input wire resend_in,
        input wire cntl_in,
        input wire [1:0] selector,
        
        input wire [7:0] din,
        output wire sioc,
        output wire siod,
        output wire config_done,
        input wire camera_v_sync,
        input wire camera_h_ref,
        output wire reset,
        output wire power_down,
        output wire xclk,
        
        output wire [3:0] VGA_RED,
        output wire [3:0] VGA_BLUE,
        output wire [3:0] VGA_GREEN,
        output wire VGA_H_SYNC,
        output wire VGA_V_SYNC
    );

    parameter BUFF_WIDTH = 16;
    
    wire clk_12MHz;
    wire clk_148_5MHz;
    wire clk_6MHz;
    wire clk_100MHz;
    
    wire [4:0] camera_red, camera_blue;
    wire [5:0] camera_green;
    wire [9:0] camera_hcnt;
    wire [9:0] camera_vcnt;
    wire [18:0] camera_addr;
    
    wire [16:0] buffer_data;
    wire [18:0] frame_addr;

    wire [7:0] sobel_data;
    wire [9:0] X_pos_camera;
    wire [9:0] Y_pos_camera;
    wire [7:0] filter_data;
    wire [7:0] laplc_data;
    wire [11:0] gray_data;

    wire [BUFF_WIDTH-1:0] video_buffer_din;
    wire [16:0] video_buffer_addr;
    wire video_buffer_wr_en;

    wire gaussian_buffer_wr_en;
    wire [16:0] gaussian_buffer_addr;
    wire [BUFF_WIDTH-1:0] gaussian_buffer_din;
    wire median_buffer_wr_en;
    wire [16:0] median_buffer_addr;
    wire [BUFF_WIDTH-1:0] median_buffer_din;
    wire laplacian_buffer_wr_en;
    wire [16:0] laplacian_buffer_addr;
    wire [11:0] laplacian_buffer_din;
    wire [16:0] filter_rd_addr;
    wire [BUFF_WIDTH-1:0] filter_rd_data;
    wire [16:0] buffer_rd_addr;
    wire [BUFF_WIDTH-1:0] buffer_rd_data;
    wire [16:0] gaussian_rd_addr;
    wire [BUFF_WIDTH-1:0] gaussian_rd_data;
    wire [16:0] median_rd_addr;
    wire [BUFF_WIDTH-1:0] median_rd_data;
    
    
    //assign video_buffer_din = filter_rd_data;
    assign video_buffer_addr = camera_addr;
    assign video_buffer_din = {camera_red[3:0], camera_green[3:0], camera_blue[3:0]};

    //assign video_buffer_din = (selector == 2'b00) ? {camera_red[3:0], camera_green[3:0], camera_blue[3:0]} :
    //                          (selector == 2'b01) ? {sobel_data[3:0], sobel_data[3:0], sobel_data[3:0]} : 
    //                          (selector == 2'b10) ? {laplc_data[3:0], laplc_data[3:0], laplc_data[3:0]} :
    //                          (selector == 2'b11) ? {gray_data[3:0], gray_data[3:0], gray_data[3:0]} : 12'h_FFF;
    
    camera_controller camera_controller(
        .clk(clk_6MHz),
        .resend(resend_in),
        .config_done(config_done),
        .sioc(sioc),
        .siod(siod),
        .reset(reset),
        .power_down(power_down),
        .xclk(xclk)
    );
    
    camera_capture2 camera_capture2(
        .pclk(pclk),
        .camera_v_sync(camera_v_sync),
        .camera_h_ref(camera_h_ref),
        .din(din),
        .addr(camera_addr),
        .dout({camera_red, camera_green, camera_blue}),
        //.dout({camera_red, camera_green, camera_blue}),
        .wr_en(video_buffer_wr_en)
    );

    VGA VGA(
        .pix_clk(clk_148_5MHz),
        .cntl(cntl_in),
        .frame_pix(buffer_data),
        .VGA_H_SYNC(VGA_H_SYNC),
        .VGA_V_SYNC(VGA_V_SYNC),
        .VGA_RED(VGA_RED),
        .VGA_BLUE(VGA_BLUE),
        .VGA_GREEN(VGA_GREEN),
        .frame_addr(frame_addr)
    );
        
    
    video_buffer1 video_buffer (
      .clka(pclk),    // input wire clka
      .wea(video_buffer_wr_en),      // input wire [0 : 0] wea
      .addra(video_buffer_addr),  // input wire [18 : 0] addra
      .dina(video_buffer_din),    // input wire [11 : 0] dina

      .clkb(clk_148_5MHz),    // input wire clkb
      .addrb(buffer_rd_addr[16:0]),  // input wire [18 : 0] addrb
      .doutb(buffer_rd_data)  // output wire [11 : 0] doutb
    );

    video_buffer1 median_buffer(
      .clka(clk_148_5MHz),    // input wire clka
      .wea(median_buffer_wr_en),      // input wire [0 : 0] wea
      .addra(median_buffer_addr[16:0]),  // input wire [18 : 0] addra
      .dina(median_buffer_din),

      .clkb(clk_148_5MHz),    // input wire clkb
      .addrb(median_rd_addr),
      .doutb(median_rd_data)  // output wire [11 : 0] doutb
    );

    video_buffer2 laplacian_buffer(
      .clka(clk_148_5MHz),    // input wire clka
      .wea(laplacian_buffer_wr_en),      // input wire [0 : 0] wea
      .addra(laplacian_buffer_addr[16:0]),  // input wire [18 : 0] addra
      .dina(laplacian_buffer_din),


      .clkb(clk_148_5MHz),    // input wire clkb
      .addrb(frame_addr),
      .doutb(buffer_data)  // output wire [11 : 0] doutb
    );

    median_filter mf(
        .clk(clk_148_5MHz),
        .color_data_in(buffer_rd_data),
        .rd_addr(buffer_rd_addr),
        .wr_en(median_buffer_wr_en),
        .addr_out(median_buffer_addr),
        .data_out(median_buffer_din)
    );

    laplacian_filter_55 lf(
        .clk(clk_148_5MHz),
        .data_in(median_rd_data),
        .rd_addr(median_rd_addr),
        .wr_en(laplacian_buffer_wr_en),
        .addr_out(laplacian_buffer_addr),
        .data_out(laplacian_buffer_din)
    );
    
      clock_resource clock_resource
     (
      // Clock out ports
      .clk_12MHz(clk_12MHz),     // output clk_12MHz
      .clk_148_5MHz(clk_148_5MHz),     // output clk_148_5MHz
      .clk_100MHz(clk_100MHz),
      .clk_6MHz(clk_6MHz),
      // Status and control signals
      .reset(1'b0), // input reset
      .locked(),       // output locked
     // Clock in ports
      .clk_in1(CLK));      // input clk_in1
    
    
    
endmodule
