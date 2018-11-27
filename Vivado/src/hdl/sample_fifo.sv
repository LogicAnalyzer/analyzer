`timescale 1ns / 1ps

module sample_fifo(
	input clk, en, rnw, clear, hold_window, reset_n,
	input [7:0] data_in,
	output full, empty, reg data_valid,
	output reg [7:0] data_out
    );
	
	reg  [15:0] wr_pointer, rd_pointer;
	reg  [14:0] out_pointer;
	reg  [3:0]  ram_EN;
	reg  [1:0]	reg_sel_q;
	wire [7:0]	data_out_0;
	wire [7:0]	data_out_1;
	wire [7:0]	data_out_2;
	wire [7:0]	data_out_3;

	assign full = ((wr_pointer[14:0] == rd_pointer[14:0]) && (wr_pointer[15]^rd_pointer[15]));
	assign empty = (wr_pointer == rd_pointer);

	assign out_pointer = rnw ? rd_pointer : wr_pointer;

	always@(*) begin
	    ram_EN = 0;
	    ram_EN[out_pointer[14:13]] = en;
	end

	/* RAM selector Logic */
	always@(posedge clk) reg_sel_q<=out_pointer[14:13];
	always@(*) begin
		case({data_valid,reg_sel_q})
			3'b100: data_out = data_out_0;
			3'b101: data_out = data_out_1;
			3'b110: data_out = data_out_2;
			3'b111: data_out = data_out_3;
			default: data_out = 8'b0;
		endcase
	end

	/* Pointer increment logic */
	initial begin
		wr_pointer = 16'b0;
		rd_pointer = 16'b0;
	end
	always@(posedge clk) begin 
		if (!reset_n | clear)begin 
			wr_pointer <= 0;
			rd_pointer <= 0;
		end
		else if(en) begin 
			if(rnw) rd_pointer <= rd_pointer + 1;
			else begin 
				if(hold_window) rd_pointer <= rd_pointer + 1;
				wr_pointer <= wr_pointer + 1;
            end
		end else begin
			rd_pointer <= rd_pointer;
			wr_pointer <= wr_pointer;
		end
	end

	/* Valid Data Logic */
	always_ff @(posedge clk) begin : proc_data_valid
		if(!reset_n) begin
			data_valid <= 0;
		end else begin
			data_valid <= (~empty & rnw & en);
		end
	end

	BRAM8k8bit ram0(
	    .CLK(clk), .WE(~rnw), .EN(ram_EN[0]),
	    .ADDR(out_pointer[12:0]),
	    .DIN(data_in),
	    .DOUT(data_out_0)
	);

	BRAM8k8bit ram1(
	    .CLK(clk), .WE(~rnw), .EN(ram_EN[1]),
	    .ADDR(out_pointer[12:0]),
	    .DIN(data_in),
	    .DOUT(data_out_1)
	);

	BRAM8k8bit ram2(
	    .CLK(clk), .WE(~rnw), .EN(ram_EN[2]),
	    .ADDR(out_pointer[12:0]),
	    .DIN(data_in),
	    .DOUT(data_out_2)
	);

	BRAM8k8bit ram3(
	    .CLK(clk), .WE(~rnw), .EN(ram_EN[3]),
	    .ADDR(out_pointer[12:0]),
	    .DIN(data_in),
	    .DOUT(data_out_3)
	);
endmodule
