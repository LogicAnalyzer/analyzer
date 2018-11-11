`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/21/2018 12:07:39 PM
// Design Name: 
// Module Name: sampler
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

module sampler #(parameter SAMPLE_WIDTH = 8)(
    input clock,
    input load_counter,                         
    input [SAMPLE_WIDTH-1:0] dataIn,
    input [23:0] divider,
    output reg [SAMPLE_WIDTH-1:0] dataOut,
    output reg validOut
    );
    
    reg [23:0] counter;
    
always@ (posedge load_counter) begin
    counter <= divider;
end
always@(posedge clock) begin
        if (counter == 0) begin
            validOut <= 1'b1;
            counter <= divider;
        end else begin
            validOut <= 1'b0;
            counter <= counter - 1;
        end
       dataOut <= dataIn;
       end
endmodule
