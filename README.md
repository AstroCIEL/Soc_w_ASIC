# ARA_SOC

Minimum implementation without vpu and dma. To compile c code into riscv, you should first install gcc and llvm, clang.

## software

Tested on EDA01. llvm installed at `/data/home/rh_xu30/tools/llvm_install` and llvm toolchain installed at `/data/home/rh_xu30/tools/llvm_toolchain`. In this project, softlink `install` to `/data/home/rh_xu30/tools/llvm_install` and `tools` to `/data/home/rh_xu30/tools/llvm_toolchain`.

```
cd software
make # compile with riscv-llvm
```

## simulation
```
cd sim
make vcs
make vcs-run app=xxx.elf
```


## syn
```
cd syn
make syn
```