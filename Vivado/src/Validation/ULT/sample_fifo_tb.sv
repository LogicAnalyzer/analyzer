`timescale 1ns / 1ps

module sample_fifo_tb(
    );
	
	localparam int MAX_ERROR = 15;
	localparam int FIFO_SIZE = 32768;
	
	localparam real INPUT_CLK_KHZ = 100_000;
	localparam real INPUT_CLK_HALF_PERIOD_NS = ( 10**6 )/( INPUT_CLK_KHZ * 2 );

	logic CLK, en, rnw, clear, reset_n;
	logic [7:0] data_in;
	logic full, empty;
	logic [7:0] data_out;

	int error_count,data_in_tb;
	int expected_data_q[$];

	int rand_rw;
	bit rw;
	string format_s;

	sample_fifo DUT(
		.clk(CLK), .en(en), .rnw(rnw),
		.clear(clear), .reset_n(reset_n),
		.data_in(data_in), .full(full),
		.empty(empty), .data_out(data_out)
    );

	initial forever begin
		#INPUT_CLK_HALF_PERIOD_NS CLK <= ~CLK;
	end

	initial forever begin
		@(posedge CLK)
		#1;
		if (full != fifo_is_full()) begin
			$sformat(	format_s,
						"Fifo full flag incorrect, Expected: %1b Received: %1b Queue size: %5d",
						fifo_is_full(), full, expected_data_q.size() );
			report_error(format_s);
		end
	end

	initial forever begin
		@(posedge CLK)
		#1;
		if (empty != fifo_is_empty()) begin
			$sformat(	format_s,
						"Fifo empty flag incorrect, Expected: %1b Received: %1b Queue size: %5d",
						fifo_is_empty(), empty, expected_data_q.size() );
			report_error(format_s);
		end
	end

	initial forever begin
		@(posedge CLK)
		if (rnw) begin
			if(data_out != expected_data_q[0])begin
				$sformat(format_s,"Incorrect data, Expected: %8b Received: %8b", expected_data_q[0],  data_out );
				report_error(format_s);
			end else begin
				$sformat(format_s,"Correct value received on read, Expected: %8b Received: %8b Queue size: %5d", 
					expected_data_q[0],  data_out, expected_data_q.size()  );
				report_info(format_s);
			end
			expected_data_q.pop_front();
		end
	end


	/*TESTBENCH*/
	initial begin 
		$srandom(10);
		initialize();
		reset_dut();
		while(1) begin
			rand_rw = ($urandom_range(100,1));
			data_in_tb = $urandom_range(255,0);
			if (rand_rw > 40) begin
				if (!fifo_is_full()) write();
			end else begin
				if(!fifo_is_empty()) read();
			end
		end
	end

	function void initialize ();
		
		CLK    	= 1'b0; 
		en     	= 1'b0; 
		rnw    	= 1'b0; 
		clear  	= 1'b0; 
		reset_n	= 1'b1;
		data_in	= 8'b0;

		error_count	=0;
		data_in_tb 	=0;
	endfunction : initialize

	task reset_dut();
		#5;
		reset_n = 1'b0;
		#10;
		reset_n = 1'b1;
		#5;	
	endtask : reset_dut

	task write();
		$sformat(format_s,"Writing value to FIFO, Data_written: %8b Queue size: %5d", 
			data_in_tb, expected_data_q.size()  );
		report_info(format_s);
		expected_data_q.push_back(data_in_tb);
		data_in = data_in_tb;
		en = 1'b1;
		rnw = 1'b0;
		@(posedge CLK);
		#0.5;
		en = 1'b0;
		#1;
	endtask : write

	task read();
		en = 1'b1;
		rnw = 1'b1;
		@(posedge CLK);
		#0.5;
		en = 1'b0;
		#1;
	endtask : read

	function bit fifo_is_full ();
		return expected_data_q.size() >= FIFO_SIZE;
	endfunction : fifo_is_full

	function bit fifo_is_empty ();
		return expected_data_q.size() == 0;
	endfunction : fifo_is_empty

	function void report_error (input string error_message);
		$timeformat(-9, 2, " ns", 0);
		$display("    Error (%t): %s",$time(),error_message );

		error_count = error_count+1;
		if(error_count > MAX_ERROR) begin
			$display("FATAL: Max errors reached");
			$finish;
		end
	endfunction : report_error 

	function void report_info(input string info_message);
		$timeformat(-9, 2, " ns", 0);
		$display("    Info (%t): %s",$time(),info_message );
	endfunction : report_info
endmodule