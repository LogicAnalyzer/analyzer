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
		input logic			input_clk, reset, trans_en, Rx,
		input logic [7:0] 	data_out,
		output logic		Tx, tx_busy,
		output logic [7:0]	data_received,
		output logic         data_rdy
		
    );
    
//    logic data_rdy_pre;
//    always_ff@(posedge input_clk) begin
//        data_rdy <= data_rdy_pre;
//    end
    
    
	UART_receiver UART_receiver_i(
     .input_clk(input_clk), .reset(reset),  .data_received(data_received), .data_rdy(data_rdy), .Rx(Rx)
    );

	UART_transmitter UART_transmitter_i(
     .input_clk(input_clk), .reset(reset), .trans_en(trans_en), .data_out(data_out), .Tx(Tx), .tx_busy(tx_busy)
    );
endmodule
