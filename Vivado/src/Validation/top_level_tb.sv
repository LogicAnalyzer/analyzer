`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/02/2018 07:23:07 PM
// Design Name: 
// Module Name: top_level_tb
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


module top_level_tb();

logic baud_clock, input_clk, reset, Rx, Tx, ext_reset;
logic [7:0] sample_data;

localparam real BAUD_RATE = 9600;
localparam real BAUD_RATE_KHZ = BAUD_RATE / 1000;
localparam real BAUD_HALF_PERIOD_NS = ( 10**6 )/( BAUD_RATE_KHZ * 2 ) ;

localparam real INPUT_CLK_KHZ = 100_000;
localparam real INPUT_CLK_HALF_PERIOD_NS = ( 10**6 )/( INPUT_CLK_KHZ * 2 );

initial forever begin
    #INPUT_CLK_HALF_PERIOD_NS input_clk <= ~input_clk;
end

initial forever begin
    #BAUD_HALF_PERIOD_NS baud_clock <= ~baud_clock;
end

function void initialize ();
    input_clk = 0;
    baud_clock =0;
    reset = 0;
    Rx = 1;
endfunction : initialize
    
task send_data(input [7:0] data);

    integer index;
    index = 0;

    $display($time, "  Sending data: %b",data);
    Rx = 0;
    while(index < 8)begin
        @(posedge baud_clock)
        Rx = data [index];
        index = index + 1;
    end 
    @(posedge baud_clock)
    Rx = 1;
    @(posedge baud_clock);
    
endtask : send_data

task arm();
    send_data(8'H00);
    send_data(8'H00);
    send_data(8'H00);
    send_data(8'H00);
    send_data(8'H00);
endtask: arm

task send_reset();
    send_data(8'H00);
    send_data(8'H00);
    send_data(8'H00);
    send_data(8'H00);
    send_data(8'H00);
endtask : send_reset

task set_sample_rate(input [23:0] sample_rate);
    send_data(8'H80);
    send_data(8'H00);
    send_data(sample_rate[23:16]);
    send_data(sample_rate[15:8]);
    send_data(sample_rate[7:0]);
endtask : set_sample_rate

task set_read_delay(input [15:0,);

endtask : set_read_delay

task set_trigger();

endtask : set_trigger




ACSP_top DUT(
    .system_clock(input_clk), 
    .ext_reset(ext_reset),
    .dataToSample(sample_data),
    .rx(Rx),
    .tx(Tx)
    );

initial begin
initialize();
ext_reset = 1;
#5;
ext_reset = 0;
#5
ext_reset = 1;
#5;
ext_reset = 0;
#5
send_data(8'h04);
#10;
send_data(8'h00);
#10;
send_data(8'h00);
#10;
send_data(8'h00);
#10;
send_data(8'h00);
#10;
send_data(8'h00);
#10;

end //initial begin
            
endmodule
