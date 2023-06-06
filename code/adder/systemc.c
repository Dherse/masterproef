#include "systemc.h"

#ifndef N
    #define N 8
#endif

SC_MODULE (BIT_ADDER) {
    sc_in<sc_logic> a, b, cin;
    sc_out<sc_logic> sum,cout;

    SC_CTOR (BIT_ADDER)
	{
        SC_METHOD (process);
        sensitive << a << b << cin;
    }

    void process() {
        sc_logic aANDb, aXORb, cinANDaXORb;

        aANDb = a.read() & b.read();
        aXORb = a.read() ^ b.read();
        cinANDaXORb = cin.read() & aXORb;

        sum = aXORb ^ cin.read();
        cout = aANDb | cinANDaXORb;
    }
};

SC_MODULE (NBIT_ADDER) {
    sc_in<sc_lv<N> > a, b;
    sc_in<sc_logic> cin;
    sc_out<sc_lv<N> > sum;
    sc_out<sc_logic> cout;

    sc_signal<sc_logic> ss[N], cc[N];

    BIT_ADDER* add[N];

    SC_CTOR (NBIT_ADDER)
	{
        SC_METHOD (process);
    }

    void process() {
        int i = 0;
        for(i = 0; i < N; i++) {
            char name[25];
            sprintf(name, "add_%d", i);
            add[i] = new BIT_ADDER(name);

            if (i == 0) {
                add[i] << a[i] << b[i] << cin << sum[i] << cc[i + 1];
            } else if (i == N - 1) {
                add[i] << a[i] << b[i] << cc[i] << sum[i] << cout;
            } else {
                add[i] << a[i] << b[i] << cc[i] << sum[i] << cc[i + 1];
            }
        }
    }
};
