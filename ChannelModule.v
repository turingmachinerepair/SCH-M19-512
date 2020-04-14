`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    02:26:40 04/09/2020 
// Design Name: 
// Module Name:    ChannelModule 
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
module ChannelModule (
	tag,
	index,
	mod_in,
	wr ,
	age ,
	lru_clr ,
	clk ,
			  
	tag_out ,
	valid ,
	lru ,
	mod_out,
	hit

);

parameter TAG_WIDTH= 8;
parameter INDEX_WIDTH= 4;
parameter LRU_WIDTH= 3;
parameter GROUP_COUNT=16;
parameter CHANNEL_NUM = 0;


reg [TAG_WIDTH-1:0] TAG_DATA [GROUP_COUNT-1:0];
reg [LRU_WIDTH-1:0] LRU_DATA [GROUP_COUNT-1:0];
reg MOD_DATA [GROUP_COUNT-1:0];
reg VALID_DATA [GROUP_COUNT-1:0];


input wire [ TAG_WIDTH-1:0] tag;
input wire [INDEX_WIDTH-1:0] index;
input wire mod_in;
input wire wr;
input wire age;
input wire clk;
input wire lru_clr;

output wire [TAG_WIDTH-1:0] tag_out;
output wire valid;
output wire [LRU_WIDTH-1:0] lru;
output wire mod_out;
output wire hit;

//read
assign tag_out = TAG_DATA[index];  
assign lru = LRU_DATA[index];
assign mod_out = MOD_DATA[index];
assign valid = VALID_DATA[index];
assign hit = (tag == tag_out) & valid;
integer i;

initial
begin
	for( i=0; i<GROUP_COUNT; i=i+1)
	begin
		TAG_DATA[i] = 0;
		LRU_DATA[i] = CHANNEL_NUM;
		MOD_DATA[i] = 0;
		VALID_DATA[i] = 0;
	end 
end

always @(posedge clk)
begin
      if (wr)
		begin
         TAG_DATA[index] <= tag;
			//LRU_DATA[index] <= 0;
			VALID_DATA[index] <= 1;
			MOD_DATA[index] <= mod_in;	
		end else if ( mod_in )
			MOD_DATA[index]<=mod_in;
		else if ( age ) begin
			LRU_DATA[index] <= LRU_DATA[index]+1;
		end else if (lru_clr ) begin
			LRU_DATA[index] <=0;
		end
end

endmodule
