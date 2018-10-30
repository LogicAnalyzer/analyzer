`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2018 06:12:30 PM
// Design Name: 
// Module Name: utils
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mux_8(
    input sel,
    input [7:0] A, B,    
    output [7:0] C
    );
    assign C = (sel) ? A : B;    
endmodule
