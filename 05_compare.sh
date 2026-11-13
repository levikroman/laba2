#!/usr/bin/env bash
set -e

echo "=== ASM (O0 vs O3_opt) ==="
grep -E "movsd|mulsd|addsd" out/prog_O0/asm_mult_ijk.txt | head -n 5 || true
echo "---"
grep -E "vmulpd|vaddpd|vfmadd|vbroadcastsd|%ymm" out/prog_O3_opt/asm_mult_ikj.txt | head -n 8 || true

echo ""
echo "=== TIME ==="
for d in prog_O0 prog_O3 prog_O3_opt; do
    echo "[$d]"
    grep -E "User time|Elapsed|Maximum resident" "out/$d/time.txt"
done

echo ""
echo "=== PERF STAT ==="
for d in prog_O0 prog_O3 prog_O3_opt; do
    echo "[$d]"
    grep -E "instructions|cycles|cpu-clock|task-clock|L1-dcache|LLC|seconds time elapsed" "out/$d/perf_stat.txt" || true
done

echo ""
cat out/energy_hwinfo.md