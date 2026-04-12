# ariane_tb – Simulation Makefile (Verilator + VCS)
#
# Verilator:
#   make verilate              # elaborate + compile (default)
#   make compile               # C++ incremental compile only
#   make simv                  # run (hello_world by default)
#   make simv app=<name>       # run a different application
#   make wave app=<name>       # run with FST waveform dump
#
# VCS:
#   make vcs                   # compile
#   make vcs-run app=<name>    # compile + run
#   make vcs-wave app=<name>   # compile + run with FSDB waveform
#   make verdi                 # open Verdi waveform
#
#   make clean                 # remove all build artifacts

SHELL    := /usr/bin/env bash
ROOT_DIR := $(patsubst %/,%, $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# ── Design parameters ─────────────────────────────────────────────────────────
NR_LANES ?= 2
VLEN     ?= 2048

# ── Shared paths ──────────────────────────────────────────────────────────────
FILELIST := $(ROOT_DIR)/filelist.f
TB_DIR   := $(ROOT_DIR)/tb
DPI_DIR  := $(ROOT_DIR)/dpi
app_path ?= $(ROOT_DIR)/../software/build/bin
app      ?= hello_world


FESVR_ROOT  := /DISK1/home/jy_hu30/workspace/toolchain/riscv-tools
# FESVR_ROOT  := /opt/riscv64

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  Verilator                                                                ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
VERILATOR   := /opt/verilator/bin/verilator
OBJCACHE    := $(shell which ccache 2>/dev/null)


VERIL_BUILD := $(ROOT_DIR)/build/verilator
VERIL_TOP   := ara_tb_verilator

# TB C++ sources
TB_CPP_DIRS := $(TB_DIR)/verilator/lowrisc_dv_verilator_memutil_dpi/cpp \
               $(TB_DIR)/verilator/lowrisc_dv_verilator_memutil_verilator/cpp \
               $(TB_DIR)/verilator/lowrisc_dv_verilator_simutil_verilator/cpp
TB_CPP_MAIN := $(TB_DIR)/verilator/ara_tb.cpp

VERIL_WFLAGS := -Wno-fatal \
  --trace-fst \
  --trace-structs \
  --no-timing \
  -Wno-PINCONNECTEMPTY -Wno-BLKANDNBLK  -Wno-CASEINCOMPLETE \
  -Wno-CMPCONST       -Wno-LATCH        -Wno-LITENDIAN \
  -Wno-UNOPTFLAT      -Wno-UNPACKED     -Wno-UNSIGNED \
  -Wno-WIDTH          -Wno-WIDTHCONCAT   -Wno-ENUMVALUE \
  -Wno-COMBDLY

VERIL_MK  := $(VERIL_BUILD)/V$(VERIL_TOP).mk
VERIL_BIN := $(VERIL_BUILD)/V$(VERIL_TOP)

-include $(VERIL_BUILD)/V$(VERIL_TOP)__ver.d

.PHONY: all verilate compile simv clean

all: verilate

verilate: $(VERIL_BIN)

$(VERIL_MK): $(FILELIST)
	mkdir -p $(VERIL_BUILD)
	$(VERILATOR) \
	  -f $(FILELIST) \
	  --MMD \
	  -GNrLanes=$(NR_LANES) -GVLEN=$(VLEN) \
	  +define+NR_LANES=$(NR_LANES) +define+VLEN=$(VLEN) \
	  --vpi \
	  -O0 $(VERIL_WFLAGS) \
	  $(TB_DIR)/verilator/waiver.vlt \
	  --Mdir $(VERIL_BUILD) \
	  -I$(DPI_DIR) \
	  --compiler clang \
	  -CFLAGS "-DTOPLEVEL_NAME=$(VERIL_TOP) -DNR_LANES=$(NR_LANES)" \
	  -CFLAGS "-I$(FESVR_ROOT)/include" \
	  $(addprefix -CFLAGS -I,$(TB_CPP_DIRS)) \
	  -LDFLAGS "-L$(FESVR_ROOT)/lib -lfesvr -lelf" \
	  --exe $(addsuffix /*.cc,$(TB_CPP_DIRS)) $(TB_CPP_MAIN) \
	  $(filter-out $(DPI_DIR)/SimDTM.cc, $(wildcard $(DPI_DIR)/*.cc)) \
	  --cc --top-module $(VERIL_TOP)

$(VERIL_BIN): $(VERIL_MK)
	cd $(VERIL_BUILD) && OBJCACHE='$(OBJCACHE)' \
	  make -j$$(nproc) -f V$(VERIL_TOP).mk VK_PCH_I_FAST= VK_PCH_I_SLOW=
	@echo "=== Verilator build complete: $@ ==="

compile:
	cd $(VERIL_BUILD) && OBJCACHE='$(OBJCACHE)' \
	  make -j$$(nproc) -f V$(VERIL_TOP).mk VK_PCH_I_FAST= VK_PCH_I_SLOW=

simv:
	$(VERIL_BIN) -l ram,$(app_path)/$(app),elf

wave:
	$(VERIL_BIN) -t -l ram,$(app_path)/$(app),elf

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  VCS                                                                      ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
VCS       := vcs
VERDI     := verdi

VCS_BUILD := $(ROOT_DIR)/build/vcs
VCS_TOP   := ara_tb
VCS_BIN   := $(VCS_BUILD)/simv

DPI_SRCS  := $(filter-out $(DPI_DIR)/SimDTM.cc, $(wildcard $(DPI_DIR)/*.cc)) ./tb/uartdpi/uartdpi.c

VCS_FLAGS := -full64 \
  -sverilog \
  -debug_access+all \
  -kdb \
  -timescale=1ns/1ps \
  -DVCS \
  +vcs+lic+wait \
  +lint=TFIPC-L \
  +warn=noUII-L \
  -error=noUCTLAB \
  -f $(FILELIST) \
  +define+NR_LANES=$(NR_LANES) +define+VLEN=$(VLEN) \
  -top $(VCS_TOP) \
  -cc /DISK1/home/jy_hu30/workspace/toolchain/gcc-bin/bin/gcc \
  -cpp /DISK1/home/jy_hu30/workspace/toolchain/gcc-bin/bin/g++ \
  -ld /DISK1/home/jy_hu30/workspace/toolchain/gcc-bin/bin/g++ \
  -CFLAGS "-std=c++17 -I$(DPI_DIR) -I$(FESVR_ROOT)/include -I./tb/uartdpi/" \
  -LDFLAGS "-L$(FESVR_ROOT)/lib -lfesvr -lelf -lutil" \
  $(DPI_SRCS) \
  -Mdir=$(VCS_BUILD)/csrc \
  -o $(VCS_BIN)

VCS_RUN_FLAGS := +vcs+lic+wait \
  +PRELOAD=$(app_path)/$(app)

VCS_WAVE_FLAGS := $(VCS_RUN_FLAGS) \
  +fsdbfile+waveform.fsdb \
  -ucli -do "fsdbDumpvars 0 $(VCS_TOP); run; exit;"

.PHONY: vcs vcs-run vcs-wave verdi

vcs: $(VCS_BIN)

$(VCS_BIN): $(FILELIST)
	mkdir -p $(VCS_BUILD)/csrc
	cd $(ROOT_DIR) && $(VCS) $(VCS_FLAGS)

vcs-run: $(VCS_BIN)
	cd $(ROOT_DIR) && $(VCS_BIN) $(VCS_RUN_FLAGS)

vcs-wave: $(VCS_BIN)
	cd $(ROOT_DIR) && $(VCS_BIN) $(VCS_WAVE_FLAGS)

verdi:
	cd $(ROOT_DIR) && $(VERDI) -dbdir $(VCS_BUILD)/simv.daidir \
	  -ssf waveform.fsdb

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  Clean                                                                    ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
clean: clean-verilator clean-vcs

clean-verilator:
	rm -rf $(VERIL_BUILD)

clean-vcs:
	rm -rf $(VCS_BUILD) *.fsdb *.vcd ucli.key novas.*
