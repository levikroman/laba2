#!/usr/bin/env bash
set -e

mkdir -p out/prog_O0 out/prog_O3 out/prog_O3_opt
FLAGS="-g -fno-omit-frame-pointer -Wall"

gcc $FLAGS -O0 prog.c -o out/prog_O0/prog
gcc -S -O0 prog.c -o out/prog_O0/asm_mult_ijk.txt
gcc -S -O0 -DUSE_OPT_IKJ prog.c -o out/prog_O0/asm_mult_ikj.txt

gcc $FLAGS -O3 -march=native prog.c -o out/prog_O3/prog
gcc -S -O3 -march=native prog.c -o out/prog_O3/asm_mult_ijk.txt
gcc -S -O3 -march=native -DUSE_OPT_IKJ prog.c -o out/prog_O3/asm_mult_ikj.txt

gcc $FLAGS -O3 -march=native -DUSE_OPT_IKJ prog.c -o out/prog_O3_opt/prog
gcc -S -O3 -march=native prog.c -o out/prog_O3_opt/asm_mult_ijk.txt
gcc -S -O3 -march=native -DUSE_OPT_IKJ prog.c -o out/prog_O3_opt/asm_mult_ikj.txt

echo "Build done."