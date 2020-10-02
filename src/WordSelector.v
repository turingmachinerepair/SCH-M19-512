`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:18:39 04/27/2020 
// Design Name: 
// Module Name:    WordSelector 
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
module WordSelector(
	in,
	sel,
	out
    );

parameter WORD_WIDTH = 32;
parameter WORD_COUNT = 4;
parameter SEL_WIDTH = 4;
localparam STR_WIDTH = WORD_WIDTH*WORD_COUNT;

input wire [STR_WIDTH-1:0] in;
input wire [SEL_WIDTH-1:0] sel;
output wire [WORD_WIDTH-1:0] out;

wire [SEL_WIDTH-1:0] effective_shift;

assign effective_shift = sel>>2;
assign out = (in >> effective_shift*WORD_WIDTH) ;

endmodule
