`timescale 1ns / 1ps

module UART_transmitter(
    input baud_clock, reset_n, trans_en,
    input [7:0]     data_out,
    output logic          Tx, tx_busy
    );
    typedef enum {IDLE, TRANS} uart_state;
    uart_state current_state, next_state;
    
    logic [3:0] bit_counter;
    logic [9:0] data_packet;
    
    logic shift, load, clear;
    
    always_ff@( posedge baud_clock or negedge reset_n) begin
        if(!reset_n) begin
            current_state <= IDLE;
            data_packet <= 10'b0;
            bit_counter <= 0;
        end else begin
            current_state <= next_state;
            if (shift)begin
                data_packet <= data_packet >> 1;
                bit_counter <= bit_counter - 1;
            end else begin
                bit_counter <= 4'd10;
                data_packet <= {1'b1,data_out,1'b0};
            end
        end
    end
    
    always_comb begin
        case (current_state)
            IDLE: begin
                if(reset_n & trans_en)begin
                    next_state = TRANS;
                    shift = 1'b0;
                    Tx = 1'b1;
                    tx_busy = 1'b0;
                end else begin
                    next_state = IDLE;
                    shift = 1'b0;
                    Tx = 1'b1;
                    tx_busy = 1'b0;
                end
            end
            TRANS: begin
                if(bit_counter > 4'b0)begin
                    shift = 1'b1;
                    Tx = data_packet[0];
                    next_state = TRANS;
                    tx_busy = 1'b1;
                end else begin
                    next_state = IDLE;
                    shift = 1'b0;
                    Tx = 1'b1;
                    tx_busy = 1'b1;
                end
            end
            default: begin
                next_state = IDLE;
                Tx = 1'b1;
                shift = 1'b0;
                tx_busy = 1'b1;
            end
        endcase
    end
    
endmodule
