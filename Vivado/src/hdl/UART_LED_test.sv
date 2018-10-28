`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/27/2018 10:48:12 AM
// Design Name: 
// Module Name: UART_LED_test
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


module UART_LED_test(
    input rx, clock, reset,
    output reg tx,
    output reg [3:0] LED, 
    output reg [3:0] OPCODELED,
    output reg LEDRX, LEDTX
);

wire tran_uart, data_rdy, checkcode;
wire [7:0] tran_data, recv_data;
wire [7:0] opcode;
wire [31:0] command;

   UART_com uart(
     .input_clk(clock),
     .reset(reset),
     .trans_en(tran_uart),
     .Rx(rx),
     .Tx(tx),
     .data_out(tran_data),
     .data_rdy(data_rdy),
     .data_received(recv_data)   
    );
   
   command_decoder cmd_decode(
       .clock(clock),
       .reset(reset),
       .byte_in(recv_data),
       .byte_in_ready(data_rdy),
       .cmd_recieved(checkcode),
       .opcode(opcode),
       .command(command)
   );
   
    always@(posedge clock) begin
        if (reset) begin
            LED[3] <= 0;
            LEDRX <= 0;
            LEDTX <= 0;
        end
        if (~tx) begin
           LEDTX <= 1; 
        end
        if (~rx) begin
           LEDRX <= 1; 
        end
        if (checkcode) begin
            LED[3] <= 1;
            if (opcode == 8'b0000_1000) begin
                LED[2:0] <= command[2:0];
            end else if (opcode == 8'b0000_0000) begin
                LED[2:0] <= 3'b111;
                end
        end
        OPCODELED <= cmd_decode.CS;
    end
    
endmodule
