#!/usr/bin/env bash
set -e

sudo apt-get update
sudo apt-get install -y build-essential time git perl python3 \
    linux-tools-common linux-tools-generic || true

if ! perf --version >/dev/null 2>&1; then
    PERF_BIN=$(find /usr/lib/linux-tools* -name "perf" 2>/dev/null | head -n 1 || true)
    if [ -n "$PERF_BIN" ]; then
        sudo ln -sf "$PERF_BIN" /usr/local/bin/perf
    fi
fi

if [ ! -d "FlameGraph" ]; then
    git clone https://github.com/brendangregg/FlameGraph.git
fi

sudo sysctl -w kernel.perf_event_paranoid=-1 || true
sudo sysctl -w kernel.kptr_restrict=0 || true

if [ -d /sys/class/powercap/intel-rapl ]; then
    sudo chmod -R a+r /sys/class/powercap/intel-rapl* || true
fi

mkdir -p out/prog_O0 out/prog_O3 out/prog_O3_opt
echo "Setup done."