`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:06:43 04/13/2020 
// Design Name: 
// Module Name:    Comparator 
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
module Comparator(
I1,
I2,
EN,
O
    );

parameter WIDTH=8;

input wire [WIDTH-1:0] I1;
input wire [WIDTH-1:0] I2;
input wire EN;
output wire O;

assign O = EN && (I1==I2) ;

endmodule
