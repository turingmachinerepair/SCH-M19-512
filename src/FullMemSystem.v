`timescale 1ns / 1ps
`include "CacheTop.v"
`include "CPUIf.v"

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:53:09 06/02/2020 
// Design Name: 
// Module Name:    FullMemSystem 
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
module FullMemSystem(
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
	cpu_clk,
	rst
);

//interface parameters
parameter ADDR_WIDTH = 16;
parameter WORD_WIDTH = 32;

localparam BVAL_WIDTH = WORD_WIDTH/8;
localparam TAG_WIDTH = 8;
localparam INDEX_WIDTH = 4;
localparam OFFSET_WIDTH = 4;

//ram interface parameters
parameter RAM_WORD_WIDTH = 8;
localparam RAM_ADDR_WIDTH = TAG_WIDTH+INDEX_WIDTH;

//cache structural parameters
parameter CHAN_WIDTH = 3;
parameter CHAN_COUNT = 8;
parameter STR_WORD_COUNT = 4;

input wire	cache_clk;
input	wire	cpu_clk;
input wire	ram_clk;
input wire rst;

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
input 	wire	ram_ack;

wire	[ADDR_WIDTH-1:0] cache_sys_addr;
wire	[WORD_WIDTH-1:0] cache_sys_wdata;
wire	[WORD_WIDTH-1:0] cache_sys_rdata;
wire	[BVAL_WIDTH-1:0]	cache_sys_bval;
wire	cache_sys_rd;
wire	cache_sys_wr;
wire	cache_sys_ack;
wire tx_fifo_ctrl;

CacheTop #(
	.ADDR_WIDTH(ADDR_WIDTH),
	.WORD_WIDTH(WORD_WIDTH),
	.RAM_WORD_WIDTH(RAM_WORD_WIDTH),
	
	.CHAN_COUNT(CHAN_COUNT),
	.CHAN_WIDTH(CHAN_WIDTH),
	.STR_WORD_COUNT(STR_WORD_COUNT)
) cache(
	.sys_addr	(cache_sys_addr),
	.sys_wdata	(cache_sys_wdata),
	.sys_rdata	(cache_sys_rdata),
	.sys_rd		(cache_sys_rd),
	.sys_wr		(cache_sys_wr),
	.sys_ack		(cache_sys_ack),
	.sys_bval	(cache_sys_bval),
	
	.ram_addr,
	.ram_avalid,
	.ram_rnw,
	.ram_rdata,
	.ram_wdata,
	.ram_ack,
	
	.cache_clk,
	.ram_clk,
	.rst,
	.tx_fifo_ctrl
);

CPUIf#(
	.ADDR_WIDTH(ADDR_WIDTH),
	.WORD_WIDTH(WORD_WIDTH),
	.BVAL_WIDTH(BVAL_WIDTH)
) CpuInterface(
	.sys_addr,
	.sys_wdata,
	.sys_rdata,
	.sys_rd,
	.sys_wr,
	.sys_ack,
	.sys_bval,

	
	.cache_sys_addr,
	.cache_sys_wdata,
	.cache_sys_rdata,
	.cache_sys_rd,
	.cache_sys_wr,
	.cache_sys_ack,
	.cache_sys_bval,
	
	.cache_clk,
	.cpu_clk,
	.rst,
	.tx_fifo_ctrl
);

endmodule
