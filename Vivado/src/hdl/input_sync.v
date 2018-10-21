//
// Synchronizes input with clock on rising or falling edge
//
//--------------------------------------------------------------------------------

`timescale 1ns/100ps

module input_sync #(parameter WIDTH = 8)(
    input clock, edge_capture,
    input [WIDTH-1: 0] data_in,
    output [WIDTH-1: 0] data_out
    );
    reg [WIDTH-1 : 0] data_in_neg;
    reg [WIDTH-1 : 0] data_in_pos;
    always @(posedge clock) data_in_pos <= data_in;
    always @(negedge clock) data_in_neg <= data_in;

    assign data_out = edge_capture ? data_in_pos : data_in_neg;

    initial begin
        $dumpfile("input_sync.vcd");
        $dumpvars(0, input_sync);
    end 
endmodule // input_sync