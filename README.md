# ARA SoC 项目

ARA SoC 是一个基于 RISC-V 的片上系统，集成了 CVA6 (Ariane) 64位应用处理器核心和 ARA 向量处理单元 (VPU)，支持 RISC-V 向量扩展 (RVV)。本项目提供从 RTL 到软件、仿真、综合的完整设计流程。

## 项目概述

- **核心架构**: CVA6 标量核 + ARA 向量处理单元
- **向量配置**: 默认 2 个 lanes，VLEN=2048 bits
- **工具链**: LLVM/Clang 17.0.6 + LLD 链接器
- **总线架构**: AXI4 互联
- **验证平台**: EDA01

## 四种 SoC 配置（并列切换）

本项目在文件组织上将四种网表并列区分，通过仿真 `sim/filelist_*.f` 选择：

### 1. Minimum 配置 (`hardware/soc/minimum/`)
- 仅 CVA6 标量核心（无 ARA VPU，无片上 iDMA，**无** `0x7000_0000` ASIC）
- 用于基础功能验证和纯标量应用
- 仓库内另含 **仅 MMIO** 的参考 RTL/驱动（`hardware/user_ip/asic_accel/`、`asic_accel.h`），**默认未接入** 任一网表；若需使用需自行在外设与 filelist 中实例化。

### 2. Minimum + ASIC（片内 DMA）(`hardware/soc/minimum_asic_dma/`)
- 在 minimum 功能集之上 **固定集成** `asic_dma_accel`（配置 AXI slave + DMA AXI master），RTL 与 `minimum/` **分目录维护**，不再用宏在 minimum 内开关。
- 仿真使用 `sim/filelist_minimum_asic_dma.f`（编入 `hardware/soc/filelist_minimum_asic_dma.f`）；软件 `make asic_dma_accel_test`；配置口 `0x7000_0000`（4KB），交叉开关上另有一路 **AXI master** 供片内 DMA 访问 DRAM。

### 3. Minimum + VMMA（VecMatMul + 内部 DMA）(`hardware/soc/minimum_vmma_dma/`)
- 第四套变体：在 minimum 之上集成 **VMMA** 仿真模型 `vmma_top`（`hardware/user_ip/vmma/vmma_sim.sv`：AXI 配置从口 + AXI 主口访存，内部完成 \(Y = W \times X\) 的 INT16 小矩阵与 DMA 写回）。
- 仿真使用 **`sim/filelist_minimum_vmma_dma.f`**；软件 **`make vmma_test`**；MMIO 窗口仍为 **`0x7000_0000`（4KB）**（`soc.h` 中 `VMMA_ACCEL_BASE`，与 `asic_dma` 变体 **互斥**：需选用对应 filelist，不可混用同一仿真镜像）。
- 软件注意：**`W_STRIDE` 须为 8 的倍数**（权重行按 64bit AXI beat 读取）；**写穿 D-cache + 预取** 下 DMA 写回的输出缓冲勿与输入紧邻布置，参见 `DOC.md` / `ASIC_INTEGRATION.md` 中「一致性 / 缓冲布局」说明。

### 4. Maximum 配置 (`hardware/soc/maximum/`)
- 完整配置：CVA6 + ARA VPU + 片上 iDMA
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
make dotproduct            # 建议在maxmimum即带ara_vpu配置下仿真用
make asic_dma_accel_test   # 配合 sim/filelist_minimum_asic_dma.f 仿真用
make vmma_test             # 配合 sim/filelist_minimum_vmma_dma.f 仿真用

# 编译所有 app 用于 FPGA（自动添加 -DTARGET_FPGA，使用 40MHz 时钟，115200 波特率）
# 如不指定，默认是sim（使用 500MHz 时钟，6250000 波特率）
make target=fpga

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

#### Minimum 配置运行步骤（不启用 ARA VPU）

`sim/Makefile` 默认使用 maximum filelist。切到 minimum 时，在 `sim/` 目录下使用**完整仿真 filelist**（含 TB 与 IP），不要单独使用 `hardware/soc/filelist_minimum.f`：

```bash
# 1) 先编译一个标量应用（推荐）
make -C software hello_world

# 2) 编译 minimum SoC 仿真（工作目录为 sim/）
make -C sim vcs FILELIST=filelist_minimum.f

# 3) 运行 minimum SoC
make -C sim vcs-run FILELIST=filelist_minimum.f \
  app=../software/build/bin/hello_world
```

**Minimum + ASIC（片内 DMA）— 第三套网表**（RTL：`hardware/soc/minimum_asic_dma/`）：

