module BRAM4K9bit(
	input CLK, EN, WE,
	input [10:0] ADDR,
	input [7:0] data_in,
	output reg [7:0] data_out
);
	reg [7:0] mem[0:2047];

	/** Delay Wires For Simulation **/
	wire [10:0] #1 dly_ADDR = ADDR;
	wire [7:0] #1 dly_DATA = data_in;
	wire #1 dly_EN = EN;
	wire #1 dly_WE = WE;

	reg sampled_EN;
	reg [7:0] rddata;

	/* 
	 * Initialize Registers to Alternating 
	 * Pattern for Simulation and Verification
 	 */
	integer i;
	initial
	begin
		for (i=0; i<2048; i=i+1) mem[i] = 8'h5A;
	end

	always @(posedge CLK)
	begin
		if (dly_EN && dly_WE) mem[dly_ADDR] = dly_DATA;
		rddata = mem[dly_ADDR];
		sampled_EN = dly_EN;
		#1;
		if (sampled_EN) data_out = rddata; 
	end
endmodule