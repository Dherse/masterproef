from myhdl import *

@block
def nbit_adder(A, B, Cin, S, Cout):
    """ n-bit adder with carry in and carry out """
    @always_comb
    def logic():
        S.next = A + B + Cin
        Cout.next = (A + B + Cin) >> 4
    return logic