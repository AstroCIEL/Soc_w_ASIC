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
_SCRIPTS_DIR := $(patsubst %/,%, $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
BSP_DIR      := $(abspath $(_SCRIPTS_DIR)/..)
SDK_DIR      := $(BSP_DIR)/sdk
SOC_DIR      := $(BSP_DIR)/soc
COMMON_DIR   := $(BSP_DIR)/common
SCRIPTS_DIR  := $(BSP_DIR)/scripts


# ---------------------------------------------------------------------------
# Architecture parameters
# ---------------------------------------------------------------------------
RISCV_XLEN   ?= 64
RISCV_ABI    ?= lp64d
RISCV_TARGET ?= riscv$(RISCV_XLEN)-unknown-elf

# ---------------------------------------------------------------------------
# Install directories (all overridable)
# BSP_DIR is software/ directory, INSTALL_DIR should be ara_soc/ directory
# LLVM toolchain is in /data/home/rh_xu30/tools/llvm_install, softlinked to ./install
# ---------------------------------------------------------------------------
INSTALL_DIR         ?= $(BSP_DIR)/..
LLVM_INSTALL_DIR    ?= $(INSTALL_DIR)/install/riscv-llvm
# Pre-installed toolchain directory (from user home) - for libgcc and sysroot
USER_TOOLS_DIR      ?= $(HOME)/tools/riscv

# ---------------------------------------------------------------------------
# Toolchain detection (priority: project-local LLVM first)
# ---------------------------------------------------------------------------
# Check for project-local LLVM built from source
ifneq ($(wildcard $(LLVM_INSTALL_DIR)/bin/clang),)
  # Use LLVM toolchain with GCC sysroot and LLD
  GCC_SYSROOT   ?= $(USER_TOOLS_DIR)/riscv64-unknown-elf
  RISCV_PREFIX  ?= $(LLVM_INSTALL_DIR)/bin/
  RISCV_CC      ?= $(RISCV_PREFIX)clang --target=$(RISCV_TARGET) --sysroot=$(GCC_SYSROOT)
  RISCV_CXX     ?= $(RISCV_PREFIX)clang++ --target=$(RISCV_TARGET) --sysroot=$(GCC_SYSROOT)
  RISCV_OBJDUMP ?= $(RISCV_PREFIX)llvm-objdump
  RISCV_OBJCOPY ?= $(RISCV_PREFIX)llvm-objcopy
  RISCV_AS      ?= $(RISCV_PREFIX)llvm-as
  RISCV_AR      ?= $(RISCV_PREFIX)llvm-ar
  RISCV_LD      ?= $(RISCV_PREFIX)ld.lld
  RISCV_STRIP   ?= $(RISCV_PREFIX)llvm-strip
  $(info Using project-local LLVM toolchain: $(LLVM_INSTALL_DIR) with LLD)
# Fallback to system paths (original behavior)
else
  RISCV_PREFIX  ?= /opt/riscv-llvm/xbin/riscv64-unknown-elf-
  RISCV_CC      ?= $(RISCV_PREFIX)clang
  RISCV_CXX     ?= $(RISCV_PREFIX)clang++
  RISCV_OBJDUMP ?= $(RISCV_PREFIX)llvm-objdump
  RISCV_OBJCOPY ?= $(RISCV_PREFIX)llvm-objcopy
  RISCV_AS      ?= $(RISCV_PREFIX)llvm-as
  RISCV_AR      ?= $(RISCV_PREFIX)llvm-ar
  RISCV_LD      ?= $(RISCV_PREFIX)ld.lld
  RISCV_STRIP   ?= $(RISCV_PREFIX)llvm-strip
  $(info Using system toolchain)
endif

# ---------------------------------------------------------------------------
# Python
# ---------------------------------------------------------------------------
PYTHON ?= python3

# ---------------------------------------------------------------------------
# Compiler / linker flags
# ---------------------------------------------------------------------------
RISCV_WARNINGS += -Wunused-variable -Wall -Wextra -Wno-unused-command-line-argument

LLVM_FLAGS   ?= -march=rv64gcv_zfh_zvfh -mabi=$(RISCV_ABI) -mno-relax -fuse-ld=lld
LLVM_V_FLAGS ?= -fno-vectorize -mllvm -scalable-vectorization=off \
                -mllvm -riscv-v-vector-bits-min=0 -mno-implicit-float

RISCV_FLAGS   ?= $(LLVM_FLAGS) $(LLVM_V_FLAGS) -mcmodel=medany \
                 $(RISCV_INCLUDES) \
                 -O3 -ffast-math -fno-common \
                 $(DEFINES) $(RISCV_WARNINGS)

RISCV_CCFLAGS  ?= $(RISCV_FLAGS) -ffunction-sections -fdata-sections -std=gnu99
RISCV_CXXFLAGS ?= $(RISCV_FLAGS) -ffunction-sections -fdata-sections
# Use -lm -lgcc only, avoid -lc to prevent LLD relocation errors with newlib
RISCV_LDFLAGS  ?= -static -nostartfiles -nostdlib -Wl,--gc-sections \
                  -T$(LINK_SCRIPT) -L$(USER_TOOLS_DIR)/lib/gcc/riscv64-unknown-elf/13.2.0 \
                  -lm -lgcc

RISCV_OBJDUMP_FLAGS ?= -D --mattr=v