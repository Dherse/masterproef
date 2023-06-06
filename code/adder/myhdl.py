from myhdl import *

@block
def bit_adder(A, B, Cin, S, Cout):
    """ 1-bit adder with carry in and carry out """
    @always_comb
    def logic():
        S.next = A ^ B ^ Cin
        Cout.next = (A & B) | (A & Cin) | (B & Cin)

    return logic

@block
def nbit_adder(A, B, Cin, S, Cout):
    """ n-bit adder with carry in and carry out """
    @always_comb
    def logic():
        Carries = [Signal(bool(0)) for i in range(len(A))]
        Carries[0].next = Cin
        for i in range(len(A)):
            if i == len(A) - 1:
                bit_adder(A[i], B[i], Carries[i], S[i], Cout)
            else:
                bit_adder(A[i], B[i], Carries[i], S[i], Carries[i + 1])
    return logic