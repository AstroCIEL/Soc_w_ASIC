# ARA SoC Debug History

## 2025-05-07: 修复仿真编译与 UART 输出

### 问题1: 链接器 undefined symbol 错误
- 现象: memset, exit, errno, puts 等符号未定义
- 解决: 创建 software/sdk/src/minlibc.c 提供最小化 C 库函数

### 问题2: newlib R_RISCV_HI20 重定位错误
- 现象: LLD 报告 R_RISCV_HI20 out of range
- 解决: 改用 minlibc.c 方案替代 newlib

### 问题3: fesvr/elf.h 找不到
- 现象: DPI elfloader.cc 编译失败
- 解决: 安装 RISC-V Spike 到 ~/tools/riscv

### 问题4: Makefile 链接标志错误
- 现象: /data/home/rh_xu30/tools/riscv/lib: file not recognized
- 修复: sim/Makefile 正确分离编译和链接标志

### 问题5: UART 无输出
- 现象: 仿真运行但 uart0.log 为空
- 解决: 修改 minlibc.c 调用 syscalls.c 的 _write() 函数