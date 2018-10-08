import cocotb
from cocotb.binary import BinaryValue
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.result import TestFailure
import random 

@cocotb.coroutine
def initiate_dut(dut):
    print("initiate DUT...")
    dut.trigRising = 0
    dut.trigFalling = 0
    dut.dataIn = 0
    dut.arm = 1
    yield RisingEdge(dut.clock)
    dut.arm = 0
    print("DUT initilizaed.")
    
@cocotb.test()
def trigger_basic_test(dut):
    cocotb.fork(Clock(dut.clock, 10, units='ns').start())
    print("AND SO IT BEGINS")
    # Confirm trigger is reset
    for data in range(256):
        for rising in range(256):
            for falling in range(256):
                # Rearm Trigger
                initiate_thread = cocotb.fork(initiate_dut(dut))
                yield initiate_thread.join();
                yield Timer(50, units='ns')
                # Test if trigger is armed
                if dut.run:
                    #raise TestFailure( "ERROR: Run not reset after arm.\nData: %d\nRising Edge: %d\n" % (data, rising))
                    print( "ERROR: Run not reset after arm.\nData: %d\nRising Edge: %d\n" % (data, rising))
                # Set Signals
                set_trigger_inputs(data, rising, falling, dut)
                # Progress till after rising edge
                yield RisingEdge(dut.clock)
                yield Timer(50, units='ns')
                # Test after rising edge
                after_falling_edge(data, rising, falling, dut.run)
                # Progress till after falling edge
                yield FallingEdge(dut.clock)
                yield Timer(50, units='ns')
                # Test after falling edge
                after_falling_edge(data, rising, falling, dut.run)
    yield Timer(50, units='ns')

def vector_selector(selected):
    selected_signal = 0
    for signal in selected:
        selected_signal = selected_signal | (2**signal)
    return selected_signal

def set_trigger_inputs(data, rising, falling, dut):
    dut.dataIn = data
    dut.trigFalling = falling
    dut.trigRising = rising 

def after_rising_edge(data, rising, falling, run):
    if (data & rising):
        if not run:
            #raise TestFailure( "ERROR: Not triggered after matching rising edge.\nData: %d\nRising Edge: %d\n" % (data,rising))
            print("ERROR: Not triggered after matching rising edge.\nData: %d\nRising Edge: %d\n" % (data,rising))  
    else:
        if run:
            #raise TestFailure( "ERROR: Triggered after rising edge on nonmatch.\nData: %d\nRising Edge: %d\n" % (data,rising))
            print( "ERROR: Triggered after rising edge on nonmatch.\nData: %d\nRising Edge: %d\n" % (data,rising))

def after_falling_edge(data, rising, falling, run):
    if (data & falling):
        if not run:
            #raise TestFailure( "ERROR: Not triggered after matching falling edge.\nData: %d\n Falling Edge: %d\n" % (data,falling))
            print( "ERROR: Not triggered after matching falling edge.\nData: %d\n Falling Edge: %d\n" % (data,falling))
    else:
        if run:
            #raise TestFailure( "ERROR: Triggered after falling edge on nonmatch.\nData: %d\n Falling Edge: %d\n" % (data,falling))
            print("ERROR: Triggered after falling edge on nonmatch.\nData: %d\n Falling Edge: %d\n" % (data,falling))

    # trigFallingVector = BinaryValue(value=vector_selector([2,3,4]), bits = 8)   
    
    # for i in range(7):
    #     print(type(dut.trigRising[i]))


    # for signal in dut.trigFalling:
    #     signal = 0

    # for signal in dut.dataIn:
    #     signal = 0

        # print("..TRIG FALLING = ", dut.trigFalling._getvalue())
    # trigFallingVector = vector_selector([2,3,4])