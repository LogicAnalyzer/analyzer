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
    input  logic clock, reset, byte_in_ready,
    input  logic [7:0] byte_in,
    output logic cmd_recieved,
    output logic [7:0] opcode,
    output logic [31:0] command
    );
    
typedef enum {IDLE, IDLE_f, BYTE0, BYTE0_f, BYTE1, BYTE1_f, 
    BYTE2, BYTE2_f, BYTE3, BYTE3_f, RECIEVED_f, RECIEVED} decoder_states;

decoder_states CS, NS; 
logic [7:0] current_opcode;
logic [31:0] current_command;   
    
always_ff @(posedge clock or posedge reset) begin : proc_
        CS <= (reset) ? IDLE : NS;
    end
    
always_comb begin
    case (CS)
        IDLE: begin            
            if(byte_in_ready) begin
               current_opcode = byte_in;
               NS = IDLE_f;
            end else begin
               NS = IDLE;
            end
            cmd_recieved = 1'b0;
        end
        IDLE_f: begin
            if (~byte_in_ready) begin
                NS = BYTE0;
            end else begin
                NS = IDLE_f;
                end
        end
        BYTE0: begin
            if(byte_in_ready) begin
                current_command[31:24] = byte_in;
                NS = BYTE0_f; 
             end else begin
                NS = BYTE0;
            end
        end
        BYTE0_f: begin
            if (~byte_in_ready) begin
                NS = BYTE1;
            end else begin
                NS = BYTE0_f;
                end
        end
        BYTE1: begin
            if(byte_in_ready) begin
                current_command[23:16] = byte_in;
                NS = BYTE1_f; 
            end else begin
                NS = BYTE1;
            end
        end
        BYTE1_f: begin
            if (~byte_in_ready) begin
                NS = BYTE2;
            end else begin
                NS = BYTE1_f;
                end
        end
        BYTE2: begin
           if(byte_in_ready) begin
                 current_command[15:8] = byte_in;
                 NS = BYTE2_f; 
            end else begin
                 NS = BYTE2;
            end     
        end
        BYTE2_f: begin
            if (~byte_in_ready) begin
                NS = BYTE3;
            end else begin
                NS = BYTE2_f;
                end
        end
        BYTE3: begin
           if(byte_in_ready) begin
              current_command[7:0] = byte_in;
              NS = BYTE3_f; 
         end else begin
              NS = BYTE3;
         end     
        end
        BYTE3_f: begin
            if (~byte_in_ready) begin
                NS = RECIEVED;
            end else begin
                NS = BYTE3_f;
                end
        end
        RECIEVED: begin
            cmd_recieved = 1'b1;
            opcode = current_opcode;
            command = current_command;
            NS = IDLE;
        end
        default: begin
            NS = IDLE;
        end
    endcase
end     
endmodule