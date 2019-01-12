module get_median_value#(
    parameter DATA_WIDTH = 8
)(
    input wire [DATA_WIDTH-1:0] d0,
    input wire [DATA_WIDTH-1:0] d1,
    input wire [DATA_WIDTH-1:0] d2,
    input wire [DATA_WIDTH-1:0] d3,
    input wire [DATA_WIDTH-1:0] d4,
    input wire [DATA_WIDTH-1:0] d5,
    input wire [DATA_WIDTH-1:0] d6,
    input wire [DATA_WIDTH-1:0] d7,
    input wire [DATA_WIDTH-1:0] d8,
    output wire [DATA_WIDTH-1:0] d_out
);

// the result is {min, med, max}
function [DATA_WIDTH*3-1:0] sort_3data_func;
    input wire [DATA_WIDTH-1:0] p0,p1,p2;
    begin
    // swich shows the order of 3 inputs.
    // swich = 3'b011 means p0>=p1, p0<p2, p1<p2
    // so the order is p1 < p0 < p2
    
    case({( (p0<p1) ? 1'b1 : 1'b0), ( (p0<p2) ? 1'b1 : 1'b0), ( (p1<p2) ? 1'b1 : 1'b0)})
        3'b_111 : sort_3data_func = {p0,p1,p2};
        // p0 < p1 < p2 case
        
        3'b_110 : sort_3data_func = {p0,p2,p1};
        // p0 < p2 < p1 case
        
        3'b_011 : sort_3data_func = {p1,p0,p2};
        // p1 < p0 < p2 case
        
        3'b_001 : sort_3data_func = {p1,p2,p0};
        // p1 < p2 < p0 case
        
        3'b_100 : sort_3data_func = {p2,p0,p1};
        // p2 < p0 < p1 case
        
        3'b_000 : sort_3data_func = {p2,p1,p0};
        // p2 < p1 < p0 case
        default : sort_3data_func = {p0,p1,p2};
    endcase
    end
endfunction

function [3*DATA_WIDTH-1:0] sort_3group_func;
    input wire [DATA_WIDTH-1:0] g0_max, g0_med, g0_min,
                     g1_max, g1_med, g1_min,
                     g2_max, g2_med, g2_min;
    // sort 3 groups by median value. Suppose the resulting order is group
    // A,B, and C. (That means C's median < B's median < A's median) 
    // let x = median value of B
    // let y = minimum value of A
    // let z = max value of C
    // sort_3group_func return {x,y,z}
    begin
    // swich shows the order of 3 inputs.
    // swich = 3'b011 means g0>=g1, g0<g2, g1<g2
    // so the order is g1 < g0 < g2
    
    case({(g0_med<g1_med), (g0_med<g2_med), (g1_med<g2_med)})
        3'b_111 : sort_3group_func = {g1_med, g2_min, g0_max};
        // g0 < g1 < g2 case
        
        3'b_110 : sort_3group_func = {g2_med, g1_min, g0_max};
        // p0 < p2 < p1 case
        
        3'b_011 : sort_3group_func = {g0_med, g2_min, g1_max};
        // p1 < p0 < p2 case
        
        3'b_001 : sort_3group_func = {g2_med, g0_min, g1_max};
        // p1 < p2 < p0 case
        
        3'b_100 : sort_3group_func = {g0_med, g1_min, g2_max};
        // p2 < p0 < p1 case
        
        3'b_000 : sort_3group_func = {g1_med, g0_min, g2_max};
        // p2 < p1 < p0 case
    endcase

    end
