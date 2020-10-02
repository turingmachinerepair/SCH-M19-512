`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    01:36:47 04/09/2020 
// Design Name: 
// Module Name:    LRUGenerator 
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



module LRUGenerator#(
	 CHAN_COUNT = 8,
	 TAG_WIDTH = 8
)(
		tag_in0,
		lru_in0,
		mod0,	
		
		tag_in1,
		lru_in1,
		mod1,
		
		tag_in2,
		lru_in2,
		mod2,	
		
		tag_in3,
		lru_in3,
		mod3,
		
		tag_in4,
		lru_in4,
		mod4,	
		
		tag_in5,
		lru_in5,
		mod5,
		
		tag_in6,
		lru_in6,
		mod6,	
		
		tag_in7,
		lru_in7,
		mod7,
		
		age_tag,
		age_chan,
		age_mod
    );
	 
	 integer i,max;
	 localparam LRU_WIDTH = CHAN_WIDTH;
	 localparam CHAN_WIDTH = 3;
	 localparam max_lru = {LRU_WIDTH{1'b1} };

	input wire [TAG_WIDTH-1:0] tag_in0;
	input wire [LRU_WIDTH-1:0] lru_in0;
	input wire	mod0;	
		
	input wire [TAG_WIDTH-1:0] tag_in1;
	input wire [LRU_WIDTH-1:0]	lru_in1;
	input wire	mod1;
		
	input wire [TAG_WIDTH-1:0] tag_in2;
	input wire [LRU_WIDTH-1:0]	lru_in2;
	input wire	mod2;	
		
	input wire [TAG_WIDTH-1:0] tag_in3;
	input wire [LRU_WIDTH-1:0]	lru_in3;
	input wire	mod3;
		
	input wire [TAG_WIDTH-1:0] tag_in4;
	input wire [LRU_WIDTH-1:0]	lru_in4;
	input wire	mod4;	
		
	input wire [TAG_WIDTH-1:0] tag_in5;
	input wire [LRU_WIDTH-1:0]	lru_in5;
	input wire	mod5;
		
	input wire [TAG_WIDTH-1:0] tag_in6;
	input wire [LRU_WIDTH-1:0]	lru_in6;
	input wire	mod6;	
		
	input wire [TAG_WIDTH-1:0] tag_in7;
	input wire [LRU_WIDTH-1:0]	lru_in7;
	input wire mod7;
	 
	 output reg [TAG_WIDTH-1:0] age_tag;
	 output reg [CHAN_WIDTH-1:0] age_chan;
	 output reg age_mod;
	 
	 reg [TAG_WIDTH-1:0] tag[CHAN_COUNT-1:0];
	 reg [LRU_WIDTH-1:0] lru[CHAN_COUNT-1:0];
	 reg mod [CHAN_COUNT-1:0];
	 
	always @* begin
		tag[0] = tag_in0;
		tag[1] = tag_in1;
		tag[2] = tag_in2;
		tag[3] = tag_in3;
		tag[4] = tag_in4;
		tag[5] = tag_in5;
		tag[6] = tag_in6;
		tag[7] = tag_in7;
		
		lru[0] = lru_in0;
		lru[1] = lru_in1;
		lru[2] = lru_in2;
		lru[3] = lru_in3;
		lru[4] = lru_in4;
		lru[5] = lru_in5;
		lru[6] = lru_in6;
		lru[7] = lru_in7;
		
		mod[0] = mod0;
		mod[1] = mod1;
		mod[2] = mod2;
		mod[3] = mod3;
		mod[4] = mod4;
		mod[5] = mod5;
		mod[6] = mod6;
		mod[7] = mod7;
	
		max = lru[0];
		age_tag = tag[0];
		age_mod = mod[0];
		age_chan = lru[0];
		
		for( i = 0; i<CHAN_COUNT; i=i+1)
		begin
			if( lru[i] == max_lru )
			begin
				max = lru[i];
				age_mod = mod[i];
				age_chan = i;
				age_tag = tag[i];
			end
		end
	end
		
	 
	
endmodule
