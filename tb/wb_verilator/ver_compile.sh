#!/bin/sh
set -e

verilator --cc -Wno-fatal --trace -Mdir obj_dir -public -I../../rtl/uart ../../rtl/uart/uart_device.sv

cd obj_dir

make -f Vuart_device.mk