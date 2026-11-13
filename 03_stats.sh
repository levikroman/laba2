#!/usr/bin/env bash
set -e

run_stats() {
    local dir=$1
    /usr/bin/time --verbose "./$dir/prog" 1200 1 > /dev/null 2> "$dir/time.txt"
    perf stat -d "./$dir/prog" 1200 1 > /dev/null 2> "$dir/perf_stat.txt" || true
    perf record -F 999 -g -o "$dir/perf_report.data" -- "./$dir/prog" 1200 2 > /dev/null 2>&1 || \
    perf record -e cpu-clock -F 999 -g -o "$dir/perf_report.data" -- "./$dir/prog" 1200 2 > /dev/null 2>&1
    perf report -i "$dir/perf_report.data" --stdio > "$dir/perf_report.txt"

    {
        echo "=== TIME ==="
        cat "$dir/time.txt"
        echo ""
        echo "=== PERF STAT ==="
        cat "$dir/perf_stat.txt"
        echo ""
        echo "=== PERF REPORT ==="
        head -n 40 "$dir/perf_report.txt"
    } > "$dir/stats_all.txt"
}

run_stats "out/prog_O0"
run_stats "out/prog_O3"
run_stats "out/prog_O3_opt"

echo "Stats collected."