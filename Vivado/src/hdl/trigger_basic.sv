`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: John Tumath
// 
// Create Date: 09/13/2018 02:53:01 PM
// Design Name: Trigger (Basic)
// Module Name: trigger_basic
// Project Name: AC1 Logic Analyzer
// Description: The trigger module looks for patterns that will begin the data 
// capture process. The trigger is setup by the controller with signals to 
// config_data and then it is armed by envoking arm. After being armed, 
// the module envokes the run signal when a signal is detected, alerting 
// the controller module to begin the capture sequence. The basic trigger 
// starts capture on any channel signal specified by the controller. 
// A more advanced trigger would have more selection options for when to trigger.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

parameter SAMPLE_WIDTH = 8;

module trigger_basic(
    input clock,    
    input arm,                      
    input [SAMPLE_WIDTH-1:0] dataIn,
    input [SAMPLE_WIDTH-1:0] trigRising,
    input [SAMPLE_WIDTH-1:0] trigFalling,
    output run    
    );
    
wire [SAMPLE_WIDTH-1:0] single_out;
genvar i;
generate
    for(i = 0; i < SAMPLE_WIDTH; i = i + 1)
        begin: generate_triggers
            single_trigger current_trigger(
                .clock(clock),
                .trig_sel_rise(trigRising[i]),
                .trig_sel_fall(trigFalling[i]),
                .sample(dataIn[i]),
                .arm(arm),
                .q(single_out[i])
            );
        end
    endgenerate
    
    assign run = &single_out[SAMPLE_WIDTH-1:0];
    
endmodule

/////////////////////////////////////////////////////////////////////////////////
// Module: single_trigger
// Description: Created by the basic trigger, one for each sampling channel.
/////////////////////////////////////////////////////////////////////////////////

module single_trigger(
    input clock,
    input trig_sel_rise,
    input trig_sel_fall,
    input sample,
    input arm,
    output reg q    
);

reg q_sample;

always@(posedge clock)
begin
q_sample <= sample;
end
    
always@(posedge clock or posedge arm) 
begin
if(arm) 
    begin
        if(trig_sel_rise | trig_sel_fall)
            q <= 0;
        else
            q <= 1;
    end
    
else if(trig_sel_rise)
    begin
        if(sample & !q_sample)
            q <= 1;
        else
            q <= 0;
    end
else if(trig_sel_fall)
    begin
        if(!sample & !q_sample)
            q <= 1;
        else
            q <= 0;
    end
else 
    q <= 1;
end
endmodule
