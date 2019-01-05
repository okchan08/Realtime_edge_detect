`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/06/08 00:04:03
// Design Name: 
// Module Name: camera_controller
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


module camera_controller(
	input	wire	clk,
	input	wire	resend,
	output	wire	config_done,
	output	wire	sioc,
	inout	wire	siod,
	output	wire	reset,
	output	wire	power_down,
	output	wire	xclk
    );

	reg sys_clk = 1'b0;
	wire [15:0] command;
	wire done;
	wire taken;
	wire send;
	reg [7:0] camera_address = 8'h42;

	assign config_done = done;
	assign send = ~done;
	assign reset = 1'b1;
	assign power_down = 1'b0;
	assign xclk = sys_clk;

	camera_register cr(
		.clk(clk),
		.resend(resend),
		.advance(taken),
		.command(command),
		.done(done)
	);

	i2c_controller ic(
		.clk(clk),
		.siod(siod),
		.sioc(sioc),
		.taken(taken),
		.send(send),
		.id(camera_address),
		.regs(command[15:8]),
		.value(command[7:0])
	);

	always @(posedge clk) begin
		sys_clk <= ~sys_clk;
	end
endmodule
