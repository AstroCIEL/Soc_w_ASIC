# ARA SoC 项目

ARA SoC 是一个基于 RISC-V 的片上系统，集成了 CVA6 (Ariane) 64 位应用处理器核心和 ARA 向量处理单元 (VPU)，支持 RISC-V 向量扩展 (RVV)。本项目提供从 RTL 到软件、仿真、综合、FPGA 的完整设计流程。

## 项目概述

- **核心架构**: CVA6 标量核 + ARA 向量处理单元（可选）
- **向量配置**: 默认 2 个 lanes，VLEN=2048 bits
- **工具链**: LLVM/Clang 17.0.6 + LLD 链接器
- **总线架构**: AXI4 互联
- **验证平台**: EDA01

## SoC 配置（并列切换）

各 SoC 变体在 `hardware/soc/<variant>/` 下独立维护顶层 RTL，通过仿真 `sim/filelist_*.f` 或综合 `SOC_CONFIG` 选择。`sim/Makefile` 默认使用 **`filelist_minimum_my_mxu_axu.f`**。

### 1. Minimum 配置 (`hardware/soc/minimum/`)

- 仅 CVA6 标量核心（无 ARA VPU，无片上 iDMA，**无** `0x7000_0000` 自定义加速器）
- 用于基础功能验证和纯标量应用
- 仿真：`sim/filelist_minimum.f`

### 2. Maximum 配置 (`hardware/soc/maximum/`)

- 完整配置：CVA6 + ARA VPU + 片上 iDMA
- 用于向量计算加速应用
- 仿真：`sim/filelist.f`（引用 `hardware/soc/filelist_maximum.f`）

### 3. Minimum + VMMA (`hardware/soc/minimum_vmma_dma/`)

- 在 minimum 之上集成 **VMMA** 仿真模型 `vmma_top`（`hardware/user_ip/vmma/vmma_sim.sv`：AXI 配置从口 + AXI 主口访存，内部完成 \(Y = W \times X\) 的 INT16 小矩阵与 DMA 写回）
- 仿真：`sim/filelist_minimum_vmma_dma.f`；软件：`make vmma_test`
- MMIO 窗口：**`0x7000_0000`（4KB）**（`soc.h` 中 `VMMA_ACCEL_BASE`）
- 软件注意：**`W_STRIDE` 须为 8 的倍数**；写穿 D-cache + 预取下 DMA 写回缓冲勿与输入紧邻布置，参见 `doc/DOC.md` / `doc/ASIC_INTEGRATION.md`

### 4. Minimum + MXU (`hardware/soc/minimum_my_mxu/`)

- 在 minimum 之上集成自定义 **MXU** 矩阵加速模块（`hardware/user_ip/my_mxu/`）
- MMIO：`0x7000_0000` 起，含配置寄存器与 weight / activation / output 三块 on-chip buffer（各 32KB）
- 仿真：`sim/filelist_minimum_my_mxu.f`；软件：`make my_mxu_test`
- 驱动：`software/soc/include/my_mxu.h`

### 5. Minimum + MXU + AXU (`hardware/soc/minimum_my_mxu_axu/`) — 当前默认仿真配置

- 在 minimum 之上同时集成 **MXU** 与 **AXU**（`hardware/user_ip/my_axu/`），并增加 **global_buffer**、片上 **iDMA**
- MMIO 布局：
  - MXU：`0x7000_0000` – `0x7001_7FFF`
  - AXU：`0x7002_0000` – `0x7003_7FFF`
  - Global Buffer：`0x7004_0000`
  - iDMA：`0x6000_0000`
- 仿真：`sim/filelist_minimum_my_mxu_axu.f`（`sim/Makefile` 默认）
- 软件：`make my_mxu_test`、`make my_axu_test`、`make mxu_idma_gbuf_test`
- 驱动：`my_mxu.h`、`my_axu.h`、`global_buffer.h`
- 综合默认 `SOC_CONFIG=minimum_my_mxu_axu`，详见 [README_SYN.md](README_SYN.md)

### 6. Minimum + DCO

tb为`/data/home/rh_xu30/Work/ara_soc_lite/tb/ariane_soc_minimum_dco_tb.sv`，仿真时用

