`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2018 05:55:02 PM
// Design Name: 
// Module Name: controller
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


module controller #(parameter SAMPLE_WIDTH = 8)(
    input logic clock,
    input logic ext_reset,
//Status Signals
    input logic [7:0] opcode, //opcode from command decoder
    input logic [31:0] command, //command from command decoder
    input logic cmd_recv_rx, //signal high when command decoder recieved all 5 bytes
    input logic run, //run signal from trigger
    input logic transmit_busy, //UART transmitter busy
    input logic meta_busy, //meta unit finished with its transmission
 
//Control Signals
    output logic reset,
    output logic [23:0] divider,
    output logic data_meta_mux, //low for meta, high for data
    output logic arm,
    output logic send_id,
    output logic begin_meta_transmit,
    output logic [SAMPLE_WIDTH-1:0] risePattern,
    output logic [SAMPLE_WIDTH-1:0] fallPattern
);

logic [7:0] current_opcode;
logic [31:0] current_command;
typedef enum {IDLE, META_WAIT, CMD_RECIEVED, RESETS} controller_state;
controller_state CS, NS;

always_ff@(posedge clock or posedge ext_reset) begin
    if (ext_reset) begin
        CS <= RESETS;   
    end else begin
        CS <= NS;
    end
end

always_comb begin
send_id = 1'b0;
begin_meta_transmit = 1'b0;
reset = 1'b0;
case(CS)
//IDLE: Power on state, reset state, waiting for opcode from UART
IDLE: begin
    if(cmd_recv_rx) begin
        NS = CMD_RECIEVED;
        current_opcode = opcode;
        current_command = command;
    end else begin
        NS = IDLE;
        current_opcode = 8'b0;
        current_command = 32'b0;
    end
end
//CMD_RECIEVED: For each OP code, do something.
CMD_RECIEVED: begin
    case(opcode)
    8'H00: begin //Reset Signal
        NS = IDLE;
        reset = 1'b1;
    end
    8'H02: begin //Query ID
        begin_meta_transmit = 1'b1;
        data_meta_mux = 1'b0;        
        send_id = 1'b1; 
        NS = META_WAIT;
    end
    8'H04: begin//Query Metadata
        begin_meta_transmit = 1'b1;
        data_meta_mux = 1'b0;        
        send_id = 1'b0; 
        NS = META_WAIT;
    end
    default: NS = IDLE;
    endcase
end
//META_WAIT: Wait for metadata module to finish transmission.
META_WAIT: begin
    if(meta_busy) begin
        NS = META_WAIT;
    end else begin
        NS = IDLE;
    end
end
RESETS: begin
    reset = 1'b1;
    NS = IDLE;
end
default : NS <= IDLE;
endcase
end //always_comb_case    
endmodule
