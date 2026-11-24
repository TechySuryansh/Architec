"""Map both memory systems and collect timing and utilization for the same FPGA."""
import csv
import json
import shutil
import subprocess
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BUILD = ROOT / "build" / "fpga"
RESULTS = ROOT / "results" / "fpga"
SOURCES = " ".join(str(p.relative_to(ROOT)) for p in sorted((ROOT / "rtl").glob("*.v")))


def measure(name, shared):
    netlist = BUILD / f"{name}.json"
    report = BUILD / f"{name}-timing.json"
    flow = (f"read_verilog {SOURCES}; chparam -set SHARED_BUS {shared} memory_system; "
            f"synth_ice40 -top memory_system -json build/fpga/{netlist.name}; check -assert")
    # Run in the project root so the RTL's relative $readmemh paths resolve.
    subprocess.run(["yosys", "-Q", "-q", "-l", str(BUILD / f"{name}-synth.log"), "-p", flow],
                   cwd=ROOT, check=True)
    with (BUILD / f"{name}-route.log").open("w") as log:
        subprocess.run(["nextpnr-ice40", "--hx8k", "--package", "ct256",
                        "--freq", "25", "--seed", "1", "--pcf-allow-unconstrained",
                        "--json", str(netlist), "--report", str(report)],
                       cwd=ROOT, stdout=log, stderr=subprocess.STDOUT, check=True)
    timing = json.loads(report.read_text())
    clock, = timing["fmax"].values()
    usage = timing["utilization"]
    cells = json.loads(netlist.read_text())["modules"]["memory_system"]["cells"]
    counts = Counter(cell["type"] for cell in cells.values())
    return dict(design=name, lut4=counts["SB_LUT4"],
                flip_flops=sum(n for kind, n in counts.items() if kind.startswith("SB_DFF")),
                logic_cells=usage["ICESTORM_LC"]["used"], available_lc=usage["ICESTORM_LC"]["available"],
                ram_blocks=usage["ICESTORM_RAM"]["used"], target_mhz=clock["constraint"],
                fmax_mhz=round(clock["achieved"], 2))


if __name__ == "__main__":
    BUILD.mkdir(parents=True, exist_ok=True)
    RESULTS.mkdir(parents=True, exist_ok=True)
    rows = [measure("harvard", 0), measure("shared", 1)]
    for row in rows:
        name = row["design"]
        (RESULTS / f"{name}-timing.json").write_bytes((BUILD / f"{name}-timing.json").read_bytes())
    with (RESULTS / "summary.csv").open("w", newline="") as stream:
        writer = csv.DictWriter(stream, fieldnames=rows[0], lineterminator="\n")
        writer.writeheader()
        writer.writerows(rows)
    versions = [subprocess.check_output(cmd, stderr=subprocess.STDOUT, text=True).strip()
                for cmd in (["yosys", "-V"], ["nextpnr-ice40", "--version"])]
    router = Path(shutil.which("nextpnr-ice40")).resolve()
    if "Cellar" in router.parts:
        versions.append(f"Homebrew nextpnr-ice40 package {router.parent.parent.name}")
    (RESULTS / "tools.txt").write_text("\n".join(versions) + "\n")
    print((RESULTS / "summary.csv").read_text(), end="")
