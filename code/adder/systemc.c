#include "systemc.h"

#define N 8

SC_MODULE(NBIT_ADDER) {
    sc_in<sc_lv<N> > a, b;
    sc_in<sc_logic> cin;
    sc_out<sc_lv<N> > sum;
    sc_out<sc_logic> cout;

    SC_CTOR(NBIT_ADDER) {
        SC_METHOD (process);
    }

    void process() {
        sc_lv<N> a_val = a.read();
        sc_lv<N> b_val = b.read();

        sc_lv<N> sum_val = a_val + b_val + cin.read();
        sum.write(sum_val);
        cout.write(sum_val[N-1]);
    }
};