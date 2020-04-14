`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   22:10:57 04/13/2020
// Design Name:   TagMemory
// Module Name:   C:/Users/Admin/Documents/CacheDesign/CacheDesign/TagMemory_Tb.v
// Project Name:  CacheDesign
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: TagMemory
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module TagMemory_Tb;

	// Inputs
	reg [7:0] tag_in;
	reg [3:0] index;
	reg wr;
	reg mod_in;
	reg age;
	reg clk;

	// Outputs
	wire [2:0] chan;
	wire [2:0] age_chan;
	wire [7:0] age_tag;
	wire age_mod;
	wire hit;

	// Instantiate the Unit Under Test (UUT)
	TagMemory uut (
		.tag_in(tag_in), 
		.index(index), 
		.wr(wr), 
		.mod_in(mod_in), 
		.age(age), 
		.clk(clk), 
		.chan(chan), 
		.age_chan(age_chan), 
		.age_tag(age_tag), 
		.age_mod(age_mod), 
		.hit(hit)
	);

	integer i;
	initial begin
		// Initialize Inputs
		tag_in = 0;
		index = 0;
		wr = 0;
		mod_in = 0;
		age = 0;
		clk = 0;
		

		// Wait 100 ns for global reset to finish
		#100;
		
		index = 4'hF;
		
      wr = 1;
		//fillup initial testing
		$display("Fillup initial test");
		for(i=0; i<8; i=i+1)
		begin
			tag_in = (i+1);
			
			wr=1;
			#50
			clk = 1;
			wr=0;
			#50
			clk = 0;
			
			age=1;
			#50
			clk = 1;
			age=0;
			#50
			clk = 0;
		end
		
		#200
		
		$display("Random read test");
		for(i=4; i<7; i=i+1)
		begin
			tag_in = (i+1);
			
			age=1;
			#50
			clk = 1;
			age=0;
			#50
			clk = 0;
		end
		
		#200
			
		$display("Random write test");
		for(i=4; i<7; i=i+1)
		begin
			tag_in = (i+1);
			
			mod_in=1;
			#50
			clk = 1;
			mod_in=0;
			#50
			clk = 0;
			
			age=1;
			#50
			clk = 1;
			age=0;
			#50
			clk = 0;
		end
		
		  
		// Add stimulus here

	end
      
endmodule

