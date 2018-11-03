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

logic baud_clock, input_clk, reset, Rx, Tx, data_rdy, ext_reset;
logic [7:0] data_received;
integer current_data, error_count, success_count;

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
    current_data =0;
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

ACSP_top DUT(
    .system_clock(input_clk), 
    .ext_reset(ext_reset),
    .dataToSample(8'hFF),
    .rx(Rx),
    .tx(Tx)
    );

initial begin
initialize();
ext_reset = 1;
#5;
ext_reset = 0;
send_data(8'h02);
send_data(8'h00);
send_data(8'h00);
send_data(8'h00);
send_data(8'h00);

end //initial begin
            
endmodule
