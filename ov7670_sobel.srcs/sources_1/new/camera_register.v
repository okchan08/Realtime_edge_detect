`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/06/07 23:53:54
// Design Name: 
// Module Name: camera_register
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


module camera_register(
	input	wire	clk,
	input	wire	resend,
	input	wire	advance,
	output	wire [15:0] command,
	output	wire	done
    );

	reg [15:0] send_reg;
	reg [7:0]  address;

	assign command = send_reg;
	assign done = (send_reg == 16'h_FFFF ? 1'b1 : 1'b0);

	always @(posedge clk) begin
		if(resend == 1'b1) begin
			address <= 8'h0;
		end else if(advance == 1'b1) begin
			address <= address + 8'h1;
		end

		case ( address )
			16'h00 :  send_reg <= 16'h_1280; //  COM7   Reset
			16'h01 :  send_reg <= 16'h_1280; //  COM7   Reset
			16'h02 :  send_reg <= 16'h_1204; //  COM7   0x04 :Size & RGB output  0x10 : QVGA
			//16'h03 :  send_reg <= 16'h_1100; //  CLKRC  Prescaler - Fin/(1+1)
			16'h03 :  send_reg <= 16'h_1181; //  CLKRC  Prescaler - Fin/(1+1)
			16'h04 :  send_reg <= 16'h_0C00; //  COM3   Lots of stuff, enable scaling, all others off
			16'h05 :  send_reg <= 16'h_3E00; //  COM14  PCLK scaling off
			16'h06 :  send_reg <= 16'h_8C00; //  RGB444 Set RGB format
			16'h07 :  send_reg <= 16'h_0400; //  COM1   no CCIR601
			16'h08 :  send_reg <= 16'h_40D0; //  COM15  Full 0-255 output, RGB 565
			16'h09 :  send_reg <= 16'h_3a04; //  TSLB   Set UV ordering,  do not auto-reset window
			16'h0A :  send_reg <= 16'h_1438; //  COM9  - AGC Celling
			16'h0B :  send_reg <= 16'h_4f40; //  16'h4fb3; -- MTX1  - colour conversion matrix
			16'h0C :  send_reg <= 16'h_5034; //  16'h50b3; -- MTX2  - colour conversion matrix
			16'h0D :  send_reg <= 16'h_510C; //  16'h5100; -- MTX3  - colour conversion matrix
			16'h0E :  send_reg <= 16'h_5217; //  16'h523d; -- MTX4  - colour conversion matrix
			16'h0F :  send_reg <= 16'h_5329; //  16'h53a7; -- MTX5  - colour conversion matrix
			16'h10 :  send_reg <= 16'h_5440; //  16'h54e4; -- MTX6  - colour conversion matrix
			16'h11 :  send_reg <= 16'h_581e; //  16'h589e; -- MTXS  - Matrix sign and auto contrast
			16'h12 :  send_reg <= 16'h_3dc0; //  COM13 - Turn on GAMMA and UV Auto adjust
			16'h13 :  send_reg <= 16'h_1181; //  CLKRC  Prescaler - Fin/(1+1)
			16'h14 :  send_reg <= 16'h_1711; //  HSTART HREF start (high 8 bits)
			16'h15 :  send_reg <= 16'h_1861; //  HSTOP  HREF stop (high 8 bits)
			16'h16 :  send_reg <= 16'h_32A4; //  HREF   Edge offset and low 3 bits of HSTART and HSTOP
			16'h17 :  send_reg <= 16'h_1903; //  VSTART VSYNC start (high 8 bits)
			16'h18 :  send_reg <= 16'h_1A7b; //  VSTOP  VSYNC stop (high 8 bits)
			16'h19 :  send_reg <= 16'h_030a; //  VREF   VSYNC low two bits
			16'h1A :  send_reg <= 16'h_0e61; //  COM5(0x0E) 0x61
			16'h1B :  send_reg <= 16'h_0f4b; //  COM6(0x0F) 0x4B
			16'h1C :  send_reg <= 16'h_1602; // 
			16'h1D :  send_reg <= 16'h_1e37; //  MVFP (0x1E) 0x07  -- FLIP AND MIRROR IMAGE 0x3x
			16'h1E :  send_reg <= 16'h_2102;
			16'h1F :  send_reg <= 16'h_2291;
			16'h20 :  send_reg <= 16'h_2907;
			16'h21 :  send_reg <= 16'h_330b;
			16'h22 :  send_reg <= 16'h_350b;
			16'h23 :  send_reg <= 16'h_371d;
			16'h24 :  send_reg <= 16'h_3871;
			16'h25 :  send_reg <= 16'h_392a;
			16'h26 :  send_reg <= 16'h_3c78; //  COM12 (0x3C) 0x78
			16'h27 :  send_reg <= 16'h_4d40;
			16'h28 :  send_reg <= 16'h_4e20;
			16'h29 :  send_reg <= 16'h_6900; //  GFIX (0x69) 0x00
			16'h2A :  send_reg <= 16'h_6b4a;
			16'h2B :  send_reg <= 16'h_7410;
			16'h2C :  send_reg <= 16'h_8d4f;
			16'h2D :  send_reg <= 16'h_8e00;
			16'h2E :  send_reg <= 16'h_8f00;
			16'h2F :  send_reg <= 16'h_9000;
			16'h30 :  send_reg <= 16'h_9100;
			16'h31 :  send_reg <= 16'h_9600;
			16'h32 :  send_reg <= 16'h_9a00;
			16'h33 :  send_reg <= 16'h_b084;
			16'h34 :  send_reg <= 16'h_b10c;
			16'h35 :  send_reg <= 16'h_b20e;
			16'h36 :  send_reg <= 16'h_b382;
			16'h37 :  send_reg <= 16'h_b80a;
            16'h38 :  send_reg <= 16'h_6B4A; //  DBLV
			default : send_reg <= 16'h_ffff;
		endcase
	end
endmodule
