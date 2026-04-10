# Simulation Makefile for export/sim
# Drives Verilator elaboration, C++ compilation, and simulation

SHELL := /usr/bin/env bash
ROOT_DIR := $(patsubst %/,%, $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# ── Tool paths ────────────────────────────────────────────────────────────────
VERILATOR     := /opt/verilator/bin/verilator

# ── Configuration ─────────────────────────────────────────────────────────────
NR_LANES  ?= 4
VLEN      ?= 4096

# ── Build directories ─────────────────────────────────────────────────────────
VERIL_BUILD  := $(ROOT_DIR)/build/verilator
VERIL_TOP    := ara_tb_verilator

# ── TB paths ─────────────────────────────────────────────────────────────────
TB_DIR       := $(ROOT_DIR)/../tb
LOWRISC_DPI  := $(TB_DIR)/verilator/lowrisc_dv_verilator_memutil_dpi/cpp
LOWRISC_MEM  := $(TB_DIR)/verilator/lowrisc_dv_verilator_memutil_verilator/cpp
LOWRISC_SIM  := $(TB_DIR)/verilator/lowrisc_dv_verilator_simutil_verilator/cpp
ARA_TB_CPP   := $(TB_DIR)/verilator/ara_tb.cpp

# ── App path ──────────────────────────────────────────────────────────────────
app_path ?= $(ROOT_DIR)/../software/build/bin
app      ?= hello_world

# ── Filelist ─────────────────────────────────────────────────────────────────
FILELIST := $(ROOT_DIR)/filelist.f

.PHONY: all verilate compile simv clean

all: verilate

# ── Step 1: Verilate (RTL elaboration + C++ compilation) ─────────────────────
verilate: $(VERIL_BUILD)/V$(VERIL_TOP)

$(VERIL_BUILD)/V$(VERIL_TOP): $(FILELIST)
	mkdir -p $(VERIL_BUILD)
	$(VERILATOR) \
	  -f $(FILELIST) \
	  -GNrLanes=$(NR_LANES) \
	  -GVLEN=$(VLEN) \
	  -O3 \
	  -Wno-fatal \
	  -Wno-PINCONNECTEMPTY \
	  -Wno-BLKANDNBLK \
	  -Wno-CASEINCOMPLETE \
	  -Wno-CMPCONST \
	  -Wno-LATCH \
	  -Wno-LITENDIAN \
	  -Wno-UNOPTFLAT \
	  -Wno-UNPACKED \
	  -Wno-UNSIGNED \
	  -Wno-WIDTH \
	  -Wno-WIDTHCONCAT \
	  -Wno-ENUMVALUE \
	  -Wno-COMBDLY \
	  +define+NR_LANES=$(NR_LANES) \
	  +define+VLEN=$(VLEN) \
	  $(TB_DIR)/verilator/waiver.vlt \
	  --Mdir $(VERIL_BUILD) \
	  -I$(TB_DIR)/dpi \
	  --compiler clang \
	  -CFLAGS "-DTOPLEVEL_NAME=$(VERIL_TOP)" \
	  -CFLAGS "-DNR_LANES=$(NR_LANES)" \
	  -CFLAGS -I$(LOWRISC_DPI) \
	  -CFLAGS -I$(LOWRISC_MEM) \
	  -CFLAGS -I$(LOWRISC_SIM) \
	  -LDFLAGS "-lelf" \
	  --exe \
	  $(LOWRISC_DPI)/*.cc \
	  $(LOWRISC_MEM)/*.cc \
	  $(LOWRISC_SIM)/*.cc \
	  $(ARA_TB_CPP) \
	  --cc \
	  --top-module $(VERIL_TOP)
	@echo ""
	@echo "=== Verilator elaboration done. Compiling C++ model... ==="
	cd $(VERIL_BUILD) && OBJCACHE='' make -j$$(nproc) -f V$(VERIL_TOP).mk VK_PCH_I_FAST= VK_PCH_I_SLOW=
	@echo ""
	@echo "=== Build complete: $(VERIL_BUILD)/V$(VERIL_TOP) ==="

# ── Step 2 (optional standalone): Compile C++ model ──────────────────────────
compile:
	cd $(VERIL_BUILD) && OBJCACHE='' make -j$$(nproc) -f V$(VERIL_TOP).mk VK_PCH_I_FAST= VK_PCH_I_SLOW=

# ── Step 3: Run simulation ────────────────────────────────────────────────────
simv:
	$(VERIL_BUILD)/V$(VERIL_TOP) -l ram,$(app_path)/$(app),elf

# ── Clean ─────────────────────────────────────────────────────────────────────
clean:
	rm -rf $(VERIL_BUILD)
