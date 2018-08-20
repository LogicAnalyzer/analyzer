<!--- Adapated from FPGAdeveloper article
http://www.fpgadeveloper.com/2014/08/version-control-for-vivado-projects.html
-->

# How to use this folder #

This is the folder with all of the source files necessary to build using Vivado. 

Place all HDL files into the `src/hdl` directory. If there is a particular block diagram
that you would like to generate, the TCL script needs to go into the `src/bd` directory.

To build, run the `build.py` script. It should work for both Windows and Linux. It requires
python 3 to installed.

# What files to commit to version control #

In general, don’t commit anything within the project sub-folder that was created by Vivado.
You want to keep ALL controlled sources including scripts out of that folder.

> 1. Commit `build.tcl` to version control.
> 2. Commit `src/bd/design_1.tcl`
> 3. If you added any other sources to the design such as VHDL or Verilog files, make sure they are located in the “src/hdl” folder and commit these as well.
> 4. If you created custom IP, you can commit all the files in the IP repository (`ip_repo`). The `ip_repo` folder should be at the same level as your `src` folder.

# Dealing with modifications #

When you make modifications to the project using the GUI, always remember to save them by using the `Tools->Write Project Tcl` and `File->Export->Export block design` options.

