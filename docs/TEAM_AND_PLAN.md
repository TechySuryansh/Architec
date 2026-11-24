# Team Architec and Submission Plan

## Roster Supplied by the Team

Section: **A**. All five members belong to the same section.

| Member | Enrolment number | Institutional email |
| --- | --- | --- |
| Suryansh Singh (Lead) | 2401010467 | suryansh.singh2024@nst.rishihood.edu.in |
| Pranjal Modi | 2401010334 | pranjal.modi2024@nst.rishihood.edu.in |
| Sarvjeet Yadav | 2401010424 | sarvjeet.yadav2024@nst.rishihood.edu.in |
| Abhishek Tripathi | 2401010022 | abhishek.tripathi2024@nst.rishihood.edu.in |
| Sameer Khan | 2401020054 | sameer.khan2024@nst.rishihood.edu.in |

Response email: `suryansh.singh2024@nst.rishihood.edu.in`.

## Work Split and Responsibilities

Every member understands the complete system architecture as well as their specialized module ownership:

| Member | Module / Responsibility | Scope & Verification Evidence |
| --- | --- | --- |
| **Suryansh Singh** | System Integration & Deployment | Architecture integration (`memory_system.v`), results comparison, IEEE report authoring, GitHub repository setup, and GitHub Pages deployment (`index.html`) |
| **Pranjal Modi** | Instruction Memory & PC | `instruction_memory.v`, `program_counter.v`; PC increment logic, fetch acceptance handshake, boundary tests |
| **Sarvjeet Yadav** | Data Memory & Control | `data_memory.v`, `read_write_control.v`; synchronous writes, combinational reads, reset retention, opcode decoding (`LOAD`, `STORE`, `HALT`, `NOP`) |
| **Abhishek Tripathi** | Shared Memory & Decoder | `shared_memory.v`, `address_decoder.v`; address mapping (0-15 instructions, 16-31 data), port arbitration, fetch stall logic |
| **Sameer Khan** | Testbench & Waveforms | `tb/tb_memory_compare.v`; 6 verification scenarios, cycle-by-cycle trace (`demo_trace.csv`), waveform validation (`demo.vcd`, `waveforms.png`) |

## Project Timeline & Milestones

| Date (IST) | Milestone Goal |
| --- | --- |
| November 8-10 | Run simulation baseline (`make demo`), verify Harvard (4 cycles) vs Shared (6 cycles) |
| November 11-12 | Implement module enhancements, testbench assertions, and address decoder logic |
| November 13 | Finalize IEEE report draft, waveform generation, and technical documentation |
| November 14 | Deploy interactive GitHub Pages showcase and record team demonstration video |
| November 15 | Complete team rehearsal for viva/interview and final review of repository links |
| November 16 | Submit official Phase I submission form before 11:59 PM IST |

## Phase I Deliverables (30% Weightage)

| Deliverable | Marks | Status & Artifacts |
| --- | ---: | --- |
| **IEEE Report** (Abstract, Lit Review, Architecture, Individual Contributions, References) | 10 | Complete draft PDF (`output/pdf/Architec_Phase_I_Report_Draft.pdf`) and LaTeX source (`docs/report/phase1_report.tex`) |
| **Prototype Video** (<= 5 min, all 5 members introduced, live simulation) | 15 | Script prepared (`docs/VIDEO_SCRIPT.md`), roles allocated, recording linked (`VIDEO.md`) |
| **GitHub Repository & GitHub Pages** (Code, waveforms, documentation, interactive site) | 5 | Repository created at [TechySuryansh/Architec](https://github.com/TechySuryansh/Architec); Interactive deployment live on [GitHub Pages](https://TechySuryansh.github.io/Architec) |

Submission Form: https://docs.google.com/forms/d/e/1FAIpQLSc6Cx8OrOQLGj_X2ZMkyG5jc8mokq36mGRq2x8jGRNV1sbegA/viewform

## Phase I Submission Checklist

- [x] Confirm common section: Section A.
- [x] Verify all 5 member names, enrolment numbers, and institutional emails.
- [x] Verify RTL modules in `rtl/` and testbench in `tb/tb_memory_compare.v`.
- [x] Run simulation verification: all 6 scenarios pass (`make test`).
- [x] Generate diagrams and waveforms (`python3 scripts/make_figures.py`).
- [x] Compile and check IEEE report draft.
- [x] Prepare interactive GitHub Pages web application for evaluator review.
- [x] Record prototype video with all 5 members following `docs/VIDEO_SCRIPT.md`.
- [x] Embed final video link in `VIDEO.md`.
- [ ] Submit repository and video link via Google Form by November 16, 2026.

## Final evaluation

The [final report](../output/pdf/final_report.pdf) includes the architecture, simulation and routed FPGA results. The [live walkthrough](LIVE_DEMO.md) covers the demonstration and can be presented by the team at evaluation.
