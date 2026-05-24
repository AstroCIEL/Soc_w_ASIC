set -euo pipefail

###############################################################################
# config
###############################################################################
PREFIX=/opt/riscv-llvm
TARGET=riscv64-unknown-elf
SYSROOT="${PREFIX}/${TARGET}"
ARCH_FLAGS="-march=rv64gc -mabi=lp64d -mno-relax -mcmodel=medany"
JOBS="${JOBS:-24}"

LLVM_SRC=/workspace/llvm-project
NEWLIB_SRC=/workspace/newlib-cygwin

mkdir -p "${PREFIX}" "${PREFIX}/xbin"

###############################################################################
# helpers
###############################################################################
msg() {
  printf '\n\033[1;34m==> %s\033[0m\n' "$*"
}

link_if_tool_exists() {
  local dst_name="$1"
  local src_name="$2"
  if [ -x "${PREFIX}/bin/${src_name}" ]; then
    ln -sfn "${PREFIX}/bin/${src_name}" "${PREFIX}/xbin/${TARGET}-${dst_name}"
  fi
}

# ###############################################################################
# # 1) LLVM / Clang / LLD / clang-tools-extra
# ###############################################################################
msg "Build and install LLVM/Clang/LLD"

cmake -S "${LLVM_SRC}/llvm" -B "${LLVM_SRC}/build-riscv" -G Ninja \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER=gcc \
  -DCMAKE_CXX_COMPILER=g++ \
  -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;lld" \
  -DLLVM_DEFAULT_TARGET_TRIPLE="${TARGET}" \
  -DLLVM_TARGETS_TO_BUILD="RISCV" \
  -DLLVM_INSTALL_UTILS=ON \
  -DLLVM_INCLUDE_TESTS=OFF \
  -DLLVM_INCLUDE_BENCHMARKS=OFF \
  -DLLVM_INCLUDE_EXAMPLES=OFF

cmake --build "${LLVM_SRC}/build-riscv" --target install -j "${JOBS}"

# ###############################################################################
# # 2) newlib
# ###############################################################################
msg "Build and install newlib"

rm -rf "${NEWLIB_SRC}/build-riscv"
mkdir -p "${NEWLIB_SRC}/build-riscv"
cd "${NEWLIB_SRC}/build-riscv"

../configure \
  --prefix="${PREFIX}" \
  --target="${TARGET}" \
  CC_FOR_TARGET="${PREFIX}/bin/clang --target=${TARGET} --sysroot=${SYSROOT} -fuse-ld=lld ${ARCH_FLAGS} -Wno-error=implicit-function-declaration -Wno-error=int-conversion" \
  AS_FOR_TARGET="${PREFIX}/bin/clang --target=${TARGET} --sysroot=${SYSROOT} -c ${ARCH_FLAGS}" \
  AR_FOR_TARGET="${PREFIX}/bin/llvm-ar" \
  NM_FOR_TARGET="${PREFIX}/bin/llvm-nm" \
  RANLIB_FOR_TARGET="${PREFIX}/bin/llvm-ranlib" \
  LD_FOR_TARGET="${PREFIX}/bin/ld.lld"

make MAKEINFO=true -j "${JOBS}"
make MAKEINFO=true install

# ###############################################################################
# # 3) compiler-rt builtins (standalone bare-metal)
# ###############################################################################
msg "Build and install compiler-rt builtins"

RESOURCE_DIR="$("${PREFIX}/bin/clang" --target="${TARGET}" --print-resource-dir)"
CANONICAL_TARGET="$("${PREFIX}/bin/clang" --target="${TARGET}" --print-target-triple)"

rm -rf "${LLVM_SRC}/compiler-rt/build-riscv"
cmake -S "${LLVM_SRC}/compiler-rt" -B "${LLVM_SRC}/compiler-rt/build-riscv" -G Ninja \
  -DCMAKE_INSTALL_PREFIX="${RESOURCE_DIR}" \
  -DLLVM_CMAKE_DIR="${PREFIX}/lib/cmake/llvm" \
  -DLLVM_CONFIG_PATH="${PREFIX}/bin/llvm-config" \
  -DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY \
  -DCMAKE_SYSROOT="${SYSROOT}" \
  -DCMAKE_C_COMPILER="${PREFIX}/bin/clang" \
  -DCMAKE_C_COMPILER_TARGET="${TARGET}" \
  -DCMAKE_CXX_COMPILER="${PREFIX}/bin/clang++" \
  -DCMAKE_CXX_COMPILER_TARGET="${TARGET}" \
  -DCMAKE_ASM_COMPILER="${PREFIX}/bin/clang" \
  -DCMAKE_ASM_COMPILER_TARGET="${TARGET}" \
  -DCMAKE_AR="${PREFIX}/bin/llvm-ar" \
  -DCMAKE_NM="${PREFIX}/bin/llvm-nm" \
  -DCMAKE_RANLIB="${PREFIX}/bin/llvm-ranlib" \
  -DCMAKE_C_FLAGS="--target=${TARGET} --sysroot=${SYSROOT} ${ARCH_FLAGS}" \
  -DCMAKE_CXX_FLAGS="--target=${TARGET} --sysroot=${SYSROOT} ${ARCH_FLAGS}" \
  -DCMAKE_ASM_FLAGS="--target=${TARGET} --sysroot=${SYSROOT} ${ARCH_FLAGS}" \
  -DCOMPILER_RT_BAREMETAL_BUILD=ON \
  -DCOMPILER_RT_OS_DIR=baremetal \
  -DCOMPILER_RT_BUILD_BUILTINS=ON \
  -DCOMPILER_RT_BUILD_CRT=OFF \
  -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
  -DCOMPILER_RT_BUILD_MEMPROF=OFF \
  -DCOMPILER_RT_BUILD_PROFILE=OFF \
  -DCOMPILER_RT_BUILD_CTX_PROFILE=OFF \
  -DCOMPILER_RT_BUILD_SANITIZERS=OFF \
  -DCOMPILER_RT_BUILD_XRAY=OFF \
  -DCOMPILER_RT_BUILD_ORC=OFF \
  -DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON

