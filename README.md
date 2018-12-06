# FPGA_Logic_Analyzer
An FPGA based Logic Analyzer project

# How to Build FPGA Bitstream #

You will need to have Xilinx Vivado Installed.

1. Clone [this](https://github.com/LogicAnalyzer/analyzer) github repository
2. Create a new project in Xilinx Vivado and import the source files located in **analyzer/Vivado/src/hdl**
3. Set `ACSP_top` as the top level module
4. Generate the bitstream
5. Upload bitstream to Digilent Nexys 4 DDR

OR

1. Download the release bitstream and install via Vivado or through a SD card.


# How to build sigrok #

You will need to install all of the dependecies of the sigrok project before building.

1. Clone [this](https://github.com/LogicAnalyzer/sigrok-util) git repository
2. Run the build script located at **sigrok-util/cross-compile/linux/sigrok-cross-linux**
3. Run the executable located at **sigrok-util/cross-compile/linux/sigrok-cross-linux/build/pulseview/build/pulsebiew**
