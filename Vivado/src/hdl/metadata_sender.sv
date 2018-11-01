`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2018 05:55:02 PM
// Design Name: 
// Module Name: metadata_sender
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


module metadata_sender(
    input logic clock,
    input logic reset, 
    input logic begin_meta_transmit, //Alerts the unit to transmit its metadata 
    input logic send_id, //if high, sends ID, if low, sends Query Metadata
    input logic tx_busy, //Signal from transmitter, high if busy transmitting
    output logic [7:0] transmit_byte, //Byte to transmit
    output logic tran_data, //Transmit byte if tx_busy is low.
    output logic meta_busy //Sends signal back to controller when operation complete
);
   
//Initilizing the ROM to hold Metadata 
`define ADDBYTE(cmd) meta_rom[i]=cmd; i=i+1
`define ADDSHORT(cmd,b0) meta_rom[i]=cmd; meta_rom[i+1]=b0; i=i+2
`define ADDLONG(cmd,b0,b1,b2,b3) meta_rom[i]=cmd; meta_rom[i+1]=b0; meta_rom[i+2]=b1; meta_rom[i+3]=b2; meta_rom[i+4]=b3; i=i+5
reg [5:0] METADATA_LEN; // Position of last byte in ROM
reg [5:0] data_addr, next_data_addr; // Pointers for ROM reading
reg [7:0] meta_rom[63:0]; //ROM be here
assign transmit_byte = meta_rom[data_addr]; 
initial
begin : meta
   integer i;
   i = 1'b0;
  `ADDLONG(8'h01, "B", "i", "g", " "); // Device name string...
  `ADDLONG("D", "i", "c", "k", " ");
  `ADDLONG("S", "w", "i", "n", "g");
  `ADDLONG("i", "n", "'", "v", "1");
  `ADDLONG( ".", "0", "0", " ", 0);

  `ADDLONG(8'h02, "1", ".", "0", "0"); // FPGA firmware version string
  `ADDBYTE(0);

  `ADDLONG(8'h21,8'h00,8'h00,8'h80,8'h00); // Amount of sample memory (24K)
  `ADDLONG(8'h23,8'h0B,8'hEB,8'hC2,8'h00); // Max sample rate (200Mhz)

  `ADDSHORT(8'h40,8'h08); // Max # of probes
  `ADDSHORT(8'h41,8'h02); // Protocol version 

  `ADDBYTE(0); // End of data flag
  METADATA_LEN = i;

  for (i=i; i<64; i=i+1) meta_rom[i]=0; // Padding end of ROM
end 
   
   
//FSM for Meta Transmission   
typedef  enum {IDLE, TRANS, BUSY_TRANS} uart_state;
uart_state current_state, next_state;

   
always_ff @(posedge clock or posedge reset) begin
  if (reset) begin  
      current_state <= IDLE;
      data_addr <= 1'b0;
  end else begin
      current_state <= next_state;
      data_addr <= next_data_addr;
  end
end

always_comb begin
tran_data = 1'b0;
meta_busy = 1'b0;
case(current_state)
    IDLE: begin
        next_data_addr = 1'b0;
        next_state = (!send_id && !tx_busy && begin_meta_transmit) ? TRANS : IDLE;    
    end
    TRANS: begin
        meta_busy = 1'b1;
        tran_data = 1'b1;
        next_data_addr = data_addr + 1'b1;
        next_state = BUSY_TRANS;
    end
    BUSY_TRANS: begin
        meta_busy = 1'b1;
        if (!tx_busy) begin
            next_state = (data_addr == METADATA_LEN) ? IDLE: TRANS;
        end else begin
            next_state = BUSY_TRANS;
        end
    end
    default: next_state = IDLE;    
    endcase 
end    
endmodule