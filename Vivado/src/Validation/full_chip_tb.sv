`timescale 1ns / 1ps

module full_chip_tb(
    );
	parameter signal_count =8;
	parameter MAX_UP_CNT = 150;
	parameter MAX_DWN_CNT =50;
	logic [signal_count-1:0] input_signals;
	logic input_clk, baud_clock, device_clk;
	integer signal_hold[signal_count];

	localparam real BAUD_RATE = 9600;
    localparam real BAUD_RATE_KHZ = BAUD_RATE / 1000;
    localparam real BAUD_HALF_PERIOD_NS = ( 10**6 )/( BAUD_RATE_KHZ * 2 ) ;

    localparam real INPUT_CLK_KHZ = 100_000;
    localparam real INPUT_CLK_HALF_PERIOD_NS = ( 10**6 )/( INPUT_CLK_KHZ * 2 );

    localparam real DEVICE_CLK_KHZ = 100_000;
    localparam real DEVICE_CLK_HALF_PERIOD_NS = ( 10**6 )/( DEVICE_CLK_KHZ * 2 );

	initial forever begin
		#INPUT_CLK_HALF_PERIOD_NS input_clk <= ~input_clk;
	end
	initial forever begin
		#BAUD_HALF_PERIOD_NS baud_clock <= ~baud_clock;
	end
	initial forever begin
		#DEVICE_CLK_HALF_PERIOD_NS device_clk <= ~device_clk;
	end

	initial forever begin
		@(posedge device_clk);
		for(integer signal =0; signal<signal_count; signal=signal+1)begin
			signal_hold[signal]=signal_hold[signal] -1;
			if(signal_hold[signal]<= 0) begin
				signal_hold[signal] = $urandom_range(MAX_DWN_CNT,MAX_UP_CNT);
				input_signals[signal] = !input_signals[signal];
			end
		end
	end

	initial begin
		initialize();
		#50;
		#50;
		#50;
		#50;
	end

	task initialize();
		input_signals = 0;
		input_clk = 0;
		baud_clock = 0;
		device_clk = 0;
		for(integer i =0; i<signal_count; i=i+1)begin
			signal_hold[i]=0;
		end
	endtask : initialize
endmodule
