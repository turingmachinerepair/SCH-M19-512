`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   02:04:35 04/09/2020
// Design Name:   UnitaryEncoder
// Module Name:   C:/Users/Admin/Documents/CacheDesign/CacheDesign/UnitaryEncoder_tb.v
// Project Name:  CacheDesign
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: UnitaryEncoder
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module UnitaryEncoder_tb;

	// Inputs
	reg [2:0] addr;

	// Outputs
	wire [7:0] selector;

	// Instantiate the Unit Under Test (UUT)
	UnitaryEncoder uut (
		.addr(addr), 
		.selector(selector)
	);
	integer i=0;
	initial begin
		// Initialize Inputs
		addr = 0;

		// Wait 100 ns for global reset to finish
		#100;
       for( i = 0; i<8;i=i+1)
		 begin
			addr<=i;
			#100;
		 end
		// Add stimulus here

	end
      
endmodule

