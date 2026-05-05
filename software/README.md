# ARA Software Build System

This directory contains the software development kit (SDK) and applications for the ARA (Ara RISC-V Accelerator) project.

## Overview

The ARA project is a vector processor implementation based on the RISC-V Vector Extension (RVV). This software directory provides:

- **SDK**: Runtime libraries and headers for ARA applications
- **Applications**: Benchmarks and test programs optimized for vector processing
- **Build System**: Makefile-based compilation system using LLVM/Clang toolchain

## What This Build System Does

The Makefile compiles RISC-V ELF binaries targeting the ARA vector processor. Specifically:

1. **Compiles C/C++ source code** to RISC-V 64-bit with vector extensions (rv64gcv)
2. **Links with ARA runtime** (printf, serial I/O, vector utilities)
3. **Generates disassembly** (.dump files) for debugging
4. **Strips debug symbols** to produce compact binaries for simulation/FPGA

### Target Architecture
- **ISA**: RISC-V RV64GCV (64-bit with general extensions and vector support)
- **Vector Length**: Configurable (default 4096 bits, 4 lanes)
- **ABI**: lp64d (64-bit integers, 64-bit doubles)
- **Memory Model**: medany (medium any - for large memory spaces)

## Prerequisites

### Toolchain
The build system uses a custom LLVM 17.0.6 toolchain with RISC-V support:

```bash
# Setup environment (must do this first!)
source /data/home/rh_xu30/Work/ara_soc/tools/setup-env.sh

# Verify toolchain
clang --version  # Should show "clang version 17.0.6"
```

**Toolchain Components:**
- **clang/clang++**: LLVM C/C++ compiler with RISC-V vector support
- **ld.lld**: LLVM linker (faster than GNU ld)
- **llvm-objdump**: Disassembly generation
- **libgcc**: GCC runtime library (stripped DWARF5 debug info for compatibility)

### System Requirements
- CentOS 7+ or compatible Linux distribution
- Python 3 (for data generation scripts)
- SSH tunnel for network access (if building from source)

## Usage

### Building Applications

```bash
# Build specific application
make hello_world
make fft
make fmatmul

# Build all applications (may stop at math-dependent apps)
make all

# Clean build artifacts
make clean

# Format source code (requires LLVM)
make format
```

### Build Output

Successful builds produce:

```
build/
├── bin/
│   ├── hello_world         # ELF binary (stripped)
│   ├── hello_world.dump    # Disassembly for debugging
│   ├── fft
│   ├── fft.dump
│   └── ...
└── app/
    └── <app_name>/
        └── *.o             # Object files
```

### Available Applications

| Application | Description | Vector Usage |
|-------------|-------------|--------------|
| hello_world | Basic I/O test | None |
| fft | Fast Fourier Transform | Heavy RVV usage |
| fmatmul | Floating-point matrix multiply | RVV vector ops |
| jacobi2d | 2D Jacobi stencil | Vectorizable loops |
| dotproduct | Vector dot product | RVV reduction |
| gemv | Matrix-vector multiply | Vector operations |
| exp/log | Math functions | SIMD math |
| spmv | Sparse matrix-vector | Gather/scatter |

## Important Notes

### 1. Environment Setup Required

**Always source the environment script before building:**

```bash
source /data/home/rh_xu30/Work/ara_soc/tools/setup-env.sh
```

This sets up:
- PATH to include LLVM toolchain
- LD_LIBRARY_PATH for runtime libraries
- http_proxy for network access (via SSH tunnel)

### 2. Known Limitations

**Math Library (libm) Issues:**

Applications using math functions (`sin`, `cos`, `exp`, `log`) from `<math.h>` may fail to link:

```
ld.lld: error: relocation R_RISCV_HI20 out of range
```

**Affected applications:** `softmax`, `conjugate_gradient`, `cos`, `dropout`, `dtype-conv3d`, `dwt`, `fconv2d`, `fconv3d`, etc.

**Workarounds:**
- Use GCC toolchain for math-heavy apps: `make USE_GCC=1 <app>`
- Implement math functions without libm
- Build newlib from source (advanced)