```bash
cd sim
make vcs FILELIST=filelist_minimum_dco.f VCS_TOP=ariane_soc_minimum_dco_tb
make vcs-run FILELIST=filelist_minimum_dco.f VCS_TOP=ariane_soc_minimum_dco_tb app=../software/build/bin/hello_world
```

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
make dotproduct            # 建议在 maximum（带 ARA VPU）配置下仿真
make vmma_test             # 配合 sim/filelist_minimum_vmma_dma.f
make my_mxu_test           # 配合 sim/filelist_minimum_my_mxu.f 或 filelist_minimum_my_mxu_axu.f
make my_axu_test           # 配合 sim/filelist_minimum_my_mxu_axu.f
make mxu_idma_gbuf_test    # 配合 sim/filelist_minimum_my_mxu_axu.f（MXU + iDMA + global buffer）

# 编译所有 app 用于 FPGA（自动添加 -DTARGET_FPGA，使用 40MHz 时钟，115200 波特率）
# 如不指定，默认是 sim（使用 500MHz 时钟，6250000 波特率）
make target=fpga

# 清理构建
make clean
```

编译输出位于 `software/build/bin/`，包含 ELF 文件和反汇编 `.dump` 文件。

### 仿真运行

#### VCS 仿真（推荐用于调试）

```bash
cd sim

# 编译仿真环境（默认 minimum_my_mxu_axu 配置）
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

#### 各 SoC 配置切换

`sim/Makefile` 通过 `FILELIST` 选择网表。切换变体时建议 **`make clean && make vcs FILELIST=…`**，且 **`vcs-run` 必须使用同一 `FILELIST`**。

**Minimum（纯净标量）**：

```bash
make -C software hello_world
make -C sim clean && make -C sim vcs FILELIST=filelist_minimum.f
make -C sim vcs-run FILELIST=filelist_minimum.f \
  app=../software/build/bin/hello_world
```

**Maximum（CVA6 + ARA VPU + iDMA）**：

```bash
make -C software fmatmul
make -C sim clean && make -C sim vcs FILELIST=filelist.f
make -C sim vcs-run FILELIST=filelist.f \
  app=../software/build/bin/fmatmul
```

**Minimum + VMMA**：

```bash
make -C software vmma_test
make -C sim clean && make -C sim vcs FILELIST=filelist_minimum_vmma_dma.f
make -C sim vcs-run FILELIST=filelist_minimum_vmma_dma.f \
  app=../software/build/bin/vmma_test
```

**Minimum + MXU**：

```bash
make -C software my_mxu_test
make -C sim clean && make -C sim vcs FILELIST=filelist_minimum_my_mxu.f
make -C sim vcs-run FILELIST=filelist_minimum_my_mxu.f \
  app=../software/build/bin/my_mxu_test
```

**Minimum + MXU + AXU（默认）**：

```bash
make -C software my_axu_test
make -C sim vcs   # 默认 FILELIST=filelist_minimum_my_mxu_axu.f
make -C sim vcs-run app=../software/build/bin/my_axu_test
```

**Minimum + DCIM**：

```bash
make -C software dcim_test
make -C sim clean && make -C sim vcs FILELIST=filelist_minimum_dcim.f
make -C sim vcs-run FILELIST=filelist_minimum_dcim.f \
  app=../software/build/bin/dcim_test

# 一键脚本（可选 golden 校验）
DCIM_RUN_GOLDEN=1 ./dcim_shell.sh
```

#### 仿真 filelist 对照

| 仿真 filelist（在 `sim/` 下） | SoC RTL 目录 | 说明 |
|------------------------------|--------------|------|
| `filelist_minimum.f` | `hardware/soc/minimum/` | 纯净 minimum，无自定义加速器 |
| `filelist.f` | `hardware/soc/maximum/` | CVA6 + ARA VPU + 片上 iDMA |
| `filelist_minimum_vmma_dma.f` | `hardware/soc/minimum_vmma_dma/` | VMMA（VecMatMul + 内部 DMA） |
| `filelist_minimum_my_mxu.f` | `hardware/soc/minimum_my_mxu/` | 自定义 MXU 加速模块 |
| `filelist_minimum_my_mxu_axu.f` | `hardware/soc/minimum_my_mxu_axu/` | MXU + AXU + global buffer + iDMA（**默认**） |
| `filelist_minimum_dcim.f` | `hardware/soc/minimum_dcim/` | DCIM wrap（单窗口 MMIO + region decode） |

