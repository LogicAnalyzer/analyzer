`timescale 1ns / 1ps

module trigger_basic #(parameter SAMPLE_WIDTH = 8) (
    input clock,
    input reset_n,    
    input valid,
    input arm,
    input load_trigs,                      
    input [SAMPLE_WIDTH-1:0] dataIn,
    input [SAMPLE_WIDTH-1:0] trigRising,
    input [SAMPLE_WIDTH-1:0] trigFalling,
    output reg run    
    );

reg [SAMPLE_WIDTH-1:0] trigRisingReg;
reg [SAMPLE_WIDTH-1:0] trigFallingReg;
reg done;
wire x;
wire [SAMPLE_WIDTH-1:0] single_out;
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

    always@(posedge clock or negedge reset_n)begin
        if (!reset_n) begin
            trigRisingReg <= 0;
            trigFallingReg <= 0;
        end else if (load_trigs) begin
            trigRisingReg <= trigRising;
            trigFallingReg <= trigFalling;
        end else begin
            trigRisingReg <= trigRising;
            trigFallingReg <= trigFalling;
        end
    end
    
    always@(posedge clock) begin
        if (arm)begin
            done <= 0;
            run <=0;
        end
        else if (&single_out[SAMPLE_WIDTH-1:0]) begin
            run <= 1;
            done <= 1;
        end
        else if (done) begin
            run <= 0;
            done <= done;
        end
        else begin
            run <= run;
            done <= done;
        end
    end
    
    
endmodule

/////////////////////////////////////////////////////////////////////////////////
// Module: single_trigger
// Description: Created by the basic trigger, one for each sampling channel.
/////////////////////////////////////////////////////////////////////////////////

module single_trigger(
    input clock,
    input valid,
    input trig_sel_rise,
    input trig_sel_fall,
    input sample,
    input arm,
    output reg q    
);

    reg q_sample;

    always@(posedge clock)
    begin
    if (valid) q_sample <= sample;
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
