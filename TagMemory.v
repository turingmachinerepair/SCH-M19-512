`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    01:28:38 04/09/2020 
// Design Name: 
// Module Name:    TagMemory 
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
`include "LRUGenerator.v"
`include "HitGenerator.v"
`include "UnitaryEncoder.v"


module TagMemory#(
	parameter TAG_WIDTH = 8,
	parameter INDEX_WIDTH = 4,
	parameter OFFSET_WIDTH = 4,
	parameter CHAN_WIDTH = 3
) (
	tag_in,
   index ,
   wr ,
   mod_in ,
   age ,
	clk ,
			  
   chan ,
   age_chan ,
   age_tag ,
   age_mod ,
   hit 
);

genvar i;
integer j;
localparam LRU_WIDTH = CHAN_WIDTH;
localparam CHAN_COUNT = 8;

input wire	[TAG_WIDTH-1:0]	tag_in;
input wire	[INDEX_WIDTH-1:0]	index;
input wire	wr;
input wire	mod_in;
input wire	age;
input wire 	clk;
			  
output wire  [CHAN_WIDTH-1:0] chan;
output reg  [CHAN_WIDTH-1:0] age_chan;
output reg  [TAG_WIDTH-1:0]	age_tag;
output reg  age_mod;
output wire  hit;

//channels' wires
wire [TAG_WIDTH-1:0]	channel_tag_out [CHAN_COUNT-1:0]	;
wire [LRU_WIDTH-1:0]	channel_lru	[CHAN_COUNT-1:0]		;
wire 						channel_valid	[CHAN_COUNT-1:0]	;
wire 						channel_mod_out [CHAN_COUNT-1:0]	;

//
wire [CHAN_COUNT-1:0]	channel_hit;
wire [CHAN_COUNT-1:0]	channel_en;
wire [CHAN_COUNT-1:0]	age_channel_en;
wire [CHAN_COUNT-1:0]	channel_en_local;

wire [LRU_WIDTH-1:0] hit_lru;

assign hit_lru = channel_lru[chan];

//
always @* begin
	
		/*hit_lru = lru[0];
		age_tag = channel_tag_out[0];
		age_mod = channel_mod_out[0];
		age_chan = lru[0];*/
		
		for( j = 0; j<CHAN_COUNT; j=j+1)
		begin
			if( channel_lru[j] == {LRU_WIDTH{1'b1}} )
			begin
				age_mod = channel_mod_out[j];
				age_chan = j;
				age_tag = channel_tag_out[j];
			end
		end
	end
/*LRUGenerator#(
	.CHAN_COUNT(CHAN_COUNT),
	.TAG_WIDTH(TAG_WIDTH)
) lru_gen(
	//could be done via text macros or using SystemVerilog-compliant compiler
		.tag_in0 ( channel_tag_out[0]),
		.lru_in0 (channel_lru[0]) ,
		.mod0 (channel_mod_out[0]),	
		
		.tag_in1 ( channel_tag_out[1]),
		.lru_in1	(channel_lru[1]),
		.mod1 (channel_mod_out[1]),
		
		.tag_in2 ( channel_tag_out[2]),
		.lru_in2 (channel_lru[2]),
		.mod2 (channel_mod_out[2]),	
		
		.tag_in3 ( channel_tag_out[3]),
		.lru_in3 (channel_lru[3]),
		.mod3 (channel_mod_out[3]),
		
		.tag_in4 ( channel_tag_out[4]),
		.lru_in4 (channel_lru[4]),
		.mod4 (channel_mod_out[4]),	
		
		.tag_in5 ( channel_tag_out[5]),
		.lru_in5 (channel_lru[5]),
		.mod5 (channel_mod_out[5]),
		
		.tag_in6 ( channel_tag_out[6]),
		.lru_in6 (channel_lru[6]),
		.mod6 (channel_mod_out[6]),	
		
		.tag_in7 ( channel_tag_out[7]),
		.lru_in7(channel_lru[7]),
		.mod7 (channel_mod_out[7]),
	
	.age_tag(age_tag),
	.age_chan(age_chan),
	.age_mod(age_mod)
);*/

HitGenerator hit_gen(
	.hit		( channel_hit	),
	.hit_out	( hit				),
	.chan		( chan			)
);

UnitaryEncoder chan_selector(
	.addr( 		chan ),
	.selector(	channel_en )
);

UnitaryEncoder age_chan_selector(
	.addr( 		age_chan			),
	.selector(	age_channel_en	)
);

generate
for(i=0;i<CHAN_COUNT;i=i+1)
	begin: epic_channel
		assign channel_en_local[i] = (channel_hit[i]? ( channel_en[i] ):(age_channel_en[i] )) && wr;
		ChannelModule#(
			.CHANNEL_NUM(i)
		) channel(
			.tag		( tag_in	),
			.index	( index	),
			.mod_in	( mod_in && channel_en[i]),
			.wr		( channel_en_local[i] ),
			.age		( (channel_lru[i] < hit_lru ) && age),// && ~channel_hit[i] ) ,
			.lru_clr	( age && ( channel_lru[i]==hit_lru) ),
			.clk		( clk ) ,
					  
			.tag_out	(channel_tag_out[i]) ,
			.valid	(channel_valid[i]) ,
			.lru		(channel_lru[i]) ,
			.mod_out	(channel_mod_out[i]),
			.hit		(channel_hit[i])
		);
		
	end
endgenerate

endmodule
