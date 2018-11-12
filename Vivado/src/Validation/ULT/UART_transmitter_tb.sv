`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/12/2018 10:06:50 AM
// Design Name: 
// Module Name: UART_transmitter_tb
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


module UART_transmitter_tb(

    );
	logic baud_clock, clock_100_Mhz, reset, Rx, Tx, data_rdy, trans_en;
	logic [7:0] data_in, data_out;
	integer current_data, error_count, success_count;

	initial forever begin
		#5ns clock_100_Mhz <= ~clock_100_Mhz;
	end
	initial forever begin
		#52083.335ns baud_clock <= ~baud_clock;
	end
    
    UART_receiver xReceiver( .input_clk(clock_100_Mhz), .reset(reset),  .data_received(data_in), .data_rdy(data_rdy), .Rx(Rx)
        );

    UART_transmitter DUT( .input_clk(clock_100_Mhz), .reset(reset), .trans_en(trans_en), .data_out(data_out), .Tx(Tx)
        );

    assign Rx = Tx;
    initial begin
    	initialize();
    	reset_dut();

    	while (current_data < 256) begin 
            fork
              send_data(current_data);

    		  check_data(current_data);
            join
    		current_data = current_data + 1;
    	end
    	print_test_results();
    	$finish;

    end

    function void initialize ();
    	clock_100_Mhz = 0;
    	baud_clock = 0;
    	reset = 1;
    	current_data = 0;
    	error_count = 0;
    	success_count = 0;
        trans_en = 0;
        data_out = 0;
    endfunction : initialize

    task reset_dut ();
    	reset = 0;
    	#5;
    	reset = 1;
    endtask : reset_dut

    task send_data(input [7:0] data);

    	integer index;
    	index = 0;

    	$display($time, "  Sending data: %b",data);
    	data_out = data;
    	
        trans_en = 1'b1;
        @(posedge baud_clock)
        trans_en = 1'b0;
        
        repeat(11)@(posedge baud_clock);
    endtask : send_data

    task check_data (input [7:0] expected_data);
    	@(posedge data_rdy);
    	#1;
        if (data_in == expected_data)begin
            $display($time," Data received and expected_data MATCHED!");
            success_count = success_count + 1;
        end else begin
            $display($time," Data reveived and expected_data did not match: data_in: %b expected_data: %b",data_in,expected_data);
            error_count = error_count + 1;
        end
    endtask : check_data
    
    function void print_test_results();
    	$display("********************** Test Complete **********************\n\n");
    	$display("    Successful Txns |   Failed Txns   |   Total Txns   \n");
    	$display("          %3d       |       %3d       |      %3d       \n", success_count, error_count, error_count+success_count );
    	if(error_count == 0) $display("Test completed with no errors! ");
    endfunction : print_test_results 
endmodule
