# ariane_tb – Simulation Makefile (VCS)
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

GCC_BIN := /DISK1/home/jy_hu30/workspace/toolchain/gcc-bin/bin

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  VCS                                                                      ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
VCS   := vcs
VERDI := verdi

VCS_BUILD := $(ROOT_DIR)/build/vcs
VCS_TOP   := ara_tb
VCS_BIN   := $(VCS_BUILD)/simv

DPI_SRCS := $(filter-out $(DPI_DIR)/SimDTM.cc, $(wildcard $(DPI_DIR)/*.cc)) \
            ./tb/uartdpi/uartdpi.c

VCS_FLAGS := \
  -full64 -sverilog \
  -timescale=1ns/1ps \
  -debug_access+all -kdb \
  -DVCS \
  +vcs+lic+wait \
  +lint=TFIPC-L \
  +warn=noUII-L \
  -error=noUCTLAB \
  -f $(FILELIST) \
  +define+NR_LANES=$(NR_LANES) +define+VLEN=$(VLEN) \
  -top $(VCS_TOP) \
  -cc  $(GCC_BIN)/gcc \
  -cpp $(GCC_BIN)/g++ \
  -ld  $(GCC_BIN)/g++ \
  -CFLAGS "-std=c++17 -I$(DPI_DIR) -I$(FESVR_ROOT)/include -I./tb/uartdpi/" \
  -LDFLAGS "-L$(FESVR_ROOT)/lib -lfesvr -lelf -lutil" \
  $(DPI_SRCS) \
  -Mdir=$(VCS_BUILD)/csrc \
  -o $(VCS_BIN)

VCS_RUN_FLAGS := \
  +vcs+lic+wait \
  +PRELOAD=$(app_path)/$(app)

VCS_WAVE_FLAGS := $(VCS_RUN_FLAGS) \
  +fsdbfile+waveform.fsdb \
  -ucli -do "fsdbDumpvars 0 $(VCS_TOP); run; exit;"

.PHONY: all vcs vcs-run vcs-wave verdi clean

all: vcs

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
clean:
	rm -rf $(VCS_BUILD) *.fsdb *.vcd ucli.key novas.*
