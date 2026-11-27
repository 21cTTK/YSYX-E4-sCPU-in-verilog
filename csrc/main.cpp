#include "VsCPU.h"
#include <nvboard.h>
#include <chrono>
#include <thread>

void nvboard_bind_all_pins(VsCPU* top);

static void cycle(VsCPU& top) {
    top.clk = 0;
    top.eval();
    top.clk = 1;
    top.eval();
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    VsCPU top;
    top.en = 0;
    top.btn = 0;
    top.dpsw = 0;
    top.arst = 1;
    cycle(top);
    top.arst = 0;
    top.eval();

    nvboard_bind_all_pins(&top);
    nvboard_init();
    while (true) {
        std::this_thread::sleep_for(std::chrono::milliseconds(17));
        if (!nvboard_update()) break;
        cycle(top);
    }
    top.final();
    nvboard_quit();
    return 0;
}
