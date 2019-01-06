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
        (*mark_debug = "true"*) input wire pclk,
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
    
    wire clk_12MHz;
    wire clk_148_5MHz;
    
    (*mark_debug = "true" *) wire [4:0] camera_red, camera_blue;
    (*mark_debug = "true" *) wire [5:0] camera_green;
    wire [9:0] camera_hcnt;
    wire [9:0] camera_vcnt;
    (*mark_debug = "true" *) wire [18:0] camera_addr;
    
    wire [11:0] buffer_data;
    wire [18:0] frame_addr;

    wire [7:0] sobel_data;
    wire [9:0] X_pos_camera;
    wire [9:0] Y_pos_camera;
    wire [7:0] filter_data;
    wire [7:0] laplc_data;
    wire [7:0] gray_data;
    
    wire [11:0] video_buffer_din;
    wire video_buffer_wr_en;
    
    assign video_buffer_din = (selector == 2'b00) ? {camera_red[3:0], camera_green[3:0], camera_blue[3:0]} :
                              (selector == 2'b01) ? {sobel_data[3:0], sobel_data[3:0], sobel_data[3:0]} : 
                              (selector == 2'b10) ? {laplc_data[3:0], laplc_data[3:0], laplc_data[3:0]} :
                              (selector == 2'b11) ? {gray_data[3:0], gray_data[3:0], gray_data[3:0]} : 12'h_FFF;
    
    camera_controller camera_controller(
        .clk(clk_12MHz),
        .resend(resend_in),
        .config_done(config_done),
        .sioc(sioc),
        .siod(siod),
        .reset(reset),
        .power_down(power_down),
        .xclk(xclk)
    );
    
    //camera_capture camera_capture(
    //    .clk(pclk),
    //    .rst(),
    //    .href(camera_h_ref),
    //    .vsync(camera_v_sync),
    //    .data_in(din),
    //    .data_en(video_buffer_wr_en),
    //    .red_out(camera_red),
    //    .green_out(camera_green),
    //    .blue_out(camera_blue),
    //    .hcnt_out(camera_hcnt),
    //    .vcnt_out(camera_vcnt),
    //    .addr_out(camera_addr)
    //);

    camera_capture2 camera_capture2(
        .pclk(pclk),
        .camera_v_sync(camera_v_sync),
        .camera_h_ref(camera_h_ref),
        .din(din),
        .addr(camera_addr),
        .dout({camera_red[3:0], camera_green[3:0], camera_blue[3:0]}),
        //.dout({camera_red, camera_green, camera_blue}),
        .wr_en(video_buffer_wr_en)
    );

    //camera_capture3 camera_capture3(
    //    .clk(pclk),
    //    .rst(1'b0),
    //    .href(camera_h_ref),
    //    .vsync(camera_v_sync),
    //    .data_in(din),
    //    .data_en(video_buffer_wr_en),
    //    .data_out({camera_red, camera_green, camera_blue}),
    //    .address(camera_addr[16:0])
    //);
        
    camera_bufs camera_bufs(
        .pclk(pclk),
        .rgb_data({camera_red, camera_green, camera_blue}),
        .X_pos_camera(camera_hcnt),
        .Y_pos_camera(camera_vcnt),
        .sobel_out(sobel_data),
        .laplc_out(laplc_data),
        .gray_out(gray_data)
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
      .addra(camera_addr[16:0]),  // input wire [18 : 0] addra
      .dina(video_buffer_din),    // input wire [11 : 0] dina
      .clkb(clk_148_5MHz),    // input wire clkb
      .addrb(frame_addr[16:0]),  // input wire [18 : 0] addrb
      .doutb(buffer_data)  // output wire [11 : 0] doutb
    );
    
      clock_resource instance_name
     (
      // Clock out ports
      .clk_12MHz(clk_12MHz),     // output clk_12MHz
      .clk_148_5MHz(clk_148_5MHz),     // output clk_148_5MHz
      // Status and control signals
      .reset(1'b0), // input reset
      .locked(),       // output locked
     // Clock in ports
      .clk_in1(CLK));      // input clk_in1
    
    
    
endmodule
