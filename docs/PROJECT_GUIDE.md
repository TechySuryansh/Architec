# Study Material & Project Guide | Team Architec

**Project:** Instruction and Data Memory Hierarchy  
**Team:** Architec (Section A, MCA Project 9, 2026)  
**Members:**  
- **Suryansh Singh (2401010467)** — System Integration, IEEE Report, Repository & Deployment  
- **Pranjal Modi (2401010334)** — Instruction Memory, Program Counter, Fetch Logic  
- **Sarvjeet Yadav (2401010424)** — Data Memory, Read/Write Control, Timing & Retention  
- **Abhishek Tripathi (2401010022)** — Shared Memory, Address Decoder, Port Contention  
- **Sameer Khan (2401020054)** — Testbench, Verification Scenarios, Waveform Validation  

---

## 1. Core Architectural Concept

The fundamental question this project answers:  
> **How does separating instruction and data paths eliminate structural hazards and improve throughput compared to a single-port shared memory?**

Both architectures in our project share:
- The **same controller** (Program Counter, Instruction Register, Accumulator).
- The **same clock period** ($10\,\text{ns}$).
- The **same memory capacity** (32 bytes total).
- The **same demo program** and initial data.

| Architectural Feature | Harvard Organization | Shared Single-Port Memory |
| --- | --- | --- |
| **Physical Organization** | Two distinct memories: $16\times8$ bit instruction + $16\times8$ bit data | Single $32\times8$ bit unified memory |
| **Address/Data Ports** | Separate dedicated instruction port and data port | One time-shared address & data port |
| **Concurrent Access** | Can fetch next instruction while reading/writing data | Fetch must wait if data access is occurring |
| **Contention Resolution** | None needed (no structural hazard) | Data access has priority; instruction fetch is stalled |
| **Demo Completion** | **4 clock cycles** | **6 clock cycles** |

---

## 2. The Demonstration Program & Flow

```text
Assembly:
  LOAD 0     ; Read data[0] (value = 7) into Accumulator
  STORE 1    ; Write Accumulator (value = 7) to data[1]
  HALT       ; Terminate execution cleanly

Machine Code (Hex):
  10         ; Opcode 1 (LOAD),  Data address 0
  21         ; Opcode 2 (STORE), Data address 1
  F0         ; Opcode F (HALT),  Operand ignored
```

### Initial State vs Final State
- **Initial:** `data[0] = 7`, `data[1] = 0`, `ACC = 0`, `PC = 0`.
- **Final:** `data[0] = 7`, `data[1] = 7`, `ACC = 7`, `halted = 1`.

---

## 3. Cycle-by-Cycle Execution Trace

| Cycle | Harvard Fetch | Harvard Execution | Shared Fetch | Shared Execution | Why the Difference Occurs |
| :---: | :--- | :--- | :--- | :--- | :--- |
| **1** | `LOAD 0` fetched | Idle (pipeline filling) | `LOAD 0` fetched | Idle (pipeline filling) | Both fetch the first instruction from PC = 0. |
| **2** | `STORE 1` fetched | `LOAD 0` executed (`ACC <= data[0]`) | **Blocked** (fetch stalled) | `LOAD 0` executed (`ACC <= data[0]`) | **Harvard overlaps fetch & data read.** Shared memory's port is occupied by `LOAD 0`, so fetch is stalled and PC holds. |
| **3** | `HALT` fetched | `STORE 1` executed (`data[1] <= ACC`) | `STORE 1` fetched | Idle (`execute_valid = 0`) | **Harvard overlaps fetch & data write.** Shared memory can now fetch `STORE 1` because no data access is active. |
| **4** | Idle | `HALT` executed (**Done!**) | **Blocked** (fetch stalled) | `STORE 1` executed (`data[1] <= ACC`) | **Harvard halts in 4 cycles.** Shared memory data write takes port priority, blocking the `HALT` fetch. |
| **5** | Halted | Halted | `HALT` fetched | Idle (`execute_valid = 0`) | Shared memory fetches delayed `HALT`. |
| **6** | Halted | Halted | Idle | `HALT` executed (**Done!**) | **Shared memory halts in 6 cycles.** |

**Summary of Difference:**  
Harvard: 2 fetch/data overlap cycles, 0 stall cycles $\rightarrow$ **4 cycles total**.  
Shared: 0 fetch/data overlap cycles, 2 stall cycles $\rightarrow$ **6 cycles total**.

---

## 4. Instruction Set & Opcode Encoding

Instructions are 8 bits wide: `[7:4]` = 4-bit Opcode, `[3:0]` = 4-bit Data Address Operand.

| Opcode `[7:4]` | Mnemonic | Format | RTL Operation | Description |
| :---: | :--- | :---: | :--- | :--- |
| `0x1` | `LOAD addr` | `1a` | `ACC <= data_mem[a]` | Read byte from data memory address $a$ into ACC |
| `0x2` | `STORE addr` | `2a` | `data_mem[a] <= ACC` | Write ACC byte to data memory address $a$ |
| `0xF` | `HALT` | `Fa` | `halted <= 1'b1` | Stop execution and suppress all further memory accesses |
| `0x0` | `NOP` | `0a` | None | No operation; advances PC without memory data traffic |
| *Others* | Fault | — | `fault <= 1'b1` | Invalid opcode trap; processor stops with fault flag |

