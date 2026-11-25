IVERILOG ?= iverilog
VVP ?= vvp
PYTHON ?= python3
CHROME ?= /Applications/Google Chrome.app/Contents/MacOS/Google Chrome
RTL := $(wildcard rtl/*.v)
.DEFAULT_GOAL := demo

# Simulation output is written to build/ first. It is copied into results/
# only after the run passes, so a failing run never overwrites the evidence.
.PHONY: demo test stress hierarchy check figures report report2 guide site clean

build/memory_compare.vvp: $(RTL) tb/tb_memory_compare.v
	mkdir -p build
	$(IVERILOG) -g2012 -Wall -s tb_memory_compare -o $@ $(RTL) tb/tb_memory_compare.v

build/random_stress.vvp: $(RTL) tb/tb_random_stress.v
	mkdir -p build
	$(IVERILOG) -g2012 -Wall -s tb_random_stress -o $@ $(RTL) tb/tb_random_stress.v

demo: build/memory_compare.vvp
	mkdir -p build results
	$(VVP) build/memory_compare.vvp +DEMO_ONLY | tee build/demo_output.txt
	@$(PYTHON) -c 'from pathlib import Path; assert "DEMO PASSED" in Path("build/demo_output.txt").read_text(), "Demo failed; inspect build/demo_output.txt"'
	cp build/demo_output.txt build/demo_trace.csv build/demo_summary.csv results/
	$(PYTHON) scripts/normalize_vcd.py build/demo.vcd results/demo.vcd

test: build/memory_compare.vvp
	mkdir -p build results
	$(VVP) build/memory_compare.vvp | tee build/test_output.txt
	@$(PYTHON) -c 'from pathlib import Path; assert "ALL TESTS PASSED" in Path("build/test_output.txt").read_text(), "Simulation failed; inspect build/test_output.txt"'
	cp build/test_output.txt build/summary.csv results/
	$(PYTHON) scripts/normalize_vcd.py build/memory_compare.vcd results/memory_compare.vcd

stress: build/random_stress.vvp
	mkdir -p build results
	$(VVP) build/random_stress.vvp | tee build/stress_output.txt
	@$(PYTHON) -c 'from pathlib import Path; assert "STRESS PASSED" in Path("build/stress_output.txt").read_text(), "Stress test failed; inspect build/stress_output.txt"'
	cp build/stress_output.txt results/

build/hierarchy.vvp: $(RTL) tb/tb_hierarchy.v
	mkdir -p build
	$(IVERILOG) -g2012 -Wall -s tb_hierarchy -o $@ $(RTL) tb/tb_hierarchy.v

# Phase II: Harvard L1 caches over one shared lower-level memory.
hierarchy: build/hierarchy.vvp
	mkdir -p build results
	$(VVP) build/hierarchy.vvp | tee build/hierarchy_output.txt
	@$(PYTHON) -c 'from pathlib import Path; assert "HIERARCHY PASSED" in Path("build/hierarchy_output.txt").read_text(), "Hierarchy test failed; inspect build/hierarchy_output.txt"'
	cp build/hierarchy_output.txt results/

check: demo test stress hierarchy

figures:
	$(PYTHON) scripts/make_figures.py
	rsvg-convert -o docs/figures/architecture.png docs/figures/architecture.svg
	rsvg-convert -o docs/figures/waveforms.png docs/figures/waveforms.svg
	rsvg-convert -o docs/figures/architecture_report.png docs/figures/architecture_report.svg
	rsvg-convert -o docs/figures/waveforms_report.png docs/figures/waveforms_report.svg

report: output/pdf/Architec_Phase_I_Report.pdf
report2: output/pdf/Architec_Final_Report.pdf

output/pdf/Architec_Phase_I_Report.pdf: docs/report/phase1_report.tex docs/report/IEEEtran.cls $(wildcard docs/figures/*png)
	$(call compile_report,phase1_report)

output/pdf/Architec_Final_Report.pdf: docs/report/phase2_report.tex docs/report/IEEEtran.cls $(wildcard docs/figures/*png)
	$(call compile_report,phase2_report)

define compile_report
mkdir -p build/report output/pdf
if command -v tectonic >/dev/null 2>&1; then tectonic -Z search-path=docs/report -Z search-path=docs/figures docs/report/$(1).tex --outdir build/report; else TEXINPUTS=docs/report: pdflatex -interaction=nonstopmode -halt-on-error -output-directory=build/report docs/report/$(1).tex && TEXINPUTS=docs/report: pdflatex -interaction=nonstopmode -halt-on-error -output-directory=build/report docs/report/$(1).tex; fi
cp build/report/$(1).pdf $@
endef

.PHONY: synth fpga-report
synth:
	$(PYTHON) scripts/synth.py

fpga-report:
	mkdir -p build/report output/pdf
	$(PYTHON) scripts/report_table.py > build/report/fpga_results.tex
	@if command -v tectonic >/dev/null 2>&1; then \
		tectonic -Z search-path=build/report -Z search-path=docs/report -Z search-path=docs/figures docs/report/final_report.tex --outdir output/pdf; \
	else \
		TEXINPUTS=build/report:docs/report: pdflatex -interaction=nonstopmode -halt-on-error -output-directory=build/report docs/report/final_report.tex && \
		TEXINPUTS=build/report:docs/report: pdflatex -interaction=nonstopmode -halt-on-error -output-directory=build/report docs/report/final_report.tex && \
		cp build/report/final_report.pdf output/pdf/final_report.pdf; \
	fi

guide:
	mkdir -p output/pdf
	"$(CHROME)" --headless=new --disable-gpu --no-pdf-header-footer --print-to-pdf=output/pdf/Architec_Study_Guide.pdf "file://$(CURDIR)/docs/study_guide/study_guide.html"

# The website (study guide + Team hub). GitHub Actions publishes it on every push to main.
site:
	$(PYTHON) scripts/check_site.py
	$(PYTHON) scripts/build_site.py _site

clean:
	rm -rf build _site
