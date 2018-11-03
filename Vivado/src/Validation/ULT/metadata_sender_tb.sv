`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/01/2018 06:05:06 PM
// Design Name: 
// Module Name: metadata_sender_tb
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


module metadata_sender_tb();

reg clock, reset, begin_meta_transmit, send_id, tx_busy;
wire [7:0] transmit_byte;
wire meta_busy, tran_data;

metadata_sender DUT(
    .clock(clock),
    .reset(reset), 
    .begin_meta_transmit(begin_meta_transmit), //Alerts the unit to transmit its metadata 
    .send_id(send_id), //if high, sends ID, if low, sends Query Metadata
    .tx_busy(tx_busy), //Signal from transmitter, high if busy transmitting
    .transmit_byte(transmit_byte), //Byte to transmit
    .tran_data(tran_data), //Transmit byte if tx_busy is low.
    .meta_busy(meta_busy) //Status signal back to controller when operation complete    
);

task tick;
input [7:0] numberofticks;
begin
  for (int i = numberofticks ;i > 0;  i = i - 1) begin
  #1; clock = 1; #1; clock = 0; #1;
      end
  end
endtask

initial begin
    reset = 1; begin_meta_transmit = 0; send_id = 0; tx_busy = 0;
    tick(3);
    reset = 0; 
    tick(10);
    begin_meta_transmit = 1;
    tick(1);
    begin_meta_transmit = 0;
    while (meta_busy) begin
        tick(1);
        tx_busy = 1;
        tick(10);
        tx_busy = 0;
    end
    tick(3);
    reset = 1;
    tick(1);
    reset = 0;
    tick(10);
    begin_meta_transmit = 1; send_id = 1;
    tick(1);
    begin_meta_transmit = 0;
    while (meta_busy) begin
        tick(1);
        tx_busy = 1;
        tick(10);
        tx_busy = 0;
    end
    
    

end //end initial
endmodule