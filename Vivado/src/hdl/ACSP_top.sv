`timescale 1ns / 1ps

parameter SAMPLE_WIDTH = 8;
parameter INPUT_CLK_KHZ = 100_000;
parameter BAUD_RATE = 115200;

module ACSP_top(
    input logic system_clock, ext_reset_n,
    input logic [SAMPLE_WIDTH-1:0] dataToSample,
    input logic rx,
    output logic tx,
    output logic [1:0] uart_test,
    output logic [5:0] indata,
    
    /****deletethis****/
    output logic [7:0] tst_signal,
    output logic [7:0] LEDSEL, 
    output logic [7:0] LEDOUT
    );

    assign indata[0] = uart.UART_transmitter_i.r_SM_Main[0];
    assign indata[1] = uart.UART_transmitter_i.r_SM_Main[1];
    assign indata[2] = uart.UART_transmitter_i.r_SM_Main[2];
//    assign indata[3] = uart.UART_receiver_i.r_SM_Main[0];
//    assign indata[4] = uart.UART_receiver_i.r_SM_Main[1];
//    assign indata[5] = uart.UART_receiver_i.r_SM_Main[2];
    assign uart_test[0] = uart.Tx;//5
    assign uart_test[1] = uart.Rx;//6

    logic   [SAMPLE_WIDTH-1:0] fallPattern, risePattern, dataSyncToSampler, dataSamplerToFIFO, fifoToUartData;
    logic   [23:0]  divider;
    logic   [7:0]   opcode, recv_data, transmit_meta_byte, tran_data;
    logic   [31:0]  command;
    logic           edge_capture, run, arm, dataValidToFIFO,
                    opcode_rdy, data_rdy, tran_meta_data, send_id,
                    dataSamplerReady, meta_busy, begin_meta_transmit,
                    tx_busy, tran_uart, data_meta_mux, reset_n, 
                    load_trigs, load_counter;
    logic           en, rnw, clear, hold_window, full, empty, fifoToUartReady,
                    en_cnt, clr_cnt, read_match, delay_match, wr_en, reg_sel;

    input_sync #(SAMPLE_WIDTH) sync_module(
        .clock(system_clock),
        .edge_capture(edge_capture),
        .data_in(dataToSample),
        .data_out(dataSyncToSampler)     
    );

    sampler #(SAMPLE_WIDTH) sampler_module(
        .clock(system_clock),
        .load_counter(load_counter),
        .dataIn(dataSyncToSampler),
        .divider(command[23:0]),
        .dataOut(dataSamplerToFIFO),
        .validOut(dataValidToFIFO)
    );

    trigger_basic #(SAMPLE_WIDTH) trigger(
        .clock(system_clock),
        .reset_n(reset_n),
        .load_trigs(load_trigs),
        .valid(dataValidToFIFO),
        .arm(arm),
        .dataIn(dataSamplerToFIFO),
        .trigRising(command[7:0]),
        .trigFalling(command[15:8]),
        .run(run)
    );

    sample_fifo sample_fifo(
        .clk(system_clock), 
        .en(en),
        .rnw(rnw),
        .clear(clear),
        .hold_window(hold_window), 
        .reset_n(reset_n),
        .data_in(dataSamplerToFIFO),
        .full(full), 
        .empty(empty), 
        .data_valid(fifoToUartReady),
        .data_out(fifoToUartData)
    );

    sample_counter sample_counter(
        .clk(system_clock),
        .reset_n(reset_n),
        .en_cnt(en_cnt),
        .clr_cnt(clr_cnt),
        .wr_en(wr_en), //Load the read/delay values
        .read_match (read_match),
        .delay_match(delay_match),
        .read_reg_in(command[31:16]),
        .delay_reg_in(command[15:0])
    );  

    UART_com #(.INPUT_CLK_KHZ(INPUT_CLK_KHZ), .BAUD_RATE(BAUD_RATE))
    uart(
        .input_clk(system_clock),
        .reset_n(reset_n),
        .trans_en(tran_uart),
        .Rx(rx),
        .Tx(tx),
        .tx_busy(tx_busy),
        .data_out(tran_data),
        .data_rdy(data_rdy),
        .data_received(recv_data)   
    );

    command_decoder cmd_decode(
       .clock(system_clock),
       .reset_n(ext_reset_n),
       .byte_in(recv_data),
       .byte_in_ready(data_rdy),
       .cmd_recieved(opcode_rdy),
       .opcode(opcode),
       .command(command)
    );

    controller #(SAMPLE_WIDTH) control_unit(   
        .clock(system_clock),
        .ext_reset_n(ext_reset_n),
    //Status Signals
        .opcode(opcode), 
        .command(command), 
        .cmd_recv_rx(opcode_rdy), 
        .run(run), 
        .transmit_busy(tx_busy), 
        .meta_busy(meta_busy), 
        .delay_match(delay_match),
        .read_match(read_match),
        .validOut(dataValidToFIFO),
        .empty(empty),
    //Control Signals
        .load_counter(load_counter),
        .data_meta_mux(data_meta_mux),
        .begin_meta_transmit(begin_meta_transmit),
        .send_id(send_id),
        .en(en),
        .rnw(rnw),
        .clear(clear),
        .hold_window(hold_window),
        .edge_capture(edge_capture),
        .arm(arm),
        .load_trigs(load_trigs),
        .en_cnt(en_cnt),
        .clr_cnt(clr_cnt),
        .wr_en(wr_en),
        .reg_sel(reg_sel),
        .reset_n(reset_n)

    );

    metadata_sender metadata(
        .clock(system_clock),
        .reset_n(reset_n),
        .begin_meta_transmit(begin_meta_transmit),
        .meta_busy(meta_busy),
        .send_id(send_id),
        .tran_data(tran_meta_data),
        .transmit_byte(transmit_meta_byte),
        .tx_busy(tx_busy)  
    );

    //Transmit muxes
    assign tran_data = (data_meta_mux) ? fifoToUartData : transmit_meta_byte;
    assign tran_uart = (data_meta_mux) ? fifoToUartReady : tran_meta_data;
    
    /************ DELETE THIS, JUST TESTING USING GENRATED SIGNALS ***********/
    logic led_clk;
    logic [8:0] cnt_to_change;
    logic [7:0] test_signals;
    logic [7:0] digit0, digit1, digit2, digit3, digit4, digit5, digit6, digit7;
    
    assign tst_signal = test_signals;

    
    initial begin
        cnt_to_change = 0;
        test_signals = 8'b10101010;
    end
    always@(posedge system_clock)begin
        cnt_to_change <= cnt_to_change + 1;
        if(cnt_to_change ==0) test_signals <= ~test_signals;
        else test_signals <= test_signals;
    end
    
    bcd_to_7seg bcd7    (4'h0, digit7);
    bcd_to_7seg bcd6    (4'h0, digit6);
    bcd_to_7seg bcd5    (4'h0, digit5);
    bcd_to_7seg bcd4    (4'h0, digit4);
    bcd_to_7seg bcd3    (4'h0, digit3);
    bcd_to_7seg bcd2    (4'h0, digit2);
    bcd_to_7seg bcd1    (4'h0, digit1);
    bcd_to_7seg bcd0    (control_unit.CS, digit0);
    led_mux led_mux (led_clk, ext_reset_n, digit7, digit6, digit5, digit4, digit3, digit2, digit1, digit0, LEDSEL, LEDOUT);
    
    clk_gen ledclock(
        .clk100MHz(system_clock),
        .reset_n(ext_reset_n),
        .clk_sec(),
        .clk_5KHz(led_clk)
    );

endmodule
