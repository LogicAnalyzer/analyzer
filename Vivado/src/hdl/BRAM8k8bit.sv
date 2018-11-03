`timescale 1ns / 1ps
module BRAM8k8bit(
    input CLK, WE, EN,
    input [12:0] ADDR,
    input [7:0] DIN,
    output reg [7:0] DOUT
);

    wire [7:0] ram0_DOUT, ram1_DOUT, ram2_DOUT, ram3_DOUT;

    reg [3:0] ram_EN;
    always@(*)
    begin
        #1;
        ram_EN = 0;
        ram_EN[ADDR[12:11]] = EN;
    end

    reg [1:0] dly_ADDR, next_dly_ADDR;
    always@(posedge CLK)
    begin
        dly_ADDR = next_dly_ADDR;
    end

    always@(*)
    begin
        #1;
        next_dly_ADDR = ADDR[12:11];
    end

    always@(*)
    begin
        #1;
        DOUT = 8'h0;
        case (dly_ADDR)
            2'h0 : begin DOUT = ram0_DOUT; end
            2'h1 : begin DOUT = ram1_DOUT; end
            2'h2 : begin DOUT = ram2_DOUT; end
            2'h3 : begin DOUT = ram3_DOUT; end
        endcase
    end


    //
    // Instantiate the 2Kx8 RAM's...
    //
    BRAM2K8bit ram0 (
        .CLK(CLK),
        .EN(ram_EN[0]),
        .WE(WE), 
        .ADDR(ADDR[10:0]),
        .data_in(DIN),
        .data_out(ram0_DOUT));

    BRAM2K8bit ram1 (
        .CLK(CLK),
        .EN(ram_EN[1]),
        .WE(WE),
        .ADDR(ADDR[10:0]),
        .data_in(DIN),
        .data_out(ram1_DOUT));

    BRAM2K8bit ram2 (
        .CLK(CLK),
        .EN(ram_EN[2]),
        .WE(WE),
        .ADDR(ADDR[10:0]),
        .data_in(DIN),
        .data_out(ram2_DOUT));
    BRAM2K8bit ram3 (
        .CLK(CLK),
        .EN(ram_EN[3]),
        .WE(WE),
        .ADDR(ADDR[10:0]),
        .data_in(DIN),
        .data_out(ram3_DOUT));

endmodule

