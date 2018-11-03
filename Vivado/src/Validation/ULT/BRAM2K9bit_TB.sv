`timescale 1ns / 1ps

module BRAM2K9bit_TB(
    );

	logic CLK, EN, WE;
	logic [10:0] ADDR;
	logic [7:0] data_in;
	logic [7:0] data_out;

	integer tb_data_in, tb_addr;

    localparam real INPUT_CLK_KHZ = 100_000;
    localparam real INPUT_CLK_HALF_PERIOD_NS = ( 10**6 )/( INPUT_CLK_KHZ * 2 );

	BRAM2K9bit DUT(
		.CLK(CLK), .EN(EN), .WE(WE),
		.ADDR(ADDR),
		.data_in(data_in),
		.data_out(data_out)
	);

	initial forever begin
		#INPUT_CLK_HALF_PERIOD_NS CLK <= ~CLK;
	end

	initial begin
		initialize();
		while(1)
		begin
			tb_data_in = $random();
			tb_addr = $random();

			ADDR = tb_addr;
			data_in = tb_data_in;

			write();
			read();
		end
	end

    function void initialize ();
    	CLK			=0;
    	EN			=0;
    	WE			=0;
    	ADDR		=0;
    	data_in		=0;
    	tb_data_in 	=0;
    	tb_addr		=0;
    endfunction : initialize

    task write();
    	EN = 1;
    	WE = 1;
    	@(posedge CLK);
    	@(negedge CLK);
    	EN = 0;
    	WE = 0; #1;
    endtask : write

    task read();
    	EN = 1;
    	@(posedge CLK);
    	@(negedge CLK);
    	EN = 0; #1;
    endtask : read








endmodule
