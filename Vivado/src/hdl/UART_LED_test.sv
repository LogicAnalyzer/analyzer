`timescale 1ns / 1ps

module UART_LED_test(
    input rx, clock, reset,
    output tx,
    output [7:0] LEDSEL, LEDOUT,
    
    output [7:0] recv_data_test,
    output [3:0] LED,
    output rx_test, data_rdy_test, checkcode_test
);

wire tran_uart, data_rdy, checkcode, led_clk;
wire [7:0] tran_data, recv_data;
wire [3:0] cs;
wire [7:0] opcode;
wire [31:0] command;
wire [7:0] digit0, digit1, digit2, digit3, digit4, digit5, digit6, digit7;
reg [39:0] hold_input;

assign rx_test = rx;
assign recv_data_test = {4'b0,cs};
assign data_rdy_test = data_rdy;
assign checkcode_test = checkcode;
assign LED = cs;

clk_gen ledclock(
    .clk100MHz(clock),
    .rst(reset),
    .clk_sec(),
    .clk_5KHz(led_clk)
);
bcd_to_7seg bcd7    (hold_input[39:36], digit7);
bcd_to_7seg bcd6    (hold_input[35:32], digit6);
bcd_to_7seg bcd5    (hold_input[23:20], digit5);
bcd_to_7seg bcd4    (hold_input[19:16], digit4);
bcd_to_7seg bcd3    (hold_input[15:12], digit3);
bcd_to_7seg bcd2    (hold_input[11:8], digit2);
bcd_to_7seg bcd1    (hold_input[7:4], digit1);
bcd_to_7seg bcd0    (hold_input[3:0], digit0);
led_mux led_mux (led_clk, reset, digit7, digit6, digit5, digit4, digit3, digit2, digit1, digit0, LEDSEL, LEDOUT);

UART_com uart(
 .input_clk(clock),
 .reset(~reset),
 .trans_en(tran_uart),
 .Rx(rx),
 .Tx(tx),
 .data_out(tran_data),
 .data_rdy(data_rdy),
 .data_received(recv_data)   
);
   
command_decoder cmd_decode(
   .clock(clock),
   .reset(reset),
   .byte_in(recv_data),
   .byte_in_ready(data_rdy),
   .cmd_recieved(checkcode),
   .opcode(opcode),
   .command(command),
   .cs_out(cs)
);

controller ctrl_unit(

);

always@(posedge checkcode) begin
    hold_input <= {opcode,command};
end

// reg [13:0] baud_counter;
// reg baud_clock;  
//always @(posedge baud_clock or posedge reset)begin
//         if (reset) hold_input <= 40'b0;
//         else if(data_rdy) begin
//             hold_input <= {32'b0, recv_data};
//             end
// end 
 
// always_ff@( posedge clock )begin
//        if (baud_counter == 14'd5207) begin
//            baud_clock <= ~baud_clock;
//            baud_counter <= 14'b0;
//        end else begin
//            baud_counter <= baud_counter + 14'b1;
//        end
//    end  
    
endmodule