`vmma` 与 `my_mxu` / `my_mxu_axu` 在 `0x7000_0000` 一带的 MMIO 布局**互斥**，必须通过正确的 `FILELIST` 选择对应 RTL。详见 `doc/DOC.md`、`doc/ASIC_INTEGRATION.md`。

推荐在 minimum 场景优先使用：

- `hello_world`
- `trap_test`
- `clint_test`
- `default_slave`

不建议在 minimum 场景作为首轮验证的应用：

- 依赖向量能力的 `fmatmul` / `dotproduct` / `fdotproduct`（需 maximum）
- 依赖 **maximum 片上 iDMA** 的 `dma_desc64_test` / `dma_reg64_1d_test`（minimum_my_mxu_axu 上有独立 iDMA，可用 `mxu_idma_gbuf_test` 验证）

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

综合流程详见 [README_SYN.md](README_SYN.md)。简要命令：

```bash
cd syn

# 检查 filelist 完整性
make check SOC_CONFIG=minimum_my_mxu_axu

# 综合 MXU / AXU / 顶层 SoC
make flat SYN_TARGET=mxu
make flat SYN_TARGET=axu
make flat SYN_TARGET=top SOC_CONFIG=minimum_my_mxu_axu
```

### FPGA

FPGA 流程位于 `fpga/`，当前 `fpga/filelist.f` 使用 **minimum** 配置（不含 MXU/AXU）。软件编译时指定 `make target=fpga`。

## 典型工作流

### 开发调试流程

```bash
# 1. 编译软件
make -C software fmatmul

# 2. 编译并运行 maximum 仿真，生成波形
make -C sim clean && make -C sim vcs FILELIST=filelist.f
make -C sim vcs-wave FILELIST=filelist.f app=../software/build/bin/fmatmul

# 3. 查看波形（另一个终端）
make -C sim verdi

# 4. 调试完成后清理
make -C sim clean
```

### Minimum bring-up 工作流

```bash
# 1. 编译基础标量程序
make -C software hello_world trap_test clint_test default_slave

# 2. 编译 minimum 配置仿真
make -C sim clean && make -C sim vcs FILELIST=filelist_minimum.f

# 3. 依次运行并检查串口输出
make -C sim vcs-run FILELIST=filelist_minimum.f \
  app=../software/build/bin/hello_world
make -C sim vcs-run FILELIST=filelist_minimum.f \
  app=../software/build/bin/trap_test
```

### MXU + AXU 加速器验证

```bash
make -C software my_mxu_test my_axu_test
make -C sim vcs   # 默认 minimum_my_mxu_axu
make -C sim vcs-run app=../software/build/bin/my_mxu_test
make -C sim vcs-run app=../software/build/bin/my_axu_test
```

### 批量回归测试

```bash
# 编译所有软件测试
make -C software all

# 运行所有测试（需与当前 FILELIST 匹配的应用）
for app in ../software/build/bin/*; do
    echo "Testing: $app"
    make verilator-run app=$app
done
```

## 项目目录结构

```
ara_soc/
├── hardware/         # RTL 硬件设计
│   ├── ip/           # IP 核（CVA6、ARA、AXI、DMA 等）
│   ├── soc/          # SoC 集成（minimum / maximum / minimum_vmma_dma /
│   │                 #   minimum_my_mxu / minimum_my_mxu_axu）
│   ├── tech/         # 工艺库和存储器 wrapper（sim / syn / fpga）
│   └── user_ip/      # 用户自定义 IP（my_mxu、my_axu、vmma、sram_buffer 等）
├── software/         # 软件 BSP
│   ├── app/          # 应用程序
│   ├── sdk/          # SDK 运行时库
│   ├── soc/          # SoC 外设驱动
│   └── scripts/      # 构建脚本
├── sim/              # 仿真环境（VCS + Verilator）
├── sim_pre_syn/      # 综合后网表仿真（MXU/AXU netlist shim）
├── tb/               # 测试台文件
├── syn/              # Design Compiler 综合脚本
├── fpga/             # Vivado FPGA 流程
├── doc/              # 技术文档
└── config/           # 配置文件
```

