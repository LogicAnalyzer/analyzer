`timescale 1ns / 1ps

module top_level_tb();

logic baud_clock, input_clk, Rx, Tx, ext_reset;
logic [1:0] uarttest;
logic [5:0] indata;
logic [7:0] tstsignal;
logic [7:0] sample_data;

localparam real BAUD_RATE = 115200;
localparam real BAUD_RATE_KHZ = BAUD_RATE / 1000;
localparam real BAUD_HALF_PERIOD_NS = ( 10**6 )/( BAUD_RATE_KHZ * 2 ) ;
localparam real SAMPLE_WIDTH = 8;
localparam real INPUT_CLK_KHZ = 100_000;
localparam real INPUT_CLK_HALF_PERIOD_NS = ( 10**6 )/( INPUT_CLK_KHZ * 2 );

initial forever begin
    #INPUT_CLK_HALF_PERIOD_NS input_clk <= ~input_clk;
end

initial forever begin
    #BAUD_HALF_PERIOD_NS baud_clock <= ~baud_clock;
end

initial forever begin
    repeat(100)@(posedge input_clk);
    sample_data = ~sample_data;
end

/**** DUT ****/
ACSP_top #(.SAMPLE_WIDTH(SAMPLE_WIDTH), .INPUT_CLK_KHZ(INPUT_CLK_KHZ), .BAUD_RATE(BAUD_RATE))
DUT(
    .system_clock(input_clk), 
    .ext_reset_n(ext_reset),
    .dataToSample(sample_data),
    .rx(Rx),
    .tx(Tx),
    .uart_test(uarttest),
    .indata(indata),
    .tst_signal(tstsignal)
);

/*Main Test Bench*/
initial begin
    initialize();
    ext_reset = 1'b0;
    #5;
    ext_reset = 1'b1;
    send_reset();
    fork
        get_meta();
        begin
            query_id();
            query_metadata();
        end

    join

    send_reset();
    set_trigger(8'b0000_0000, 8'b0000_0000);
    set_sample_rate(24'h98967f);
    set_read_delay(16'h03, 16'h03);
    
    send_data(8'H82);
    send_data(8'H38);
    send_data(8'H00);
    send_data(8'H00);
    send_data(8'H00);
    
    arm();
    
//    send_reset();
//    set_trigger(8'b0000_0001, 8'b0000_0000);
//    set_sample_rate(24'h1f3);
//    set_read_delay(16'h18, 16'h18);
    
//    arm();
    
//    send_reset();send_reset();
//    set_trigger(8'b0000_0001, 8'b0000_0000);
//    set_sample_rate(24'h1f3);
//    set_read_delay(16'h18, 16'h18);
    
//    arm();
    
//    send_reset();send_reset();send_reset();send_reset();
//    set_trigger(8'b0000_0001, 8'b0000_0000);
//    set_sample_rate(24'h1f3);
//    set_read_delay(16'h18, 16'h18);
    
//    arm();
    
//    send_reset();send_reset();send_reset();send_reset();
//    set_trigger(8'b0000_0001, 8'b0000_0000);
//    set_sample_rate(24'h1f3);
//    set_read_delay(16'h18, 16'h18);
    
//    arm();
    
    // $finish;
end //initial begin



function void initialize ();
    input_clk = 0;
    baud_clock =0;
    ext_reset = 1;
    Rx = 1;
    sample_data = 8'hFF;
endfunction : initialize
    
task send_data(input [7:0] data);

    integer index;
    index = 0;

    $display($time, "  Sending data: %b",data);
    Rx = 0;
    while(index < 8)begin
        @(posedge baud_clock)
        Rx = data [index];
        index = index + 1;
    end 
    @(posedge baud_clock)
    Rx = 1;
    @(posedge baud_clock);
    
endtask : send_data

task receive_data(output [7:0] rcv_byte, output bit valid);
    automatic integer bit_count=0;
    valid=0;
    @(posedge baud_clock);
    if(Tx===0) begin //Start bit detected
        while(bit_count<8)begin
            @(posedge baud_clock);
            rcv_byte[bit_count] = Tx;
            bit_count = bit_count+1;
        end
        valid = 1;
    end

endtask : receive_data

task arm();
    send_data(8'H01);
endtask: arm

task send_reset();
    send_data(8'H00);
endtask : send_reset

task set_sample_rate(input [23:0] sample_rate);
    $display("setting sample rate to: %d",sample_rate);
    send_data(8'H80);
    send_data(8'H00);
    send_data(sample_rate[23:16]);
    send_data(sample_rate[15:8]);
    send_data(sample_rate[7:0]);
endtask : set_sample_rate

task set_read_delay(input [15:0] read_count, input [15:0] delay_count);
    send_data(8'H81);
    send_data(read_count[15:8]);
    send_data(read_count[7:0]);
    send_data(delay_count[15:8]);
    send_data(delay_count[7:0]);
endtask : set_read_delay

task set_trigger(input [7:0] rising_edge, input [7:0] falling_edge);
    send_data(8'HC1);
    send_data(8'H00);
    send_data(8'H00);
    send_data(falling_edge);
    send_data(rising_edge);
endtask : set_trigger

task query_metadata();
    send_data(8'H02);
endtask : query_metadata

task query_id();
    send_data(8'H04);
endtask : query_id

task receive_nullend_string();
    logic [7:0] string_buffer [0:200];
    bit valid;
    automatic integer current_char=0;
    
    do 
        begin
            receive_data(string_buffer[current_char],valid);
            if(valid) current_char = current_char+1;
        end 
    while(string_buffer[current_char-1]!==0);
    current_char =0;
    $write($time, "  Received data: ");
    do 
        begin
            $write("%c",string_buffer[current_char]);
            current_char = current_char+1;
        end 
    while(string_buffer[current_char-1]!==0);
    $write("\n");
    
endtask: receive_nullend_string
         
task receive_32_bit();
    logic [7:0] recv_32b [0:3];
    bit valid;
    automatic integer current_char=0;
    
    do 
        begin
        receive_data(recv_32b[current_char],valid);
        if(valid)
            current_char = current_char+1;
        end 
    while(current_char < 4);

    $display($time, "  Received data: 0x%x%x%x%x ",recv_32b[0],recv_32b[1],recv_32b[2],recv_32b[3]);
endtask: receive_32_bit      

task receive_8_bit();
    logic [7:0] recv_8b;
    bit valid; 
    valid =0;
    while(valid !==1) receive_data(recv_8b,valid);
    $display($time, "  Received data: 0x%x ",{recv_8b});
endtask: receive_8_bit     

task get_meta();
    logic [7:0] rcv_byte;
    bit valid;
    valid =0;
    do
        begin
            while(valid !==1) receive_data(rcv_byte,valid);
            case(rcv_byte)
                8'h00:begin
                    $display($time, "  Received data: end of metadata ");
                end
                8'h01:begin
                    $display($time, "  Received 0x01, Device Name");
                    receive_nullend_string();
                end
                8'h02:begin
                    $display($time, "  Received 0x02, Version of FPGA firmware");
                    receive_nullend_string();
                end
                8'h03:begin
                    $display($time, "  Received 0x03, Ancillary Version");
                    receive_nullend_string();
                end
                8'h20:begin
                    $display($time, "  Received 0x20, Number of Probes");
                    receive_32_bit();
                end
                8'h21:begin
                    $display($time, "  Received 0x21, Sample Memory Available");
                    receive_32_bit();
                end
                8'h22:begin
                    $display($time, "  Received 0x22, Dynamic Memory Available");
                    receive_32_bit();
                end
                8'h23:begin
                    $display($time, "  Received 0x23, Max Sample Rate");
                    receive_32_bit();
                end
                8'h24:begin
                    $display($time, "  Received 0x24, Protocol version");
                    receive_32_bit();
                end
                8'h25:begin
                    $display($time, "  Received 0x25, Capability Flags");
                    receive_32_bit();
                end
                8'h40:begin
                    $display($time, "  Received 0x40, Number of probes (Short version)");
                    receive_8_bit();
                end
                8'h41:begin
                    $display($time, "  Received 0x41, Protocol version (Short Version)");
                    receive_8_bit();
                end
            endcase
            valid =0;
        end
    while(rcv_byte !==0);
endtask: get_meta

endmodule


           
