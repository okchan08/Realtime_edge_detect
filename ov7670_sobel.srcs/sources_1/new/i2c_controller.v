`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/06/08 00:12:38
// Design Name: 
// Module Name: i2c_contoroller
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


module i2c_controller(
	input	wire	clk,
	inout	siod,
	output	reg	sioc,
	output	reg	taken,
	input	wire	send,
	input	wire	[7:0] id,
	input	wire	[7:0] regs,
	output  wire    [7:0] div_out,
	input	wire	[7:0] value
    );

	reg [7:0] divider = 8'b_1111_1100;
	reg [31:0] busy_sr = 32'h0;
	reg [31:0] data_sr = 32'h_FFFF_FFFF;

    assign div_out = divider;
    assign siod = (busy_sr[11:10] == 2'b10 || busy_sr[20:19] == 2'b10 || busy_sr[29:28] == 2'b10) ? 1'bz : data_sr[31];
//	always @(busy_sr or data_sr[31]) begin
//		if(busy_sr[11:10] == 2'b10 ||
//		   busy_sr[20:19] == 2'b10 ||
//		   busy_sr[29:28] == 2'b10) begin
//		      assign siod = 1'bz;
//		end else begin
//			  assign siod = data_sr[31];
//		end
//	end

	always @(posedge clk) begin
		taken <= 1'b0;

		if(busy_sr[31] == 1'b0) begin
		sioc <= 1'b1;
			if(send == 1'b1) begin
				if(divider == 8'b_0000_0000) begin
					data_sr <= {3'b100, id, 1'b0, regs, 1'b0, value, 1'b0, 2'b01};
					busy_sr <= 32'h_FFFF_FFFF;
					taken <= 1'b1;
				end else begin
					divider <= divider + 8'b1;
				end
			end
		end else begin
			case ( {busy_sr[31:29], busy_sr[2:0]} )
				6'b_111111 : begin // start seq #1
                		  case (divider[7:6])
                		      2'b00   : sioc <= 1'b1;
                		      2'b01   : sioc <= 1'b1;
                		      2'b10   : sioc <= 1'b1;
                		      default : sioc <= 1'b1;
                		  endcase
				end
                6'b_111110 : begin // start seq #2
                		  case (divider[7:6])
                		      2'b00   : sioc <= 1'b1;
                		      2'b01   : sioc <= 1'b1;
                		      2'b10   : sioc <= 1'b1;
                		      default : sioc <= 1'b1;
                		  endcase
				end
                6'b_111100 : begin // start seq #3
                		  case (divider[7:6])
                		      2'b00   : sioc <= 1'b0;
                		      2'b01   : sioc <= 1'b0;
                		      2'b10   : sioc <= 1'b0;
                		      default : sioc <= 1'b0;
                		  endcase
				end
                6'b_110000 : begin // end seq #1
                		  case (divider[7:6])
                		      2'b00   : sioc <= 1'b0;
                		      2'b01   : sioc <= 1'b1;
                		      2'b10   : sioc <= 1'b1;
                		      default : sioc <= 1'b1;
                		  endcase
				end
                6'b_100000 : begin // end seq #2
					       case(divider[7:6])
                		       2'b00   : sioc <= 1'b1;
                		       2'b01   : sioc <= 1'b1;
                		       2'b10   : sioc <= 1'b1;
                		       default : sioc <= 1'b1;
                		   endcase
				end
                6'b_000000 : begin //Idle
					       case(divider[7:6])
                		       2'b00   : sioc <= 1'b1;
                		       2'b01   : sioc <= 1'b1;
                		       2'b10   : sioc <= 1'b1;
                		       default : sioc <= 1'b1;
                		   endcase
				end
				default : begin
				         	case(divider[7:6])
                		       2'b00   : sioc <= 1'b0;
                		       2'b01   : sioc <= 1'b1;
                		       2'b10   : sioc <= 1'b1;
                		       default : sioc <= 1'b0;
                		    endcase
				end
            endcase
		    if(divider == 8'b_1111_1111) begin
			     busy_sr <= {busy_sr[30:0], 1'b0};
			     data_sr <= {data_sr[30:0], 1'b1};
			     divider <= 8'h0;
		    end else begin
			     divider <= divider + 8'h1;
      		end
        end
	end
endmodule