endfunction

    wire [DATA_WIDTH-1:0] m0_max;
    wire [DATA_WIDTH-1:0] m0_med;
    wire [DATA_WIDTH-1:0] m0_min;
    wire [DATA_WIDTH-1:0] m1_max;
    wire [DATA_WIDTH-1:0] m1_med;
    wire [DATA_WIDTH-1:0] m1_min;
    wire [DATA_WIDTH-1:0] m2_max;
    wire [DATA_WIDTH-1:0] m2_med;
    wire [DATA_WIDTH-1:0] m2_min;

    // divide 9 data into 3 groups of 3 elements.
    // sort 3 groups indivisually.
    assign {m0_min,m0_med,m0_max} = sort_3data_func(d0,d1,d2);
    assign {m1_min,m1_med,m1_max} = sort_3data_func(d3,d4,d5);
    assign {m2_min,m2_med,m2_max} = sort_3data_func(d6,d7,d8);
    // sort 3 groups by median value. Suppose the resulting order is group
    // A,B, and C. (That means A's median > B's median > C's median) 
    // let y = minimum value of A
    // let x = median value of B
    // let z = max value of C
    wire [DATA_WIDTH-1:0] x,y,z;
    assign {x,y,z} = sort_3group_func(m0_max, m0_med, m0_min,
                                      m1_max, m1_med, m1_min,
                                      m2_max, m2_med, m2_min);
    // we now know
    // group        1   2   3
    //        min:  A   C   z
    //        med:  B > x > E 
    //        max:  y   D   *
    // 
    // so B,y,D is larger than x,
    //    C,E,z is smaller than x.
    // The relation among x,y,z is yet unkown.
    // Comparing them gives the median value of 9 inputs.

    wire [DATA_WIDTH-1:0] final_max, final_min;
    assign {final_min, d_out, final_max} = sort_3data_func(x,y,z);

endmodule

module median_filter(
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
    wire [11:0] median_value;

    reg [3:0] state = 0;
    reg [10:0] hcnt = 0;
    reg [10:0] vcnt = 0;
    reg [16:0] address_next;

    assign state_out = state;
    assign hcnt_out = hcnt;
    assign vcnt_out = vcnt;

    get_median_value #(
        .DATA_WIDTH(12)
    ) get_median_value(
        .d0(tmp_data0),
        .d1(tmp_data1),
        .d2(tmp_data2),
        .d3(tmp_data3),
        .d4(tmp_data4),
        .d5(tmp_data5),
        .d6(tmp_data6),
        .d7(tmp_data7),
        .d8(tmp_data8),
        .d_out(median_value)
    );

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
                    rd_addr <= addr_out - CAMERA_WIDTH - 1;
                    tmp_data0 <= data_in;
                    wr_en <= 1'b0;
                    state <= DATA1;
                end

                DATA1 : begin
                    rd_addr <= addr_out - CAMERA_WIDTH;
                    tmp_data1 <= data_in;
                    wr_en <= 1'b0;
                    state <= DATA2;
                end

                DATA2 : begin
                    rd_addr <= addr_out - CAMERA_WIDTH + 1;
                    wr_en <= 1'b0;
                    tmp_data2 <= data_in;
                    state <= DATA3;
                end

                DATA3 : begin
                    rd_addr <= addr_out - 1;
                    tmp_data3 <= data_in;
                    wr_en <= 1'b0;
                    state <= DATA4;
                end

                DATA4 : begin
                    rd_addr <= addr_out;
                    tmp_data4 <= data_in;
                    wr_en <= 1'b0;
                    state <= DATA5;
                end

                DATA5 : begin
                    rd_addr <= addr_out + 1;
                    tmp_data5 <= data_in;
                    wr_en <= 1'b0;
                    state <= DATA6;
                end

                DATA6 : begin
                    rd_addr <= addr_out + CAMERA_WIDTH - 1;
                    tmp_data6 <= data_in;
                    wr_en <= 1'b0;
                    state <= DATA7;
                end

                DATA7 : begin
                    rd_addr <= addr_out + CAMERA_WIDTH;
                    tmp_data7 <= data_in;
                    wr_en <= 1'b0;
                    state <= DATA8;
                end

                DATA8 : begin
                    rd_addr <= addr_out + CAMERA_WIDTH + 1;
                    tmp_data8 <= data_in;
                    wr_en <= 1'b0;
                    state <= CALC_DATA;
                end
    
                CALC_DATA : begin
                    calc_data <= median_value;
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
