module sample_counter #(parameter CNT_BITS=8)(
	input rst_n, clk, en_cnt, clr_cnt, wr_en, reg_sel,
	input [CNT_BITS-1:0] reg_in,
	output read_match, delay_match,
	output [CNT_BITS-1:0] reg_out
	);
	logic [CNT_BITS-1:0] read_reg, delay_reg, count;

	/* Register Logic*/
	assign reg_out = reg_sel ? read_reg : delay_reg;
	always@(posedge clk)begin
		if(!rst_n)begin
			read_reg <= 0;
			delay_reg <= 0;
		end else begin
			if(wr_en)begin
				if(reg_sel)begin
					read_reg <= reg_in;
					delay_reg <= delay_reg;
				end else begin
					read_reg <= read_reg;
					delay_reg <= reg_in;
				end
			end else begin
				read_reg <= read_reg;
				delay_reg <= delay_reg;
			end
		end
	end

	/* Counter Logic */
	always@(posedge clk)begin 
		if(!rst_n)begin
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