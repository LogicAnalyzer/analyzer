`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2018 05:55:02 PM
// Design Name: 
// Module Name: controller
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


module controller #(parameter SAMPLE_WIDTH = 8)(
    input clock,
    input reset,
//Status Signals
    input [7:0] opcode, //opcode from command decoder
    input [31:0] command, //command from command decoder
    input cmd_recv_rx, //signal high when command decoder recieved all 5 bytes
    input run, //run signal from trigger
    input transmit_busy, //UART transmitter busy
    input meta_transmit_finish, //meta unit finished with its transmission
 
//Control Signals
    output [23:0] divider,
    output data_meta_mux,
    output arm,
    output send_id,
    output begin_meta_transmit,
    output [SAMPLE_WIDTH-1:0] risePattern,
    output [SAMPLE_WIDTH-1:0] fallPattern

);
    
    
endmodule
