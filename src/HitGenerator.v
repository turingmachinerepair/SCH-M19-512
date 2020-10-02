`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    01:30:02 04/09/2020 
// Design Name: 
// Module Name:    HitGenerator 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module HitGenerator(
		hit,
		hit_out,
		chan
    );
	 
	 parameter CHAN_COUNT = 8;
	 parameter CHAN_WIDTH = 3;
	 integer i;
	 
	 input [CHAN_COUNT-1:0] hit;
	 output hit_out;
	 output reg [CHAN_WIDTH-1:0] chan;
	 
	 assign hit_out = |hit;
	 always @* begin
		 chan = 0; // default value if 'in' is all 0's
		 for (i=0; i<CHAN_COUNT; i=i+1)
			  if (hit[i]) chan = i;
	  end

endmodule
