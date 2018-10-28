`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/11/2018 10:16:41 AM
// Design Name: 
// Module Name: UART_reveiver_tb
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


module UART_reveiver_tb(

    );
	logic baud_clock, input_clk, reset, Rx, data_rdy;
	logic [7:0] data_received;
	integer current_data, error_count, success_count;

    localparam real BAUD_RATE = 9600;
    localparam real BAUD_RATE_KHZ = BAUD_RATE / 1000;
    localparam real BAUD_HALF_PERIOD_NS = ( 10**6 )/( BAUD_RATE_KHZ * 2 ) ;

    localparam real INPUT_CLK_KHZ = 100_000;
    localparam real INPUT_CLK_HALF_PERIOD_NS = ( 10**6 )/( INPUT_CLK_KHZ * 2 );

	initial forever begin
		#INPUT_CLK_HALF_PERIOD_NS input_clk <= ~input_clk;
	end
	initial forever begin
		#BAUD_HALF_PERIOD_NS baud_clock <= ~baud_clock;
	end
    

    
    UART_receiver DUT( .input_clk(input_clk), .reset(reset),  .data_received(data_received), .data_rdy(data_rdy), .Rx(Rx)
        );

    initial begin
        print_test_header();
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
    	input_clk = 0;
    	baud_clock =0;
    	reset = 1;
    	Rx = 1;
    	current_data =0;
    	error_count =0;
    	success_count =0;
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

    task check_data (input [7:0] expected_data);
    	@(posedge data_rdy);
    	#1;
        if (data_received == expected_data)begin
            $display($time," Data received and expected_data MATCHED!");
            success_count = success_count + 1;
        end else begin
            $display($time," Data reveived and expected_data did not match: data_received: %b expected_data: %b",data_received,expected_data);
            error_count = error_count + 1;
        end
    endtask : check_data
    
    function void print_test_results();
    	$display("********************** Test Complete **********************\n\n");
    	$display("    Successful Txns |   Failed Txns   |   Total Txns   \n");
    	$display("          %3d       |       %3d       |      %3d       \n", success_count, error_count, error_count+success_count );
    	if(error_count == 0) $display("Test completed with no errors! ");
    endfunction : print_test_results 

    function void print_test_header();
        $display("********************** UART_receiver Test **********************\n\n");
        $display("Test Bench Constant Values:");
        $display("BAUD_RATE                 = %0.2f", BAUD_RATE);
        $display("BAUD_RATE_KHZ             = %0.2f", BAUD_RATE_KHZ);
        $display("BAUD_HALF_PERIOD_NS       = %0.2f", BAUD_HALF_PERIOD_NS);
        $display("INPUT_CLK_KHZ             = %0.2f", INPUT_CLK_KHZ);
        $display("INPUT_CLK_HALF_PERIOD_NS  = %0.2f", INPUT_CLK_HALF_PERIOD_NS);
        $display("DUT Constant Values:");
        $display("INPUT_CLK_KHZ             = %0.2f", DUT.INPUT_CLK_KHZ);
        $display("BAUD_RATE                 = %0.2f", DUT.BAUD_RATE);
        $display("BAUD_RATE_KHZ             = %0.2f", DUT.BAUD_RATE_KHZ);
        $display("BAUD_COUNT                = %0.2f", DUT.BAUD_COUNT);

    endfunction : print_test_header
endmodule
