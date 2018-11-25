`timescale 1ns / 1ps

module command_decoder(
    input  logic clock, reset_n, byte_in_ready,
    input  logic [7:0] byte_in,
    output logic cmd_recieved,
    output logic [7:0] opcode,
    output logic [31:0] command
);
	typedef enum {IDLE, CHK_OP, WR_BYTE, WR_WAIT, DONE} command_state;

	logic cmd_we, clr, op_we, cmd_done, done;
	logic [7:0] current_opcode;
	logic [31:0] current_command;
	command_state NS, CS;

	command_shift command_shift_i
	(
		.clock(clock), .we(cmd_we), 
		.reset_n(reset_n), .clr(clr),
		.byte_in(byte_in), .done(cmd_done),
		.command(current_command)
	);

	always_ff @(posedge clock)begin
		if(!reset_n) begin
			command <= 0;
			opcode <= 0;
		end else if(done)begin
			command <= current_command;
			opcode <= current_opcode;
		end else begin
			command <= command;
			opcode <= opcode;			
		end
    end

	always_ff @(posedge clock)begin 
		if(!reset_n)begin
			CS <= IDLE;
		end else begin
			CS <= NS;
		end
	end

	always_ff @(posedge clock) begin : proc_cmd
		if(!reset_n) begin
			current_opcode <= 0;
		end else if (clr) begin
			current_opcode <= 0;
		end else if (op_we) begin
			current_opcode <= byte_in;
		end else begin
			current_opcode <= current_opcode;
		end
	end

	always_comb begin
		case(CS)
			IDLE:
			begin 
				if(byte_in_ready)begin
					cmd_we = 0;
					clr = 0;
					op_we = 1;
					done = 0;
					cmd_recieved = 0;
					NS = CHK_OP;
				end else begin
					cmd_we = 0;
					clr = 1;
					op_we = 0;
					done = 0;
					cmd_recieved = 0;
					NS = IDLE;
				end
			end
			CHK_OP:
			begin 
				if(byte_in_ready)begin // wait for ready to clear
					cmd_we = 0;
					clr = 0;
					op_we = 0;
					done = 0;
					cmd_recieved = 0;
					NS = CHK_OP;
				end else begin
					if(current_opcode[7])begin // long command
						cmd_we = 0;
						clr = 0;
						op_we = 0;
						done = 0;
						cmd_recieved = 0;
						NS = WR_BYTE;
					end else begin // short command
						cmd_we = 0;
						clr = 0;
						op_we = 0;
						done = 1;
						cmd_recieved = 0;
						NS = DONE;
					end
				end
			end
			WR_BYTE:
			begin 
				if(byte_in_ready)begin
					cmd_we = 1;
					clr = 0;
					op_we = 0;
					done = 0;
					cmd_recieved = 0;
					NS = WR_WAIT;
				end else begin
					cmd_we = 0;
					clr = 0;
					op_we = 0;
					done = 0;
					cmd_recieved = 0;
					NS = WR_BYTE;
				end
			end
			WR_WAIT:
			begin 
				if (cmd_done) begin
					cmd_we = 0;
					clr = 0;
					op_we = 0;
					done = 1;
					cmd_recieved = 0;
					NS = DONE;
				end
				else if(byte_in_ready)begin
					cmd_we = 0;
					clr = 0;
					op_we = 0;
					done = 0;
					cmd_recieved = 0;
					NS = WR_WAIT;
				end else begin
					cmd_we = 0;
					clr = 0;
					op_we = 0;
					done = 0;
					cmd_recieved = 0;
					NS = WR_BYTE;
				end
			end
			DONE:
			begin 
				cmd_we = 0;
				clr = 1;
				op_we = 0;
				done = 0;
				cmd_recieved = 1;
				NS = IDLE;
			end
			default:
			begin 
				cmd_we = 0;
				clr = 1;
				op_we = 0;
				done = 0;
				cmd_recieved = 0;
				NS = IDLE;
			end
	   endcase
    end
endmodule // command_decoder

module command_shift
	(
		input logic clock, we, reset_n, clr,
		input logic [7:0] byte_in,
		output logic done,
		output logic [31:0] command
	);
	logic [2:0] counter;
	logic [7:0] cmd_ary [0:3];

	assign command [7:0] = cmd_ary[3];
	assign command [15:8] = cmd_ary[2];
	assign command [23:16] = cmd_ary[1];
	assign command [31:24] = cmd_ary[0];

	assign done = counter[2];

	always_ff @(posedge clock)begin
		if(!reset_n)begin
		    for(int i =0; i<4; i=i+1)cmd_ary[i]<=0;
			counter <= 0;
		end else if(clr) begin
		    for(int i =0; i<4; i=i+1)cmd_ary[i]<=0;
			counter <= 0;
		end else if (we) begin
			cmd_ary [counter] <= byte_in;
			counter <= counter + 1;
		end else begin
			cmd_ary <= cmd_ary;
			counter <= counter;
		end
	end
endmodule // command_shift