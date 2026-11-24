"""Render the archived synthesis measurements as the report's LaTeX table."""
import csv
from pathlib import Path

root = Path(__file__).resolve().parents[1]
with (root / "results/fpga/summary.csv").open() as stream:
    rows = {row["design"]: row for row in csv.DictReader(stream)}

metrics = [("Mapped LUT4s", "lut4"), ("Mapped flip-flops", "flip_flops"),
           ("Packed logic cells", "logic_cells"), ("Embedded RAM blocks", "ram_blocks"),
           ("Clock target (MHz)", "target_mhz"), ("Estimated Fmax (MHz)", "fmax_mhz")]
print(r"\begin{table}[ht]\centering\caption{Mapped resources and post-route timing.}")
print(r"\begin{tabular}{lrr}\hline Metric & Harvard & Shared \\ \hline")
for label, key in metrics:
    print(label, "&", rows["harvard"][key], "&", rows["shared"][key], r"\\")
print(r"\hline\end{tabular}\end{table}")
