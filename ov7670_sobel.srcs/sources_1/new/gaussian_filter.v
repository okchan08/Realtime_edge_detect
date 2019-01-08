`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/01/08 21:00:34
// Design Name: 
// Module Name: gaussian_filter
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


module gaussian_filter(
        input wire clk,
        input wire reset_in,
        input wire [11:0] data_in,
        output wire [3:0] state_out,
        output reg [16:0] rd_addr,
        output reg wr_en,
        output wire [10:0] hcnt_out,
        output wire [10:0] vcnt_out,
        output reg [16:0] addr_out,
        output reg [11:0] data_out
    );

    parameter CAMERA_WIDTH = 320;
    parameter CAMERA_HEIGHT = 240;
    parameter DATA0 = 4'h0;
    parameter DATA1 = 4'h1;
    parameter DATA2 = 4'h2;
    parameter DATA3 = 4'h3;
    parameter DATA4 = 4'h4;
    parameter DATA5 = 4'h5;
    parameter DATA6 = 4'h6;
    parameter DATA7 = 4'h7;
    parameter DATA8 = 4'h8;
    parameter DATA_OUT = 4'h9;
    parameter CALC_DATA = 4'ha;
    parameter IDLE = 4'hf;

    // data contains gray scaled image. data[11:0] = {4'b0, grayscale[7:0]}
    reg [11:0] tmp_data0;
    reg [11:0] tmp_data1;
    reg [11:0] tmp_data2;
    reg [11:0] tmp_data3;
    reg [11:0] tmp_data4;
    reg [11:0] tmp_data5;
    reg [11:0] tmp_data6;
    reg [11:0] tmp_data7;
    reg [11:0] tmp_data8;
    reg [11:0] calc_data;
    reg [11:0] calc_data_prev;

    reg [3:0] state = 0;
    reg [10:0] hcnt = 0;
    reg [10:0] vcnt = 0;
    reg [16:0] address_next;

    assign state_out = state;
    assign hcnt_out = hcnt;
    assign vcnt_out = vcnt;

    always @(posedge clk) begin
        if(reset_in) begin
            wr_en <= 1'b0;
            state <= IDLE;
            hcnt <= 0;
            vcnt <= 0;
            rd_addr <= 0;
            addr_out <= 0;
            data_out <= 0;
            address_next <= 0;
        end else begin
            case (state)
                IDLE : begin
                    wr_en <= 1'b0;
                    state <= DATA0;
                end

                DATA0 : begin
                    //if(hcnt==0 || hcnt==CAMERA_WIDTH-1 || vcnt==0 || vcnt==CAMERA_HEIGHT-1)
                    //    tmp_data0 <= 0;
                    //else
                    //    rd_addr <= (hcnt-1) + (vcnt-1) * CAMERA_WIDTH;
                    rd_addr <= addr_out - CAMERA_WIDTH - 1;

                    tmp_data0 <= data_in;
                    wr_en <= 1'b0;
                    state <= DATA1;
                end

                DATA1 : begin
                    //if(hcnt==0 || hcnt==CAMERA_WIDTH-1 || vcnt==0 || vcnt==CAMERA_HEIGHT-1)
                    //    tmp_data1 <= 0;
                    //else
                    //    rd_addr <= hcnt + (vcnt-1) * CAMERA_WIDTH;

                    rd_addr <= addr_out - CAMERA_WIDTH;
                    tmp_data1 <= data_in;
                    wr_en <= 1'b0;
                    state <= DATA2;
                end

                DATA2 : begin
                    //if(hcnt==0 || hcnt==CAMERA_WIDTH-1 || vcnt==0 || vcnt==CAMERA_HEIGHT-1)
                    //    tmp_data2 <= 0;
                    //else
                    //    rd_addr <= (hcnt+1) + (vcnt-1) * CAMERA_WIDTH;

                    rd_addr <= addr_out - CAMERA_WIDTH + 1;
                    wr_en <= 1'b0;
                    tmp_data2 <= data_in;
                    state <= DATA3;
                end

                DATA3 : begin
                    //if(hcnt==0 || hcnt==CAMERA_WIDTH-1 || vcnt==0 || vcnt==CAMERA_HEIGHT-1)
                    //    tmp_data3 <= 0;
                    //else
                    //    rd_addr <= (hcnt-1) + vcnt * CAMERA_WIDTH;

                    rd_addr <= addr_out - 1;
                    tmp_data3 <= data_in;
                    wr_en <= 1'b0;
                    state <= DATA4;
                end

                DATA4 : begin
                    //if(hcnt==0 || hcnt==CAMERA_WIDTH-1 || vcnt==0 || vcnt==CAMERA_HEIGHT-1)
                    //    tmp_data4 <= 0;
                    //else
                    //    rd_addr <= hcnt + vcnt * CAMERA_WIDTH;
                    rd_addr <= addr_out;
                    tmp_data4 <= data_in;
                    //addr_out <= hcnt + vcnt * CAMERA_WIDTH;

                    wr_en <= 1'b0;
                    state <= DATA5;
                end

                DATA5 : begin
                    //if(hcnt==0 || hcnt==CAMERA_WIDTH-1 || vcnt==0 || vcnt==CAMERA_HEIGHT-1)
                    //    tmp_data5 <= 0;
                    //else
                    //    rd_addr <= (hcnt+1) + vcnt * CAMERA_WIDTH;
                    rd_addr <= addr_out + 1;
                    tmp_data5 <= data_in;

                    wr_en <= 1'b0;
                    state <= DATA6;
                end

                DATA6 : begin
                    //if(hcnt==0 || hcnt==CAMERA_WIDTH-1 || vcnt==0 || vcnt==CAMERA_HEIGHT-1)
                    //    tmp_data6 <= 0;
                    //else
                    //    rd_addr <= (hcnt-1) + (vcnt+1) * CAMERA_WIDTH;
                    rd_addr <= addr_out + CAMERA_WIDTH - 1;
                    tmp_data6 <= data_in;

                    wr_en <= 1'b0;
                    state <= DATA7;
                end

                DATA7 : begin
                    //if(hcnt==0 || hcnt==CAMERA_WIDTH-1 || vcnt==0 || vcnt==CAMERA_HEIGHT-1)
                    //    tmp_data7 <= 0;
                    //else
                    //    rd_addr <= hcnt + (vcnt+1) * CAMERA_WIDTH;
                    rd_addr <= addr_out + CAMERA_WIDTH;
                    tmp_data7 <= data_in;

                    wr_en <= 1'b0;
                    state <= DATA8;
                end

                DATA8 : begin
                    //if(hcnt==0 || hcnt==CAMERA_WIDTH-1 || vcnt==0 || vcnt==CAMERA_HEIGHT-1)
                    //    tmp_data8 <= 0;
                    //else
                    //    rd_addr <= (hcnt+1) + (vcnt+1) * CAMERA_WIDTH;
                    rd_addr <= addr_out + CAMERA_WIDTH + 1;
                    tmp_data8 <= data_in;

                    wr_en <= 1'b0;
                    state <= CALC_DATA;
                end
    
                CALC_DATA : begin
                    calc_data <= (tmp_data0 >> 4) + (tmp_data1 >> 3) + (tmp_data2 >> 4) +
                                 (tmp_data3 >> 3) + (tmp_data4 >> 2) + (tmp_data5 >> 3) +
                                 (tmp_data6 >> 4) + (tmp_data7 >> 3) + (tmp_data8 >> 4);
                    state <= DATA_OUT;
                end

                DATA_OUT : begin
                    if(hcnt < CAMERA_WIDTH)
                        hcnt <= hcnt + 1;
                    else begin
                        hcnt <= 0;
                        if(vcnt < CAMERA_HEIGHT)
                            vcnt <= vcnt + 1;
                        else
                            vcnt <= 0;
                    end
    
                    if(addr_out < CAMERA_WIDTH*CAMERA_HEIGHT)
                        addr_out <= addr_out + 1;   
                    else
                        addr_out <= 0;
                    //addr_out <= hcnt + vcnt * CAMERA_WIDTH;
                    //calc_data_prev <= calc_data;
                    data_out <= calc_data;
                    wr_en <= 1'b1;
                    state <= DATA0;
                end
                default : begin
                    wr_en <= 1'b0;
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
