`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/21/2018 12:07:39 PM
// Design Name: 
// Module Name: ASCP_top
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
    
    assign LED [7:0] = uart.data_out;
    assign LED [15:8] = uart.data_out_f;
    assign indata[0] = uart.trans_latch;
    assign indata[1]= uart.trans_en;
    assign indata[2]= uart.trans_busy;
    assign indata[3]= uart.baud_clock;
    assign indata[4]= uart.input_clk;
    
    
logic [SAMPLE_WIDTH-1:0] fallPattern, risePattern, dataSyncToSampler, dataSamplerToFIFO;
logic [23:0] divider;
logic edge_capture, run, arm, dataValidToFIFO, opcode_rdy, data_rdy, tran_meta_data, send_id, dataSamplerReady;
logic meta_busy, begin_meta_transmit, tx_busy, tran_uart, data_meta_mux, reset_n, load_trigs, load_counter;
logic [7:0] opcode, recv_data, transmit_meta_byte, tran_data;
logic [31:0] command;
   
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
    .reset_n(reset_n),
    .ext_reset_n(ext_reset_n),
    //Status Signals
    .opcode(opcode),
    .command(command),
    .cmd_recv_rx(opcode_rdy),
    .run(run),
    .transmit_busy(tx_busy),
    .meta_busy(meta_busy),
    //Control Signals
    .divider(divider),
    .data_meta_mux(data_meta_mux),
    .arm(arm),
    .send_id(send_id),
    .begin_meta_transmit(begin_meta_transmit)
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
assign tran_data = (data_meta_mux) ? dataSamplerToFIFO : transmit_meta_byte;
assign tran_uart = (data_meta_mux) ? dataSamplerReady : tran_meta_data;



endmodule