**Successfully working applications:**
- `hello_world`, `fft`, `fmatmul`, `jacobi2d`, `dotproduct`, `gemv`, `exp`, `log`, `spmv`

### 3. Linker Warnings

Non-critical warnings you may see:

```
ld.lld: warning: ignoring memory region assignment for non-allocatable section '.comment'
```

This is harmless - it just means debug comment sections aren't being placed in memory regions.

### 4. Build Stops on Error

The `make all` command processes applications alphabetically and stops on first failure. To build specific working apps:

```bash
# Build working applications individually
make hello_world fft fmatmul jacobi2d dotproduct
```

### 5. Configuration Options

The build system reads configuration from `config/` directory:

```bash
# Use different ARA configuration (lanes, vector length)
make config=8_lanes hello_world  # 8 lanes, different VLEN
```

Default: `config=4_lanes` (4 vector lanes, VLEN=4096)

### 6. Custom Data Generation

Some apps generate data at build time using Python:

```bash
# Force regeneration of data.S files
make clean && make fft

# Use pre-committed data instead of regenerating
make old_data=1 fft
```

## Build System Internals

### Key Files

| File | Purpose |
|------|---------|
| `Makefile` | Top-level build orchestration |
| `sdk/mk/toolchain.mk` | Toolchain detection and compiler flags |
| `sdk/mk/rules.mk` | Compilation pattern rules |
| `sdk/include/` | Runtime headers (serial.h, encoding.h, etc.) |
| `sdk/src/` | Runtime implementation (printf.c, string.c, crt0.S) |
| `sdk/scripts/link.ld` | Linker script (auto-generated) |

### Compiler Flags

**Architecture flags:**
- `-march=rv64gcv_zfh_zvfh`: RV64 with vector, float16 extensions
- `-mabi=lp64d`: 64-bit ABI with doubles
- `-mcmodel=medany`: Medium code model for large memory
- `-mno-relax`: Disable linker relaxation (compatibility)

**Vector flags:**
- `-fno-vectorize`: Disable auto-vectorization
- `-mllvm -scalable-vectorization=off`: Disable LLVM vectorizer
- `-mllvm -riscv-v-vector-bits-min=0`: Disable fixed-width vectors

**Link flags:**
- `-static`: Static linking (no shared libs)
- `-nostartfiles`: Custom startup (crt0.S)
- `-Wl,--gc-sections`: Garbage collect unused sections
- `-rtlib=libgcc`: Use GCC runtime (not compiler-rt)

## Troubleshooting

### "command not found: clang"

**Cause:** Environment not sourced

**Fix:**
```bash
source /data/home/rh_xu30/Work/ara_soc/tools/setup-env.sh
```

### "error: unable to find library -lclang_rt.builtins-riscv64"

**Cause:** Using compiler-rt instead of libgcc

**Fix:** Already configured in current toolchain.mk (uses -rtlib=libgcc)

### "error while loading shared libraries: libtinfo.so.6"

**Cause:** LLVM binary needs newer ncurses

**Fix:** Use environment setup which sets correct LD_LIBRARY_PATH

### DWARF5 relocation errors

**Cause:** GCC 13 libgcc has incompatible debug info

**Fix:** libgcc.a has been stripped of debug sections (see tools/BUILD_LOG.md)

## Simulation and Deployment

After building, binaries can be:

1. **Simulated** using Spike (RISC-V ISA simulator)
2. **Run on FPGA** with ARA hardware implementation
3. **Used for verification** against RTL simulation

Example simulation command:
```bash
# Requires spike installed
spike --isa=rv64gcv_zfh --varch="vlen:4096,elen:64" build/bin/hello_world
```

## References

- **ARA Project**: https://github.com/pulp-platform/ara
- **RISC-V Vector Spec**: https://github.com/riscv/riscv-v-spec
- **LLVM RISC-V**: https://llvm.org/docs/RISCVUsage.html
- **Build Log**: See `../tools/BUILD_LOG.md` for detailed toolchain construction

## License

Copyright 2020 ETH Zurich and University of Bologna.
SPDX-License-Identifier: Apache-2.0
