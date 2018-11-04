`timescale 1ns / 1ps
module BRAM2K8bit(
	input CLK, EN, WE,
	input [10:0] ADDR,
	input [7:0] data_in,
	output reg [7:0] data_out
);
	reg [7:0] mem[0:2047];

	/** Delay Wires For Simulation **/
	wire [10:0] dly_ADDR = ADDR;
	wire [7:0] dly_DATA = data_in;
	wire dly_EN = EN;
	wire dly_WE = WE;

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
		if (sampled_EN) data_out = rddata; 
	end
endmodule