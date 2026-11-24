# Live demonstration

From the repository root, have Make, Python 3, Icarus Verilog and its vvp runtime on PATH. Allow about four minutes. The simulation runs entirely on the host.

1. **Show the two memory paths.** Open the [diagram](figures/architecture.png). Follow PC to the Harvard instruction ROM and the operand address to data memory. In the baseline, point out where the decoder selects the address for the one shared port.
2. **Execute the program.** Run `make demo`. Read cycle 2 in the Harvard F/R/W column: fetch and read are both 1. In cycle 3 fetch and write are both 1. The shared machine gives the port to data in cycles 2 and 4 and holds PC. Both copy 7 into data[1].
3. **Inspect the trace.** Open `results/demo.vcd` in GTKWave, expand `tb_memory_compare`, and add clk, h_fetch, h_read, h_write, s_fetch, s_read and s_write. Zoom to fit and inspect the enables immediately before rising edges after reset release. The [waveform figure](figures/waveforms.png) shows the same six cycles from the pre-edge CSV samples.
4. **Explain performance.** Count from first fetch through HALT. Four versus six cycles at a common clock gives 1.5× speedup. Run `make test` and point to the no-data case: both finish in four cycles. Show the six-scenario pass line.
5. **Show FPGA evidence.** Run `make synth` with Yosys and nextpnr-ice40 installed, or open the [saved summary](../results/fpga/summary.csv) and [tool versions](../results/fpga/tools.txt). Compare packed logic cells and routed Fmax. These estimates use automatic pins, one placement seed and the supplied program. The 10 ns simulation period is independent of the 25 MHz routing target.
