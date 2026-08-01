#!/bin/bash

if [ -n "${1:-}" ]; then
    set -euo pipefail

    cat start.s $1 > tmp_test6.s
    rm $1
    mv tmp_test6.s $1

    sed -i '/rv32i2p0_m2p0/s/.*/''/' $1
    sed -i '/option nopic/s/.*/''/' $1
    sed -i '/space 8192/c\.space 8192' $1
else
    set -euo pipefail

    cat start.s test6.s > tmp_test6.s
    rm test6.s
    mv tmp_test6.s test6.s

    sed -i '/rv32i2p0_m2p0/s/.*/''/' test6.s
    sed -i '/option nopic/s/.*/''/' test6.s
    sed -i '/space 8192/c\.space 8192' test6.s
fi



