`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:35:04 05/24/2020 
// Design Name: 
// Module Name:    StrRegister 
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
module StrRegister(
	clk,
	rst,
	
	lshift,
	rshift,
	str_load,
	word_load,
	
	str_in,
	word_in,
	str_out,
	word_out
);

parameter WORD_WIDTH = 8;
parameter STR_WIDTH = 128;

input clk;
input	rst;
	
input	lshift;
input	rshift;
input	str_load;
input	word_load;
	
input	[STR_WIDTH-1:0] str_in;
input	[WORD_WIDTH-1:0] word_in;
output [STR_WIDTH-1:0]	str_out;
output [WORD_WIDTH-1:0] word_out;

reg	[STR_WIDTH-1:0] str_buffer;
wire	[STR_WIDTH-1:0] mask;

assign str_out = str_buffer;
assign word_out = str_buffer;
assign mask = { {8{1'b0}},{120{1'b1}}};

always @(posedge clk	or posedge rst)
begin
	if(rst) begin
		str_buffer = 0;
		
	end else begin
	
		//load logic
		if( str_load ) begin
			str_buffer = str_in;
		end else if (word_load) begin
			str_buffer =  ( str_buffer & mask) | ( { word_in , {120{1'b0}}}) ;
		end
		
		//shift logic
		if( lshift ) begin
			str_buffer = str_buffer << WORD_WIDTH;
		end else if (rshift ) begin
			str_buffer = str_buffer >> WORD_WIDTH;
		end
		
	end
	
end

endmodule
