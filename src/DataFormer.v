`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:22:58 04/28/2020 
// Design Name: 
// Module Name:    DataFormer 
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
module DataFormer(
	str,
	wdata,
	bval,
	offset,
	
	o_str
);
genvar i;

parameter WORD_WIDTH = 32;
parameter WORD_COUNT = 4;
parameter OFFSET_WIDTH = 4;

localparam BVAL_WIDTH = WORD_COUNT;
localparam STR_WIDTH = WORD_COUNT*WORD_WIDTH;

input wire	[STR_WIDTH-1:0]		str;
input wire	[WORD_WIDTH-1:0]		wdata;
input wire	[BVAL_WIDTH-1:0]		bval;
input wire	[OFFSET_WIDTH-1:0]	offset;

output reg [STR_WIDTH-1:0]		o_str;

wire [8*BVAL_WIDTH-1:0] expanded_bval;
wire [WORD_WIDTH-1:0]	effective_word;

//form valid word
//expand bval to word
/*for( i=0; i<BVAL_WIDTH*8; i=i+1)
begin: EXPANDED_BVAL_GEN
	assign expanded_bval = bval[ i >> 3 ];
end*/
//filter valid bytes
assign expanded_bval = { {8{bval[3]}}, {8{bval[2]}}, {8{bval[1]}}, {8{bval[0]}} };
assign effective_word = wdata & expanded_bval;

reg [STR_WIDTH-1:0] mask;
reg [STR_WIDTH-1:0] word_mask;
reg [7:0]	effective_shift;

always @(*)
begin

	mask = expanded_bval;//32'hffffffff;
	effective_shift = ((offset>>2))*WORD_WIDTH;
	mask = (mask<< effective_shift);
	
	o_str = (( ~mask & str ) | (effective_word << effective_shift) );
end

/*for( i =0; i<STR_WIDTH; i= i+1)
begin
	assign o_str[i] = ( (i/8) == offset>>2 )?effective_word[i%8]:str[i];
end*/

endmodule
