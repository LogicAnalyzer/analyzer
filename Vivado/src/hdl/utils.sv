`timescale 1ns / 1ps

module mux_8(
    input sel,
    input [7:0] A, B,    
    output [7:0] C
    );
    assign C = (sel) ? A : B;    
endmodule
