`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/09/2018 06:18:47 PM
// Design Name: 
// Module Name: UART_transmitter
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


module UART_receiver(
    input baud_clock, reset, Rx,
    output logic[7:0]data_received,
    output logic     data_rdy
    );

    typedef enum {IDLE, TRANS} uart_state;
    uart_state current_state, next_state;
    
    logic [3:0] bit_counter;
    logic [7:0] data_received_d;
    logic shift;
    
    
    /*Block Output Until Ready*/
    always @(*)begin
        data_received <= data_rdy? data_received_d : 8'b0 ;
    end

    /*Control Data Path*/
    always_ff@( posedge baud_clock or negedge reset) begin
        if(~reset) begin
            bit_counter <= 0;
            data_received_d <= 0;
        end else begin
            if (shift)begin
                bit_counter <= bit_counter + 1;
                data_received_d[bit_counter] <= Rx;
            end else begin 
                bit_counter <= 0;
                data_received_d <= data_received_d;
            end
        end
    end

    /*Control State Logic*/
    always_ff @(posedge baud_clock or negedge reset) begin
        if(~reset) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end
    
    /*Combinational Logic*/
    always_comb begin
        case (current_state)
            IDLE: begin
                if(reset & !Rx)begin
                    shift = 1'b0;
                    data_rdy =1'b0;
                    next_state = TRANS;
                end else begin
                    shift = 1'b0;
                    data_rdy =1'b0;
                    next_state = IDLE;
                end
            end
            TRANS: begin
                if(bit_counter < 4'd8)begin
                    data_rdy =1'b0;
                    next_state = TRANS;
                    shift = 1'b1;
                end else begin
                    next_state = IDLE;
                    shift = 1'b0;
                    data_rdy =1'b1;
                end
            end
            default: begin
                shift = 1'b0;
                data_rdy =1'b0;
                next_state = IDLE;
            end
        endcase
    end
    
endmodule
