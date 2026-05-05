# Copyright 2025 ETH Zurich and University of Bologna.
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

# Tools Makefile - Build RISC-V LLVM toolchain from source

SHELL = /usr/bin/env bash
ROOT_DIR := $(patsubst %/,%, $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))/..
TOOLS_DIR := $(ROOT_DIR)/tools
INSTALL_DIR ?= $(ROOT_DIR)/install

# LLVM Configuration
LLVM_VERSION ?= 17.0.6
LLVM_SRC_DIR ?= $(TOOLS_DIR)/llvm-project-$(LLVM_VERSION)
LLVM_BUILD_DIR ?= $(TOOLS_DIR)/build/llvm
LLVM_INSTALL_DIR ?= $(INSTALL_DIR)/riscv-llvm

# Proxy settings (for network access via SSH tunnel)
PROXY_PORT ?= 2345
PROXY_HOST ?= 127.0.0.1
export http_proxy := http://$(PROXY_HOST):$(PROXY_PORT)
export https_proxy := http://$(PROXY_HOST):$(PROXY_PORT)
export HTTP_PROXY := $(http_proxy)
export HTTPS_PROXY := $(https_proxy)
export GIT_SSL_NO_VERIFY := 1

# Parallel jobs for build
NPROC ?= $(shell nproc 2>/dev/null || echo 4)

# ---------------------------------------------------------------------------
# Targets
# ---------------------------------------------------------------------------
.PHONY: all clean llvm clean-llvm help status

# Default target shows help instead of building
all: help

# ---------------------------------------------------------------------------
# Directory creation
# ---------------------------------------------------------------------------
$(INSTALL_DIR):
	mkdir -p $@

$(LLVM_BUILD_DIR):
	mkdir -p $@

$(TOOLS_DIR)/src:
	mkdir -p $@

# ---------------------------------------------------------------------------
# Download LLVM source
# ---------------------------------------------------------------------------
$(TOOLS_DIR)/src/llvm-project-$(LLVM_VERSION).src.tar.xz: | $(TOOLS_DIR)/src
	@echo "Downloading LLVM $(LLVM_VERSION)..."
	curl -L -o $@ https://github.com/llvm/llvm-project/releases/download/llvmorg-$(LLVM_VERSION)/llvm-project-$(LLVM_VERSION).src.tar.xz || \
	wget -O $@ https://github.com/llvm/llvm-project/releases/download/llvmorg-$(LLVM_VERSION)/llvm-project-$(LLVM_VERSION).src.tar.xz

$(LLVM_SRC_DIR): $(TOOLS_DIR)/src/llvm-project-$(LLVM_VERSION).src.tar.xz
	@echo "Extracting LLVM source..."
	tar -xf $< -C $(TOOLS_DIR)/src/
	touch $@

# Alternative: Clone from git (for development versions)
clone-llvm: | $(TOOLS_DIR)/src
	@echo "Cloning LLVM repository..."
	cd $(TOOLS_DIR)/src && \
	git clone --depth 1 --branch llvmorg-$(LLVM_VERSION) \
		https://github.com/llvm/llvm-project.git llvm-project-$(LLVM_VERSION) || \
	git clone --depth 1 --branch release/17.x \
		https://github.com/llvm/llvm-project.git llvm-project-$(LLVM_VERSION)

# ---------------------------------------------------------------------------
# Build LLVM/Clang with RISC-V support
# ---------------------------------------------------------------------------
# Use Unix Makefiles instead of Ninja (no extra dependency needed)
LLVM_CMAKE_FLAGS := \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX=$(LLVM_INSTALL_DIR) \
	-DCMAKE_C_COMPILER=gcc \
	-DCMAKE_CXX_COMPILER=g++ \
	-DLLVM_ENABLE_PROJECTS="clang;lld;llvm" \
	-DLLVM_TARGETS_TO_BUILD="RISCV;X86" \
	-DLLVM_DEFAULT_TARGET_TRIPLE=riscv64-unknown-elf \
	-DLLVM_ENABLE_RTTI=ON \
	-DLLVM_ENABLE_EH=ON \
	-DLLVM_ENABLE_ASSERTIONS=OFF \
	-DLLVM_ENABLE_OCAMLDOC=OFF \
	-DLLVM_ENABLE_BINDINGS=OFF \
	-DLLVM_ENABLE_ZLIB=OFF \
	-DLLVM_ENABLE_ZSTD=OFF \
	-DCLANG_DEFAULT_LINKER=lld \
	-DCLANG_DEFAULT_OBJCOPY=llvm-objcopy \
	-DCLANG_DEFAULT_RTLIB=compiler-rt \
	-DCLANG_DEFAULT_UNWINDLIB=libgcc \
	-DCLANG_DEFAULT_CXX_STDLIB=libc++ \
	-DLLVM_INSTALL_TOOLCHAIN_ONLY=ON \
	-DLLVM_BUILD_TOOLS=ON \
	-DLLVM_INCLUDE_TOOLS=ON \
	-DLLVM_INSTALL_UTILS=ON

