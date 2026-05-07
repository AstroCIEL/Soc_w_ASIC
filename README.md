# ARA SoC 项目

ARA SoC 是一个基于 RISC-V 的片上系统，集成了 CVA6 (Ariane) 64位应用处理器核心和 ARA 向量处理单元 (VPU)，支持 RISC-V 向量扩展 (RVV)。本项目提供从 RTL 到软件、仿真、综合的完整设计流程。

## 项目概述

- **核心架构**: CVA6 标量核 + ARA 向量处理单元
- **向量配置**: 默认 2 个 lanes，VLEN=2048 bits
- **工具链**: LLVM/Clang 17.0.6 + LLD 链接器
- **总线架构**: AXI4 互联
- **验证平台**: EDA01

## 两种配置模式

本项目支持两种 SoC 配置：

### 1. Minimum 配置 (`hardware/soc/minimum/`)
- 仅 CVA6 标量核心（无 ARA VPU，无 DMA）
- 用于基础功能验证和纯标量应用

### 2. Maximum 配置 (`hardware/soc/maximum/`)
- 完整配置：CVA6 + ARA VPU + DMA
- 用于向量计算加速应用

## 快速开始

### 前置条件

1. **LLVM/Clang 工具链**
   - 安装路径：`/data/home/rh_xu30/tools/llvm_install`
   - 工具链路径：`/data/home/rh_xu30/tools/llvm_toolchain`
   - 项目中通过软链接 `install` 和 `tools` 指向上述路径

2. **仿真工具（二选一）**
   - **VCS** (推荐): `/home/EDAtools/synopsys/vcs/V-2023.12-SP1`
   - **Verilator**: 开源免费，仿真速度快

3. **其他依赖**
   - RISC-V fesvr (Front-End Server): `$(HOME)/tools/riscv`
   - GCC 11+ (用于 DPI-C 编译)

### 软件编译

```bash
cd software

# 编译所有应用
make all

# 或编译特定应用
make hello_world
make fmatmul
make dotproduct

# 清理构建
make clean
```

编译输出位于 `software/build/bin/`，包含 ELF 文件和反汇编 `.dump` 文件。

### 仿真运行

#### VCS 仿真（推荐用于调试）

```bash
cd sim

# 编译仿真环境
make vcs

# 运行默认应用 (hello_world)
make vcs-run

# 运行指定应用
make vcs-run app=../software/build/bin/fmatmul

# 运行并生成 FSDB 波形（用于 Verdi 查看）
make vcs-wave app=../software/build/bin/dma_desc64_test

# 使用 Verdi 查看波形
make verdi
```

#### Verilator 仿真（开源免费）

```bash
cd sim

# 编译仿真环境
make verilate

# 运行默认应用
make verilator-run

# 运行指定应用
make verilator-run app=../software/build/bin/dotproduct

# 运行并生成 FST 波形
make verilator-wave app=../software/build/bin/fmatmul
```

### 综合

```bash
cd syn

# 运行 Design Compiler 综合
make syn

# 检查文件列表完整性
make check
```

## 典型工作流

### 开发调试流程

```bash
# 1. 编译软件
make -C ../software fmatmul

# 2. 编译并运行仿真，生成波形
make vcs-wave app=../software/build/bin/fmatmul

# 3. 查看波形（另一个终端）
make verdi

# 4. 调试完成后清理
make clean
```

### 批量回归测试

```bash
# 编译所有软件测试
make -C ../software all

# 运行所有测试
for app in ../software/build/bin/*; do
    echo "Testing: $app"
    make verilator-run app=$app
done
```

## 项目目录结构

```
ara_soc/
├── hardware/         # RTL 硬件设计
│   ├── ip/           # IP 核（CVA6、ARA、AXI、DMA等）
│   ├── soc/          # SoC 集成（minimum/maximum配置）
│   ├── tech/         # 工艺库和存储器wrapper
│   └── user_ip/      # 用户自定义IP
├── software/         # 软件 BSP
│   ├── app/          # 应用程序
│   ├── sdk/          # SDK运行时库
│   ├── soc/          # SoC外设驱动
│   └── scripts/      # 构建脚本
├── sim/              # 仿真环境（VCS + Verilator）
├── tb/               # 测试台文件
├── syn/              # 综合脚本
└── config/           # 配置文件
```

## 应用列表

| 应用 | 说明 | 特性 |
|------|------|------|
| `hello_world` | 基础功能测试 | UART输出 |
| `fmatmul` | 浮点矩阵乘法 | RVV向量指令 |
| `dotproduct` | 向量点积 | 整数/浮点向量 |
| `fdotproduct` | 浮点向量点积 | RVV向量指令 |
| `dma_desc64_test` | DMA描述符测试 | 中断、链式传输 |
| `dma_reg64_1d_test` | DMA寄存器1D测试 | 1D内存拷贝 |
| `clint_test` | 定时器测试 | CLINT中断 |
| `default_slave` | 默认从设备测试 | PLIC中断 |
| `trap_test` | 异常测试 | 异常处理 |

## 配置参数

在 `config/default.mk` 中可配置硬件参数：

```makefile
nr_lanes ?= 2      # 向量处理器lane数量
vlen     ?= 2048   # 向量寄存器位宽（VLEN）
```

## 调试技巧

### 查看 UART 输出

仿真运行时，UART 输出会同时输出到：
- 仿真终端
- `sim/uart0.log` 文件

### 查看指令追踪

仿真后会生成：
- `sim/trace_hart_0.log` - 完整指令追踪
- `sim/trace_hart_0_commit.log` - 提交指令追踪

### 使用函数追踪

```bash
# 在仿真命令中添加 ftrace 参数
make vcs-run app=../software/build/bin/fmatmul +ftrace

# 查看函数调用追踪
cat sim/ftrace.log
```

## 常见问题

### 许可证问题

```bash
# 检查 VCS 许可证
lmstat -c 27000@license_server -a | grep vcs

# 如果许可证不足，使用 Verilator 免费方案
make verilate
```

### 编译错误

1. **文件找不到**：检查 `filelist.f` 中的相对路径
2. **DPI 编译错误**：确保 C++ 编译器支持 C++17 (`-std=c++17`)
3. **内存不足**：VCS 编译需要较大内存，尝试减少并行任务

## 扩展开发

### 添加自定义 ASIC

要为 SoC 添加自定义 ASIC：

1. **在 `hardware/user_ip/` 下创建新目录**
   ```
   hardware/user_ip/my_accelerator/
   ├── my_accelerator.sv
   └── filelist_sim.f
   ```

2. **在 AXI 总线上添加新设备**
   - 在 `ariane_soc_pkg.sv` 中添加新的 AXI 从设备
   - 在 `ariane_soc_top.sv` 中实例化并连接到 AXI Crossbar

3. **添加软件驱动**
   - 在 `software/soc/src/` 创建驱动
   - 在 `software/app/` 创建测试应用

详细步骤请参考 DOC.md 文档。

## 参考文档

- [DOC.md](DOC.md) - 详细技术文档（硬件架构、软件模块、仿真逻辑）
- `sim/README.md` - 仿真环境详细说明
- `software/README.md` - 软件 BSP 详细说明

