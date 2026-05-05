#!/usr/bin/env bash
# Copyright 2025 ETH Zurich and University of Bologna.
#
# SPDX-License-Identifier: Apache-2.0
#
# Source this file to set up the environment for RISC-V development:
#   source /data/home/rh_xu30/Work/ara_soc/tools/setup-env.sh

# ARA project directory
export ARA_DIR="/data/home/rh_xu30/Work/ara_soc"

# Project-local LLVM toolchain (built from source, recommended)
export LLVM_INSTALL_DIR="$ARA_DIR/install/riscv-llvm"

# GCC 11 used to build LLVM (required for libstdc++)
export GCC11_DIR="/data/home/rh_xu30/Work/ara_soc/tools/gcc-install"

# Legacy pre-installed toolchain (fallback only)
export RISCV_TOOLCHAIN_DIR="/data/home/rh_xu30/tools/riscv"

# Local libraries for legacy toolchain
export LOCAL_LIBS_DIR="/data/home/rh_xu30/tools/local-libs/install"

# Set PATH - LLVM toolchain takes priority
if [ -d "$LLVM_INSTALL_DIR/bin" ]; then
    if [[ ":$PATH:" != *":$LLVM_INSTALL_DIR/bin:"* ]]; then
        export PATH="$LLVM_INSTALL_DIR/bin:$PATH"
    fi
fi

# Legacy toolchain PATH (lower priority)
if [[ ":$PATH:" != *":$RISCV_TOOLCHAIN_DIR/bin:"* ]]; then
    export PATH="$RISCV_TOOLCHAIN_DIR/bin:$PATH"
fi

# Set LD_LIBRARY_PATH
# Priority: GCC11 libs (for LLVM) > local libs > legacy toolchain libs
if [ -d "$GCC11_DIR/lib64" ]; then
    if [[ ":$LD_LIBRARY_PATH:" != *":$GCC11_DIR/lib64:"* ]]; then
        export LD_LIBRARY_PATH="$GCC11_DIR/lib64:$LD_LIBRARY_PATH"
    fi
fi

if [ -d "$LOCAL_LIBS_DIR/lib" ]; then
    if [[ ":$LD_LIBRARY_PATH:" != *":$LOCAL_LIBS_DIR/lib:"* ]]; then
        export LD_LIBRARY_PATH="$LOCAL_LIBS_DIR/lib:$LD_LIBRARY_PATH"
    fi
fi

if [[ ":$LD_LIBRARY_PATH:" != *":$RISCV_TOOLCHAIN_DIR/lib:"* ]]; then
    export LD_LIBRARY_PATH="$RISCV_TOOLCHAIN_DIR/lib:$LD_LIBRARY_PATH"
fi

# Proxy settings for network access (via SSH tunnel)
export http_proxy="http://127.0.0.1:2345"
export https_proxy="http://127.0.0.1:2345"
export HTTP_PROXY="$http_proxy"
export HTTPS_PROXY="$https_proxy"
export GIT_SSL_NO_VERIFY="1"

echo "RISC-V toolchain environment configured:"
echo "  LLVM Toolchain: $LLVM_INSTALL_DIR"
echo "  GCC11 (for LLVM libs): $GCC11_DIR"
echo "  PATH includes: $LLVM_INSTALL_DIR/bin"
echo "  LD_LIBRARY_PATH includes: $GCC11_DIR/lib64"
echo "  Proxy: $http_proxy"
echo ""
echo "Toolchain version:"
if clang --version 2>/dev/null | head -n1; then
    : # Success
else
    echo "  clang: not available (check LD_LIBRARY_PATH)"
fi
