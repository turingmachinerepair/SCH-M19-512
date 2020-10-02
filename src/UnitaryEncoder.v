`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: TMR
// Engineer: MC_Red_Trebuxa
// 
// Create Date:    01:59:39 04/09/2020 
// Design Name: 
// Module Name:    UnitaryEncoder 
// Project Name: TurboCache
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
module UnitaryEncoder #(
	parameter INPUT_WIDTH = 3,
	localparam OUTPUT_WIDTH = 2**INPUT_WIDTH
) (
	input wire [INPUT_WIDTH-1:0]addr,
	output reg [OUTPUT_WIDTH-1:0]selector
);

always @*
  selector = {{(OUTPUT_WIDTH-1){1'b0}},1'b1} << addr;

endmodule
