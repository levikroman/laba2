#!/usr/bin/env python3
import sys
import time
import subprocess

if len(sys.argv) < 2:
    print("Usage: python3 loop_run.py <binary_path> [seconds]")
    sys.exit(1)

binary = sys.argv[1]
duration = float(sys.argv[2]) if len(sys.argv) > 2 else 15.0

t_end = time.time() + duration
runs = 0

while time.time() < t_end:
    subprocess.run([binary, "1200", "1"], stdout=subprocess.DEVNULL)
    runs += 1

print(f"Completed {runs} runs in {duration}s")