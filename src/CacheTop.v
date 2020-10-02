`timescale 1ns / 1ps

`include "TagMemory.v"
`include "CacheControlUnit.v"
`include "DataMemory.v"
`include "WordSelector.v"
`include "RAMInterface.v"

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:57:11 04/26/2020 
// Design Name: 
// Module Name:    CacheTop 
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
module CacheTop(
	sys_addr,
	sys_wdata,
	sys_rdata,
	sys_rd,
	sys_wr,
	sys_ack,
	sys_bval,
	
	ram_addr,
	ram_avalid,
	ram_rnw,
	ram_rdata,
	ram_wdata,
	ram_ack,
	cache_clk,
	ram_clk,
	rst,
	tx_fifo_ctrl
);

genvar i;
parameter ADDR_WIDTH = 16;
parameter WORD_WIDTH = 32;
parameter RAM_WORD_WIDTH = 8;

parameter CHAN_WIDTH = 3;
parameter CHAN_COUNT = 8;
parameter STR_WORD_COUNT = 4;

localparam TAG_WIDTH = 8;
localparam INDEX_WIDTH = 4;
localparam OFFSET_WIDTH = 4;
localparam STR_WIDTH = STR_WORD_COUNT*WORD_WIDTH;
localparam BVAL_WIDTH = WORD_WIDTH/8;
localparam RAM_ADDR_WIDTH = TAG_WIDTH+INDEX_WIDTH;

input		wire	[ADDR_WIDTH-1:0] sys_addr;
input		wire	[WORD_WIDTH-1:0] sys_wdata;
output	wire	[WORD_WIDTH-1:0] sys_rdata;
input		wire	[BVAL_WIDTH-1:0]	sys_bval;
input		wire	sys_rd;
input		wire	sys_wr;
output	wire	sys_ack;
	
output	wire	[RAM_ADDR_WIDTH-1:0] 		ram_addr;
input		wire	[RAM_WORD_WIDTH-1:0] ram_rdata;
output	wire	[RAM_WORD_WIDTH-1:0] ram_wdata;
output	wire	ram_avalid;
output	wire	ram_rnw;
output	wire	tx_fifo_ctrl;
input 	wire	ram_ack;

input wire	cache_clk;
input wire	ram_clk;
input wire rst;

wire hit;
wire age;
wire age_mod;
wire tag_wr;
wire ram_inner_ack;
wire mod;
wire age_valid;

wire [STR_WIDTH-1:0] cache_str;
wire [STR_WIDTH-1:0] cpu_data;
wire [STR_WIDTH-1:0] ram_data;

wire [TAG_WIDTH-1:0]		age_tag;
wire [CHAN_WIDTH-1:0]	chan;
wire [CHAN_WIDTH-1:0]	age_chan;

reg	[TAG_WIDTH-1:0]		tag;
reg	[INDEX_WIDTH-1:0]		index;
reg	[OFFSET_WIDTH-1:0]	offset;

always @(sys_addr)
   {tag, index, offset} = sys_addr;

//CS4 - select word from offset
/*WordSelector #(
	.WORD_WIDTH(WORD_WIDTH),
	.WORD_COUNT(WORD_COUNT),
	.SEL_WIDTH(OFFSET_WIDTH)
) wSel(
	.in	( cache_str ),
	.out	( sys_rdata ),
	.sel	( offset )
);*/
//CS4 - select word from offset
assign sys_rdata = cache_str>> ((offset >> 2) * WORD_WIDTH);

//CS3
DataFormer cpuDataFormer(
	.str(cache_str),
	.wdata(sys_wdata),
	.bval(sys_bval),
	.offset(offset),
	
	.o_str(cpu_data)
);

RAMInterface RAMIf(
	.wdata (cache_str),
	.tag ( tag_sel ? age_tag : tag ),
	.index (  index),
	
	.cache_ram_rnw (ram_rnw_inner),
	.cache_ram_aval (ram_aval_inner),
	.cache_ram_ack (ram_inner_ack) ,
	
	.rdata (ram_data) ,
	
	.ram_addr (ram_addr),
	.ram_aval(ram_avalid),
	.ram_rnw(ram_rnw),
	.ram_rdata(ram_rdata),
	.ram_wdata(ram_wdata),
	.ram_ack(ram_ack),
	
	.cache_clk(cache_clk),
	.ram_clk (ram_clk),
	.rst(rst)
);


TagMemory tagMemory(
	.tag_in	(tag),
   .index	(index) ,
   .wr		(tag_wr) ,
   .mod_in	(mod) ,
   .age		(age),
	.clk 		(cache_clk),
			  
   .chan 		(chan),
   .age_chan 	(age_chan),
   .age_tag 	(age_tag),
   .age_mod 	(age_mod),
	.age_valid	(age_valid),
   .hit			(hit) 
);

CacheControlUnit CCU(
	.hit			( hit ) ,
	.age_mod		( age_mod ),
	.sys_rd		( sys_rd ),
	.sys_wr		( sys_wr ),
	.ram_ack		( ram_inner_ack ),
	.clk			( cache_clk ),
	.reset		( rst ),
	.age_valid	( age_valid),
	
	.tag_wr		( tag_wr ),
	.mod			( mod ),
	.age			( age ),
	.chan_sel	( chan_sel ),
	.data_sel	( data_sel ),
	.tag_sel		( tag_sel	),
	.cache_wr	( cache_wr ),
	.ram_rnw		( ram_rnw_inner ),
	.ram_aval	( ram_aval_inner ),
	.sys_ack		( sys_ack ),
	.tx_fifo_ctrl
);

DataMemory DataMem(
	.index		( index ),
	.chan			( chan_sel ? age_chan : chan ),
	.data_in		( data_sel ? ram_data : cpu_data ),
	.wr			( cache_wr ),
	.data_out	( cache_str ),
	.clk			( cache_clk ),
	.rsta			( rst )
);

endmodule
