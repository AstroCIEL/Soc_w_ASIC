# Copyright 2020 ETH Zurich and University of Bologna.
#
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Author: Samuel Riedel, ETH Zurich
#         Matheus Cavalcante, ETH Zurich

# toolchain.mk -- Toolchain detection, compiler flags, and defines.
# Included by the top-level Makefile; should NOT be included directly by
# individual application Makefiles.

SHELL = /usr/bin/env bash

# ---------------------------------------------------------------------------
# Path helpers
# ---------------------------------------------------------------------------
_SDK_MK_DIR := $(patsubst %/,%, $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
SDK_DIR     := $(abspath $(_SDK_MK_DIR)/..)

ARA_DIR := $(shell git rev-parse --show-toplevel 2>/dev/null || echo $$ARA_DIR)

# ---------------------------------------------------------------------------
# Ara configuration
# ---------------------------------------------------------------------------
ifndef config
	ifdef ARA_CONFIGURATION
		config := $(ARA_CONFIGURATION)
	else
		config := default
	endif
endif

include $(ARA_DIR)/config/$(config).mk

# ---------------------------------------------------------------------------
# Install directories  (all overridable)
# ---------------------------------------------------------------------------
INSTALL_DIR         ?= $(ARA_DIR)/install
LLVM_INSTALL_DIR    ?= $(INSTALL_DIR)/riscv-llvm
ISA_SIM_INSTALL_DIR ?= $(INSTALL_DIR)/riscv-isa-sim

# ---------------------------------------------------------------------------
# Architecture parameters
# ---------------------------------------------------------------------------
RISCV_XLEN   ?= 64
RISCV_ABI    ?= lp64d
RISCV_TARGET ?= riscv$(RISCV_XLEN)-unknown-elf

# ---------------------------------------------------------------------------
# LLVM toolchain  (single toolchain – keeps things simple & extensible)
# ---------------------------------------------------------------------------
RISCV_PREFIX  ?= /opt/riscv-llvm/xbin/riscv64-unknown-elf-
RISCV_CC      ?= $(RISCV_PREFIX)clang
RISCV_CXX     ?= $(RISCV_PREFIX)clang++
RISCV_OBJDUMP ?= $(RISCV_PREFIX)llvm-objdump
RISCV_OBJCOPY ?= $(RISCV_PREFIX)llvm-objcopy
RISCV_AS      ?= $(RISCV_PREFIX)llvm-as
RISCV_AR      ?= $(RISCV_PREFIX)llvm-ar
RISCV_LD      ?= $(RISCV_PREFIX)ld.lld
RISCV_STRIP   ?= $(RISCV_PREFIX)llvm-strip

# ---------------------------------------------------------------------------
# Spike ISA simulator
# ---------------------------------------------------------------------------
RISCV_SIM     ?= $(ISA_SIM_INSTALL_DIR)/bin/spike
vlen_spike    := $(shell vlen=$$(grep vlen $(ARA_DIR)/config/$(config).mk | cut -d" " -f3) && echo "$$(( $$vlen < 4096 ? $$vlen : 4096 ))")
RISCV_SIM_OPT ?= --isa=rv64gcv_zfh --varch="vlen:$(vlen_spike),elen:64"

# ---------------------------------------------------------------------------
# Python
# ---------------------------------------------------------------------------
PYTHON ?= python3

# ---------------------------------------------------------------------------
# Preprocessor defines  (all additive – callers may append to DEFINES)
# ---------------------------------------------------------------------------
ENV_DEFINES ?=
ifeq ($(vcd_dump),1)
ENV_DEFINES += -DVCD_DUMP=1
endif
MAKE_DEFINES = -DNR_LANES=$(nr_lanes) -DVLEN=$(vlen)
DEFINES += $(ENV_DEFINES) $(MAKE_DEFINES)

# ---------------------------------------------------------------------------
# Compiler / linker flags
# ---------------------------------------------------------------------------
RISCV_WARNINGS += -Wunused-variable -Wall -Wextra -Wno-unused-command-line-argument

LLVM_FLAGS   ?= -march=rv64gcv_zfh_zvfh -mabi=$(RISCV_ABI) -mno-relax -fuse-ld=lld
LLVM_V_FLAGS ?= -fno-vectorize -mllvm -scalable-vectorization=off \
                -mllvm -riscv-v-vector-bits-min=0 -mno-implicit-float

RISCV_FLAGS   ?= $(LLVM_FLAGS) $(LLVM_V_FLAGS) -mcmodel=medany \
                 -I$(SDK_DIR)/include -O3 -ffast-math -fno-common \
                 -fno-builtin-printf $(DEFINES) $(RISCV_WARNINGS)

RISCV_CCFLAGS  ?= $(RISCV_FLAGS) -ffunction-sections -fdata-sections -std=gnu99
RISCV_CXXFLAGS ?= $(RISCV_FLAGS) -ffunction-sections -fdata-sections
RISCV_LDFLAGS  ?= -static -nostartfiles -lm -Wl,--gc-sections \
                  -T$(SDK_DIR)/scripts/link.ld

RISCV_OBJDUMP_FLAGS ?= --mattr=v