---

## 5. Module Reference & Responsibilities

| RTL Source File | Responsibility | Owner | Key Logic Implemented |
| --- | --- | --- | --- |
| `rtl/program_counter.v` | Program Counter | Pranjal Modi | 4-bit register; increments when `fetch_enable` is high; holds value when fetch is stalled. |
| `rtl/instruction_memory.v` | Instruction Memory | Pranjal Modi | $16 \times 8$-bit ROM/RAM loaded via `$readmemh`; read-only during normal execution. |
| `rtl/data_memory.v` | Data Memory | Sarvjeet Yadav | $16 \times 8$-bit RAM; combinational reads, synchronous rising-edge writes; contents preserved across reset. |
| `rtl/read_write_control.v` | Opcode Decoder | Sarvjeet Yadav | Decodes 4-bit opcode into control flags: `is_load`, `is_store`, `is_halt`, `is_nop`. |
| `rtl/shared_memory.v` | Unified Memory | Abhishek Tripathi | Unified $32 \times 8$-bit storage accessed through a single bidirectional port. |
| `rtl/address_decoder.v` | Address Decoding & Arbitration | Abhishek Tripathi | Translates addresses (0–15 instruction, 16–31 data); gives data access priority over instruction fetch. |
| `rtl/simple_controller.v` | Controller Core | Suryansh Singh | Houses ACC, instruction register, and `execute_valid` flag; coordinates fetch and execution pipelines. |
| `rtl/memory_system.v` | Top-Level Integration | Suryansh Singh | Parameterized wrapper (`SHARED_BUS=0` for Harvard, `SHARED_BUS=1` for Shared) binding controller to memories. |
| `tb/tb_memory_compare.v` | Testbench Suite | Sameer Khan | Instantiates both architectures side-by-side, exercises 6 test scenarios, logs cycle traces and VCD waveforms. |

---

## 6. Verification Suite (All 6 Scenarios Pass)

1. **Scenario 0: Main Demo (`LOAD 0; STORE 1; HALT`)**
   - Verifies 4 vs 6 cycle timing and correct memory copy (`data[1] = 7`).
2. **Scenario 1: Boundary & Back-to-Back Accesses**
   - Verifies STORE immediately followed by LOAD at the boundary address 15.
3. **Scenario 2: Compute/NOP Only (`NOP; NOP; HALT`)**
   - Verifies equal performance (4 cycles each) when no data memory traffic competes for the shared port. Proves that Harvard speedup depends on workload access patterns.
4. **Scenario 3: Immediate HALT (`HALT`)**
   - Both complete in 2 cycles cleanly without unintended memory activity.
5. **Scenario 4: Invalid Opcode Trap**
   - Unknown opcode halts processor and asserts `fault` output flag immediately.
6. **Scenario 5: Reset & Restart During Multi-Byte Copy**
   - Verifies that synchronous reset clears controller and PC while preserving previously committed data in RAM.

---

## 7. Viva & Interview Questions with Model Answers

### Q1: Why does Harvard architecture finish the demo in 4 cycles while Shared memory takes 6 cycles?
> **Answer:** In Harvard architecture, separate instruction and data buses allow the controller to fetch the next instruction while simultaneously reading or writing data for the current instruction. During the 3-instruction demo, two overlap opportunities occur (during `LOAD 0` in cycle 2 and `STORE 1` in cycle 3). Shared memory has only one port; when `LOAD` or `STORE` accesses data, it monopolizes the port. Instruction fetch is blocked for one cycle each time, adding 2 stall cycles.

### Q2: What is the purpose of the `execute_valid` bit in `simple_controller.v`?
> **Answer:** In shared memory mode, when a data access stalls instruction fetch, no new instruction enters the instruction register in that cycle. The `execute_valid` bit clears to `0` for the following cycle. This prevents the controller from re-executing the previous instruction a second time while waiting for the next fetched instruction.

### Q3: How is address space mapped and arbitrated in shared memory?
> **Answer:** The address decoder maps the lower 16 addresses (0–15) to instructions and the upper 16 addresses (16–31) to data by offsetting data addresses by $+16$. Arbitration gives strict priority to data operations (`data_read_enable` or `data_write_enable`). If a data request is active, `physical_address` routes the data address and the fetch acknowledge is suppressed.

### Q4: Why are memory reads combinational while writes are synchronous?
> **Answer:** In our design, combinational reads allow memory data to settle within the clock cycle so the accumulator can sample it reliably on the rising edge. Synchronous writes commit data on the rising clock edge when `data_write_enable` is high, preventing race conditions.

### Q5: Does Harvard architecture always outperform shared single-port memory?
> **Answer:** No. Harvard architecture only provides speedup when there is concurrent demand for instruction fetching and data access. In Scenario 2 (programs with only `NOP` and `HALT` and no memory data accesses), both Harvard and Shared architectures execute in exactly 4 cycles because the shared memory port is never contested.

### Q6: How does reset behave?
> **Answer:** Reset is synchronous and active-high. It resets the Program Counter to 0, clears the Accumulator to 0, clears `execute_valid`, and drops all memory request enables. Importantly, it does **not** erase data or instruction memory contents, ensuring data retention across resets.
