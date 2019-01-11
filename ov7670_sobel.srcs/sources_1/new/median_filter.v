module median_filter#(
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
        /*
        sort_3data m0(
            .p0(d0), .p1(d1), p2(d2), d_max(m0_max), d_med(m0_med), d_min(m0_min)
        );

        sort_3data m1(
            .p0(d3), .p1(d4), p2(d5), d_max(m1_max), d_med(m1_med), d_min(m1_min)
        );

        sort_3data m2(
            .p0(d6), .p1(d7), p2(d8), d_max(m2_max), d_med(m2_med), d_min(m2_min)
        );
        */
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
