# Check against the supplied project brief

The scope is a **small Verilog Harvard memory organization, a simple controller, and a shared single-port comparison**. The short program is `LOAD 0; STORE 1; HALT`. It copies one byte and exposes the required simultaneous access opportunity.

## Technical requirements

| Requested item | Evidence in this project |
| --- | --- |
| Separate instruction and data paths | `rtl/memory_system.v` instantiates independent instruction and data memories in Harvard mode |
| Simple processor or controller | `rtl/simple_controller.v`: PC, one instruction register, one accumulator, and memory controls |
| Program counter | `rtl/program_counter.v`; tests check advance on fetch and hold during a blocked fetch |
| Instruction memory | `rtl/instruction_memory.v`; 16 x 8 bits, loaded from the program hex file |
| Data memory and read/write control | `rtl/data_memory.v` and `rtl/read_write_control.v`; expected values and exact access counts checked |
| Address decoding and organization | `rtl/address_decoder.v`; shared addresses 0-15 contain instructions and 16-31 contain data |
| Execute programs with fetches and data accesses | `make demo` runs LOAD/STORE/HALT; `make test` exercises six scenarios |
| Analyze simultaneous access | Harvard overlaps fetch/data in cycles 2 and 3; shared memory permits one access per cycle |
| Harvard architecture RTL | All implementation modules in `rtl/` |
| Block diagram | `docs/figures/architecture.png` and editable SVG |
| Simulation waveforms | `results/demo.vcd`, sampled CSV, and `docs/figures/waveforms.png` |
| Shared-memory comparison | Same controller, program, data, capacity, and clock period; measured demo: 4 versus 6 cycles |
| Correct separation and control | Testbench checks all data words, unchanged instructions, exactly-once operations, and exclusive shared-port use |
| Timing behavior | Combinational reads, rising-edge writes, synchronous reset, PC hold, halt, and store-to-load checks |
| Optional shared lower-level memory | Omitted; explicitly optional in the supplied brief |

The one-register fetch/execute overlap demonstrates concurrent access. Caches, a full instruction set, a frontend, and board deployment are outside this implementation's scope.

## Final deliverables

| Requirement | Evidence |
| --- | --- |
| Microarchitecture and timing | The final report describes PC enable, execute-valid, shared-port priority, bubbles, synchronous reset, HALT and fault handling. |
| Directed verification | `make test` runs six self-checking programs. The testbench checks port ownership, cycle counts, end state and instruction integrity. |
| Quantitative comparison | `results/summary.csv` covers all six cases. The three-instruction copy has CPI 1.33 versus 2.00 including fill and HALT. |
| FPGA utilization and maximum frequency | `make synth` maps and routes both designs for iCE40-HX8K CT256. See `results/fpga/summary.csv`, the routed JSON reports and tool versions. |
| Final technical report | [Final report](../output/pdf/final_report.pdf), rebuilt with `make report`. |
| Live demonstration | [Presenter walkthrough](LIVE_DEMO.md), [recorded prototype](../VIDEO.md). The team can perform the walkthrough during evaluation. |
