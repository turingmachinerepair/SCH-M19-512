`timescale 1ns / 1ps
`include "RCU.v"
`include "StrRegister.v"

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    01:38:14 04/28/2020 
// Design Name: 
// Module Name:    RAMInterface 
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
module RAMInterface(
	wdata,
	tag,
	index,
	
	cache_ram_rnw,
	cache_ram_aval,
	cache_ram_ack,
	
	rdata,
	
	ram_addr,
	ram_aval,
	ram_rnw,
	ram_rdata,
	ram_wdata,
	ram_ack,
	
	cache_clk,
	ram_clk,
	rst
	
);
genvar i;

parameter TAG_WIDTH = 8;	
parameter INDEX_WIDTH = 4;
parameter STR_WIDTH = 128;

parameter RAM_ADDR_WIDTH = 12;
parameter RAM_WORD_WIDTH = 8;

//packet lengths
localparam TX_PACKET_WIDTH = 2+INDEX_WIDTH+TAG_WIDTH+RAM_WORD_WIDTH;
localparam RX_PACKET_WIDTH = 1+RAM_WORD_WIDTH;

//data signals
input		wire [STR_WIDTH-1:0]		wdata;
output	wire [STR_WIDTH-1:0]		rdata;
input		wire [TAG_WIDTH-1:0]		tag;
input		wire [INDEX_WIDTH-1:0]	index;

//cache interface
input		wire cache_ram_rnw;
input		wire cache_ram_aval;
output	wire cache_ram_ack;
	
//ram interface
output	wire [RAM_ADDR_WIDTH-1:0] ram_addr;
input 	wire [RAM_WORD_WIDTH-1:0] ram_rdata;
output	wire [RAM_WORD_WIDTH-1:0] ram_wdata;
output	wire ram_aval;
output	wire ram_rnw;
input		wire ram_ack;
//clocks
input wire	cache_clk;
input wire	ram_clk;
input wire	rst;


//additional wires
wire reg_lshift;
wire reg_rshift;
wire reg_str_load;
wire reg_word_load;
	
wire tx_fifo_wr;
wire tx_fifo_empty;

wire rx_fifo_empty;
wire rx_fifo_full;
wire rx_fifo_read;

//tx packet for ram fifo - concat of status signals, addr and word
wire [TX_PACKET_WIDTH-1:0] tx_packet;
wire [TX_PACKET_WIDTH-1:0] tx_packet_ram;
//rx packet for ram fifo - concat of ram_ack and data from RAM
wire [RX_PACKET_WIDTH-1:0] rx_packet;

wire [RAM_WORD_WIDTH-1:0]	word_buffer;
wire [STR_WIDTH-1:0]			str_buffer;
wire ram_ack_resync;
wire buffered_ram_rnw;
wire buffered_ram_aval;
wire [3:0]	rd_data_count;

assign ram_ack_resync = rx_packet[RAM_WORD_WIDTH];
assign word_buffer = str_buffer;

//assemble tx packet for FIFO
assign tx_packet = { buffered_ram_rnw, buffered_ram_aval, {tag,index}, word_buffer };
//disassemble tx packet after FIFO 
assign ram_wdata = tx_packet_ram;
assign ram_aval = tx_packet_ram[ TX_PACKET_WIDTH-1 ];
assign ram_rnw = tx_packet_ram[ TX_PACKET_WIDTH-2 ];
generate
	for( i = 0; i < RAM_ADDR_WIDTH; i = i+1)
	begin : RAM_ADDR_GEN
		assign ram_addr[i] = tx_packet_ram[ RAM_WORD_WIDTH + i ];
	end
endgenerate

assign rdata = str_buffer;

//tx fifo
SyncFIFO TX_buffer (
  .rst	(rst),
  .wr_clk(cache_clk),
  .rd_clk(ram_clk),
  
  .din	( tx_packet ), // input [7 : 0] din
  .wr_en	(tx_fifo_wr), // input wr_en
  
  .dout	( tx_packet_ram ), // output [7 : 0] dout
  .rd_en	( ~tx_fifo_empty ), // input rd_en
  
  .full(), // output full
  .empty(tx_fifo_empty) // output empty
);

//rx fifo
SyncFIFO_RX RX_buffer (
	.rst		(rst), 
	.wr_clk	(ram_clk), 
	.rd_clk	(cache_clk), 
  
	.wr_en(ram_ack), // input wr_en
	.din	( {ram_ack, ram_rdata} ), // input [8 : 0] din

	.rd_en( rx_fifo_read ), // input rd_en
	.dout	( rx_packet ), // output [8 : 0] dout
	
	.full		(), // output full
	.rd_data_count(rd_data_count),
	//.valid	(rx_fifo_empty)
	.prog_full(rx_fifo_full),
	.empty	(rx_fifo_empty) // output empty
);

//control unit
RCU RamControl(
	.clk(cache_clk),
	.rst(rst),
	
	.cache_avalid	( cache_ram_aval ),
	.cache_rnw		( cache_ram_rnw ),
	.cache_ack		( cache_ram_ack ),
	.ram_ack			( ram_ack_resync ),
	
	.reg_lshift		(reg_lshift),
	.reg_rshift		(reg_rshift),
	.reg_str_load	(reg_str_load),
	.reg_word_load	(reg_word_load),
	
	.tx_fifo_wr		(tx_fifo_wr),
	.rx_fifo_empty	(rx_fifo_empty),
	.rx_fifo_full	(rx_fifo_full),
	.rx_fifo_read	(rx_fifo_read),
	.last_bit		(~rd_data_count[0]),
	
	.buffered_ram_rnw(buffered_ram_rnw),
	.buffered_ram_aval(buffered_ram_aval)
);

//register
StrRegister #(
	.WORD_WIDTH (RAM_WORD_WIDTH),
	.STR_WIDTH	(STR_WIDTH)
) StrReg(
	.clk(cache_clk),
	.rst(rst),
	
	.lshift		(reg_lshift),
	.rshift		(reg_rshift ),
	//.rshift( reg_rshift ),
	.str_load	(reg_str_load),
	.word_load	(reg_word_load),
	
	.str_in	(wdata),
	.word_in	(rx_packet),
	.str_out	(str_buffer),
	.word_out ()
);

endmodule