$(LLVM_BUILD_DIR)/Makefile: $(LLVM_SRC_DIR) | $(LLVM_BUILD_DIR)
	@echo "Configuring LLVM with CMake..."
	cd $(LLVM_BUILD_DIR) && cmake $(LLVM_CMAKE_FLAGS) $(LLVM_SRC_DIR)/llvm

$(LLVM_INSTALL_DIR)/bin/clang: $(LLVM_BUILD_DIR)/Makefile
	@echo "Building LLVM/Clang (this will take a while)..."
	@echo "Start time: $$(date)"
	cd $(LLVM_BUILD_DIR) && make -j$(NPROC) 2>&1 | tee $(TOOLS_DIR)/llvm-build.log
	@echo "Installing LLVM..."
	cd $(LLVM_BUILD_DIR) && make install
	@echo "Installing LLVM..."
	cd $(LLVM_BUILD_DIR) && ninja install
	@echo "LLVM installed to $(LLVM_INSTALL_DIR)"

llvm: $(LLVM_INSTALL_DIR)/bin/clang
	@echo "RISC-V LLVM toolchain is ready at $(LLVM_INSTALL_DIR)"
	@echo "  clang: $(LLVM_INSTALL_DIR)/bin/clang"
	@echo "  clang++: $(LLVM_INSTALL_DIR)/bin/clang++"
	@echo "  lld: $(LLVM_INSTALL_DIR)/bin/lld"
	@echo "  llvm-objdump: $(LLVM_INSTALL_DIR)/bin/llvm-objdump"

# ---------------------------------------------------------------------------
# Clean targets
# ---------------------------------------------------------------------------
clean-llvm:
	rm -rf $(LLVM_BUILD_DIR)

clean: clean-llvm
	rm -rf $(LLVM_INSTALL_DIR)

# ---------------------------------------------------------------------------
# Clean source (for full rebuild)
# ---------------------------------------------------------------------------
distclean: clean
	rm -rf $(LLVM_SRC_DIR)

# Pre-installed toolchain from user home
USER_TOOLS_DIR := $(HOME)/tools/riscv

# ---------------------------------------------------------------------------
# Status check
# ---------------------------------------------------------------------------
status:
	@echo "=== Toolchain Status ==="
	@echo ""
	@echo "User pre-installed toolchain: $(USER_TOOLS_DIR)"
	@test -d $(USER_TOOLS_DIR) && echo "  [OK] Directory exists" || echo "  [MISSING] Directory not found"
	@test -f $(USER_TOOLS_DIR)/bin/riscv64-unknown-elf-gcc && echo "  [OK] riscv64-unknown-elf-gcc" || echo "  [MISSING] riscv64-unknown-elf-gcc"
	@test -f $(USER_TOOLS_DIR)/bin/clang && echo "  [OK] clang (may have lib issues on CentOS 7)" || echo "  [MISSING] clang"
	@echo ""
	@echo "Project-local LLVM: $(LLVM_INSTALL_DIR)"
	@test -f $(LLVM_INSTALL_DIR)/bin/clang && echo "  [OK] clang built from source" || echo "  [NOT BUILT] Run 'make llvm' to build"
	@echo ""
	@echo "Network:"
	@echo "  Proxy: $(http_proxy)"
	@echo ""
	@echo "=== Quick Start ==="
	@echo "1. Source environment: source setup-env.sh"
	@echo "2. Test GCC: riscv64-unknown-elf-gcc --version"
	@echo "3. Build software: cd ../software && make hello_world"

# ---------------------------------------------------------------------------
# Help
# ---------------------------------------------------------------------------
help:
	@echo "RISC-V Toolchain Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  make status     - Check toolchain status"
	@echo "  make llvm       - Build LLVM from source (optional)"
	@echo "  make clean      - Clean build artifacts"
	@echo "  make distclean  - Remove everything including source"
	@echo "  make help       - Show this help"
	@echo ""
	@echo "Current configuration uses pre-installed GCC toolchain."
	@echo "LLVM build is only needed if you specifically need clang features."
