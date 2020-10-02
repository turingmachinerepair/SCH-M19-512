`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:19:52 04/26/2020 
// Design Name: 
// Module Name:    DataMemory 
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
module DataMemory(
	index,
	chan,
	data_in,
	wr,
	data_out,
	clk,
	rsta
);

parameter INDEX_WIDTH = 4;
parameter CHAN_WIDTH = 3;
parameter DATA_WIDTH = 128;

input wire [INDEX_WIDTH-1:0] index;
input wire [CHAN_WIDTH-1:0] chan;
input wire [DATA_WIDTH-1:0] data_in;
input wire wr;
input wire clk;
input wire rsta;

output wire [DATA_WIDTH-1:0] data_out;

TagMemoryMatrix dataBlock(
	.clka(clk), // input clka
	.rsta(rsta), // input rsta
	.wea(wr), // input [0 : 0] wea
	.addra( {chan,index} ), // input [6 : 0] addra
	.dina(data_in), // input [127 : 0] dina
	.douta(data_out) // output [127 : 0] douta
);

endmodule
