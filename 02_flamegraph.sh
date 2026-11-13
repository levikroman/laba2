#!/usr/bin/env bash
set -e

FG="./FlameGraph"

run_fg() {
    local dir=$1
    local rep=$2
    perf record -F 999 -g --call-graph dwarf -o "$dir/perf.data" -- "./$dir/prog" 1200 "$rep" > /dev/null 2>&1 || \
    perf record -e cpu-clock -F 999 -g --call-graph dwarf -o "$dir/perf.data" -- "./$dir/prog" 1200 "$rep" > /dev/null 2>&1
    perf script -i "$dir/perf.data" > "$dir/out.perf"
    "$FG/stackcollapse-perf.pl" "$dir/out.perf" > "$dir/out.folded"
    "$FG/flamegraph.pl" "$dir/out.folded" > "$dir/flame.svg"
}

run_fg "out/prog_O0" 1
run_fg "out/prog_O3" 2
run_fg "out/prog_O3_opt" 15

"$FG/difffolded.pl" out/prog_O3/out.folded out/prog_O3_opt/out.folded | \
    "$FG/flamegraph.pl" --negate > out/diff_O3_vs_opt.svg

echo "FlameGraphs generated."