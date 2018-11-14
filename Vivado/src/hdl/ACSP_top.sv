`timescale 1ns / 1ps

parameter SAMPLE_WIDTH = 8;

module ACSP_top(
    input system_clock, ext_reset_n,
    input [SAMPLE_WIDTH-1:0] dataToSample,
    input rx,
    output tx,
    //Testing LEDS
//    output [7:0] LEDSEL, LEDOUT,
    output [15:0] LED,
    output [4:0] indata
    );
    

    //assign LED [7:0] = uart.data_out;
    //assign LED [15:8] = uart.data_out_f;
    assign indata[0] = uart.trans_latch;
    assign indata[1]= uart.trans_en;
    assign indata[2]= uart.trans_busy;
    assign indata[3]= uart.baud_clock;
    assign indata[4]= uart.input_clk;
    
    
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
//        .readdelay(command)
    );  

    UART_com uart(
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
       .reset_n(reset_n),
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
        .validOut           (dataValidToFIFO),
        .empty              (empty),
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

    //    assign LED[0] = ext_reset_n;
    //    assign LED[1] = reset_n;
    //    assign LED[2] = uart.UART_receiver_i.reset_n;
    //    assign LED[3] = uart.UART_transmitter_i.reset_n;
endmodule
