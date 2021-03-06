# TinyFPGA-BX
#PNRFLAGS  ?= --lp8k --package cm81 --pcf board/tinyfpga.pcf -q
#BOARD_TOP = TinyFPGABX_Top

# Icestick
PNRFLAGS  ?= --hx1k --package tq144 --pcf board/icestick.pcf -q
BOARD_TOP = Icestick_Top

#--

YOSYS_FLAGS ?=
YOSYS_SYNTH ?= synth_ice40
GHDL        ?= ghdl
GHDL_FLAGS  += --std=08
GHDL_SYNTH  ?= ghdl
YOSYS       ?= yosys
NEXTPNR     ?= nextpnr-ice40
ICEPACK     ?= icepack

VHDL_SYN_FILES = \
	src/cfg_pkg.vhd \
	src/sync_gen.vhd \
	src/sync_st.vhd \
	src/pattern.vhd \
	board/Icestick_PLL_cfg_pkg.vhd \
	board/ICE40_components_pkg.vhd \
	board/$(BOARD_TOP).vhd

# Default target: run all required targets to build the image.
all: vgatest.bin
	@true

.DEFAULT: all

## Use *Yosys* to generate the synthesized netlist.
## This is called the **synthesis** and **tech mapping** step.
vgatest.json: $(VHDL_SYN_FILES) $(VERILOG_SYN_FILES)
	$(YOSYS) $(YOSYS_FLAGS) \
		-p \
		"$(GHDL_SYNTH) $(GHDL_FLAGS) $(VHDL_SYN_FILES) -e; \
		$(YOSYS_SYNTH) \
		-top $(BOARD_TOP) \
		-json $@" -q 2>&1 board/pll.v | tee yosys-report.txt

# Use **nextpnr** to generate the FPGA configuration.
# This is called the **place** and **route** step.
vgatest.asc: vgatest.json
	$(NEXTPNR) \
		$(PNRFLAGS) \
		--json $< \
		--asc $@

# Use icepack to convert the FPGA configuration into a "bitstream" loadable onto the FPGA.
# This is called the bitstream generation step.
vgatest.bin: vgatest.asc
	$(ICEPACK) $< $@

# Use tinyprog to load the image onto the TinyFPGA-BX.
load: vgatest.bin
	iceprog $<
#	tinyprog -p $<

.PHONY: load

# Cleanup the generated files.
clean:
	rm -fr *.cf *.json *-report.txt *.asc *.bin abc.history

.PHONY: clean