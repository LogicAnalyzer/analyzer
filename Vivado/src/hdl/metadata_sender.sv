`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2018 05:55:02 PM
// Design Name: 
// Module Name: metadata_sender
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


module metadata_sender(
    input clock,
    input reset, 
    input begin_meta_transmit, //Alerts the unit to transmit its metadata 
    input send_id, //if high, sends ID, if low, sends Query Metadata
    input tx_busy, //Signal from transmitter, high if busy transmitting
    output [7:0] transmit_byte, //Byte to transmit
    output tran_data, //Transmit byte if tx_busy is low.
    meta_transmit_finish //Sends signal back to controller when operation complete
);
    
    
endmodule