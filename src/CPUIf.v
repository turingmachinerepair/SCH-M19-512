`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:48:16 06/01/2020 
// Design Name: 
// Module Name:    CPUIf 
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
module CPUIf(
	sys_addr,
	sys_wdata,
	sys_rdata,
	sys_rd,
	sys_wr,
	sys_ack,
	sys_bval,

	
	cache_sys_addr,
	cache_sys_wdata,
	cache_sys_rdata,
	cache_sys_rd,
	cache_sys_wr,
	cache_sys_ack,
	cache_sys_bval,
	
	cache_clk,
	cpu_clk,
	rst,
	tx_fifo_ctrl
);

genvar i;

parameter ADDR_WIDTH = 16;
parameter WORD_WIDTH = 32;
parameter BVAL_WIDTH = 4;

//cpu interface
input		wire	[ADDR_WIDTH-1:0] sys_addr;
input		wire	[WORD_WIDTH-1:0] sys_wdata;
output	wire	[WORD_WIDTH-1:0] sys_rdata;
input		wire	[BVAL_WIDTH-1:0]	sys_bval;
input		wire	sys_rd;
input		wire	sys_wr;
output	wire	sys_ack;
	
//cache interface

output		wire	[ADDR_WIDTH-1:0] cache_sys_addr;
output		wire	[WORD_WIDTH-1:0] cache_sys_wdata;
input			wire	[WORD_WIDTH-1:0] cache_sys_rdata;
output		wire	[BVAL_WIDTH-1:0]	cache_sys_bval;
output		wire	cache_sys_rd;
output		wire	cache_sys_wr;
input			wire	cache_sys_ack;

input wire	cpu_clk;
input wire	cache_clk;
input wire rst;
input wire tx_fifo_ctrl;

wire [ADDR_WIDTH+WORD_WIDTH+BVAL_WIDTH+1:0] cpu_tx_packet;
wire [WORD_WIDTH:0] cpu_rx_packet;

wire [ADDR_WIDTH+WORD_WIDTH+BVAL_WIDTH+1:0] cache_tx_packet;
wire [WORD_WIDTH:0] cache_rx_packet;

wire tx_wr_en;
assign tx_wr_en = sys_wr | sys_rd;

//CPU->CACHE
//pre-buffer
assign cpu_tx_packet = {sys_rd,sys_wr, sys_bval,sys_addr, sys_wdata};
//post-buffer
assign cache_sys_wdata = cache_tx_packet;
for(i=0;i<ADDR_WIDTH;i=i+1)
begin
		assign cache_sys_addr[i] = cache_tx_packet[WORD_WIDTH+i];
end

for(i=0;i<BVAL_WIDTH;i=i+1)
begin
	assign cache_sys_bval[i] = cache_tx_packet[WORD_WIDTH+ADDR_WIDTH+i];
end

assign cache_sys_rd = ( cache_tx_packet[WORD_WIDTH+ADDR_WIDTH+BVAL_WIDTH+1] & ~tx_empty);
assign cache_sys_wr = ( cache_tx_packet[WORD_WIDTH+ADDR_WIDTH+BVAL_WIDTH] & ~tx_empty);

//CPU<-CACHE
//pre-buffer
assign cache_rx_packet = {cache_sys_ack, cache_sys_rdata};
//post-buffer
assign sys_rdata = cpu_rx_packet;
assign sys_ack = cpu_rx_packet[WORD_WIDTH];
wire tx_empty,rx_empty;


//fifos
CPU_TX_buffer CPU_TX_buffer(
  .rst(rst), // input rst
  .wr_clk(cpu_clk), // input wr_clk
  .rd_clk(cache_clk), // input rd_clk
  
  .din(cpu_tx_packet), // input [53 : 0] din
  .wr_en( tx_wr_en ), // input wr_en
  .rd_en( ~tx_empty ), // input rd_en
  
  .dout(cache_tx_packet), // output [53 : 0] dout
  
  .full(), // output full
  .empty(tx_empty) // output empty
);

CPU_RX_buffer CPU_RX_buffer(
	.rst(rst), 
  .wr_clk(cache_clk), 
  .rd_clk(cpu_clk), 
  
  .din(cache_rx_packet), 
  .wr_en(tx_fifo_ctrl), 
  
  .rd_en(~rx_empty), 
  .dout(cpu_rx_packet), 
  
  .full(),
  .empty(rx_empty) 
);

endmodule
