`timescale 1ns / 1ps

module command_decoder(
    input clock, reset_n, byte_in_ready,
    input [7:0] byte_in,
    output reg cmd_recieved,
    output reg [7:0] opcode,
    output reg [31:0] command
    );
    
    
parameter IDLE =    4'b0000;
parameter IDLE_f =  4'b1000;
parameter BYTE0 =   4'b0001;
parameter BYTE0_f = 4'b1001;
parameter BYTE1 =   4'b0010;
parameter BYTE1_f = 4'b1010;
parameter BYTE2 =   4'b0011;
parameter BYTE2_f = 4'b1011;
parameter BYTE3 =   4'b0100;
parameter BYTE3_f=  4'b1100;
parameter RECIEVED_f = 4'b1101;    
parameter RECIEVED =    4'b0101;

reg [3:0] CS, NS;    
    
always@(posedge clock or negedge reset_n) begin
        if(!reset_n) begin
            CS <= IDLE;          
        end else begin
            CS <= NS;
        end
    end
    
always@(posedge clock) begin
    case (CS)
        IDLE: begin             
            if(byte_in_ready) begin
               opcode <= byte_in;
               NS <= IDLE_f;
            end else begin
               NS <= IDLE;
            end
            cmd_recieved <= 1'b0;
        end
        IDLE_f: begin
            if (~byte_in_ready) begin
                NS <= BYTE0;
            end else begin
                NS <= IDLE_f;
                end
        end
        BYTE0: begin
            if(byte_in_ready) begin
                command[31:24] <= byte_in;
                NS <= BYTE0_f; 
             end else begin
                NS <= BYTE0;
            end
        end
        BYTE0_f: begin
            if (~byte_in_ready) begin
                NS <= BYTE1;
            end else begin
                NS <= BYTE0_f;
                end
        end
        BYTE1: begin
            if(byte_in_ready) begin
                command[23:16] <= byte_in;
                NS <= BYTE1_f; 
            end else begin
                NS <= BYTE1;
            end
        end
        BYTE1_f: begin
            if (~byte_in_ready) begin
                NS <= BYTE2;
            end else begin
                NS <= BYTE1_f;
                end
        end
        BYTE2: begin
           if(byte_in_ready) begin
                 command[15:8] <= byte_in;
                 NS <= BYTE2_f; 
            end else begin
                 NS <= BYTE2;
            end     
        end
        BYTE2_f: begin
            if (~byte_in_ready) begin
                NS <= BYTE3;
            end else begin
                NS <= BYTE2_f;
                end
        end
        BYTE3: begin
           if(byte_in_ready) begin
              command[7:0] <= byte_in;
              NS <= BYTE3_f; 
         end else begin
              NS <= BYTE3;
         end     
        end
        BYTE3_f: begin
            if (~byte_in_ready) begin
                NS <= RECIEVED;
            end else begin
                NS <= BYTE3_f;
                end
        end
        RECIEVED: begin
            cmd_recieved <= 1'b1;
            NS <= IDLE;
        end
        default: begin
            NS <= IDLE;
        end
    endcase
end     
endmodule