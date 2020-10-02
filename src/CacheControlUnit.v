`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:58:32 04/26/2020 
// Design Name: 
// Module Name:    CacheControlUnit 
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
module CacheControlUnit(
	hit,
	age_mod,
	sys_rd,
	sys_wr,
	ram_ack,
	age_valid,
	clk,
	reset,
	
	tag_wr,
	mod,
	age,
	chan_sel,
	data_sel,
	tag_sel,
	cache_wr,
	ram_rnw,
	ram_aval,
	sys_ack,
	
	tx_fifo_ctrl

);

input wire hit;
input wire age_mod;
input wire sys_rd;
input wire sys_wr;
input wire ram_ack;
input wire clk;
input wire reset;
input wire age_valid;
	
output reg tag_wr;
output reg mod;
output reg age;
output reg chan_sel;
output reg data_sel;
output reg cache_wr;
output reg ram_rnw;
output reg ram_aval;
output reg sys_ack;
output reg tag_sel;
output reg tx_fifo_ctrl;

localparam IDLE  = 0,
				DATA_WR = 1,
				DATA_RD = 2,
				RAM_WR = 3,
				RAM_COMMIT_WR = 4,
				RAM_RD =5,
				RAM_COMMIT_RD = 6,
				RAM_RAW_WR = 7,
				AUX_TICK = 8;
localparam SIZE = 4;

reg   [SIZE-1:0]          state        ;// Seq part of the FSM
reg  [SIZE-1:0]          next_state   ;// combo part of FSM
reg buffered_sys_rd;
reg buffered_sys_wr;

always @(posedge clk or posedge reset)
begin	
	if( reset == 1) 
		buffered_sys_wr <= 0;
	else if( sys_ack == 1) 
		buffered_sys_wr <= 0;
	else if (sys_wr == 1)
		buffered_sys_wr <= sys_wr;
	else 
		buffered_sys_wr <= buffered_sys_wr;
end

always @(posedge clk or posedge reset)
begin
	if( reset == 1)
		buffered_sys_rd <= 0;
	else if( sys_ack == 1) 
		buffered_sys_rd <= 0;
	else if( sys_rd == 1)
		buffered_sys_rd <= sys_rd;
	else 
		buffered_sys_rd <= buffered_sys_rd;
end

//state transitions
always @ (hit or sys_rd or sys_wr or ram_ack or age_mod or state)
begin : TRANSITION_LOGIC
  next_state = 0;
  case(state)
    IDLE : if (buffered_sys_wr && hit) begin
						next_state = DATA_WR;
               end else if (buffered_sys_rd && hit) begin
						next_state= DATA_RD;
               end else if (age_mod && ~hit && (buffered_sys_wr || buffered_sys_rd) ) begin
						next_state = RAM_WR;
               end else if (~age_mod && ~hit && (buffered_sys_wr || buffered_sys_rd) ) begin
						next_state = RAM_RD;
					end else begin
						next_state = state;
					end 
    DATA_RD : next_state = AUX_TICK;
    DATA_WR : next_state = DATA_RD;
	 
	 RAM_WR : next_state = RAM_COMMIT_WR;
	 RAM_COMMIT_WR: if( ram_ack ) 
							next_state = RAM_RD;
						 else 
							next_state = state;
	 
	 RAM_RD  : next_state = RAM_COMMIT_RD;
	 RAM_COMMIT_RD: if(ram_ack)
							next_state = RAM_RAW_WR;
						 else 
							next_state = state;
	 RAM_RAW_WR: if(buffered_sys_wr == 1'b1) begin
						next_state = DATA_WR;
					end else if(buffered_sys_rd == 1'b1) begin
						next_state = DATA_RD;
					end
	 AUX_TICK: next_state = IDLE;
    default : next_state = state;
   endcase
end 

//state logic
always @(posedge clk or posedge reset)
begin: STATE_TRANSITIONS
	if(reset == 1'b1)
	begin
		state <= IDLE;
	end else begin
		state <= next_state;
	end
end

//output logic
always @(*)
begin:OUTPUT_LOGIC
		case(state)
			IDLE: begin
				/*mod <= 0;
				age <= 0;
				sys_ack <= 0;
				chan_sel <= 0;*/
				tag_wr <= 0;
				mod <= 0;
				age <= 0;
				chan_sel <= 0;
				data_sel <= 0;
				cache_wr <= 0;
				ram_rnw <= 0;
				ram_aval <= 0;
				sys_ack <= 0;
				tag_sel = 1;
				tx_fifo_ctrl = 0;
			end
			
			DATA_WR: begin
				//buffered_sys_rd = sys_rd;
				//buffered_sys_wr = sys_wr;
				data_sel <= 0;
				chan_sel <= 0;
				mod <= 1;
				cache_wr <= 1;
				sys_ack <= 0;
			end
			
			DATA_RD: begin
				//buffered_sys_rd = sys_rd;
				//buffered_sys_wr = sys_wr;
				
				data_sel <= 0;
				chan_sel <= 0;
				mod <= 0;
				age <= 1;
				cache_wr <= 0;
				tag_wr <= 0;
				sys_ack <= 1;
				tx_fifo_ctrl = 1;
			end
			
			RAM_WR: begin
				//buffered_sys_rd = sys_rd;
				//buffered_sys_wr = sys_wr;
				ram_rnw <= 0;
				ram_aval <= 0;
				chan_sel <= 1;
				data_sel <= 1;
				sys_ack <= 0;
			end
			
			RAM_COMMIT_WR: begin
				ram_aval <= 1;	
			end
			
			RAM_RD: begin
				//buffered_sys_rd = sys_rd;
				//buffered_sys_wr = sys_wr;
				ram_rnw <= 1;
				ram_aval <= 0;
				chan_sel <= 1;
				sys_ack <= 0;
				tag_sel = 0;
			end
			
			RAM_COMMIT_RD: begin
				ram_aval <= 1;
			end
			
			RAM_RAW_WR: begin
				tag_sel = 1;
				ram_aval <= 0;
				ram_rnw <= 0;
				
				tag_wr <= 1;
				cache_wr <= 1;
				data_sel <= 1;
			end
			
			AUX_TICK: begin
				sys_ack <= 0;
				//buffered_sys_rd = 0;
				//buffered_sys_wr = 0;
			end
			
			default: begin
				tag_wr <= 0;
				mod <= 0;
				age <= 0;
				chan_sel <= 0;
				data_sel <= 0;
				cache_wr <= 0;
				ram_rnw <= 0;
				ram_aval <= 0;
				sys_ack <= 0;
				tx_fifo_ctrl = 0;
			end

		endcase
	//end	
end

endmodule