## 应用列表

| 应用 | 说明 | 适用 SoC 配置 |
|------|------|---------------|
| `hello_world` | 基础功能测试，UART 输出 | 全部 |
| `trap_test` | 异常处理测试 | minimum 系列 |
| `clint_test` | 定时器 / CLINT 中断 | minimum 系列 |
| `default_slave` | 默认从设备 / PLIC 中断 | minimum 系列 |
| `fmatmul` | 浮点矩阵乘法（RVV） | maximum |
| `dotproduct` | 向量点积 | maximum |
| `fdotproduct` | 浮点向量点积（RVV） | maximum |
| `dma_desc64_test` | DMA 描述符测试 | maximum |
| `dma_reg64_1d_test` | DMA 寄存器 1D 测试 | maximum |
| `vmma_test` | VMMA（VecMatMul + DMA）回归 | `filelist_minimum_vmma_dma.f` |
| `my_mxu_test` | MXU 矩阵加速回归 | `filelist_minimum_my_mxu.f` 或 `filelist_minimum_my_mxu_axu.f` |
| `my_axu_test` | AXU 向量 / SFU / NLI / SCH 回归 | `filelist_minimum_my_mxu_axu.f` |
| `mxu_idma_gbuf_test` | MXU + iDMA + global buffer 联调 | `filelist_minimum_my_mxu_axu.f` |

## 配置参数

在 `config/default.mk` 或 `software/Makefile` 中可配置硬件参数：

```makefile
nr_lanes ?= 2      # 向量处理器 lane 数量
vlen     ?= 2048   # 向量寄存器位宽（VLEN）
```

## 调试技巧

### 查看 UART 输出

仿真运行时，UART 输出会同时输出到：

- 仿真终端
- `sim/uart0.log` 文件

### 查看指令追踪

仿真后会生成：

- `sim/trace_hart_0.log` — 完整指令追踪
- `sim/trace_hart_0_commit.log` — 提交指令追踪

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

CVA6 默认 **写穿 D-cache**，且无 **Zicbom** 一类软件维护指令时，**硬件预取**可能在加速器写回 DRAM **之前**把输出缓冲所在 cache line 装成旧数据；此后 CPU **命中 D$** 读到的不是 DRAM 真值。缓解办法：**输出缓冲与输入（W/X）在地址上拉开距离**、**启动加速器前**对 CPU 写入的源数据执行 `fence ow, ow` 排空写缓冲；长期需在 SoC 层做一致性或非缓存 PMA。详见 `doc/DOC.md`、`doc/ASIC_INTEGRATION.md`。

## 扩展开发

### 添加自定义加速器

要为 SoC 添加自定义加速器，推荐像 `minimum_my_mxu` / `minimum_my_mxu_axu` 一样 **复制并维护独立顶层目录**：

1. **在 `hardware/user_ip/` 下创建新目录**
   ```
   hardware/user_ip/my_accelerator/
   ├── my_accelerator.sv
   └── filelist_sim.f
   ```

2. **新建 SoC 变体目录**（如 `hardware/soc/minimum_my_accel/`）
   - 修改 `ariane_soc_pkg.sv`：添加 AXI 从设备枚举与基地址
   - 修改 `ariane_peripherals.sv`：实例化并连接加速器
   - 添加 `hardware/soc/filelist_minimum_my_accel.f` 与 `sim/filelist_minimum_my_accel.f`

3. **添加软件驱动**
   - 在 `software/soc/src/` 创建驱动
   - 在 `software/app/` 创建测试应用

详细步骤请参考 `doc/DOC.md`、`doc/ASIC_INTEGRATION.md`，以及 `doc/如何修改hardware文件夹下的内容？.md`。

## 参考文档

- [doc/DOC.md](doc/DOC.md) — 详细技术文档（硬件架构、软件模块、仿真逻辑）
- [doc/ASIC_INTEGRATION.md](doc/ASIC_INTEGRATION.md) — 自定义加速器集成指南
- [doc/DEBUG.md](doc/DEBUG.md) — 调试说明
- [README_SYN.md](README_SYN.md) — Design Compiler 综合流程
- [sim/README.md](sim/README.md) — 仿真环境详细说明
- [software/README.md](software/README.md) — 软件 BSP 详细说明
