#!/usr/bin/env bash
# Rebuild newlib with medany code model for LLD compatibility
# This fixes R_RISCV_HI20 relocation errors when linking with lld

set -e

# Paths
NEWLIB_SRC="/data/home/rh_xu30/tools/riscv-gnu-toolchain-src/newlib"
INSTALL_DIR="/data/home/rh_xu30/tools/riscv"
BUILD_DIR="/data/home/rh_xu30/tools/riscv-newlib-medany-build"
TARGET="riscv64-unknown-elf"

# Verify source exists
if [ ! -d "$NEWLIB_SRC/newlib" ]; then
    echo "ERROR: newlib source not found at $NEWLIB_SRC"
    echo "Expected to find newlib at: $NEWLIB_SRC/newlib"
    exit 1
fi

echo "==============================================="
echo "Rebuilding newlib with medany code model"
echo "==============================================="
echo "Source: $NEWLIB_SRC"
echo "Install: $INSTALL_DIR"
echo "Build: $BUILD_DIR"
echo "Target: $TARGET"
echo "==============================================="
echo ""

# Clean previous build
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Export target flags for newlib build
# medany is required for addresses > 2GB (like 0x80000000)
# -mno-relax is needed for LLD compatibility
export CFLAGS_FOR_TARGET="-mcmodel=medany -march=rv64gcv -mabi=lp64d -O3 -mno-relax -fno-pic"
export CXXFLAGS_FOR_TARGET="-mcmodel=medany -march=rv64gcv -mabi=lp64d -O3 -mno-relax -fno-pic"

# Use the existing GCC toolchain
export PATH="$INSTALL_DIR/bin:$PATH"

# Set library path for compiler dependencies (libmpfr, libgmp, libmpc)
export LD_LIBRARY_PATH="/data/home/rh_xu30/tools/local-libs/install/lib:$LD_LIBRARY_PATH"

# Verify compiler is available
if ! command -v riscv64-unknown-elf-gcc &> /dev/null; then
    echo "ERROR: riscv64-unknown-elf-gcc not found in PATH"
    echo "Expected at: $INSTALL_DIR/bin/riscv64-unknown-elf-gcc"
    ls -la "$INSTALL_DIR/bin/" 2>/dev/null | head -10
    exit 1
fi

echo "Using RISC-V GCC: $(which riscv64-unknown-elf-gcc)"
riscv64-unknown-elf-gcc --version | head -1

cd "$BUILD_DIR"

echo "Configuring newlib..."
"$NEWLIB_SRC/configure" \
    --prefix="$INSTALL_DIR" \
    --target="$TARGET" \
    --enable-newlib-io-long-double \
    --enable-newlib-io-long-long \
    --enable-newlib-io-c99-formats \
    --enable-newlib-register-fini \
    --disable-newlib-supplied-syscalls \
    --disable-nls \
    --disable-libssp \
    --disable-libstdcxx-pch \
    --disable-shared \
    --disable-threads \
    --disable-tls

echo ""
echo "Building newlib (this may take 10-15 minutes)..."
make -j$(nproc 2>/dev/null || echo 4) 2>&1 | tee build.log

echo ""
echo "Installing newlib..."
make install

echo ""
echo "==============================================="
echo "Rebuild Complete!"
echo "==============================================="
echo ""
echo "Newlib with medany code model installed to:"
echo "  $INSTALL_DIR/$TARGET/lib/libc.a"
echo ""
echo "You can now build ARA software:"
echo "  cd /data/home/rh_xu30/Work/ara_soc/software"
echo "  make clean && make"
echo ""
