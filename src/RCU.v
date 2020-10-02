`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:12:38 05/24/2020 
// Design Name: 
// Module Name:    RCU 
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
module RCU(
	clk,
	rst,
	cache_avalid,
	cache_rnw,
	cache_ack,
	ram_ack,
	
	reg_lshift,
	reg_rshift,
	reg_str_load,
	reg_word_load,
	
	tx_fifo_wr,
	rx_fifo_empty,
	rx_fifo_read,
	rx_fifo_full,
	buffered_ram_rnw,
	buffered_ram_aval,
	last_bit
		
);

input	clk;
input	rst;
input	cache_avalid;
input	cache_rnw;
input	ram_ack;
input	rx_fifo_empty;
input rx_fifo_full;
input last_bit;
	
output reg	cache_ack;
output reg	reg_lshift;
output reg	reg_rshift;
output reg	reg_str_load;
output reg	reg_word_load;
output reg 	buffered_ram_rnw,
	buffered_ram_aval;
	
output reg	tx_fifo_wr;
output reg	rx_fifo_read;

localparam 	IDLE  = 0,
				ADDR2FIFO = 1,
				ADDR2FIFO2 = 2,
				WAIT_ACK = 3,
				
				FIFO2REG1 = 4,
				FIFO2REG2 = 5,
				FIFO2REG3 =6,
				FIFO2REG4 = 7,
				FIFO2REG5 = 8,
				FIFO2REG6 = 9,
				FIFO2REG7 = 10,
				FIFO2REG8 = 11,
				FIFO2REG9 = 12,
				FIFO2REG10 = 13,
				FIFO2REG11 =14,
				FIFO2REG12 = 15,
				FIFO2REG13 = 16,
				FIFO2REG14 = 17,
				FIFO2REG15 = 18,
				FIFO2REG16 = 19,
				FIFO2REG17 =20,
				
				STR_LOAD = 21,
				REG2FIFO1= 22,
				REG2FIFO2= 23,
				REG2FIFO3=24,
				REG2FIFO4=25,
				REG2FIFO5=26,
				REG2FIFO6=27,
				REG2FIFO7=28,
				REG2FIFO8=29,
				REG2FIFO9=30,
				REG2FIFO10=31,
				REG2FIFO11=32,
				REG2FIFO12=33,
				REG2FIFO13=34,
				REG2FIFO14=35,
				REG2FIFO15=36,
				REG2FIFO16=37,
				
				CACHE_ACK = 38,
				WR_CACHE_ACK = 39;

localparam STATE_WIDTH = 6;

reg   [STATE_WIDTH-1:0]          state        ;// Seq part of the FSM
reg  [STATE_WIDTH-1:0]          next_state   ;// combo part of FSM


//state transitions
always @ (cache_avalid or cache_rnw or ram_ack or state or rx_fifo_empty or rx_fifo_full or last_bit)
begin : TRANSITION_LOGIC
	next_state = 0;
	case(state)
		IDLE : if( cache_avalid && cache_rnw) begin
					next_state = ADDR2FIFO;
				end else if ( cache_avalid  && ~cache_rnw) begin
					next_state = STR_LOAD;
				end else
					next_state = state;
					
		CACHE_ACK:	//if( ram_ack ) begin
							next_state = IDLE;
						//end else
							//next_state = state;
		
		//write subgraph
		STR_LOAD:begin
				next_state = REG2FIFO1;
		end
		REG2FIFO1: next_state = REG2FIFO2;
		REG2FIFO2: next_state = REG2FIFO3;
		REG2FIFO3: next_state = REG2FIFO4;
		REG2FIFO4: next_state = REG2FIFO5;
		REG2FIFO5: next_state = REG2FIFO6;
		REG2FIFO6: next_state = REG2FIFO7;
		REG2FIFO7: next_state = REG2FIFO8;
		REG2FIFO8: next_state = REG2FIFO9;
		REG2FIFO9: next_state = REG2FIFO10;
		REG2FIFO10: next_state = REG2FIFO11;
		REG2FIFO11: next_state = REG2FIFO12;
		REG2FIFO12: next_state = REG2FIFO13;
		REG2FIFO13: next_state = REG2FIFO14;
		REG2FIFO14: next_state = REG2FIFO15;
		REG2FIFO15: next_state = REG2FIFO16;
		REG2FIFO16: next_state = WR_CACHE_ACK;
		
		WR_CACHE_ACK: if( ram_ack && ~rx_fifo_empty )
						next_state = CACHE_ACK;
					else
						next_state = state;
						
		//read subgraph
		ADDR2FIFO: next_state = ADDR2FIFO2;
		ADDR2FIFO2: next_state = WAIT_ACK;
		
		WAIT_ACK: if( rx_fifo_full )
						next_state = FIFO2REG1;
					else
						next_state = state;
						
		FIFO2REG1: next_state = FIFO2REG2;
		FIFO2REG2: next_state = FIFO2REG3;
		FIFO2REG3: next_state = FIFO2REG4;
		FIFO2REG4: next_state = FIFO2REG5;
		FIFO2REG5: next_state = FIFO2REG6;		
		FIFO2REG6: next_state = FIFO2REG7;
		FIFO2REG7: next_state = FIFO2REG8;
		FIFO2REG8: next_state = FIFO2REG9;
		FIFO2REG9: next_state = FIFO2REG10;
		FIFO2REG10: next_state = FIFO2REG11;
		FIFO2REG11: next_state = FIFO2REG12;
		FIFO2REG12: next_state = FIFO2REG13;
		FIFO2REG13: next_state = FIFO2REG14;
		FIFO2REG14: next_state = FIFO2REG15;
		FIFO2REG15: next_state = FIFO2REG16;
		FIFO2REG16: next_state = FIFO2REG17;
		FIFO2REG17: next_state = CACHE_ACK;
		
		default : next_state = state;
   endcase
end 

//state logic
always @(posedge clk or posedge rst)
begin: STATE_TRANSITIONS
	if(rst == 1'b1)
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
				reg_lshift = 0;
				reg_rshift = 0;
				tx_fifo_wr = 0;
				rx_fifo_read = 0;
				cache_ack = 0;
				reg_word_load = 0;
				reg_str_load = 0;
				buffered_ram_rnw = 0;
				buffered_ram_aval = 0;
			end
			
			//read logic
			ADDR2FIFO: begin
				tx_fifo_wr = 1;
				buffered_ram_rnw = cache_avalid;
				buffered_ram_aval = cache_rnw;
			end
			
			ADDR2FIFO2: begin
				buffered_ram_rnw = 0;
				buffered_ram_aval = 0;
			end
			
			WAIT_ACK: begin
				
				tx_fifo_wr = 0;
				
				//reg_rshift = 1;
				//effective_reg_word_load = 1;
				
			end
				
			FIFO2REG1: begin
				tx_fifo_wr = 0;
				rx_fifo_read = 1;
				reg_word_load = 1;
				reg_rshift = 1;
			end
			
			/*FIFO2REG2: begin			end
			FIFO2REG3: begin			end
			FIFO2REG4: begin			end
			FIFO2REG5: begin			end
			FIFO2REG6: begin			end
			FIFO2REG7: begin			end
			FIFO2REG8: begin			end
			FIFO2REG9: begin			end
			FIFO2REG10: begin			end
			FIFO2REG11: begin			end
			FIFO2REG12: begin			end
			FIFO2REG13: begin			end
			FIFO2REG14: begin			end
			FIFO2REG15: begin			end*/
			
			FIFO2REG17: begin
				//reg_lshift = 0;
				reg_rshift = 0;
				//reg_word_load = 0;
				//rx_fifo_read = 0;
			end
				
			//write logic
			STR_LOAD: begin
				reg_str_load = 1;
			end
			
			REG2FIFO1: begin				
				tx_fifo_wr = 1;
				buffered_ram_rnw = cache_avalid;
				buffered_ram_aval = cache_rnw;
				reg_str_load = 0;
				reg_rshift = 1;
			end
			
			REG2FIFO2: begin	
				buffered_ram_rnw = 0;
				buffered_ram_aval = 0;		
			end
			/*REG2FIFO3: begin			end
			REG2FIFO4: begin			end
			REG2FIFO5: begin			end
			REG2FIFO6: begin			end
			REG2FIFO7: begin			end
			REG2FIFO8: begin			end			
			REG2FIFO9: begin			end
			REG2FIFO10: begin			end
			REG2FIFO11: begin			end
			REG2FIFO12: begin			end
			REG2FIFO13: begin			end
			REG2FIFO14: begin			end
			REG2FIFO15: begin			end*/
			REG2FIFO16: begin		
				//rx_fifo_read = 1;
			end
			
			WR_CACHE_ACK: begin
				tx_fifo_wr = 0;
				rx_fifo_read = 1;
			end
			
			CACHE_ACK:begin
				reg_lshift = 0;
				reg_rshift = 0;
				reg_str_load = 0;
				reg_word_load = 0;
				tx_fifo_wr = 0;
				rx_fifo_read = 0;
				cache_ack = 1;
				//effective_reg_word_load = 0;
			end
			
			default: begin

			end

		endcase
	//end	
end


endmodule
