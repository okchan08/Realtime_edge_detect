`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/01/05 16:39:59
// Design Name: 
// Module Name: image_filter
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


module image_filter(
        input wire clk,
        input wire [7:0] data0,
        input wire [7:0] data1,
        input wire [7:0] data2,
        input wire [7:0] data3,
        input wire [7:0] data4,
        input wire [7:0] data5,
        input wire [7:0] data6,
        input wire [7:0] data7,
        input wire [7:0] data8,

        output reg [7:0] filter_out,

        output reg [9:0] X_pos,
        output reg [8:0] Y_pos,
        output wire [18:0] addr
    );

    reg signed [8:0] data0_reg;
    reg signed [8:0] data1_reg;
    reg signed [8:0] data2_reg;
    reg signed [8:0] data3_reg;
    reg signed [8:0] data4_reg;
    reg signed [8:0] data5_reg;
    reg signed [8:0] data6_reg;
    reg signed [8:0] data7_reg;
    reg signed [8:0] data8_reg;

    reg signed [8:0] kernel0 = 1;
    reg signed [8:0] kernel1 = 1;
    reg signed [8:0] kernel2 = 1;
    reg signed [8:0] kernel3 = 1;
    reg signed [8:0] kernel4 = -8;
    reg signed [8:0] kernel5 = 1;
    reg signed [8:0] kernel6 = 1;
    reg signed [8:0] kernel7 = 1;
    reg signed [8:0] kernel8 = 1;

    wire signed [17:0] multi0 = kernel0 * data0_reg;
    wire signed [17:0] multi1 = kernel1 * data1_reg;
    wire signed [17:0] multi2 = kernel2 * data2_reg;
    wire signed [17:0] multi3 = kernel3 * data3_reg;
    wire signed [17:0] multi4 = kernel4 * data4_reg;
    wire signed [17:0] multi5 = kernel5 * data5_reg;
    wire signed [17:0] multi6 = kernel6 * data6_reg;
    wire signed [17:0] multi7 = kernel7 * data7_reg;
    wire signed [17:0] multi8 = kernel8 * data8_reg;

    wire signed [17:0] sum = multi0 + multi1 + multi2 + multi3 + multi4 + multi5 + multi6 + multi7 + multi8;
    reg signed [17:0] sum_reg;

    always @(posedge clk) begin
        
        data0_reg <= $signed({1'b0,data0});
        data1_reg <= $signed({1'b0,data1});
        data2_reg <= $signed({1'b0,data2});
        data3_reg <= $signed({1'b0,data3});
        data4_reg <= $signed({1'b0,data4});
        data5_reg <= $signed({1'b0,data5});
        data6_reg <= $signed({1'b0,data6});
        data7_reg <= $signed({1'b0,data7});
        data8_reg <= $signed({1'b0,data8});
        
        //sum_reg <= sum;
        //sum_reg <= {10'b0, data4};
        //filter_out <= sum_reg[7:0];
        filter_out <= data0;
    end


    parameter X_MAX = 640;
    parameter Y_MAX = 480;
    assign addr = X_pos + Y_pos * 640;
    always @(posedge clk) begin
        if(X_pos < X_MAX) begin
            X_pos <= X_pos + 1;
        end else begin
            X_pos <= 0;
            if(Y_pos < Y_MAX) begin
                Y_pos <= Y_pos + 1;
            end else begin
                Y_pos <= 0;
            end
        end
    end

endmodule