cmake --build "${LLVM_SRC}/compiler-rt/build-riscv" --target install -j "${JOBS}"

# ###############################################################################
# # 4) Normalize compiler-rt runtime layout inside resource dir
# ###############################################################################
msg "Normalize compiler-rt runtime layout"

mkdir -p "${RESOURCE_DIR}/lib"

PRIMARY_BUILTINS="$(
  find "${RESOURCE_DIR}/lib" -maxdepth 3 -type f -name 'libclang_rt.builtins*.a' | head -n1 || true
)"

if [ -z "${PRIMARY_BUILTINS}" ]; then
  echo "error: compiler-rt builtins were not installed under ${RESOURCE_DIR}/lib" >&2
  echo "debug: current contents:" >&2
  find "${RESOURCE_DIR}" -maxdepth 4 -print >&2 || true
  exit 1
fi

mkdir -p "${RESOURCE_DIR}/lib/${TARGET}"
ln -sfn "${PRIMARY_BUILTINS}" "${RESOURCE_DIR}/lib/${TARGET}/libclang_rt.builtins.a"

if [ "${CANONICAL_TARGET}" != "${TARGET}" ]; then
  mkdir -p "${RESOURCE_DIR}/lib/${CANONICAL_TARGET}"
  ln -sfn "${PRIMARY_BUILTINS}" "${RESOURCE_DIR}/lib/${CANONICAL_TARGET}/libclang_rt.builtins.a"
fi

###############################################################################
# 5) xbin wrappers: target-prefixed clang / clang++
###############################################################################
msg "Install xbin compiler wrappers"

cat > "${PREFIX}/xbin/${TARGET}-clang" <<EOF
#!/usr/bin/env bash
exec "${PREFIX}/bin/clang" --target=${TARGET} --sysroot=${SYSROOT} "\$@"
EOF

cat > "${PREFIX}/xbin/${TARGET}-clang++" <<EOF
#!/usr/bin/env bash
exec "${PREFIX}/bin/clang++" --target=${TARGET} --sysroot=${SYSROOT} "\$@"
EOF

chmod +x \
  "${PREFIX}/xbin/${TARGET}-clang" \
  "${PREFIX}/xbin/${TARGET}-clang++"

###############################################################################
# 6) xbin prefixed tools
###############################################################################
msg "Install xbin prefixed tools"

link_prefixed() {
  local out_name="$1"
  local real_name="$2"
  if [ -x "${PREFIX}/bin/${real_name}" ]; then
    ln -sfn "${PREFIX}/bin/${real_name}" "${PREFIX}/xbin/${TARGET}-${out_name}"
  fi
}


# # GNU-style prefixed names
# link_prefixed ar          llvm-ar
# link_prefixed ranlib      llvm-ranlib
# link_prefixed nm          llvm-nm
# link_prefixed objdump     llvm-objdump
# link_prefixed objcopy     llvm-objcopy
# link_prefixed readelf     llvm-readelf
# link_prefixed strip       llvm-strip
# link_prefixed addr2line   llvm-addr2line
# link_prefixed size        llvm-size
# link_prefixed strings     llvm-strings
# link_prefixed c++filt     llvm-cxxfilt
# link_prefixed symbolizer  llvm-symbolizer

# LLVM-style prefixed names
link_prefixed llvm-ar         llvm-ar
link_prefixed llvm-ranlib     llvm-ranlib
link_prefixed llvm-nm         llvm-nm
link_prefixed llvm-objdump    llvm-objdump
link_prefixed llvm-objcopy    llvm-objcopy
link_prefixed llvm-readelf    llvm-readelf
link_prefixed llvm-strip      llvm-strip
link_prefixed llvm-addr2line  llvm-addr2line
link_prefixed llvm-size       llvm-size
link_prefixed llvm-strings    llvm-strings
link_prefixed llvm-cxxfilt    llvm-cxxfilt
link_prefixed llvm-symbolizer llvm-symbolizer

if [ -x "${PREFIX}/bin/ld.lld" ]; then
  ln -sfn "${PREFIX}/bin/ld.lld" "${PREFIX}/xbin/${TARGET}-ld"
  ln -sfn "${PREFIX}/bin/ld.lld" "${PREFIX}/xbin/${TARGET}-ld.lld"
fi

###############################################################################
# 7) sanity checks
###############################################################################
msg "Sanity checks"

echo "-- compiler wrapper target triple"
"${PREFIX}/xbin/${TARGET}-clang" --print-target-triple

echo "-- resource dir"
"${PREFIX}/xbin/${TARGET}-clang" --print-resource-dir

echo "-- sysroot headers"
test -f "${SYSROOT}/include/string.h"
echo "found: ${SYSROOT}/include/string.h"

echo "-- compiler-rt builtins"
find "${RESOURCE_DIR}/lib" -maxdepth 3 -name 'libclang_rt.builtins*.a' -print | sort

echo "-- xbin tools"
ls -1 "${PREFIX}/xbin" | sort
