`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   19:13:40 04/13/2020
// Design Name:   ChannelModule
// Module Name:   C:/Users/Admin/Documents/CacheDesign/CacheDesign/ChannelModule_tb.v
// Project Name:  CacheDesign
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: ChannelModule
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module ChannelModule_tb;

	// Inputs
	reg [7:0] tag;
	reg [3:0] index;
	reg mod_in;
	reg wr;
	reg age;
	reg clk;

	// Outputs
	wire [7:0] tag_out;
	wire valid;
	wire [2:0] lru;
	wire mod_out;

	// Instantiate the Unit Under Test (UUT)
	ChannelModule uut (
		.tag(tag), 
		.index(index), 
		.mod_in(mod_in), 
		.wr(wr), 
		.age(age), 
		.clk(clk), 
		.tag_out(tag_out), 
		.valid(valid), 
		.lru(lru), 
		.mod_out(mod_out)
	);

	initial begin
		// Initialize Inputs
		tag = 0;
		index = 0;
		mod_in = 0;
		wr = 0;
		age = 0;
		clk = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		//write test 
		$display("%d%:Write test.",$time);
		tag = 8'h5A;
		index = 4'hF;
		wr = 1;
		
		#50
		clk = 1;
		#50
		clk = 0;
		wr = 0;
		
		$display("%d%:Write test 2.",$time);
		tag = 8'h5D;
		index = 4'hA;
		wr = 1;
		
		#50
		clk = 1;
		#50
		clk = 0;
		wr = 0;
		
		$display("%d%:Mod test.",$time);
		tag = 8'h5A;
		index = 4'hF;
		mod_in = 1;
		
		#50
		clk = 1;
		#50
		clk = 0;		
		mod_in = 0;
		age = 0;
		wr = 0;
		
		
		$display("%d%:Age test.",$time);
		tag = 8'h5A;
		index = 4'hF;
		age = 1;
		
		#50
		clk = 1;
		#50
		clk = 0;		
		mod_in = 0;
		age = 0;
		wr = 0;
		
		

	end
      
endmodule

