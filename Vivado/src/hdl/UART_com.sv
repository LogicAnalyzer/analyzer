`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/09/2018 06:18:47 PM
// Design Name: 
// Module Name: UART_com
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


module UART_com(
		input 			input_clk, reset, trans_en, Rx,
		input [7:0] 	data_out,
		output 			Tx, tx_busy,
		output [7:0]	data_received,
		output reg         data_rdy
    );
    
    wire data_rdy_pre;
    always@(posedge input_clk) begin
        data_rdy <= data_rdy_pre;
    end
    
    
	UART_receiver UART_receiver_i(
     .input_clk(input_clk), .reset(reset),  .data_received(data_received), .data_rdy(data_rdy_pre), .Rx(Rx)
    );

	UART_transmitter UART_transmitter_i(
     .input_clk(input_clk), .reset(reset), .trans_en(trans_en), .data_out(data_out), .Tx(Tx), .tx_busy(tx_busy)
    );
endmodule
