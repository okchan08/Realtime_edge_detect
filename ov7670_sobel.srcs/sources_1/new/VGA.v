`timescale 1ns / 1ps

module VGA #(
    parameter FRAME_WIDTH = 1920,
    parameter FRAME_HEIGHT = 1080,
    parameter H_FP = 88,
    parameter H_PW = 44,
    parameter H_MAX = 2200,
    parameter V_FP = 4,
    parameter V_PW = 5,
    parameter V_MAX = 1125,
    parameter BITS_WIDTH = 12,
    parameter ADDR_WIDTH = 17,
    parameter PIX_WIDTH = 12,
    parameter VGABIT_WIDTH = 4,
    parameter CAMERA_WIDTH = 320,
    parameter CAMERA_HEIGHT = 240 
)
(
    input   wire    pix_clk,
    input   wire    cntl,
    input   wire [PIX_WIDTH-1:0] frame_pix,
    output  reg     VGA_H_SYNC,
    output  reg     VGA_V_SYNC,
    output  reg [VGABIT_WIDTH-1:0]  VGA_RED,
    output  reg [VGABIT_WIDTH-1:0]  VGA_BLUE,
    output  reg [VGABIT_WIDTH-1:0]  VGA_GREEN,
    output  reg [ADDR_WIDTH-1:0] frame_addr
);

    // constant
    reg H_POSITIVE = 1'b1;
    reg V_POSITIVE = 1'b1;

    // counters
    reg [BITS_WIDTH - 1:0] h_cnt;
    reg [BITS_WIDTH - 1:0] v_cnt;

    // counters for display
    reg [BITS_WIDTH - 1:0] h_cnt_d;
    reg [BITS_WIDTH - 1:0] v_cnt_d;

    // syncronization signal
    reg h_sync;
    reg v_sync;

    // syncronization signal for display
    reg h_sync_d;
    reg v_sync_d;

    // pix data is valid
    wire valid;

    // pix data is blank or not (blank = HIGH : pix data is valid)
    reg blank;

    // colors
    reg [28:0] cnt_bg;
    wire [BITS_WIDTH - 1:0] cnt_bg_h;
    wire [BITS_WIDTH - 1:0] cnt_bg_v;
    reg [VGABIT_WIDTH-1:0] bg_red;
    reg [VGABIT_WIDTH-1:0] bg_blue;
    reg [VGABIT_WIDTH-1:0] bg_green;

    reg [VGABIT_WIDTH-1:0] bg_red_d;
    reg [VGABIT_WIDTH-1:0] bg_blue_d;
    reg [VGABIT_WIDTH-1:0] bg_green_d;

    initial begin
	h_cnt <= 0;
	v_cnt <= 0;
	cnt_bg <= 0;
	blank <= 1'b0;
    end


    // horizon counter

    always @(posedge pix_clk) begin
        if(h_cnt == (H_MAX - 1)) begin 
            h_cnt <= 0;
        end else begin
            h_cnt <= h_cnt + 1;
        end
    end

    // vertical counter
    always @(posedge pix_clk) begin
        if(h_cnt == (H_MAX - 1) && v_cnt == (V_MAX - 1)) begin
            v_cnt <= 0;
        end else if(h_cnt == (H_MAX - 1)) begin
            v_cnt <= v_cnt + 1;
        end
    end

    // horizontal sync.
    always @(posedge pix_clk) begin
        if( (h_cnt >= (H_FP + FRAME_WIDTH - 1)) && (h_cnt < (H_FP + FRAME_WIDTH + H_PW - 1)) ) begin
            h_sync <= H_POSITIVE;
        end else begin
            h_sync <= ~H_POSITIVE;
        end
    end
    
    // vertical sync.
    always @(posedge pix_clk) begin
        if( (v_cnt >= (V_FP + FRAME_HEIGHT - 1)) && (v_cnt < (V_FP + FRAME_HEIGHT + V_PW - 1)) ) begin
            v_sync <= V_POSITIVE;
        end else begin
            v_sync <= ~V_POSITIVE;
        end
    end

    // pixel address counter
    always @(posedge pix_clk) begin
        //frame_addr <= h_cnt + v_cnt * CAMERA_WIDTH;
	    if(v_cnt >= CAMERA_HEIGHT) begin
	    	blank <= 1;
	    	frame_addr <= 0;
	    end else begin
	    	if(h_cnt <  CAMERA_WIDTH) begin
	    		blank <= 0;
	    		frame_addr <= frame_addr + 1;
	    	end else begin
	    		blank <= 1;
	    	end
	    end
    end

    // validation
    assign valid = ((h_cnt_d < FRAME_WIDTH) && (v_cnt_d < FRAME_HEIGHT));


    always @(posedge pix_clk) begin
        if(cntl) begin
	         if((cntl == 1'b1) ? blank : 1'b0) begin
	         	bg_red <= 4'b0;
	         	bg_green <= 4'b0;
	         	bg_blue <= 4'b0;
	         end else begin
	         	bg_red <= frame_pix[PIX_WIDTH-1:PIX_WIDTH-VGABIT_WIDTH];
	         	bg_green <= frame_pix[PIX_WIDTH-VGABIT_WIDTH-1: PIX_WIDTH-2*VGABIT_WIDTH];
	         	bg_blue <= frame_pix[PIX_WIDTH-2*VGABIT_WIDTH-1: PIX_WIDTH-3*VGABIT_WIDTH];
	         end
        end else begin
	         
                 if(h_cnt < FRAME_WIDTH/8) begin
                     // black
                     bg_red <= 4'b0;
                     bg_blue <= 4'b0;
                     bg_green <= 4'b0;
                 end else if(h_cnt >= FRAME_WIDTH/8 && h_cnt < FRAME_WIDTH/4) begin
                     // blue
                     bg_red <= 4'b0;
                     bg_blue <= 4'b1111;
                     bg_green <= 4'b0;
                 end else if(h_cnt >= FRAME_WIDTH/4 && h_cnt < FRAME_WIDTH/8 * 3) begin
                     // green
                     bg_red <= 4'b0;
                     bg_blue <= 4'b0;
                     bg_green <= 4'b1111;
                 end else if(h_cnt >= FRAME_WIDTH/8 * 3 && h_cnt < FRAME_WIDTH/2) begin
                     // cyan
                     bg_red <= 4'b0;
                     bg_blue <= 4'b1111;
                     bg_green <= 4'b1111;
                 end else if(h_cnt >= FRAME_WIDTH/2 && h_cnt < FRAME_WIDTH/8 * 5) begin
                     // red 
                     bg_red <= 4'b1111;
                     bg_blue <= 4'b0;
                     bg_green <= 4'b0;
                 end else if(h_cnt >= FRAME_WIDTH/8 * 5 && h_cnt < FRAME_WIDTH/4 * 3) begin
                     // magenta
                     bg_red <= 4'b1111;
                     bg_blue <= 4'b1111;
                     bg_green <= 4'b0;
                 end else if(h_cnt >= FRAME_WIDTH/4 * 3 && h_cnt < FRAME_WIDTH/8 * 7) begin
                     // yellow
                     bg_red <= 4'b1111;
                     bg_blue <= 4'b0;
                     bg_green <= 4'b1111;
                 end else if(h_cnt >= FRAME_WIDTH/8 * 7 && h_cnt < FRAME_WIDTH) begin
                     // white 
                     bg_red <= 4'b1111;
                     bg_blue <= 4'b1111;
                     bg_green <= 4'b1111;
                 end
             end
    end


    // register output 
    always @(posedge pix_clk) begin
        bg_blue_d <= bg_blue;
        bg_red_d <= bg_red;
        bg_green_d <= bg_green;

        h_cnt_d <= h_cnt;
        v_cnt_d <= v_cnt;

        h_sync_d <= h_sync;
        v_sync_d <= v_sync;
    end

    always @(posedge pix_clk) begin
        VGA_BLUE <= bg_blue_d;
        VGA_RED <= bg_red_d;
        VGA_GREEN <= bg_green;
        VGA_H_SYNC <= h_sync_d;
        VGA_V_SYNC <= v_sync_d;
    end
endmodule