```bash
make -C software asic_dma_accel_test
make -C sim clean && make -C sim vcs FILELIST=filelist_minimum_asic_dma.f
make -C sim vcs-run FILELIST=filelist_minimum_asic_dma.f \
  app=../software/build/bin/asic_dma_accel_test
```

**Minimum + VMMA（第四套网表）**（RTL：`hardware/soc/minimum_vmma_dma/`）：

```bash
make -C software vmma_test
make -C sim clean && make -C sim vcs FILELIST=filelist_minimum_vmma_dma.f
make -C sim vcs-run FILELIST=filelist_minimum_vmma_dma.f \
  app=../software/build/bin/vmma_test
```

`asic_dma` 与 `vmma` 两套变体均使用 `0x7000_0000` 作为加速器配置基址，但 **RTL 实例不同**；必须通过 **正确的 `FILELIST`** 选择其一。详见根目录 `DOC.md`、`ASIC_INTEGRATION.md`。

#### Minimum 系列仿真 filelist 对照

| 仿真 filelist（在 `sim/` 下） | 说明 |
|------------------------------|------|
| `filelist_minimum.f` | 纯净 minimum（`hardware/soc/minimum/`），**无** `0x7000_0000` 加速器 |
| `filelist_minimum_asic_dma.f` | 第三套网表（`hardware/soc/minimum_asic_dma/`），`asic_dma_accel`（slave + master DMA） |
| `filelist_minimum_vmma_dma.f` | 第四套网表（`hardware/soc/minimum_vmma_dma/`），`vmma_top`（VecMatMul + 内部 DMA） |

构建与运行 `asic_dma` 测试：`make -C software asic_dma_accel_test`，再使用 `filelist_minimum_asic_dma.f`。RTL：`hardware/user_ip/asic_dma_accel/`；驱动：`asic_dma_accel.h`。

构建与运行 VMMA 测试：`make -C software vmma_test`，再使用 **`filelist_minimum_vmma_dma.f`**。RTL：`hardware/user_ip/vmma/vmma_sim.sv`；驱动：`vmma.h` / `vmma.c`；PLIC 源与 `IRQn_VVMA_ACCEL`（见 `soc.h`）可按需扩展中断路径；当前 `vmma_test` 以轮询 `busy` 为主。

推荐在 minimum 场景优先使用：

- `hello_world`
- `trap_test`
- `clint_test`
- `default_slave`

不建议在 minimum 场景作为首轮验证的应用：

- 依赖向量能力的 `fmatmul` / `dotproduct` / `fdotproduct`
- 依赖 **片上 iDMA**（maximum）的 `dma_desc64_test` / `dma_reg64_1d_test`（与 `asic_dma_accel_test` / `vmma_test` 不同；后两者走各自 **minimum_*** filelist）

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

### Minimum bring-up 工作流

```bash
# 1. 编译基础标量程序
make -C software hello_world trap_test clint_test default_slave

# 2. 编译 minimum 配置仿真（在 sim/ 下使用 filelist_minimum.f）
make -C sim vcs FILELIST=filelist_minimum.f

# 3. 依次运行并检查串口输出
make -C sim vcs-run FILELIST=filelist_minimum.f \
  app=../software/build/bin/hello_world
make -C sim vcs-run FILELIST=filelist_minimum.f \
  app=../software/build/bin/trap_test
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
│   ├── soc/          # SoC 集成（minimum / minimum_asic_dma / minimum_vmma_dma / maximum）
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
| `vmma_test` | VMMA（VecMatMul+DMA）回归 | 需 `filelist_minimum_vmma_dma.f`；INT16 小矩阵 |
| `asic_dma_accel_test` | 片内 DMA ASIC 测试 | 需 `filelist_minimum_asic_dma.f` |
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
4. **换 SoC 变体后仿真行为未变**：`sim/Makefile` 可能未因 `FILELIST` 变化而重编；执行 `make -C sim clean && make -C sim vcs FILELIST=…`，且 **`vcs-run` 必须使用同一 `FILELIST`**

### VMMA / 外设 DMA 读回全 0 或错误

CVA6 默认 **写穿 D-cache**，且无 **Zicbom** 一类软件维护指令时，**硬件预取**可能在加速器写回 DRAM **之前**把输出缓冲所在 cache line 装成旧数据；此后 CPU **命中 D$** 读到的不是 DRAM 真值。缓解办法：**输出缓冲与输入（W/X）在地址上拉开距离**（例如 `vmma_test` 通过链接选项把 `.vmma_dma_out` 放到高地址）、**启动加速器前**对 CPU 写入的源数据执行 `fence ow, ow` 排空写缓冲；长期需在 SoC 层做一致性或非缓存 PMA。详见 `DOC.md` §1.5、`ASIC_INTEGRATION.md` §7。

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

