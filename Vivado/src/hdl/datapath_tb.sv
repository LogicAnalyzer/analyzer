`timescale 1ns / 1ps

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
fall = 5'b00000; rise = 4'b0000; div = 4; arm = 0; testdata = 0;
tick(3);
arm = 1;
tick(1);
arm = 0;
tick(3);
for (i = 0; i < 255; i = i + 1) begin
    testdata = i;
    tick(1);
end
fall = 8'b1111_1111; testdata = 0;
arm = 1; tick(6); arm = 0; tick (6);
testdata = 8'b1111_1111;
tick(10);
testdata = 8'b0;
tick(20);

end //end initial
endmodule
