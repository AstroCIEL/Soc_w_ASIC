#!/usr/bin/env bash
# Install RISC-V Spike simulator for CentOS 7
# This provides the fesvr library needed for simulation

set -e

# Use the SSH tunnel proxy for network access
export http_proxy=http://127.0.0.1:23456
export https_proxy=http://127.0.0.1:23456
export HTTP_PROXY=$http_proxy
export HTTPS_PROXY=$https_proxy

# Installation directory
INSTALL_DIR="/data/home/rh_xu30/tools/riscv"
BUILD_DIR="/data/home/rh_xu30/tools/spike-build"
SRC_DIR="/data/home/rh_xu30/tools/riscv-isa-sim"

# Use newer GCC for C++2a support
GCC_HOME="/data/home/rh_xu30/Work/ara_soc_vpu/tools/gcc-install"
export CC="$GCC_HOME/bin/gcc"
export CXX="$GCC_HOME/bin/g++"
export LD_LIBRARY_PATH="$GCC_HOME/lib64:$LD_LIBRARY_PATH"
export PATH="$GCC_HOME/bin:$PATH"

echo "==============================================="
echo "Installing RISC-V Spike Simulator"
echo "==============================================="
echo "Install dir: $INSTALL_DIR"
echo "Source dir: $SRC_DIR"
echo "Build dir: $BUILD_DIR"
echo "==============================================="
echo ""

# Check if already installed
if [ -f "$INSTALL_DIR/bin/spike" ]; then
    echo "Spike already installed at $INSTALL_DIR/bin/spike"
    echo "Version:"
    $INSTALL_DIR/bin/spike --version 2>/dev/null || true
    exit 0
fi

# Clone the repository if needed
if [ ! -d "$SRC_DIR/.git" ]; then
    echo "Cloning riscv-isa-sim repository..."
    rm -rf "$SRC_DIR"
    git clone --depth 1 https://github.com/riscv-software-src/riscv-isa-sim.git "$SRC_DIR"
fi

# Clean and create build directory
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

cd "$BUILD_DIR"

echo ""
echo "Configuring Spike..."
"$SRC_DIR/configure" \
    --prefix="$INSTALL_DIR" \
    --with-isa=RV64GCV \
    --enable-commitlog \
    --enable-histogram

echo ""
echo "Building Spike (this may take 5-10 minutes)..."
make -j$(nproc 2>/dev/null || echo 4)

echo ""
echo "Installing Spike..."
make install

echo ""
echo "==============================================="
echo "Installation Complete!"
echo "==============================================="
echo ""
echo "Spike installed to: $INSTALL_DIR/bin/spike"
echo "FESVR library installed to: $INSTALL_DIR/lib"
echo ""
echo "To use:"
echo "  export PATH=$INSTALL_DIR/bin:\$PATH"
echo "  export LD_LIBRARY_PATH=$INSTALL_DIR/lib:\$LD_LIBRARY_PATH"
echo ""
