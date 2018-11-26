`timescale 1ns / 1ps

module metadata_sender(
    input logic clock,
    input logic reset_n, 
    input logic begin_meta_transmit, //Alerts the unit to transmit its metadata 
    input logic send_id, //if high, sends ID, if low, sends Query Metadata
    input logic tx_busy, //Signal from transmitter, high if busy transmitting
    output logic [7:0] transmit_byte, //Byte to transmit
    output logic tran_data, //Transmit byte if tx_busy is low.
    output logic meta_busy //Status signal back to controller when operation complete
);
   
//Initilizing the ROM to hold Metadata 
`define ADDBYTE(cmd) meta_rom[i]=cmd; i=i+1
`define ADDSHORT(cmd,b0) meta_rom[i]=cmd; meta_rom[i+1]=b0; i=i+2
`define ADDLONG(cmd,b0,b1,b2,b3) meta_rom[i]=cmd; meta_rom[i+1]=b0; meta_rom[i+2]=b1; meta_rom[i+3]=b2; meta_rom[i+4]=b3; i=i+5
logic [5:0] METADATA_LEN; // Position of last byte in ROM
logic [5:0] data_addr, next_data_addr; // Pointers for ROM reading
logic [3:0] id_data_addr, next_id_data_addr; //Pointers for ID_reading
logic [7:0] meta_rom[63:0]; //ROM be here
logic [7:0] id_rom[4:0]; // ID ROM here
logic send_id_reg;
logic ID_ROM_LEN = 2'b11;
assign transmit_byte = (send_id_reg) ? id_rom[id_data_addr] : meta_rom[data_addr];
initial
begin : meta
   integer i;
   i = 1'b0;
  `ADDLONG(8'h01, "A", "C", "S", "P"); // Device name string...
  `ADDLONG(" ", "v", "1", ".", "0");
  `ADDBYTE(0);

  `ADDLONG(8'h02, "1", ".", "0", "0"); // FPGA firmware version string
  `ADDBYTE(0);

  `ADDLONG(8'h21,8'h00,8'h00,8'h80,8'h00); // Amount of sample memory (24K)
  `ADDLONG(8'h23,8'h0B,8'hEB,8'hC2,8'h00); // Max sample rate (200Mhz)

  `ADDSHORT(8'h40,8'h08); // Max # of probes
  `ADDSHORT(8'h41,8'h02); // Protocol version 

  `ADDBYTE(0); // End of data flag
  METADATA_LEN = i;

  for (i=i; i<64; i=i+1) meta_rom[i]=0; // Padding end of ROM
  //Set the ID Into the id_rom.
  id_rom[0] = "A"; id_rom[1] = "C"; id_rom[2] = "S"; id_rom[3] = "P"; id_rom[4] = 0; 
end 
   
   
//FSM for Meta Transmission   
typedef  enum {IDLE, TRANS, BUSY_TRANS, TRANS_ID, BUSY_TRANS_ID} uart_state;
uart_state current_state, next_state;

   
always_ff @(posedge clock) begin
  if (!reset_n) begin  
      current_state <= IDLE;
      data_addr <= 1'b0;
      id_data_addr <= 1'b0;
  end else begin
      current_state <= next_state;
      data_addr <= next_data_addr;
      id_data_addr <= next_id_data_addr;
  end
end

//always_comb begin
always_ff@(negedge clock) begin
case(current_state)
    IDLE: begin
        tran_data <= 1'b0;
        meta_busy <= 1'b0;
        next_data_addr <= 1'b0;
        next_id_data_addr <= 1'b0;         
        send_id_reg = send_id;  
        if(send_id) begin
            next_state <= (!tx_busy && begin_meta_transmit) ? TRANS_ID : IDLE;  
        end else begin
            next_state <= (!tx_busy && begin_meta_transmit) ? TRANS : IDLE;    
        end  
    end
    TRANS: begin
        meta_busy <= 1'b1;
        tran_data <= 1'b1;
        next_data_addr <= data_addr + 1'b1;
        next_state <= BUSY_TRANS;
    end
    BUSY_TRANS: begin
        meta_busy <= 1'b1;
        tran_data <= 1'b0;
        if (!tx_busy) begin
            next_state <= (data_addr == METADATA_LEN) ? IDLE: TRANS;
        end else begin
            next_state <= BUSY_TRANS;
        end
    end
    TRANS_ID: begin
        meta_busy <= 1'b1;
        tran_data <= 1'b1;
        next_id_data_addr <= id_data_addr + 1'b1;
        next_state <= BUSY_TRANS_ID;
    end
    BUSY_TRANS_ID: begin
        meta_busy <= 1'b1;
        tran_data <= 1'b0;
        if (!tx_busy) begin
            next_state <= (id_data_addr >= 4) ? IDLE: TRANS_ID;
        end else begin
            next_state <= BUSY_TRANS_ID;
        end
    end
    default: next_state <= IDLE;    
    endcase 
end    
endmodule