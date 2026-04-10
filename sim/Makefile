# Ara SoC – Simulation Makefile (Verilator + VCS)
#
# Verilator:
#   make verilate              # elaborate + compile (default)
#   make compile               # C++ incremental compile only
#   make simv                  # run (hello_world by default)
#   make simv app=<name>       # run a different application
#
# VCS:
#   make vcs                   # compile
#   make vcs-run               # compile + run
#   make vcs-run app=<name>    # run a different application
#   make wave                  # open Verdi waveform viewer
#
# Common:
#   make clean                 # remove all build artifacts

SHELL    := /usr/bin/env bash
ROOT_DIR := $(patsubst %/,%, $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# ── Design parameters ─────────────────────────────────────────────────────────
NR_LANES ?= 4
VLEN     ?= 4096

# ── Shared paths ──────────────────────────────────────────────────────────────
FILELIST := $(ROOT_DIR)/filelist.f
TB_DIR   := $(ROOT_DIR)/../tb
app_path ?= $(ROOT_DIR)/../software/build/bin
app      ?= hello_world

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
  -Wno-PINCONNECTEMPTY -Wno-BLKANDNBLK  -Wno-CASEINCOMPLETE \
  -Wno-CMPCONST       -Wno-LATCH        -Wno-LITENDIAN \
  -Wno-UNOPTFLAT      -Wno-UNPACKED     -Wno-UNSIGNED \
  -Wno-WIDTH          -Wno-WIDTHCONCAT   -Wno-ENUMVALUE \
  -Wno-COMBDLY

VERIL_MK  := $(VERIL_BUILD)/V$(VERIL_TOP).mk
VERIL_BIN := $(VERIL_BUILD)/V$(VERIL_TOP)

-include $(VERIL_BUILD)/V$(VERIL_TOP)__ver.d

.PHONY: all verilate compile simv

all: verilate

verilate: $(VERIL_BIN)

$(VERIL_MK): $(FILELIST)
	mkdir -p $(VERIL_BUILD)
	$(VERILATOR) \
	  -f $(FILELIST) \
	  --MMD \
	  -GNrLanes=$(NR_LANES) -GVLEN=$(VLEN) \
	  +define+NR_LANES=$(NR_LANES) +define+VLEN=$(VLEN) \
	  -O3 $(VERIL_WFLAGS) \
	  $(TB_DIR)/verilator/waiver.vlt \
	  --Mdir $(VERIL_BUILD) \
	  -I$(TB_DIR)/dpi \
	  --compiler clang \
	  -CFLAGS "-DTOPLEVEL_NAME=$(VERIL_TOP) -DNR_LANES=$(NR_LANES)" \
	  $(addprefix -CFLAGS -I,$(TB_CPP_DIRS)) \
	  -LDFLAGS "-lelf" \
	  --exe $(addsuffix /*.cc,$(TB_CPP_DIRS)) $(TB_CPP_MAIN) \
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

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  VCS                                                                      ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
VCS       := vcs
VERDI     := verdi

VCS_BUILD := $(ROOT_DIR)/build/vcs
VCS_TOP   := ara_tb
VCS_BIN   := $(VCS_BUILD)/simv

# DPI-C sources used by ara_tb.sv (ELF loader)
DPI_SRCS  := $(TB_DIR)/dpi/elfloader.cc

VCS_FLAGS := -full64 \
  -sverilog \
  -debug_access+all \
  -kdb \
  -timescale=1ns/1ps \
  -DVCS \
  +vcs+lic+wait \
  +lint=TFIPC-L \
  +warn=noUII-L \
  -f $(FILELIST) \
  +define+NR_LANES=$(NR_LANES) +define+VLEN=$(VLEN) \
  -top $(VCS_TOP) \
  -CFLAGS "-I$(TB_DIR)/dpi" \
  -LDFLAGS "-lelf" \
  $(DPI_SRCS) \
  -Mdir=$(VCS_BUILD)/csrc \
  -o $(VCS_BIN)

VCS_RUN_FLAGS := +vcs+lic+wait \
  +FIRMWARE=$(app_path)/$(app)

.PHONY: vcs vcs-run wave

vcs: $(VCS_BIN)

$(VCS_BIN): $(FILELIST)
	mkdir -p $(VCS_BUILD)/csrc
	cd $(ROOT_DIR) && $(VCS) $(VCS_FLAGS)

vcs-run: $(VCS_BIN)
	cd $(ROOT_DIR) && $(VCS_BIN) $(VCS_RUN_FLAGS)

wave:
	cd $(ROOT_DIR) && $(VERDI) -dbdir $(VCS_BUILD)/simv.daidir \
	  -ssf waveform.fsdb

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  Clean                                                                  ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
.PHONY: clean clean-verilator clean-vcs

clean: clean-verilator clean-vcs

clean-verilator:
	rm -rf $(VERIL_BUILD)

clean-vcs:
	rm -rf $(VCS_BUILD) *.fsdb *.vcd ucli.key novas.*
