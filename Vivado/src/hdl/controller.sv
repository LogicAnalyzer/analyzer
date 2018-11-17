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
    input logic validOut, //Signal from sampler signaling that data is currently valid.
    input logic delay_match, //Status from the counter, alerting to a delay match
    input logic read_match, //Status from the counter, alerting a read length match
    input logic empty,

//Control Signals
    output logic load_counter,
    output logic data_meta_mux, //low for meta, high for data
    output logic begin_meta_transmit,
    output logic send_id,
    output logic en,
    output logic rnw,
    output logic clear,
    output logic hold_window,
    output logic edge_capture,
    output logic arm,
    output logic load_trigs,
    output logic en_cnt,
    output logic clr_cnt,
    output logic wr_en,
    output logic reg_sel,
    output logic reset_n
);

logic [7:0] current_opcode;
logic [31:0] current_command;
logic [15:0] control_signals;
typedef enum {IDLE, META_WAIT, CMD_RECIEVED, RESETS, WAIT_FOR_DLYCNT, 
    WAIT_FOR_TRIGGER, SAMPLING, TRANSMITTING, TRANSMIT_WAIT} controller_state;
controller_state CS, NS;

//!!!VERY IMPORTANT If you add signals to this list you MUST expand "control_signals" vector size and LOCALPARAM
assign {load_counter,data_meta_mux,begin_meta_transmit,
        send_id,en,rnw,clear,hold_window,edge_capture,
        arm,load_trigs,en_cnt,clr_cnt,wr_en,reg_sel,reset_n} = control_signals;

    localparam IDLE_    = 16'b0000_0000_0000_0001;
    //State1 - CMD_RECIEVED
    localparam CMD_OP00 = 16'b0000_0000_0000_0000;
    localparam CMD_OP01 = 16'b0000_0010_0100_1001;
    localparam CMD_OP02 = 16'b0011_0000_0000_0001;
    localparam CMD_OP03 = 16'b0000_0000_0000_0001;
    localparam CMD_OP04 = 16'b0010_0000_0000_0001;
    localparam CMD_OP05 = 16'b0000_0000_0000_0001;
    localparam CMD_OP06 = 16'b0000_0000_0000_0001;
    localparam CMD_OP07 = 16'b0000_0000_0000_0001;
    localparam CMD_OP08 = 16'b0000_0000_0000_0001;
    localparam CMD_OP09 = 16'b0000_0000_0000_0001;
    localparam CMD_OP80 = 16'b1000_0000_0000_0001;
    localparam CMD_OP81 = 16'b0000_0000_0000_0101;
    localparam CMD_OPC0 = 16'b0000_0000_0000_0001;
    localparam CMD_OPC1 = 16'b0000_0000_0010_0001;
    //State2 - RESET
    localparam RESETSIG = 16'b0000_0000_0000_0000;
    //State3 - METAWAIT
    localparam METAWAIT = 16'b0000_0000_0000_0001;
    //State4 - WAIT_FOR_DLYCNT
    localparam DLYCNT1  = 16'b0000_0000_0000_0001;
    localparam DLYCNT2  = 16'b0000_1000_0001_0001;
    localparam DLYCNT3  = 16'b0000_1001_0000_0001;
    localparam DLYCNT4  = 16'b0000_1000_0001_0001;
    //State5 - WAIT_FOR_TRIGGER
    localparam WTTRIG1  = 16'b0000_0000_0000_0001;
    localparam WTTRIG2  = 16'b0000_1001_0000_0001;
    localparam WTTRIG3  = 16'b0000_1000_0001_0001;
    //State6 - SAMPLING
    localparam SAMPLE1  = 16'b0000_0000_0000_0001;
    localparam SAMPLE2  = 16'b0000_1000_0001_0001;
    localparam SAMPLE3  = 16'b0000_0000_0000_0001;
    //State7 - TRANSMITTING
    localparam TRANS1   = 16'b0100_0100_0000_0001;
    localparam TRANS2   = 16'b0100_0100_0000_0001;
    localparam TRANS3   = 16'b0100_1100_0000_0001;
    //State8 - TRANSMIT_IDLE
    localparam TRAIDLE  = 16'b0100_0100_0000_0001;
    localparam RESETS_  = 16'b0000_0000_0000_0000;
    localparam DEFAULT_ = 16'b0000_0000_0000_0001;
//!!!VERY IMPORTANT If you add signals to this list you MUST expand "control_signals" vector size and LOCALPARAM

always_ff@(posedge clock or negedge ext_reset_n) begin
    if (!ext_reset_n) begin
        CS <= RESETS;   
    end else begin
        CS <= NS;
    end
end

