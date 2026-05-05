# RISC-V LLVM Toolchain Setup

This directory manages the RISC-V toolchain for the ARA project.

## Status: Toolchain Already Installed

✅ **You already have a complete RISC-V toolchain installed at:**
```
~/tools/riscv/
```

This includes:
- **LLVM/Clang 17** - Modern RISC-V compiler with vector support
- **GCC 13.2.0** - GNU RISC-V toolchain
- **LLD** - LLVM linker
- **GDB** - Debugger

## Quick Setup

### Option 1: Source the Environment Script

```bash
source /data/home/rh_xu30/Work/ara_soc/tools/setup-env.sh
```

This sets up:
- `PATH` to include `~/tools/riscv/bin`
- `LD_LIBRARY_PATH` for clang shared libraries
- HTTP proxy for network access

### Option 2: Manual Setup

```bash
export PATH="/data/home/rh_xu30/tools/riscv/bin:$PATH"
export LD_LIBRARY_PATH="/data/home/rh_xu30/tools/riscv/lib:$LD_LIBRARY_PATH"
```

## Verify Toolchain

```bash
# Test LLVM/Clang
clang --version
clang -target riscv64-unknown-elf --version

# Test GCC
riscv64-unknown-elf-gcc --version

# Test linker
ld.lld --version
```

## Building Software

Once the environment is set up, build ARA software:

```bash
cd /data/home/rh_xu30/Work/ara_soc/software
make hello_world   # Build specific application
make all           # Build all applications
```

## Toolchain Detection Priority

The build system automatically detects toolchains in this order:

1. **User pre-installed** (`~/tools/riscv/`) ← **Current**
2. **Project-local built** (`install/riscv-llvm/`)
3. **System pre-installed** (`/opt/riscv-llvm/`)

## Troubleshooting

### Clang: "error while loading shared libraries"

**Solution:** Set `LD_LIBRARY_PATH`:
```bash
export LD_LIBRARY_PATH="/data/home/rh_xu30/tools/riscv/lib:$LD_LIBRARY_PATH"
```

Or source the setup script:
```bash
source tools/setup-env.sh
```

### Network Access (Downloads)

The setup script configures HTTP proxy via your SSH tunnel:
```
http_proxy=http://127.0.0.1:2345
```

Ensure your tunnel is active:
```bash
# On your local machine:
ssh -N -R 2345:127.0.0.1:7890 rh_xu30@<remote-host>
```

### Missing Spike Simulator

If you need the Spike RISC-V ISA simulator:

```bash
# Option 1: Check if it exists elsewhere
which spike
find /data/home/rh_xu30/tools -name "spike" 2>/dev/null

# Option 2: Build from source (see Makefile targets below)
```

## Rebuilding from Source (Optional)

If you need to rebuild the toolchain from source:

```bash
cd /data/home/rh_xu30/Work/ara_soc/tools

# Check dependencies
./check-deps.sh

# Build LLVM from source (takes 1-3 hours)
make llvm LLVM_VERSION=17.0.6

# Or use existing source at ~/tools/riscv-gnu-toolchain-src/
```

### Makefile Targets

| Target | Description |
|--------|-------------|
| `make status` | Check toolchain status |
| `make llvm` | Build LLVM from source |
| `make clean` | Clean build artifacts |
| `make distclean` | Remove everything including source |

## Directory Structure

```
~/tools/
├── riscv/                      # Pre-installed toolchain
│   ├── bin/clang, clang++     # LLVM 17
│   ├── bin/lld, llvm-*        # LLVM tools
│   ├── bin/riscv64-unknown-* # GCC toolchain
│   └── lib/libclang.so*       # Shared libraries
│
└── riscv-gnu-toolchain-src/    # Source code (if needed for rebuild)
    ├── llvm/                   # LLVM source
    ├── gcc/                    # GCC source
    └── binutils/               # Binutils source
```

## Toolchain Details

- **LLVM Version:** 17.x
- **GCC Version:** 13.2.0
- **Target:** riscv64-unknown-elf
- **Supported Extensions:** rv64gcv, zfh (vector, half-precision float)

## References

- [ARA Documentation](https://github.com/pulp-platform/ara)
- [RISC-V GNU Toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain)
- [LLVM Project](https://llvm.org/)
