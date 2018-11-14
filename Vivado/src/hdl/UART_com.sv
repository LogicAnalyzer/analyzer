`timescale 1ns / 1ps

module UART_com #(parameter INPUT_CLK_KHZ = 100_000, BAUD_RATE =9600)(
		input logic			input_clk, reset_n, trans_en, Rx,
		input logic [7:0] 	data_out,
		output logic		Tx, tx_busy,
		output logic [7:0]	data_received,
		output logic         data_rdy
		
    );

    localparam real BAUD_RATE_KHZ = BAUD_RATE / 1000.0;
    localparam integer BAUD_COUNT = (INPUT_CLK_KHZ / (BAUD_RATE_KHZ * 2) - 1);

    logic [12:0] baud_counter;
    logic baud_clock, trans_busy, trans_latch;
    logic [7:0]	data_out_f;

    // assign tx_busy = trans_latch | trans_busy;

    // /*Create Baud Clock*/
    // always_ff@( posedge input_clk or negedge reset_n)begin
    //     if(!reset_n)begin
    //         baud_counter<= 14'b0;
    //         baud_clock <= 1'b0;
    //     end else begin
    //         if (baud_counter == BAUD_COUNT) begin
    //             baud_clock <= ~baud_clock;
    //             baud_counter <= 14'b0;
    //         end else begin
    //             baud_counter <= baud_counter + 14'b1;
    //         end
    //     end
    // end
    
    // initial begin trans_latch <=0; end
    // always@(posedge trans_en or posedge trans_busy)begin
    // 	if (trans_busy) trans_latch <=0;
    // 	else if (trans_en) trans_latch <=1;
    // end

    // always_ff @(posedge trans_latch or negedge reset_n) begin : proc_data_out_f
    // 	if(!reset_n) begin
    // 		data_out_f <= 0;
    // 	end else begin
    // 		data_out_f <= data_out;
    // 	end
    // end

    uart_rx #(.CLKS_PER_BIT(BAUD_COUNT))
    UART_receiver_i
    (
       .i_Clock(input_clk),
       .i_Rx_Serial( Rx),
       .o_Rx_DV(data_rdy),
       .o_Rx_Byte(data_received)
    );

    uart_tx #(.CLKS_PER_BIT(BAUD_COUNT))
    UART_transmitter_i
    (
        .i_Clock(input_clk),
        .i_Tx_DV(trans_en),
        .i_Tx_Byte(data_out), 
        .o_Tx_Active(tx_busy),
        .o_Tx_Serial(Tx),
        .o_Tx_Done()
    );
endmodule
