`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/10/2018 11:37:52 AM
// Design Name: 
// Module Name: FIFO
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


module FIFO(
	input logic clk, reset, clear, en, rnw, set_counters,
	input logic [7:0] read_count, delay_count,
	input logic data_valid,
	input logic [7:0] data_in
	output logic full, empty,
	output logic [7:0] data_out
    );

sample_fifo fifo ()





always_ff @(posedge clk or posedge reset) begin :
	if(reset) begin
		 read_count_reg <= 0;
		 delay_count_reg <= 0; 
		 //RESET FIFO
	end 
	if(set_counters) begin
		 read_count_reg <= {read_count, 2'b00};
		 delay_count_reg <= {delay_count,2'b00};
		 //CLEAR FIFO 
	end
		 
	end
end

endmodule
