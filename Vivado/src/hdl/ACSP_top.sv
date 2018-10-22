`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/21/2018 12:07:39 PM
// Design Name: 
// Module Name: ASCP_top
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
parameter SAMPLE_WIDTH = 8;

module ACSP_top(
    input system_clock,
    input [SAMPLE_WIDTH-1:0] dataToSample,
    input [SAMPLE_WIDTH-1:0] fallPattern,
    input [SAMPLE_WIDTH-1:0] risePattern,
    input [23:0] divider,
    input edge_capture,
    input arm,
    output run,
    output [SAMPLE_WIDTH-1:0] dataSamplerToFIFO,
    output dataValidToFIFO    
    );
    
    wire [SAMPLE_WIDTH-1:0] dataSyncToSampler;
   
    input_sync #(SAMPLE_WIDTH) sync_module(
        .clock(system_clock),
        .edge_capture(edge_capture),
        .data_in(dataToSample),
        .data_out(dataSyncToSampler)     
    );
    sampler #(SAMPLE_WIDTH) sampler_module(
        .clock(system_clock),
        .reset(arm),
        .dataIn(dataSyncToSampler),
        .divider(divider),
        .dataOut(dataSamplerToFIFO),
        .validOut(dataValidToFIFO)
    );
    trigger_basic #(SAMPLE_WIDTH) trigger(
        .clock(system_clock),
        .valid(dataValidToFIFO),
        .arm(arm),
        .dataIn(dataSamplerToFIFO),
        .trigRising(risePattern),
        .trigFalling(fallPattern),
        .run(run)
   );
endmodule
