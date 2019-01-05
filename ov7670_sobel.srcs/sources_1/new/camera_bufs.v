module camera_bufs #(
    parameter CAMERA_X_MAX = 640
)
(

///// input data from camera module
    input wire pclk,                // clock from camera module
    input wire [15:0] rgb_data,     // color data from camera module
    input wire [9:0] X_pos_camera,  // horizontal pixel position of data
    input wire [9:0] Y_pos_camera,


///// data for filter module
    output wire [7:0] gray_out,
    output wire [7:0] sobel_out,
    output wire [7:0] laplc_out
);


    reg [7:0] gray;
    reg [18:0] rd_addr0;
    reg [18:0] rd_addr1;
    reg [18:0] rd_addr2;
    reg [18:0] rd_addr3;
    reg [18:0] rd_addr4;
    reg [18:0] rd_addr5;
    reg [18:0] rd_addr6;
    reg [18:0] rd_addr7;
    reg [18:0] wr_addr;

    wire [7:0] data0;
    wire [7:0] data1;
    wire [7:0] data2;
    wire [7:0] data3;
    wire [7:0] data4;
    wire [7:0] data5;
    wire [7:0] data6;
    wire [7:0] data7;

    wire [5:0] red_in;
    wire [5:0] blue_in;
    wire [5:0] green_in;

    assign red_in = {1'b0,rgb_data[15:11]};
    assign green_in = rgb_data[10:5];
    assign blue_in = {1'b0, rgb_data[4:0]};
    
    wire [7:0] data0c = data0;
    wire [7:0] data1c = data1;
    wire [7:0] data2c = data2;
    wire [7:0] data3c = data3;
    wire [7:0] data4c = gray;
    wire [7:0] data5c = data4;
    wire [7:0] data6c = data5;
    wire [7:0] data7c = data6;
    wire [7:0] data8c = data7;

    wire signed [10:0] cal_x, cal_y;
    wire signed [10:0] abs_x, abs_y;
    wire [10:0] sum;

    assign cal_x = ((data2c-data0c) + ((data5c-data3c)<<1) + (data8c-data6c));
    assign cal_y = ((data0c-data6c) + ((data1c-data7c)<<1) + (data2c-data8c));

    assign abs_x = (cal_x[10] ? ~cal_x+1 : cal_x);
    assign abs_y = (cal_y[10] ? ~cal_y+1 : cal_y);

    assign sum = (abs_x + abs_y);
    assign sobel_out = (|sum[10:8]) ? 8'hff : sum[7:0];
    assign gray_out = gray;

    wire [11:0] lap = data0c + data1c + data2c + data3c + data5c + data6c + data7c - (data4c<<3);
    assign laplc_out = (|lap[10:8]) ? 8'h0 : lap[7:0];

    always @(posedge pclk) begin
        gray <= (red_in>>2) + (red_in>>5) + (green_in>>1) + (green_in>>4) + (blue_in>>4) + (blue_in>>5);
        wr_addr <= X_pos_camera + CAMERA_X_MAX * Y_pos_camera[1:0];

    end


    always @(posedge pclk) begin
        // assign read address
        rd_addr0 <= (X_pos_camera - 10'b1) + CAMERA_X_MAX * (Y_pos_camera[1:0] - 2'b1);
        rd_addr1 <= (X_pos_camera        ) + CAMERA_X_MAX * (Y_pos_camera[1:0] - 2'b1);
        rd_addr2 <= (X_pos_camera + 10'b1) + CAMERA_X_MAX * (Y_pos_camera[1:0] - 2'b1);
        rd_addr3 <= (X_pos_camera - 10'b1) + CAMERA_X_MAX * (Y_pos_camera[1:0]       );
        rd_addr4 <= (X_pos_camera + 10'b1) + CAMERA_X_MAX * (Y_pos_camera[1:0]       );
        rd_addr5 <= (X_pos_camera - 10'b1) + CAMERA_X_MAX * (Y_pos_camera[1:0] + 2'b1);
        rd_addr6 <= (X_pos_camera        ) + CAMERA_X_MAX * (Y_pos_camera[1:0] + 2'b1);
        rd_addr7 <= (X_pos_camera + 10'b1) + CAMERA_X_MAX * (Y_pos_camera[1:0] + 2'b1);
    end


    // fifo to buffer input pix data
    camera_buffer cf0(
        .clka(pclk),          // input wire clka
        .wea(1'b1),           // input wire [0 : 0] wea
        .addra(wr_addr[11:0]),      // input wire [11 : 0] addra
        .dina(gray),          // input wire [7 : 0] dina
        .clkb(pclk),    // input wire clkb
        .addrb(rd_addr0[11:0]),     // input wire [11 : 0] addrb
        .doutb(data0)         // output wire [7 : 0] doutb
    );
        
    camera_buffer cf1(
        .clka(pclk),          // input wire clka
        .wea(1'b1),           // input wire [0 : 0] wea
        .addra(wr_addr[11:0]),      // input wire [11 : 0] addra
        .dina(gray),          // input wire [7 : 0] dina
        .clkb(pclk),    // input wire clkb
        .addrb(rd_addr1[11:0]),     // input wire [11 : 0] addrb
        .doutb(data1)         // output wire [7 : 0] doutb
    );

    camera_buffer cf2(
        .clka(pclk),          // input wire clka
        .wea(1'b1),           // input wire [0 : 0] wea
        .addra(wr_addr[11:0]),      // input wire [11 : 0] addra
        .dina(gray),          // input wire [7 : 0] dina
        .clkb(pclk),    // input wire clkb
        .addrb(rd_addr2[11:0]),     // input wire [11 : 0] addrb
        .doutb(data2)         // output wire [7 : 0] doutb
    );

    camera_buffer cf3(
        .clka(pclk),          // input wire clka
        .wea(1'b1),           // input wire [0 : 0] wea
        .addra(wr_addr[11:0]),      // input wire [11 : 0] addra
        .dina(gray),          // input wire [7 : 0] dina
        .clkb(pclk),    // input wire clkb
        .addrb(rd_addr3[11:0]),     // input wire [11 : 0] addrb
        .doutb(data3)         // output wire [7 : 0] doutb
    );

    camera_buffer cf4(
        .clka(pclk),          // input wire clka
        .wea(1'b1),           // input wire [0 : 0] wea
        .addra(wr_addr[11:0]),      // input wire [11 : 0] addra
        .dina(gray),          // input wire [7 : 0] dina
        .clkb(pclk),    // input wire clkb
        .addrb(rd_addr4[11:0]),     // input wire [11 : 0] addrb
        .doutb(data4)         // output wire [7 : 0] doutb
    );

    camera_buffer cf5(
        .clka(pclk),          // input wire clka
        .wea(1'b1),           // input wire [0 : 0] wea
        .addra(wr_addr[11:0]),      // input wire [11 : 0] addra
        .dina(gray),          // input wire [7 : 0] dina
        .clkb(pclk),    // input wire clkb
        .addrb(rd_addr5[11:0]),     // input wire [11 : 0] addrb
        .doutb(data5)         // output wire [7 : 0] doutb
    );

    camera_buffer cf6(
        .clka(pclk),          // input wire clka
        .wea(1'b1),           // input wire [0 : 0] wea
        .addra(wr_addr[11:0]),      // input wire [11 : 0] addra
        .dina(gray),          // input wire [7 : 0] dina
        .clkb(pclk),    // input wire clkb
        .addrb(rd_addr6[11:0]),     // input wire [11 : 0] addrb
        .doutb(data6)         // output wire [7 : 0] doutb
    );

    camera_buffer cf7(
        .clka(pclk),          // input wire clka
        .wea(1'b1),           // input wire [0 : 0] wea
        .addra(wr_addr[11:0]),      // input wire [11 : 0] addra
        .dina(gray),          // input wire [7 : 0] dina
        .clkb(pclk),    // input wire clkb
        .addrb(rd_addr7[11:0]),     // input wire [11 : 0] addrb
        .doutb(data7)         // output wire [7 : 0] doutb
    );

endmodule
