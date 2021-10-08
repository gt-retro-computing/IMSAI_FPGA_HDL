//
// Created by devbox on 10/5/2021.
//

#include "Vuart_device.h"
#include <verilated.h>
#include "testbench.h"

int main(int argc, char** argv) {

    Verilated::commandArgs(argc, argv);
    auto *tb = new TESTBENCH<Vuart_device>();
    tb->opentrace("trace.vcd");

    tb->tick();
    tb->reset();
    tb->tick();
    tb->m_core->i_wb_cyc = 1;
    tb->m_core->i_wb_stb = 1;
    tb->m_core->i_wb_addr = 2;
    tb->tick();
    tb->m_core->i_wb_cyc = 0;
    tb->m_core->i_wb_stb = 0;
    tb->m_core->i_wb_addr = 0;
    tb->tick();

    return 0;
}