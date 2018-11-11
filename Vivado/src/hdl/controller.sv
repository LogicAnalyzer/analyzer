`timescale 1ns / 1ps

module controller #(parameter SAMPLE_WIDTH = 8)(
    input logic clock,
    input logic ext_reset_n,
//Status Signals
    input logic [7:0] opcode, //opcode from command decoder
    input logic [31:0] command, //command from command decoder
    input logic cmd_recv_rx, //signal high when command decoder recieved all 5 bytes
    input logic run, //run signal from trigger
    input logic transmit_busy, //UART transmitter busy
    input logic meta_busy, //meta unit finished with its transmission
 
//Control Signals
    output logic reset_n,
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

always_ff@(posedge clock or negedge ext_reset_n) begin
    if (!ext_reset_n) begin
        CS <= RESETS;   
    end else begin
        CS <= NS;
    end
end

always_comb begin
send_id = 1'b0;
begin_meta_transmit = 1'b0;
reset_n = 1'b1;
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
    8'H00: begin //Reset_n Signal
        NS = IDLE;
        reset_n = 1'b0;
    end
    8'H02: begin //Query ID
        begin_meta_transmit = 1'b1;
        data_meta_mux = 1'b0;        
        send_id = 1'b1; 
        NS = META_WAIT;
    end
    8'H04: begin //Query Metadata
        begin_meta_transmit = 1'b1;
        data_meta_mux = 1'b0;        
        send_id = 1'b0; 
        NS = META_WAIT;
    end
    8'H05: begin // Finish Now

    end // 
    8'H07: begin //0x07 - Poll/Query Analyzer State

    end
    8'H08: begin //0x08 - Return Capture Data

    end 
    8'H80: begin // Set Sample Rate

    end
    8'H81: begin // Set Read Count & Delay Count

    end
    8'HC0: begin // Set Basic Trigger Mask

	end // 
	8'HC1: begin // Set Basic Trigger Value

	end
	8'H01: begin // Arm Basic Trigger

	end
    default: NS = IDLE;
    endcase
end
//META_WAIT: Wait for metadata module to finish transmission.
META_WAIT: begin
    begin_meta_transmit = 1'b0;
    if(meta_busy) begin
        NS = META_WAIT;
    end else begin
        NS = IDLE;
    end
end
RESETS: begin
    reset_n = 1'b0;
    NS = IDLE;
end
default : NS <= IDLE;
endcase
end //always_comb_case    
endmodule