always_comb begin
    case(CS)
        //IDLE: Power on state, reset state, waiting for opcode from UART
        IDLE: begin
            if(cmd_recv_rx) begin
                NS = CMD_RECIEVED;
                current_opcode = opcode;
                current_command = command;
                control_signals = IDLE_;
            end else begin
                NS = IDLE;
                current_opcode = 8'b0;
                current_command = 32'b0;
                control_signals = IDLE_;
            end
        end
        //CMD_RECIEVED: For each OP code, do something.
        CMD_RECIEVED: begin
            case(opcode)
            8'H00: begin //Reset_n Signal
                NS = RESETS;
                current_opcode = 8'b0;
                current_command = 32'b0;
                control_signals = CMD_OP00;
            end
            8'H01: begin // Arm Basic Trigger
                NS = WAIT_FOR_DLYCNT;
                current_opcode = 8'b0;
                current_command = 32'b0;
                control_signals = CMD_OP01;
            end
            8'H02: begin //Query ID
                NS = META_WAIT;
                current_opcode = 8'b0;
                current_command = 32'b0;
                control_signals = CMD_OP02;
            end
            8'H04: begin //Query Metadata
                NS = META_WAIT;
                current_opcode = 8'b0;
                current_command = 32'b0;
                control_signals = CMD_OP04;
            end
            8'H05: begin // Finish Now
                NS = IDLE;
                current_opcode = 8'b0;
                current_command = 32'b0;
                control_signals = CMD_OP05;
            end // 
            8'H07: begin //0x07 - Poll/Query Analyzer State
                NS = IDLE;
                current_opcode = 8'b0;
                current_command = 32'b0;
                control_signals = CMD_OP07;
            end
            8'H08: begin //0x08 - Return Capture Data
                NS = IDLE;
                current_opcode = 8'b0;
                current_command = 32'b0;
                control_signals = CMD_OP08;
            end 
            8'H80: begin // Set Sample Rate
                NS = IDLE;
                current_opcode = 8'b0;
                current_command = 32'b0;
                control_signals = CMD_OP80;
            end
            8'H81: begin // Set Read Count & Delay Count
                NS = IDLE;
                current_opcode = 8'b0;
                current_command = 32'b0;
                control_signals = CMD_OP81;
            end
            8'HC0: begin // Set Basic Trigger Mask
                NS = IDLE;
                current_opcode = 8'b0;
                current_command = 32'b0;
                control_signals = CMD_OPC0;
        	end // 
        	8'HC1: begin // Set Basic Trigger Value
                NS = IDLE;
                current_opcode = 8'b0;
                current_command = 32'b0;
                control_signals = CMD_OPC1;
        	end
            default: NS = IDLE;
            endcase
        end
        //META_WAIT: Wait for metadata module to finish transmission.
        META_WAIT: begin
            if(meta_busy) begin
                NS = META_WAIT;
                current_opcode = 8'b0;
                current_command = 32'b0;
                control_signals = METAWAIT;
            end else begin
                NS = IDLE;
                current_opcode = 8'b0;
                current_command = 32'b0;
                control_signals = METAWAIT;
            end
        end
        //RESET
        RESETS: begin
            NS = IDLE;
            current_opcode = 8'b0;
            current_command = 32'b0;
            control_signals = RESETS_;
        end
        //WAIT_FOR_DLYCNT - Waits for the delay counter.ss
        WAIT_FOR_DLYCNT: begin
            if (!validOut) begin
                NS = WAIT_FOR_DLYCNT;
                control_signals = DLYCNT1;
            end
            else begin 
                if (run) begin
                    NS = SAMPLING;
                    control_signals = DLYCNT4;
                end
                else begin
                     if (delay_match) begin
                        NS = WAIT_FOR_TRIGGER;
                        control_signals = DLYCNT3;
                    end
                    else begin
                        NS = WAIT_FOR_DLYCNT;
                        control_signals = DLYCNT2;
                    end
                end
            end
        end
        //WAIT_FOR_TRIGGER - Waits for the trigger signal.
        WAIT_FOR_TRIGGER: begin
            if(!validOut) begin
                NS = WAIT_FOR_TRIGGER;
                control_signals = WTTRIG1;
            end
            else begin
                if(run) begin
                    NS = SAMPLING;
                    control_signals = WTTRIG2;
                end
                else begin
                    NS = WAIT_FOR_TRIGGER;
                    control_signals = WTTRIG2;
                end
            end
        end
        //SAMPLING - Collects samples until read_match.
        SAMPLING: begin
            if (!validOut) begin
                NS = SAMPLING;
                control_signals = SAMPLE1;
            end
            else begin
                if(read_match) begin
                    NS = TRANSMITTING;
                    control_signals = SAMPLE3;
                end
                else begin
                    NS = SAMPLING;
                    control_signals = SAMPLE2;
                end
            end
        end
        //TRANSMITTING - Transmit signals to the UART module
        TRANSMITTING: begin
            if (transmit_busy) begin
                NS = TRANSMITTING;
                control_signals = TRANS1;
            end
            else begin
                if (empty) begin
                    NS = IDLE;
                    control_signals = TRANS2;
                end
                else begin
                    NS = TRANSMIT_WAIT;
                    control_signals = TRANS3;
                end
            end
        end
        //TRANSMIT_WAIT - Wait state to allow transmission flag to enable.
        TRANSMIT_WAIT: begin
            NS = TRANSMITTING;
            control_signals = TRAIDLE;
        end
        //
        default : begin
            NS = IDLE;
            current_opcode = 8'b0;
            current_command = 32'b0; 
            control_signals = DEFAULT_;
        end
    endcase
end //always_comb_case    
endmodule
