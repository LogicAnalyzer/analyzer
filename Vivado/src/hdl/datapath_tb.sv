`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/21/2018 05:40:15 PM
// Design Name: 
// Module Name: datapath_tb
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


module datapath_tb();

reg clock, arm;
reg [7:0] testdata, fall, rise;
reg [23:0] div;
wire [7:0] dataSamplerToFIFO;
wire datavalid, run;

reg [7:0] i;

ACSP_top DUT(
    .system_clock(clock),
    .dataToSample(testdata),
    .fallPattern(fall),
    .risePattern(rise),
    .divider(div),
    .edge_capture(1),
    .arm(arm),
    .run(run),
    .dataSamplerToFIFO(dataSamplerToFIFO),
    .dataValidToFIFO(datavalid)    
);

task tick;
input [7:0] numberofticks;
begin
  for (int i = numberofticks ;i > 0;  i = i - 1) begin
  #1; clock = 1; #1; clock = 0; #1;
      end
  end
endtask

initial begin
fall = 5'b00001; rise = 4'b000; div = 0; arm = 4; testdata = 0;
tick(3);
arm = 1;
tick(1);
arm = 0;
tick(3);
for (i = 0; i < 255; i = i + 1) begin
    testdata = i;
    tick(1);
end


end //end initial
endmodule
