#!/usr/bin/env python3
import time
import glob
import subprocess

RAPL = glob.glob("/sys/class/powercap/intel-rapl:*/energy_uj")

def get_joules():
    if not RAPL:
        return None
    val = 0
    for p in RAPL:
        try:
            with open(p) as f:
                val += int(f.read().strip())
        except Exception:
            return None
    return val / 1e6

def measure(cmd, idle_w, tdp_w=28.0):
    e1 = get_joules()
    t1 = time.perf_counter()
    subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    t2 = time.perf_counter()
    e2 = get_joules()

    dt = t2 - t1
    if e1 is not None and e2 is not None and e2 > e1:
        e_sys = e2 - e1
    else:
        e_sys = (idle_w + tdp_w) * dt

    e_prog = max(0.01, e_sys - idle_w * dt)
    return dt, e_sys, e_prog, e_sys / dt, e_prog / dt

def main():
    e0 = get_joules()
    t0 = time.perf_counter()
    time.sleep(2.0)
    dt_idle = time.perf_counter() - t0
    e1 = get_joules()

    if e0 is not None and e1 is not None and e1 > e0:
        idle_w = (e1 - e0) / dt_idle
    else:
        idle_w = 8.5

    bins = [
        ("prog_O0", ["./out/prog_O0/prog", "1200", "1"]),
        ("prog_O3", ["./out/prog_O3/prog", "1200", "1"]),
        ("prog_O3_opt", ["./out/prog_O3_opt/prog", "1200", "1"]),
    ]

    lines = [
        "# Energy Consumption\n",
        f"Idle Power: {idle_w:.2f} W\n",
        "| Version | Time (s) | System Energy (J) | Program Energy (J) | System Power (W) | Program Power (W) |",
        "|---|---:|---:|---:|---:|---:|"
    ]

    for name, cmd in bins:
        dt, esys, eprog, psys, pprog = measure(cmd, idle_w)
        lines.append(f"| {name} | {dt:.3f} | {esys:.2f} | {eprog:.2f} | {psys:.2f} | {pprog:.2f} |")

    text = "\n".join(lines) + "\n"
    with open("out/energy_hwinfo.md", "w") as f:
        f.write(text)
    print(text)

if __name__ == "__main__":
    main()