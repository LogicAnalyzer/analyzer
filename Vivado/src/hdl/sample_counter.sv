`timescale 1ns / 1ps

module sample_counter #(parameter CNT_BITS=16)(
	input reset_n, clk, en_cnt, clr_cnt, wr_en,
	input [CNT_BITS-1:0] read_reg_in, delay_reg_in,
	output read_match, delay_match,
	output [CNT_BITS-1:0] read_reg_out, delay_reg_out
	);
	logic [CNT_BITS-1:0] read_reg, delay_reg, count;

	/* Register Logic*/
	assign read_reg_out = read_reg;
	assign delay_reg_out = delay_reg;
	always@(posedge clk)begin
		if(!reset_n)begin
			read_reg <= 0;
			delay_reg <= 0;
		end else begin
			if(wr_en)begin
				read_reg <= read_reg_in;
				delay_reg <= delay_reg_in;
			end else begin
				read_reg <= read_reg;
				delay_reg <= delay_reg;
			end
		end
	end

	/* Counter Logic */
	always@(posedge clk)begin 
		if(!reset_n)begin
			count <= 0;
		end else begin 
			if(clr_cnt) begin
				count <= 0;
			end else begin
				if(en_cnt) begin
					count <= count + 1;
				end else begin
					count <= count;
				end
			end
		end
	end

	/* Match Logic */
	assign delay_match = (count == delay_reg); 
	assign read_match = (count == read_reg); 


endmodule // sample_counter