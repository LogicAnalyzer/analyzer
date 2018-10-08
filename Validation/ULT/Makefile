PWD=$(shell pwd)

WPWD=$(shell pwd)

export COCOTB_REDUCED_LOG_FMT=1

VERILOG_SOURCES = $(WPWD)/../../Design/trigger_basic.sv

TOPLEVEL := trigger_basic
MODULE   := trigger_basic_tb

include $(COCOTB)/makefiles/Makefile.inc
include $(COCOTB)/makefiles/Makefile.sim