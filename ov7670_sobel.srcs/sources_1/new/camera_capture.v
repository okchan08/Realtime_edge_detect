
module camera_capture(
input clk,
input rst,
input href,
input vsync,
input [7:0] data_in,

output        data_en,
output        href_neg_out,
//output [15:0] data_out,
output [4:0]  red_out,
output [5:0]  green_out,
output [4:0]  blue_out,
output [9:0]  hcnt_out,
output [9:0]  vcnt_out,
output [18:0] addr_out
);

reg href_1t;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        href_1t <= 1'b0;
    end else begin
        href_1t <= href;
    end
end

wire href_neg;

//assign href_neg = (~href && href_1t) ? 1'b1 : 1'b0;
assign href_neg = (~href && href_1t);
assign href_neg_out = href_neg;

reg vsync_1t;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        vsync_1t <= 1'b0;
    end else begin
        vsync_1t <= href;
    end
end

wire vsync_pos;

assign vsync_pos = (vsync && ~vsync_1t) ? 1'b1 : 1'b0;

reg [10:0] vcnt;

always @(posedge clk or posedge rst) begin
    if(rst)
        vcnt <= 11'h0;
    else if(vsync_pos)
        vcnt <= 11'h0;
    else if(href_neg)
        vcnt <= vcnt + 11'h1;
end

reg [10:0] hcnt;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        hcnt <= 11'h0;
    end else if(vsync_pos) begin
        hcnt <= 11'h0;
    end else if(href_neg) begin
        hcnt <= 11'h0;
    end else if(href)begin
        hcnt <= hcnt + 11'h1;
    end
end


reg [7:0] data_in_1t;
reg [15:0] rgb_data;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        data_in_1t <= 8'h0;
        rgb_data <= 16'h0;
    end else begin
        data_in_1t <= data_in;
        rgb_data <= {rgb_data[7:0], data_in};
    end
end


//always @(posedge clk or posedge rst) begin
//    if(rst) begin
//        rgb_data <= 16'h0;
//    end else begin
//        if(~hcnt[0])
//            rgb_data[15:8] <= data_in_1t; // first byte
//        else
//            rgb_data[7:0] <= data_in_1t; // second byte
//    end
//    //end else if(~hcnt[0]) begin
//    //    rgb_data[15:8] <= data_in_1t;
//    //end else if(hcnt[0]) begin
//    //    rgb_data[7:0] <= data_in_1t;    
//    //end
//end

assign data_en = hcnt[0];
assign {red_out, green_out, blue_out} = rgb_data; //{rgb_data[15:12], rgb_data[10:7], rgb_data[4:1]};
assign hcnt_out = hcnt[10:1];
assign vcnt_out = vcnt[9:0];
assign addr_out = hcnt_out + vcnt_out * 10'd_640;

endmodule
