`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/01/09 16:37:13
// Design Name: 
// Module Name: laplacian_filter
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


module laplacian_filter(
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
    reg [11:0] calc0,calc1,calc2;
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
                    calc_data <= tmp_data0 + tmp_data1        + tmp_data2 +
                                 tmp_data3 - (tmp_data4 << 3) + tmp_data5 +
                                 tmp_data6 + tmp_data7        + tmp_data8;
                    calc0 <= tmp_data0 + tmp_data1        + tmp_data2 +
                             tmp_data3                    + tmp_data5 +
                             tmp_data6 + tmp_data7        + tmp_data8;
                    calc1 <= (tmp_data4<<3);
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
                    //data_out <= calc_data;
                    data_out <= (calc0 <= calc1) ? 8'h0 :
                                (calc0 > calc1 ) ? 8'hff : (calc0-calc1);
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

module laplacian_filter_55(
        input wire clk,
        input wire reset_in,
        input wire [11:0] data_in,
        output wire [7:0] state_out,
        output reg [16:0] rd_addr,
        output reg wr_en,
        output wire [10:0] hcnt_out,
        output wire [10:0] vcnt_out,
        output reg [16:0] addr_out,
        output reg [11:0] data_out
    );

    parameter CAMERA_WIDTH = 320;
    parameter CAMERA_HEIGHT = 240;
    parameter DATA0 = 8'h0;
    parameter DATA1 = 8'h1;
    parameter DATA2 = 8'h2;
    parameter DATA3 = 8'h3;
    parameter DATA4 = 8'h4;
    parameter DATA5 = 8'h5;
    parameter DATA6 = 8'h6;
    parameter DATA7 = 8'h7;
    parameter DATA8 = 8'h8;
    parameter DATA9 = 8'h9;
    parameter DATA10 = 8'ha;
    parameter DATA11 = 8'hb;
    parameter DATA12 = 8'hc;
    parameter DATA13 = 8'hd;
    parameter DATA14 = 8'he;
    parameter DATA15 = 8'hf;
    parameter DATA16 = 8'h10;
    parameter DATA17 = 8'h11;
    parameter DATA18 = 8'h12;
    parameter DATA19 = 8'h13;
    parameter DATA20 = 8'h14;
    parameter DATA21 = 8'h15;
    parameter DATA22 = 8'h16;
    parameter DATA23 = 8'h17;
    parameter DATA24 = 8'h18;

    parameter DATA_OUT = 8'hfa;
    parameter CALC_DATA = 8'hfb;
    parameter IDLE = 8'hff;

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
    reg [11:0] tmp_data9;
    reg [11:0] tmp_data10;
    reg [11:0] tmp_data11;
    reg [11:0] tmp_data12;
    reg [11:0] tmp_data13;
    reg [11:0] tmp_data14;
    reg [11:0] tmp_data15;
    reg [11:0] tmp_data16;
    reg [11:0] tmp_data17;
    reg [11:0] tmp_data18;
    reg [11:0] tmp_data19;
    reg [11:0] tmp_data20;
    reg [11:0] tmp_data21;
    reg [11:0] tmp_data22;
    reg [11:0] tmp_data23;
    reg [11:0] tmp_data24;
    reg [11:0] calc_data;
    wire [3:0] calc_edge;
    reg [11:0] calc_data_prev;

    reg [7:0] state = 0;
    reg [10:0] hcnt = 0;
    reg [10:0] vcnt = 0;
    reg [16:0] address_next;

    assign state_out = state;
    assign hcnt_out = hcnt;
    assign vcnt_out = vcnt;
    //assign calc_edge = (|calc_data[11:8]) ? 4'hf : calc_data[3:0];
    assign calc_edge = (|calc_data[11:8]) ? 4'hf : 4'h0;
    

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
                    rd_addr <= addr_out - 2*CAMERA_WIDTH - 2;

                    tmp_data0 <= data_in;
                    wr_en <= 1'b0;
                    state <= DATA1;
                end

                DATA1 : begin
                    rd_addr <= addr_out - 2*CAMERA_WIDTH - 1;

                    tmp_data1 <= data_in;
                    wr_en <= 1'b0;
                    state <= DATA2;
                end

                DATA2 : begin
                    rd_addr <= addr_out - 2*CAMERA_WIDTH;

                    wr_en <= 1'b0;
                    tmp_data2 <= data_in;
                    state <= DATA3;
                end

                DATA3 : begin
                    rd_addr <= addr_out - 2*CAMERA_WIDTH + 1;

                    tmp_data3 <= data_in;
                    wr_en <= 1'b0;
                    state <= DATA4;
                end

                DATA4 : begin
                    rd_addr <= addr_out - 2*CAMERA_WIDTH + 2;

                    tmp_data4 <= data_in;
                    wr_en <= 1'b0;
                    state <= DATA5;
                end

                DATA5 : begin
                    rd_addr <= addr_out - CAMERA_WIDTH - 2;

                    tmp_data5 <= data_in;
                    wr_en <= 1'b0;
                    state <= DATA6;
                end

                DATA6 : begin
                    rd_addr <= addr_out - CAMERA_WIDTH - 1;

                    tmp_data6 <= data_in;
                    wr_en <= 1'b0;
                    state <= DATA7;
                end

                DATA7 : begin
                    rd_addr <= addr_out - CAMERA_WIDTH;

                    tmp_data7 <= data_in;
                    wr_en <= 1'b0;
                    state <= DATA8;
                end

                DATA8 : begin
                    rd_addr <= addr_out - CAMERA_WIDTH + 1;

                    tmp_data8 <= data_in;
                    wr_en <= 1'b0;
                    state <= DATA9;
                end

                DATA9 : begin
                    rd_addr <= addr_out - CAMERA_WIDTH + 2;

                    tmp_data9 <= data_in;
                    wr_en <= 1'b0;
                    state <= DATA10;
                end

                DATA10 : begin
                    rd_addr <= addr_out - 2;

                    tmp_data10 <= data_in;
                    wr_en <= 1'b0;
                    state <= DATA11;
                end

                DATA11 : begin
                    rd_addr <= addr_out - 1;

                    tmp_data11 <= data_in;
                    wr_en <= 1'b0;
                    state <= DATA12;
                end

                DATA12 : begin
                    rd_addr <= addr_out;

                    tmp_data12 <= data_in;
                    wr_en <= 1'b0;
                    state <= DATA13;
                end

                DATA13 : begin
                    rd_addr <= addr_out + 1;

                    tmp_data13 <= data_in;
                    wr_en <= 1'b0;
                    state <= DATA14;
                end

                DATA14 : begin
                    rd_addr <= addr_out + 2;

                    tmp_data14 <= data_in;
                    wr_en <= 1'b0;
                    state <= DATA15;
                end

                DATA15 : begin
                    rd_addr <= addr_out + CAMERA_WIDTH - 2;

                    tmp_data15 <= data_in;
                    wr_en <= 1'b0;
                    state <= DATA16;
                end

                DATA16 : begin
                    rd_addr <= addr_out + CAMERA_WIDTH - 1;

                    tmp_data16 <= data_in;
                    wr_en <= 1'b0;
                    state <= DATA17;
                end

                DATA17 : begin
                    rd_addr <= addr_out + CAMERA_WIDTH;

                    tmp_data17 <= data_in;
                    wr_en <= 1'b0;
                    state <= DATA18;
                end

                DATA18 : begin
                    rd_addr <= addr_out + CAMERA_WIDTH + 1;

                    tmp_data18 <= data_in;
                    wr_en <= 1'b0;
                    state <= DATA19;
                end

                DATA19 : begin
                    rd_addr <= addr_out + CAMERA_WIDTH + 2;

                    tmp_data19 <= data_in;
                    wr_en <= 1'b0;
                    state <= DATA20;
                end

                DATA20 : begin
                    rd_addr <= addr_out + 2*CAMERA_WIDTH - 2;

                    tmp_data20 <= data_in;
                    wr_en <= 1'b0;
                    state <= DATA21;
                end

                DATA21 : begin
                    rd_addr <= addr_out + 2*CAMERA_WIDTH - 1;

                    tmp_data21 <= data_in;
                    wr_en <= 1'b0;
                    state <= DATA22;
                end

                DATA22 : begin
                    rd_addr <= addr_out + 2*CAMERA_WIDTH;

                    tmp_data22 <= data_in;
                    wr_en <= 1'b0;
                    state <= DATA23;
                end

                DATA23 : begin
                    rd_addr <= addr_out + 2*CAMERA_WIDTH + 1;

                    tmp_data23 <= data_in;
                    wr_en <= 1'b0;
                    state <= DATA24;
                end

                DATA24 : begin
                    rd_addr <= addr_out + 2*CAMERA_WIDTH + 2;

                    tmp_data24 <= data_in;
                    wr_en <= 1'b0;
                    state <= CALC_DATA;
                end
    
                CALC_DATA : begin
                    calc_data <= (tmp_data7 + tmp_data11 + tmp_data13 + tmp_data17)*6 + 20*tmp_data14 - (tmp_data2 + tmp_data10 + tmp_data14 + tmp_data22)*4
                                -(tmp_data1 + tmp_data3 + tmp_data5 + tmp_data9 + tmp_data15 + tmp_data19 + tmp_data21 + tmp_data23)*3
                                - tmp_data0 - tmp_data4 - tmp_data20 - tmp_data24;
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
                    data_out <= {calc_edge,calc_edge, calc_edge};
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
