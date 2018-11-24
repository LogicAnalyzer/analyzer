`timescale 1ns / 1ps

module trigger_basic #(parameter SAMPLE_WIDTH = 8) (
    input logic clock,
    input logic reset_n,    
    input logic valid,
    input logic arm,
    input logic load_trigs,                      
    input logic [SAMPLE_WIDTH-1:0] dataIn,
    input logic [SAMPLE_WIDTH-1:0] trigRising,
    input logic [SAMPLE_WIDTH-1:0] trigFalling,
    output logic run    
    );

logic [SAMPLE_WIDTH-1:0] trigRisingReg;
logic [SAMPLE_WIDTH-1:0] trigFallingReg;
logic done;
logic [SAMPLE_WIDTH-1:0] single_out;
genvar i;
generate
    for(i = 0; i < SAMPLE_WIDTH; i = i + 1)
        begin: generate_triggers
            single_trigger current_trigger(
                .clock(clock),
                .valid(valid),
                .trig_sel_rise(trigRisingReg[i]),
                .trig_sel_fall(trigFallingReg[i]),
                .sample(dataIn[i]),
                .arm(arm),
                .q(single_out[i])
            );
        end
    endgenerate
    
    always_ff@(posedge clock) begin
        if (!reset_n) begin
            trigRisingReg <= 0;
            trigFallingReg <= 0;
            run <= 0;
            done <= 1;
        end 
        else if (load_trigs) begin
            trigRisingReg <= trigRising;
            trigFallingReg <= trigFalling;
            run <= 0;
            done <= 1;
        end
        else if (arm) begin
            trigRisingReg <= trigRisingReg;
            trigFallingReg <= trigFallingReg;
            done <= 0;
            run <=0;
        end
        else if ((&single_out[SAMPLE_WIDTH-1:0]) & !done) begin
            trigRisingReg <= trigRisingReg;
            trigFallingReg <= trigFallingReg;
            run <= 1;
            done <= 1;
        end
        else begin
            trigRisingReg <= trigRisingReg;
            trigFallingReg <= trigFallingReg;
            run <= 0;
            done <= done;
        end
    end
endmodule

/////////////////////////////////////////////////////////////////////////////////
// Module: single_trigger
// Description: Created by the basic trigger, one for each sampling channel.
/////////////////////////////////////////////////////////////////////////////////

module single_trigger(
    input logic clock,
    input logic valid,
    input logic trig_sel_rise,
    input logic trig_sel_fall,
    input logic sample,
    input logic arm,
    output logic q    
);

    logic q_sample;

    always_ff@(posedge clock)
    begin
    if (valid) q_sample <= sample;
    else q_sample <= q_sample;
    end
        
    always_ff@(posedge clock) 
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
            if(valid & sample & !q_sample)
                q <= 1;
            else
                q <= 0;
        end
    else if(trig_sel_fall)
        begin
            if(valid & !sample & q_sample)
                q <= 1;
            else
                q <= 0;
        end
    else 
        q <= 1;
    end
endmodule
