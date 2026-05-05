#!/usr/bin/env bash
# Fix missing libraries for pre-installed toolchain
# This script builds mpfr 4.x locally to provide libmpfr.so.6

set -e

export http_proxy=http://127.0.0.1:2345
export https_proxy=http://127.0.0.1:2345
export HTTP_PROXY=$http_proxy
export HTTPS_PROXY=$https_proxy
export GIT_SSL_NO_VERIFY=1

# Directories
LOCAL_DIR="/data/home/rh_xu30/tools/local-libs"
SRC_DIR="$LOCAL_DIR/src"
BUILD_DIR="$LOCAL_DIR/build"
INSTALL_DIR="$LOCAL_DIR/install"

# Versions
MPFR_VERSION="4.2.1"
GMP_VERSION="6.3.0"
MPC_VERSION="1.3.1"

mkdir -p "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR"

echo "=== Building missing libraries for toolchain ==="
echo "Install directory: $INSTALL_DIR"
echo ""

# Build GMP (dependency for MPFR)
build_gmp() {
    echo "Downloading and building GMP $GMP_VERSION..."
    cd "$SRC_DIR"
    if [ ! -f "gmp-${GMP_VERSION}.tar.xz" ]; then
        curl -L -o "gmp-${GMP_VERSION}.tar.xz" \
            "https://ftp.gnu.org/gnu/gmp/gmp-${GMP_VERSION}.tar.xz" || \
        wget "https://ftp.gnu.org/gnu/gmp/gmp-${GMP_VERSION}.tar.xz"
    fi
    
    if [ ! -d "gmp-${GMP_VERSION}" ]; then
        tar -xf "gmp-${GMP_VERSION}.tar.xz"
    fi
    
    mkdir -p "$BUILD_DIR/gmp"
    cd "$BUILD_DIR/gmp"
    
    if [ ! -f "$INSTALL_DIR/lib/libgmp.so.10" ]; then
        "$SRC_DIR/gmp-${GMP_VERSION}/configure" \
            --prefix="$INSTALL_DIR" \
            --enable-shared \
            --disable-static
        make -j$(nproc)
        make install
        echo "GMP installed"
    else
        echo "GMP already installed, skipping"
    fi
}

# Build MPFR
build_mpfr() {
    echo ""
    echo "Downloading and building MPFR $MPFR_VERSION..."
    cd "$SRC_DIR"
    if [ ! -f "mpfr-${MPFR_VERSION}.tar.xz" ]; then
        curl -L -o "mpfr-${MPFR_VERSION}.tar.xz" \
            "https://ftp.gnu.org/gnu/mpfr/mpfr-${MPFR_VERSION}.tar.xz" || \
        wget "https://ftp.gnu.org/gnu/mpfr/mpfr-${MPFR_VERSION}.tar.xz"
    fi
    
    if [ ! -d "mpfr-${MPFR_VERSION}" ]; then
        tar -xf "mpfr-${MPFR_VERSION}.tar.xz"
    fi
    
    mkdir -p "$BUILD_DIR/mpfr"
    cd "$BUILD_DIR/mpfr"
    
    if [ ! -f "$INSTALL_DIR/lib/libmpfr.so.6" ]; then
        "$SRC_DIR/mpfr-${MPFR_VERSION}/configure" \
            --prefix="$INSTALL_DIR" \
            --with-gmp="$INSTALL_DIR" \
            --enable-shared \
            --disable-static
        make -j$(nproc)
        make install
        echo "MPFR installed"
    else
        echo "MPFR already installed, skipping"
    fi
}

# Build MPC
build_mpc() {
    echo ""
    echo "Downloading and building MPC $MPC_VERSION..."
    cd "$SRC_DIR"
    if [ ! -f "mpc-${MPC_VERSION}.tar.gz" ]; then
        curl -L -o "mpc-${MPC_VERSION}.tar.gz" \
            "https://ftp.gnu.org/gnu/mpc/mpc-${MPC_VERSION}.tar.gz" || \
        wget "https://ftp.gnu.org/gnu/mpc/mpc-${MPC_VERSION}.tar.gz"
    fi
    
    if [ ! -d "mpc-${MPC_VERSION}" ]; then
        tar -xzf "mpc-${MPC_VERSION}.tar.gz"
    fi
    
    mkdir -p "$BUILD_DIR/mpc"
    cd "$BUILD_DIR/mpc"
    
    if [ ! -f "$INSTALL_DIR/lib/libmpc.so.3" ]; then
        "$SRC_DIR/mpc-${MPC_VERSION}/configure" \
            --prefix="$INSTALL_DIR" \
            --with-gmp="$INSTALL_DIR" \
            --with-mpfr="$INSTALL_DIR" \
            --enable-shared \
            --disable-static
        make -j$(nproc)
        make install
        echo "MPC installed"
    else
        echo "MPC already installed, skipping"
    fi
}

# Main
build_gmp
build_mpfr
build_mpc

echo ""
echo "=== Build Complete ==="
echo ""
echo "Libraries installed to: $INSTALL_DIR/lib"
echo ""
echo "To use these libraries, add to your environment:"
echo "  export LD_LIBRARY_PATH=$INSTALL_DIR/lib:\$LD_LIBRARY_PATH"
echo ""
echo "Or source the updated setup script:"
echo "  source /data/home/rh_xu30/Work/ara_soc/tools/setup-env.sh"
