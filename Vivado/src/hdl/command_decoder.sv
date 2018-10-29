`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/27/2018 11:48:36 AM
// Design Name: 
// Module Name: command_decoder
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


module command_decoder(
    input clock, reset, byte_in_ready,
    input [7:0] byte_in,
    output reg cmd_recieved,
    output reg [7:0] opcode,
    output reg [31:0] command
    );
        
    parameter IDLE = 3'b000;
    parameter BYTE0 = 3'b001;
    parameter BYTE1 = 3'b010;
    parameter BYTE2 = 3'b011;
    parameter BYTE3 = 3'b100;
    parameter RECIEVED = 3'b101;
    parameter RECIEVED2 = 3'b111;

    reg [2:0] CS, NS;    
   
always@(posedge clock or posedge reset) begin
        if(reset) begin
            CS <= IDLE;          
        end else begin
            CS <= NS;
        end
    end
    
always@(CS, byte_in_ready) begin
    case (CS)
        IDLE: begin             
            if(byte_in_ready) begin
               opcode <= byte_in;
               NS <= BYTE0;
            end else begin
               NS <= IDLE;
            end
            cmd_recieved <= 1'b0;
        end
        BYTE0: begin
            if(byte_in_ready) begin
                command[31:24] <= byte_in;
                NS <= BYTE1; 
             end else begin
                NS <= BYTE0;
            end
        end
        BYTE1: begin
            if(byte_in_ready) begin
                command[23:16] <= byte_in;
                NS <= BYTE2; 
            end else begin
                NS <= BYTE1;
            end
        end
        BYTE2: begin
           if(byte_in_ready) begin
                 command[15:8] <= byte_in;
                 NS <= BYTE3; 
            end else begin
                 NS <= BYTE2;
            end     
        end
        BYTE3: begin
           if(byte_in_ready) begin
              command[7:0] <= byte_in;
              NS <= RECIEVED; 
         end else begin
              NS <= BYTE3;
         end     
        end
        RECIEVED: begin
            cmd_recieved <= 1'b1;
            NS <= RECIEVED2;
        end
        RECIEVED2: begin
            cmd_recieved <= 1'b1;
            NS <= IDLE;
        end
        default: begin
            NS <= IDLE;
        end
    endcase
end     
endmodule