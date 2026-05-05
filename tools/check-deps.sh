#!/usr/bin/env bash
# Copyright 2025 ETH Zurich and University of Bologna.
#
# SPDX-License-Identifier: Apache-2.0
#
# Check build dependencies for RISC-V LLVM toolchain

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "==============================================="
echo "Checking RISC-V LLVM Build Dependencies"
echo "==============================================="
echo ""

FAILED=0

# Check for basic tools
check_cmd() {
    if command -v "$1" &> /dev/null; then
        echo -e "${GREEN}[OK]${NC} $1 found: $(command -v $1)"
        if [ -n "$2" ]; then
            $2
        fi
        return 0
    else
        echo -e "${RED}[MISSING]${NC} $1 not found"
        if [ -n "$3" ]; then
            echo "       $3"
        fi
        FAILED=1
        return 1
    fi
}

check_version() {
    local cmd="$1"
    local min_version="$2"
    local current_version="$3"

    # Simple version comparison (not perfect but works for most cases)
    if [ "$(printf '%s\n' "$min_version" "$current_version" | sort -V | head -n1)" = "$min_version" ]; then
        echo -e "${GREEN}[OK]${NC} $cmd version $current_version (>= $min_version)"
    else
        echo -e "${RED}[ERROR]${NC} $cmd version $current_version < $min_version"
        FAILED=1
    fi
}

# System tools
echo "=== System Tools ==="
check_cmd "python3" "python3 --version" "Python 3.6+ required for LLVM build"
check_cmd "cmake" "cmake --version | head -n1" "CMake 3.13+ required for LLVM build"
check_cmd "ninja" "ninja --version" "Ninja build system required (ninja-build package)"
check_cmd "curl" "" "curl required to download LLVM sources"
check_cmd "git" "git --version | head -n1" "Git required for cloning repositories"
check_cmd "gcc" "gcc --version | head -n1" "GCC required as host compiler"
check_cmd "g++" "g++ --version | head -n1" "G++ required as host compiler"

echo ""
echo "=== Network Configuration ==="

# Check proxy settings
if [ -n "$http_proxy" ] || [ -n "$HTTP_PROXY" ]; then
    echo -e "${GREEN}[OK]${NC} HTTP proxy configured: ${http_proxy:-$HTTP_PROXY}"
else
    echo -e "${YELLOW}[WARNING]${NC} HTTP proxy not configured"
    echo "       Set http_proxy environment variable or use:"
    echo "       export http_proxy=http://127.0.0.1:2345"
fi

if [ -n "$https_proxy" ] || [ -n "$HTTPS_PROXY" ]; then
    echo -e "${GREEN}[OK]${NC} HTTPS proxy configured: ${https_proxy:-$HTTPS_PROXY}"
else
    echo -e "${YELLOW}[WARNING]${NC} HTTPS proxy not configured"
fi

# Test network connectivity
echo ""
echo "Testing network connectivity..."
if curl -s --connect-timeout 5 --max-time 10 -I https://github.com | grep -q "HTTP"; then
    echo -e "${GREEN}[OK]${NC} Can reach GitHub (network is working)"
else
    echo -e "${RED}[ERROR]${NC} Cannot reach GitHub"
    echo "       Check your proxy settings and SSH tunnel:"
    echo "       ssh -N -R 2345:127.0.0.1:7890 rh_xu30@<host>"
    FAILED=1
fi

echo ""
echo "=== Disk Space ==="

# Check available disk space
REQUIRED_GB=30
AVAILABLE_KB=$(df -k . | tail -1 | awk '{print $4}')
AVAILABLE_GB=$((AVAILABLE_KB / 1024 / 1024))

if [ "$AVAILABLE_GB" -ge "$REQUIRED_GB" ]; then
    echo -e "${GREEN}[OK]${NC} Available disk space: ${AVAILABLE_GB}GB (>= ${REQUIRED_GB}GB required)"
else
    echo -e "${RED}[ERROR]${NC} Available disk space: ${AVAILABLE_GB}GB (< ${REQUIRED_GB}GB required)"
    echo "       Building LLVM requires significant disk space."
    FAILED=1
fi

echo ""
echo "=== Memory ==="

# Check available memory
TOTAL_MEM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
TOTAL_MEM_GB=$((TOTAL_MEM_KB / 1024 / 1024))

if [ "$TOTAL_MEM_GB" -ge 8 ]; then
    echo -e "${GREEN}[OK]${NC} Total memory: ${TOTAL_MEM_GB}GB"
else
    echo -e "${YELLOW}[WARNING]${NC} Total memory: ${TOTAL_MEM_GB}GB (< 8GB recommended)"
    echo "       Consider using fewer parallel jobs: make llvm -j2"
fi

echo ""
echo "==============================================="

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All checks passed! Ready to build RISC-V LLVM.${NC}"
    echo ""
    echo "Next steps:"
    echo "  cd $(dirname $0)/.."
    echo "  make -C tools llvm"
    exit 0
else
    echo -e "${RED}Some checks failed. Please install missing dependencies.${NC}"
    echo ""
    echo "To install dependencies (if you have sudo access on another machine):"
    echo "  sudo apt-get update"
    echo "  sudo apt-get install -y cmake ninja-build python3 curl git gcc g++"
    exit 1
fi
