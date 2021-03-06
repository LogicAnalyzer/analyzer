`timescale 1ns / 1ps

module UART_com #(parameter INPUT_CLK_KHZ = 100_000, BAUD_RATE =9600)(
		input logic			input_clk, reset_n, trans_en, Rx,
		input logic [7:0] 	data_out,
		output logic		Tx, tx_busy,
		output logic [7:0]	data_received,
		output logic         data_rdy
		
    );

    localparam real BAUD_RATE_KHZ = BAUD_RATE / 1000.0;
    localparam integer BAUD_COUNT = (INPUT_CLK_KHZ / (BAUD_RATE_KHZ) - 1);

    uart_rx #(.CLKS_PER_BIT(BAUD_COUNT))
    UART_receiver_i
    (
       .reset_n(reset_n),
       .i_Clock(input_clk),
       .i_Rx_Serial( Rx),
       .o_Rx_DV(data_rdy),
       .o_Rx_Byte(data_received)
    );

    uart_tx #(.CLKS_PER_BIT(BAUD_COUNT))
    UART_transmitter_i
    (
        .reset_n(reset_n),
        .i_Clock(input_clk),
        .i_Tx_DV(trans_en),
        .i_Tx_Byte(data_out), 
        .o_Tx_Active(tx_busy),
        .o_Tx_Serial(Tx),
        .o_Tx_Done()
    );
endmodule
