# Prototype Video Demonstration Script

**Target Duration:** 3 minutes 30 seconds (Maximum: 5 minutes)  
**Team:** Architec, Section A  
**Project:** Instruction and Data Memory Hierarchy (MCA Project 9, 2026)

All five team members must be introduced and clearly visible on screen. Use this script for recording the project demonstration video.

---

## Video Outline & Speaker Timeline

| Timestamp | Speaker | Topic & Visuals to Present |
| --- | --- | --- |
| **0:00 - 0:30** | All Five Members | Title slide, team introduction, and project overview |
| **0:30 - 1:00** | Pranjal Modi | Instruction fetch path, Program Counter (`program_counter.v`), and instruction memory |
| **1:00 - 1:30** | Sarvjeet Yadav | Demo program execution (`LOAD 0 / STORE 1 / HALT`), data memory, and read/write timing |
| **1:30 - 2:00** | Abhishek Tripathi | Shared memory architecture, address decoding (0-15 vs 16-31), and fetch stall arbitration |
| **2:00 - 3:00** | Sameer Khan | Live simulation (`make demo`), waveform analysis (`waveforms.png`), and 4 vs 6 cycle proof |
| **3:00 - 3:30** | Suryansh Singh | Comprehensive test suite (`make test`), IEEE report, and interactive GitHub Pages portal |

---

## Detailed Speaking Script

### 1. Opening: All Team Members (0:00 - 0:30)

*Visual: Title slide showing "Team Architec - MCA Project 9, Section A - Instruction and Data Memory Hierarchy".*

> **Suryansh Singh:** "Hello everyone. We are **Team Architec** from Section A. Our project explores the architectural differences between Harvard and Shared-Memory hierarchies in Verilog. Let's introduce our team:"  
> - **Suryansh Singh:** "I'm Suryansh Singh (Enrollment 2401010467), responsible for system integration, the IEEE report, and deployment."  
> - **Pranjal Modi:** "I'm Pranjal Modi (Enrollment 2401010334), handling instruction memory and the program counter."  
> - **Sarvjeet Yadav:** "I'm Sarvjeet Yadav (Enrollment 2401010424), covering data memory and read/write control."  
> - **Abhishek Tripathi:** "I'm Abhishek Tripathi (Enrollment 2401010022), focusing on shared memory architecture and address decoding."  
> - **Sameer Khan:** "I'm Sameer Khan (Enrollment 2401020054), responsible for testbench verification and waveform analysis."

---

### 2. Instruction Path & PC: Pranjal Modi (0:30 - 1:00)

*Visual: Zoom into the Harvard controller and instruction memory diagram (`docs/figures/architecture.png`).*

> **Pranjal Modi:** "At the core of memory organization is the separation of control flow and data flow. In our design, the **Program Counter (PC)** generates 4-bit instruction addresses, addressing a $16 \times 8$-bit instruction memory.  
> The controller features an instruction register with an execution valid bit. Because instruction fetch has its own dedicated bus in Harvard architecture, the controller can fetch the next instruction simultaneously while the current instruction executes, eliminating structural hazards."

---

### 3. Program Flow & Data Memory: Sarvjeet Yadav (1:00 - 1:30)

*Visual: Show program table (`LOAD 0`, `STORE 1`, `HALT`) and `rtl/data_memory.v`.*

> **Sarvjeet Yadav:** "Our demonstration executes a targeted program:  
> 1. `LOAD 0` reads seed value `7` from data address 0 into the accumulator.  
> 2. `STORE 1` writes `7` from the accumulator to data address 1.  
> 3. `HALT` stops the processor cleanly.  
> Data memory is a $16 \times 8$-bit synchronous RAM. Reads are combinational, allowing the operand to be captured at the rising clock edge, while writes commit synchronously at the clock edge. Reset clears registers while preserving memory contents."

---

### 4. Shared Memory & Port Contention: Abhishek Tripathi (1:30 - 2:00)

*Visual: Show shared memory block and `rtl/address_decoder.v`.*

> **Abhishek Tripathi:** "To highlight the Harvard advantage, we compare it against an equivalent 32-byte shared single-port memory.  
> Our address decoder maps instruction addresses 0 to 15, and data addresses 16 to 31 onto one physical port. When a `LOAD` or `STORE` instruction executes, data memory access requires the port. Because data has priority, the instruction fetch is blocked and the PC holds its value. This single structural bottleneck introduces stalls that directly increase total execution time."

---

### 5. Live Demonstration & Waveforms: Sameer Khan (2:00 - 3:00)

*Visual: Terminal running `make demo`, followed by the waveform diagram (`docs/figures/waveforms.png`).*

> **Sameer Khan:** "Let's see this live. Running `make demo` in the terminal compiles our RTL with Icarus Verilog:  
> - In **Cycle 2**, Harvard executes `LOAD 0` while simultaneously fetching `STORE 1`—both fetch and read signals are active. In contrast, shared memory blocks the fetch.  
> - In **Cycle 3**, Harvard executes `STORE 1` while fetching `HALT`—both write and fetch signals are active concurrently!  
> As a result, Harvard finishes the program in **4 clock cycles**, whereas shared memory requires **6 clock cycles** to achieve the exact same final state: `data[1] = 7`."

---

### 6. Verification Suite & Conclusion: Suryansh Singh (3:00 - 3:30)

*Visual: Terminal running `make test` showing 6 passing tests, then showing the IEEE Report PDF and the interactive GitHub Pages site.*

> **Suryansh Singh:** "Running `make test` verifies six rigorous verification scenarios: the primary demo, address boundary tests, zero-data NOP sequences, immediate HALT, invalid opcode trap, and mid-execution reset recovery. All six scenarios pass.  
> All project artifacts—including our IEEE conference paper draft, complete Verilog source code, automated test suite, and an interactive GitHub Pages dashboard—are available in our GitHub repository at `TechySuryansh/Architec`. Thank you!"

---

## Recording Tips

1. Ensure good audio quality and no background noise.
2. Maintain camera eye contact during spoken parts.
3. Keep the shared terminal and diagrams zoomed in and legible.
4. Keep the total video duration under **5 minutes** (aiming for 3:30).
5. Upload the video (unlisted YouTube or Google Drive with public view access) and update `VIDEO.md`.
