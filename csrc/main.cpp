#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "Vexample.h"
#include "verilated.h"

int main(int argc, char** argv) {
	VerilatedContext* contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);
    contextp->traceEverOn(true);

    Vexample top;

    while (contextp->time() < 12) {
        top.a = rand() & 1;
        top.b = rand() & 1;

        top.eval();

        printf("a = %d, b = %d, f = %d\n",
               top.a, top.b, top.f);

        assert(top.f == (top.a ^ top.b));
        contextp->timeInc(1);
    }

    top.eval();
    top.final();
    return 0;
}

