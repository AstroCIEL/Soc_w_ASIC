#!/usr/bin/env bash
# Rebuild RISC-V toolchain from source on CentOS 7
# This ensures compatibility with the local system libraries

set -e

export http_proxy=http://127.0.0.1:2345
export https_proxy=http://127.0.0.1:2345
export HTTP_PROXY=$http_proxy
export HTTPS_PROXY=$https_proxy
export GIT_SSL_NO_VERIFY=1

# Directories
SRC_DIR="/data/home/rh_xu30/tools/riscv-gnu-toolchain-src"
BUILD_DIR="$SRC_DIR/build-centos7"
INSTALL_DIR="/data/home/rh_xu30/tools/riscv-centos7"

# Make sure source exists
if [ ! -d "$SRC_DIR/.git" ]; then
    echo "ERROR: Source directory $SRC_DIR not found or not a git repo"
    exit 1
fi

mkdir -p "$BUILD_DIR"
mkdir -p "$INSTALL_DIR"

echo "==============================================="
echo "Rebuilding RISC-V Toolchain from Source"
echo "==============================================="
echo "Source: $SRC_DIR"
echo "Build:  $BUILD_DIR"
echo "Install: $INSTALL_DIR"
echo ""
echo "This will take 1-2 hours depending on your system."
echo "==============================================="
echo ""

# Use the local libraries we built earlier for the build process
export LOCAL_LIBS="/data/home/rh_xu30/tools/local-libs/install"
export LD_LIBRARY_PATH="$LOCAL_LIBS/lib:$LD_LIBRARY_PATH"
export PATH="$LOCAL_LIBS/bin:$PATH"

cd "$BUILD_DIR"

# Configure
echo "Configuring toolchain..."
if [ ! -f Makefile ]; then
    "$SRC_DIR/configure" \
        --prefix="$INSTALL_DIR" \
        --with-arch=rv64gcv \
        --with-abi=lp64d \
        --enable-multilib \
        --disable-gdb \
        --disable-qemu-system \
        --disable-qemu-user
fi

# Build
echo ""
echo "Building toolchain (this will take a while)..."
echo "Start time: $(date)"
make -j$(nproc 2>/dev/null || echo 4) 2>&1 | tee build.log

echo ""
echo "==============================================="
echo "Build Complete!"
echo "End time: $(date)"
echo "==============================================="
echo ""
echo "Toolchain installed to: $INSTALL_DIR"
echo ""
echo "To use the new toolchain:"
echo "  export PATH=$INSTALL_DIR/bin:\$PATH"
echo ""
echo "Or update the setup script:"
echo "  source /data/home/rh_xu30/Work/ara_soc/tools/setup-env.sh"
