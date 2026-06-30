# ARA SoC 技术文档

本文档详细介绍 ARA SoC 的软件模块、硬件架构和仿真逻辑，帮助开发者理解系统并扩展自定义 ASIC。

---

## 1. 软件部分 (software/)

### 1.1 目录结构

```
software/
├── Makefile           # 主构建系统
├── app/               # 应用程序
│   ├── hello_world/   # 基础测试
│   ├── fmatmul/       # 浮点矩阵乘法（maximum）
│   ├── dotproduct/    # 向量点积（maximum）
│   ├── fdotproduct/   # 浮点点积（maximum）
│   ├── dma_desc64_test/  # DMA 描述符测试（maximum）
│   ├── dma_reg64_1d_test/# DMA 寄存器测试（maximum）
│   ├── vmma_test/         # minimum_vmma_dma：VMMA（VecMatMul + 内部 DMA）
│   ├── dcim_test/         # minimum_dcim：DCIM wrap smoke / kick
│   ├── my_mxu_test/       # minimum_my_mxu / minimum_my_mxu_axu：MXU 回归
│   ├── my_axu_test/       # minimum_my_mxu_axu：AXU 回归
│   ├── mxu_idma_gbuf_test/# minimum_my_mxu_axu：MXU + iDMA + global buffer
│   ├── clint_test/    # 定时器中断测试
│   ├── default_slave/ # 默认从设备测试
│   └── trap_test/     # 异常处理测试
├── sdk/               # 软件开发套件
│   ├── src/           # 运行时库源码
│   │   ├── crt0.S     # 启动代码
│   │   ├── printf.c   # 轻量级 printf
│   │   ├── string.c   # 字符串操作
│   │   ├── syscalls.c # 系统调用桩
│   │   └── util.c     # 工具函数
│   └── include/       # SDK头文件
├── soc/               # SoC外设驱动
│   ├── src/           # 驱动源码
│   │   ├── serial.c   # UART驱动
│   │   ├── plic.c     # PLIC中断控制器
│   │   ├── clint.c    # CLINT定时器
│   │   ├── soc_ctrl.c # SoC控制
│   │   ├── dma_desc64.c  # DMA描述符接口
│   │   ├── dma_reg64_1d.c# DMA寄存器接口
│   │   ├── my_mxu.c      # MXU 驱动（minimum_my_mxu / minimum_my_mxu_axu）
│   │   ├── my_axu.c      # AXU 驱动（minimum_my_mxu_axu）
│   │   ├── vmma.c        # VMMA 驱动（minimum_vmma_dma）
│   │   ├── dcim.c        # DCIM 驱动（minimum_dcim）
│   │   ├── asic_dma_accel.c # 遗留参考驱动（网表已移除，不再接入）
│   │   └── asic_accel.c  # MMIO ASIC 参考驱动（默认未接入 SoC）
│   └── include/       # 驱动头文件
│       ├── my_mxu.h
│       ├── dcim.h
│       ├── my_axu.h
│       ├── global_buffer.h  # global_buffer MMIO 布局（minimum_my_mxu_axu）
│       └── ...
├── common/            # 通用代码
├── build/             # 构建输出
└── scripts/           # 构建脚本
    ├── toolchain.mk   # 工具链配置
    ├── rules.mk       # 构建规则
    └── link.ld        # 链接器脚本
```

### 1.2 各模块逻辑与用途

#### SDK 模块 (`sdk/`)

**启动流程 (crt0.S)**
- 设置栈指针 (SP)
- 清零 BSS 段
- 跳转到 `main()` 函数

**printf 实现 (`printf.c`)**
- 轻量级格式化输出，通过 UART 输出
- 支持基本的 `%d`, `%s`, `%x`, `%f` 等格式

**系统调用 (`syscalls.c`)**
- 实现基础 I/O 的系统调用桩
- 使用 `-nostdlib` 避免 newlib 的 LLD 兼容性问题

**工具函数 (`util.c`)**
- `start_timer()`, `stop_timer()`, `get_timer()`: 性能计时
- `similarity_check()`: 浮点结果验证

#### SoC 驱动模块 (`soc/`)

**UART 驱动 (`serial.c`)**
```c
void serial_init(void);           // 初始化 UART
void serial_putchar(char c);      // 输出单个字符
void serial_puts(const char *s);  // 输出字符串
```
- 波特率：6250000 (6.25 Mbaud)
- 通过 AXI 总线访问 UART 寄存器 (基地址: 0x1000_0000)

**PLIC 中断控制器 (`plic.c`)**
```c
void plic_init(void);
void plic_irq_enable(uint32_t irq_id);
void plic_irq_disable(uint32_t irq_id);
```
- 支持 30 个中断源
- 优先级可配置 (最大 7 级)
- 基地址: 0x0C00_0000

**CLINT 定时器 (`clint.c`)**
```c
void clint_init(void);
void clint_set_timer(uint64_t ticks);
uint64_t clint_get_time(void);
```
- 提供 M-mode 定时器中断
- 支持软件中断 (IPI)
- 基地址: 0x0200_0000

**DMA 驱动 (`dma_desc64.c`, `dma_reg64_1d.c`)**
- **desc64**: 基于描述符的 DMA，支持链式传输和中断
- **reg64_1d**: 基于寄存器的简单 1D 传输，轮询模式
- DMA 基地址: 0x6000_0000

**MXU 驱动（`minimum_my_mxu` / `minimum_my_mxu_axu`）**
- **已接入网表的路径**：使用 `sim/filelist_minimum_my_mxu.f` 或 `sim/filelist_minimum_my_mxu_axu.f` 时，SoC 在 `0x7000_0000` 起暴露 **MXU** 四路 MMIO 窗口（配置 + weight / activation / output 三块 on-chip buffer，各 32KB）。软件：`my_mxu.h` / `my_mxu.c`（`struct my_mxu_drv` + `my_mxu_bind` 操作表），测试应用 **`my_mxu_test`**。
- **MMIO 布局**（与 `hardware/soc/minimum_my_mxu/ariane_soc_pkg.sv` 一致）：
  - `MY_MXU_CFG_BASE` = `0x7000_0000`
  - `MY_MXU_WGT_BASE` = `0x7000_8000`
  - `MY_MXU_ACT_BASE` = `0x7001_0000`
  - `MY_MXU_OUT_BASE` = `0x7001_8000`
- **典型流程**：通过 MMIO 写入 buffer → 配置 `cfg_write` 寄存器 → `mxu_start` → 轮询 `mxu_wait_done`。
- kick 前对 CPU 写入的源数据执行 **`fence ow, ow`**，避免写穿 D-cache 下写缓冲未排空。

**AXU 驱动（`minimum_my_mxu_axu`）**
- **已接入网表的路径**：使用 `sim/filelist_minimum_my_mxu_axu.f`（`sim/Makefile` 默认）时，SoC 在 `0x7002_0000` 起暴露 **AXU** 四路 MMIO 窗口（配置 + op_a / op_b / output 三块 buffer）。软件：`my_axu.h` / `my_axu.c`，测试应用 **`my_axu_test`**。
- **MMIO 布局**：
  - `MY_AXU_CFG_BASE` = `0x7002_0000`
  - `MY_AXU_OPA_BASE` = `0x7002_8000`
  - `MY_AXU_OPB_BASE` = `0x7003_0000`
  - `MY_AXU_OUT_BASE` = `0x7003_8000`
- AXU 支持 VPU / SFU / NLI / SCH 四个计算单元，通过 `axu_write_cfg` 配置 `func_sel`、`unit_sel`、`batch_size` 等字段后 `axu_start`。

**Global Buffer（`minimum_my_mxu_axu`）**
- 头文件 `global_buffer.h` 定义 `GLOBAL_BUFFER_BASE = 0x7004_0000`，4096×64bit 片上缓冲。
- 与 iDMA 联调见 **`mxu_idma_gbuf_test`**：DMA 将数据搬入 global buffer，再由 MXU 读取计算。

**VMMA 驱动（`minimum_vmma_dma`）**
- **已接入网表的路径**：使用 **`sim/filelist_minimum_vmma_dma.f`**（SoC RTL 在 **`hardware/soc/minimum_vmma_dma/`**）时，在 **`0x7000_0000`** 暴露 **`vmma_top`**（仿真模型 **`hardware/user_ip/vmma/vmma_sim.sv`**：经 `axi2mem` 的 **64 位 MMIO 槽** + **AXI master** 访存），交叉开关上索引 **`VmmaDmaMst`**。软件：`vmma.h` / `vmma.c`（`struct vmma_drv` + `vmma_bind` 操作表），测试应用 **`vmma_test`**。
- **与 MXU / AXU 的关系**：`vmma`、`my_mxu`、`my_mxu_axu` 在 `0x7000_0000` 一带的 MMIO 布局 **互斥**；仿真/下载程序时必须与 **`FILELIST`** 一致。
- **RTL 能力（当前仿真模型）**：`CTRL[1:0]==2'b01` 表示 **INT16**；**M、N ≤ 32**；权重行 DMA 按 **64bit beat** 读取，故 **`W_STRIDE` 应为 8 的倍数**；可对每行右侧 **padding** 以满足对齐与 `N` 列数。
- **软件一致性（重要）**：CVA6 配置为 **写穿 D-cache**，且无 **Zicbom** 时，**D$ 预取** 可能在加速器写回 DRAM **之前** 把 **输出缓冲** 所在 line 填成旧值，CPU 随后 **命中 cache** 读到错误数据（仿真中曾表现为 **Y 全 0**）。**缓解**：① 输出区与 **W/X** 在地址上 **拉开**（`vmma_test` 用 **`vmma_test_LDFLAGS := -Wl,--section-start=.vmma_dma_out=0x8001F800`** 将 `.vmma_dma_out` 置于 DRAM 高址、靠近栈保护区）；② 对 CPU 写入的源数据在 **kick** 加速器前执行 **`fence ow, ow`**；③ 避免在加速器完成 **前** 对输出区做 **多余 store**（否则 line 在 D$ 中有效）。长期应在硬件侧做 **一致性** 或 **非缓存缓冲**。

**DCIM 驱动（`minimum_dcim`）**
- **已接入网表的路径**：使用 **`sim/filelist_minimum_dcim.f`**（SoC RTL 在 **`hardware/soc/minimum_dcim/`**）时，在 **`0xE000_0000`** 暴露 **`dcim_wrap`**（单 AXI slave + 内部 region：ctrl/cfg/act/out/wei）。软件：`dcim.h` / `dcim.c`（`struct dcim_drv` + `dcim_bind`），测试应用 **`dcim_test`**；一键脚本 **`dcim_shell.sh`**。
- **MMIO 布局**（与 `adapt_decode.sv` / `ariane_soc_pkg.sv` 一致）：
  - `DCIM_CTRL_BASE` = `0xE000_0000`
  - `DCIM_CFG_BASE`  = `0xE002_0000`
  - `DCIM_ACT_BASE`  = `0xE004_0000`（4 bank，stride `0x800`）
  - `DCIM_OUT_BASE`  = `0xE006_0000`（4 bank，stride `0x2000`）
  - `DCIM_WEI_BASE`  = `0xE008_0000`（4 bank，stride `0x8000`）
- **与 MXU/AXU/VMMA 的关系**：地址空间 **互斥**；`dcim_test` 必须配 **`filelist_minimum_dcim.f`**。
- **软件注意**：当前 RTL **无 STATUS 寄存器、无 irq_o**；`dcim_wait_done()` 为软件延时；buffer ownership 在 `CTRL.START` 后由硬件自动切到加速器，读 output 前须 `set_buffer_owner(CPU,…)` 并 **`fence`**。

**遗留参考驱动（不再接入网表）**
- `asic_dma_accel.h` / `asic_dma_accel.c` 与 `hardware/user_ip/asic_dma_accel/` 为早期片内 DMA 演示，对应 `minimum_asic_dma` 网表已从仓库移除。
- `asic_accel.h` / `asic_accel.c` 与 `hardware/user_ip/asic_accel/` 为纯 MMIO 加速器示例，**默认未挂入** 任一网表。

### 1.3 应用示例详解

#### fmatmul (浮点矩阵乘法)

```c
// C = A × B，其中 A=[MxN], B=[NxP], C=[MxP]
int main() {
    start_timer();
    fmatmul(c, a, b, s, s, s);  // 调用 RVV 优化的内核
    stop_timer();
    
    int64_t runtime = get_timer();
    float performance = 2.0 * s * s * s / runtime;  // FLOP/cycle
    float utilization = 100 * performance / (2.0 * NR_LANES);
}
```

**关键特性：**
- 使用 RISC-V Vector Extension (RVV) 指令
- 自动适配配置的 NR_LANES (默认 2)
- 数据对齐要求：32 * NR_LANES 字节对齐
- 存储在 `.l2` section (DRAM)

#### dotproduct (向量点积)

- 支持整数和浮点版本
- 展示基本的向量加载/乘加/归约操作
- 用于验证 VPU 基础功能

#### dma_desc64_test

```c
// 设置 DMA 描述符
dma_desc_t desc = {
    .src_addr = (uint64_t)src,
    .dst_addr = (uint64_t)dst,
    .length   = size,
    .next     = 0  // 链式传输指针
};
// 启动传输并等待中断
```

#### my_mxu_test（MXU 矩阵加速回归）

- 通过 MMIO 向 weight / activation buffer 写入测试向量
- 配置 `MXU_CFG_*` 寄存器（data flow、data type、tile base 等）
- 调用 `my_mxu0.mxu_start()` 启动，轮询 `mxu_wait_done`
- 读 output buffer 与 golden 比对
- 适用 `filelist_minimum_my_mxu.f` 或 `filelist_minimum_my_mxu_axu.f`

#### my_axu_test（AXU 多单元回归）

- 覆盖 VPU / SFU / NLI / SCH 四个计算单元的多种 `func_sel` 组合
- 每个 case 写入 op_a / op_b buffer，配置 `axu_write_cfg`，`axu_start` 后比对 output
- 仅适用 `filelist_minimum_my_mxu_axu.f`

#### mxu_idma_gbuf_test（DMA + global buffer + MXU 联调）

- 使用 iDMA 描述符将数据搬入 `GLOBAL_BUFFER_BASE`（`0x7004_0000`）
- 再由 MXU 从 global buffer 读取并计算
- 验证 `minimum_my_mxu_axu` 上 DMA master 与加速器的数据通路

#### dcim_test（DCIM wrap smoke / kick）

- `dcim_bind` → `init` → cfg/buffer 读回 → 最小 kick 流程（写 act/wei → `DCIM_FENCE_OW` → `configure` → `start` → `wait_done`）
- UART marker：**`DCIM_PASS`** / **`DCIM_FAIL`**
- 仅适用 **`filelist_minimum_dcim.f`**；构建变量 **`DCIM_TEST_TOPO`**、**`DCIM_WAIT_CYCLES`**

### 1.4 构建系统详解

**工具链配置 (`scripts/toolchain.mk`)**

```makefile
# 使用 LLVM/Clang 17.0.6 + LLD
RISCV_CC = clang --target=riscv64-unknown-elf
RISCV_LD = ld.lld

# RISC-V 架构配置
LLVM_FLAGS = -march=rv64gcv_zfh_zvfh -mabi=lp64d
# 禁用自动向量化，手动控制 RVV
LLVM_V_FLAGS = -fno-vectorize -mno-implicit-float
```

**链接器脚本 (`scripts/link.ld`)**
- 定义内存布局：DRAM 基地址 0x8000_0000
- 代码段、数据段、BSS 段分布
- 栈底初始化位置

**每应用追加链接选项 (`software/Makefile`)**

- 链接命令为 **`$(RISCV_LDFLAGS) $(<app>_LDFLAGS)`**：全局 **`RISCV_LDFLAGS`**（含 `-T link.ld`、`-lm -lgcc` 等）**始终保留**，应用仅在 **`$(app)_LDFLAGS`** 中追加片段（例如 **`vmma_test`** 的 **`--section-start=.vmma_dma_out=...`**，或 DMA 测试的 **`-Wl,--no-relax`**）。
- 请勿在 `app.mk` 里再写一整套 `-static -nostdlib …`，否则易与全局标志重复或遗漏库路径。

### 1.5 外设 DMA 与 D-cache（minimum 系列必读）

在 **`minimum` / `minimum_vmma_dma` / `minimum_my_mxu` / `minimum_my_mxu_axu` / `minimum_dcim`** 上，CVA6 数据通路经 **写穿（WT）D-cache** 连到与 DMA master **同一** SRAM/DRAM 模型。下列情况会导致 **CPU 与加速器看到的数据不一致**：

| 现象 | 常见原因 | 处理思路 |
|------|----------|----------|
| 加速器已写回，CPU 读输出仍为 0 或旧值 | D$ **line 有效** 但与 DRAM 不同步（预取/先前 store） | 输出缓冲 **远离** 输入与顺序访问区；**`fence ow, ow`**；或硬件 **一致性 / 非缓存区** |
| VMMA 读 **W/X** 为 0 | CPU **store** 仍在 **WT 写缓冲** | kick 前 **`fence ow, ow`** |
| 矩阵结果行错误 | **`W_STRIDE`** 非 8 对齐导致 **64b burst** 读到错误行 | **stride ≥ 8 且为 8 倍数**，必要时 **行尾 padding** |

---

## 2. 硬件部分 (hardware/)

### 2.1 SoC 组织架构

```
┌─────────────────────────────────────────────────────────────┐
│                    ariane_soc_top                           │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐      │
│  │   CVA6      │◄──►│   AXI       │◄──►│  AXI Xbar   │      │
│  │  (标量核)    │    │  宽度转换    │    │  交叉开关   │      │
│  └─────────────┘    └─────────────┘    └────────┬────┘      │
│  ┌──────────────────────────────────────────────┴─────┐     │
│  │                   AXI 总线互联                      │     │
│  ├──────────┬──────────┬──────────┬──────────┬────────┤     │
│  │  DRAM    │  UART    │  Timer   │  PLIC    │  CLINT │     │
│  │ 0x8000_  │ 0x1000_  │ 0x1800_  │ 0x0C00_  │0x0200_ │     │
│  │ 0000     │ 0000     │ 0000     │ 0000     │ 0000   │     │
│  └──────────┴──────────┴──────────┴──────────┴────────┘     │
│                                                  │          │
│  ┌─────────────┐    ┌─────────────┐              │          │
│  │   ROM       │    │   Debug     │              │          │
│  │ 0x0001_0000 │    │   Module    │              │          │
│  └─────────────┘    └─────────────┘              │          │
│                                                  │          │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐      │
│  │  Default    │    │   DMA       │    │ MXU/AXU/    │      │
│  │  Slave      │    │ 0x6000_0000 │    │ VMMA 等     │      │
│  │ 0x5000_0000 │    │ (部分变体)  │    │ 0x7000_0000 │      │
│  └─────────────┘    └─────────────┘    └─────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 地址映射表

| 设备 | 基地址 | 长度 | 说明 |
|------|--------|------|------|
| Debug | 0x0000_0000 | 4KB | 调试模块 |
| ROM | 0x0001_0000 | 64KB | Boot ROM |
| CLINT | 0x0200_0000 | 768KB | 核心本地中断器 |
| PLIC | 0x0C00_0000 | 64MB | 平台级中断控制器 |
| UART | 0x1000_0000 | 4KB | 串口 |
| Timer | 0x1800_0000 | 4KB | 定时器 |
| GPIO | 0x4000_0000 | 4KB | GPIO (未实现) |
| DefaultSlave | 0x5000_0000 | 4KB | 默认从设备 + IRQ（部分变体未接入） |
| DMA | 0x6000_0000 | 4KB | iDMA 配置（`maximum`、`minimum_my_mxu_axu`） |
| MXU Cfg | 0x7000_0000 | 4KB | MXU 配置寄存器（`minimum_my_mxu` / `minimum_my_mxu_axu`） |
| MXU WgtBuf | 0x7000_8000 | 32KB | MXU weight buffer |
| MXU ActBuf | 0x7001_0000 | 32KB | MXU activation buffer |
| MXU OutBuf | 0x7001_8000 | 32KB | MXU output buffer |
| AXU Cfg | 0x7002_0000 | 4KB | AXU 配置寄存器（`minimum_my_mxu_axu`） |
| AXU OpABuf | 0x7002_8000 | 32KB | AXU operand A buffer |
| AXU OpBBuf | 0x7003_0000 | 32KB | AXU operand B buffer |
| AXU OutBuf | 0x7003_8000 | 32KB | AXU output buffer |
| Global Buffer | 0x7004_0000 | 32KB | 片上 global buffer（`minimum_my_mxu_axu`） |
| VMMA | 0x7000_0000 | 4KB | VMMA 配置口（`minimum_vmma_dma`，与 MXU 互斥） |
| DCIM | 0xE000_0000 | 640KB | DCIM wrap 单窗口（`minimum_dcim`，含 ctrl/cfg/buffer regions） |
| DRAM | 0x8000_0000 | 32KB–128KB | 主内存（`minimum_my_mxu_axu` 为 32KB） |
| Ctrl | 0xD000_0000 | 4KB | 控制寄存器 |

### 2.3 关键文件结构与用途

#### IP 核目录 (`hardware/ip/`)

| IP | 路径 | 用途 |
|----|------|------|
| CVA6 | `ip/cva6/` | 64位 RISC-V 应用处理器核 |
| ARA | `ip/ara/` | 向量处理单元 (VPU) |
| AXI | `ip/axi/` | AXI4 总线基础设施 |
| FPnew | `ip/fpnew/` | 浮点运算单元 |
| iDMA | `ip/iDMA/` | DMA 引擎 |
| PLIC | `ip/rv_plic/` | 中断控制器 |
| Debug | `ip/riscv-dbg/` | RISC-V 调试模块 |

#### ARA VPU 结构 (`hardware/ip/ara/`)

```
ara/
├── include/
│   ├── rvv_pkg.sv      # RISC-V Vector 规范定义
│   └── ara_pkg.sv      # ARA 包定义
└── src/
    ├── ara.sv          # ARA 顶层模块
    ├── ara_dispatcher.sv  # 指令分发器
    ├── ara_sequencer.sv   # 主序列器
    ├── lane/              # 向量 Lane 实现
    │   ├── lane.sv        # Lane 顶层
    │   ├── valu.sv        # 向量 ALU
    │   ├── vmfpu.sv       # 向量浮点单元
    │   └── vector_regfile.sv  # 向量寄存器堆
    ├── masku/             # 掩码单元
    ├── sldu/              # 滑动单元
    └── vlsu/              # 向量 Load/Store 单元
        ├── vlsu.sv
        ├── vldu.sv        # 向量 Load
        └── vstu.sv        # 向量 Store
```

#### SoC 集成 (`hardware/soc/`)

在本项目里，五种顶层 SoC 目录（`maximum` / `minimum` / `minimum_vmma_dma` / `minimum_my_mxu` / **`minimum_my_mxu_axu`**）共用大量 `soc/common/` 逻辑，核心区别是是否接入 ARA VPU、片上 iDMA，以及 **minimum 系列**上挂载哪一种自定义加速器（或无）。  
可通过不同 filelist 进行切换：

- `hardware/soc/filelist_maximum.f`：选择 `soc/maximum/*`
- `hardware/soc/filelist_minimum.f`：选择 `soc/minimum/*`
- `hardware/soc/filelist_minimum_vmma_dma.f`：选择 `soc/minimum_vmma_dma/*`
- `hardware/soc/filelist_minimum_my_mxu.f`：选择 `soc/minimum_my_mxu/*`
- `hardware/soc/filelist_minimum_my_mxu_axu.f`：选择 **`soc/minimum_my_mxu_axu/*`**
- `hardware/soc/filelist_minimum_dcim.f`：选择 **`soc/minimum_dcim/*`**

**仿真侧 filelist（在 `sim/` 目录使用，含 TB 与 IP）：**

- `sim/filelist.f`：**maximum** SoC 完整仿真。
- `sim/filelist_minimum.f`：**纯净** minimum SoC + TB（无自定义加速器）。
- `sim/filelist_minimum_vmma_dma.f`：minimum + **`vmma_top`**（`hardware/user_ip/vmma/filelist_sim.f`）。
- `sim/filelist_minimum_my_mxu.f`：minimum + **MXU**（`hardware/user_ip/my_mxu/filelist_mxu_top_sim.f`）。
- **`sim/filelist_minimum_my_mxu_axu.f`**：**默认仿真配置**，minimum + **MXU + AXU + global buffer + iDMA**。
- `sim/filelist_minimum_dcim.f`：minimum + **DCIM wrap**（`hardware/user_ip/dcim_wrap/filelist_sim.f`）。

> **已移除**：早期 `minimum_asic_dma`（`asic_dma_accel`）及其 `filelist_minimum_asic_dma.f` 已从仓库清理；`hardware/soc/minimum_asic_dma/` 仅残留 `ariane_peripherals.sv` 供参考。

**maximum 配置关键文件：**

| 文件 | 路径 | 用途 |
|------|------|------|
| `ariane_soc_top.sv` | `soc/maximum/` | SoC 顶层，实例化所有模块 |
| `ara_system.sv` | `soc/maximum/` | CVA6+ARA 系统集成 |
| `ariane_peripherals.sv` | `soc/maximum/` | 外设集成 (UART/Timer/PLIC/DMA) |
| `ariane_soc_pkg.sv` | `soc/maximum/` | SoC 配置参数包 |
| `clint.sv` | `soc/common/` | CLINT 实现 |
| `ctrl_registers.sv` | `soc/common/` | 控制寄存器 |

**minimum 配置关键文件：**

| 文件 | 路径 | 用途 |
|------|------|------|
| `ariane_soc_top.sv` | `soc/minimum/` | SoC 顶层（无 ARA 无 DMA） |
| `ara_system.sv` | `soc/minimum/` | CVA6 标量系统集成（仅标量主路径） |
| `ariane_peripherals.sv` | `soc/minimum/` | 外设集成（UART/Timer/PLIC/CLINT 等） |
| `ariane_soc_pkg.sv` | `soc/minimum/` | minimum 地址映射与参数定义 |
| `clint.sv` | `soc/common/` | CLINT 实现 |
| `ctrl_registers.sv` | `soc/common/` | 控制寄存器 |

**minimum 架构特征：**

- 仅保留 CVA6 标量核执行路径，不实例化 ARA VPU。
- 不包含 **片上 iDMA**（`0x6000_0000`），与 maximum 的 DMA 外设不同。
- 不包含 `0x7000_0000` 起的自定义加速器；这些外设仅在对应变体目录与 filelist 中集成。
- 适合跑 `hello_world`、`trap_test`、`clint_test`、`default_slave` 等基础/标量测试。
- 可作为自定义 ASIC 的轻量集成基线，先通标量系统再逐步扩展加速器。

**minimum_my_mxu 关键文件：**

| 文件 | 路径 | 用途 |
|------|------|------|
| `ariane_soc_top.sv` | `soc/minimum_my_mxu/` | SoC 顶层，含 MXU 地址映射与总线挂接 |
| `ara_system.sv` | `soc/minimum_my_mxu/` | CVA6 标量系统集成 |
| `ariane_peripherals.sv` | `soc/minimum_my_mxu/` | 外设 + `mxu_top_wrapper` 实例 |
| `ariane_soc_pkg.sv` | `soc/minimum_my_mxu/` | 含 MXU 四路 MMIO 窗口枚举 |
| `mxu_top_wrapper.sv` | `hardware/user_ip/my_mxu/` | MXU 顶层 wrapper（配置 + 三块 buffer） |

**minimum_my_mxu_axu 关键文件：**

| 文件 | 路径 | 用途 |
|------|------|------|
| `ariane_soc_top.sv` | `soc/minimum_my_mxu_axu/` | SoC 顶层，含 MXU + AXU + iDMA + global buffer |
| `ara_system.sv` | `soc/minimum_my_mxu_axu/` | CVA6 标量系统集成 |
| `ariane_peripherals.sv` | `soc/minimum_my_mxu_axu/` | 外设 + MXU + AXU + DMA + global_buffer 实例 |
| `ariane_soc_pkg.sv` | `soc/minimum_my_mxu_axu/` | 含 MXU/AXU/DMA/GlobalBuffer 枚举与基地址 |
| `axu_top_wrapper.sv` | `hardware/user_ip/my_axu/` | AXU 顶层 wrapper |
| `global_buffer.sv` | `hardware/user_ip/sram_buffer/` | 4096×64 片上缓冲 |

**minimum_vmma_dma 关键文件：**

| 文件 | 路径 | 用途 |
|------|------|------|
| `ariane_soc_top.sv` | `soc/minimum_vmma_dma/` | SoC 顶层，含 **VMMA** 地址映射与 **`VmmaDmaMst`** 挂接 |
| `ara_system.sv` | `soc/minimum_vmma_dma/` | CVA6 标量系统集成 |
| `ariane_peripherals.sv` | `soc/minimum_vmma_dma/` | 外设 + **`i_vmma`（`vmma_top`）** 实例 |
| `ariane_soc_pkg.sv` | `soc/minimum_vmma_dma/` | 含 **`VMMA`** 从端口索引与 **`VmmaDmaMst`** 等参数 |
| `vmma_sim.sv` | `hardware/user_ip/vmma/` | 仿真用 **VMMA** 行为模型（单文件 `vmma_top`） |

**minimum_dcim 关键文件：**

| 文件 | 路径 | 用途 |
|------|------|------|
| `ariane_soc_top.sv` | `soc/minimum_dcim/` | SoC 顶层，含 **DCIM** 地址映射 |
| `ariane_peripherals.sv` | `soc/minimum_dcim/` | 外设 + **`i_dcim_wrap`（axi2mem + dcim_wrap）** |
| `ariane_soc_pkg.sv` | `soc/minimum_dcim/` | 含 **`DCIM`** 从端口与 **`DCIMBase/Length`** |
| `dcim_wrap.sv` | `hardware/user_ip/dcim_wrap/` | adapt + 4×dcim + on-chip act/out buffer |

**ara_system.sv 架构：**

```systemverilog
// 1. CVA6 标量核
//    - 64位 RISC-V 核
//    - 通过 CVXIF 接口连接 ARA
//    - 64位 AXI 窄总线输出

// 2. AXI 数据宽度转换器
//    - CVA6 64位 ──► 系统总线宽度 (64 * NrLanes / 2)
//    - 例如：2 lanes → 64位 → 64位
//           4 lanes → 64位 → 128位

// 3. ARA VPU
//    - 通过 CVXIF 接收向量指令
//    - 宽 AXI 总线输出 (与系统总线匹配)

// 4. AXI Mux
//    - 合并 CVA6 和 ARA 的总线请求
//    - 输出到系统 AXI Crossbar
```

### 2.4 添加自定义 ASIC 指南

**推荐做法**（本仓库 `minimum_my_mxu` / `minimum_my_mxu_axu` 所采用）：为每种 SoC 形态 **复制并维护独立顶层目录**，避免在 `minimum/` 内用宏开关分叉。

#### 步骤 1: 创建加速器 RTL

在 `hardware/user_ip/my_accelerator/` 创建 RTL 与 filelist：

```
hardware/user_ip/my_accelerator/
├── my_accelerator.sv       # 或 wrapper（参考 mxu_top_wrapper.sv）
├── filelist_sim.f          # 仿真 filelist
└── filelist_syn.f          # 综合 filelist（如需 tape-out）
```

#### 步骤 2: 新建 SoC 变体目录

复制 `hardware/soc/minimum/` 为 `hardware/soc/minimum_my_accel/`，修改：

- `ariane_soc_pkg.sv`：添加 AXI 从设备枚举、`NB_PERIPHERALS`、基地址与长度
- `ariane_peripherals.sv`：实例化加速器并连接 AXI 端口
- `ariane_soc_top.sv`：更新 crossbar `addr_map`

添加对应 filelist：

- `hardware/soc/filelist_minimum_my_accel.f`
- `sim/filelist_minimum_my_accel.f`（引用上述 soc filelist + user_ip filelist + TB）

#### 步骤 3: 添加软件驱动与测试

- `software/soc/include/my_accelerator.h`：MMIO 基地址与寄存器定义（与 RTL 一致）
- `software/soc/src/my_accelerator.c`：驱动实现（可参考 `my_mxu.c` 的 `struct *_drv` + `*_bind` 模式）
- `software/app/my_accel_test/`：回归测试应用

#### 步骤 4: 综合（可选）

在 `hardware/soc/filelist_syn_minimum_my_accel.f` 中加入综合用 user_ip filelist，详见 [README_SYN.md](../README_SYN.md)。

更详细的硬件修改步骤见 [如何修改hardware文件夹下的内容？.md](如何修改hardware文件夹下的内容？.md)、[ASIC_INTEGRATION.md](ASIC_INTEGRATION.md)。

---

## 3. 仿真部分 (sim/)

### 3.1 仿真逻辑与 SoC 工作方式

#### 仿真架构

```
┌─────────────────────────────────────────────────────────────┐
│                        Testbench                            │
│                     (ara_tb.sv)                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐      │
│  │   Clock/    │    │    DUT      │    │    UART     │      │
│  │   Reset     ├───►│  (SoC)      │◄──►│    DPI      │      │
│  │   Gen       │    │             │    │  (uartdpi)  │      │
│  └─────────────┘    └──────┬──────┘    └─────────────┘      │
│                            │                                │
│  ┌─────────────────────────┴───────────────────────────┐    │
│  │                  Memory Initialization              │    │
│  │  - 通过 DPI-C read_elf() 加载 ELF 文件               │    │
│  │  - 解析 ELF section 写入 SRAM                        │    │
│  │  - 程序从 ROMBase (0x0001_0000) 开始执行             │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                  JTAG Debug Interface               │    │
│  │  - SimJTAG 模块提供远程调试能力                       │    │
│  │  - 支持 OpenOCD 连接                                 │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### SoC 启动流程

1. **复位阶段** (`ara_tb.sv`)
   ```systemverilog
   initial begin
       clk   = 1'b0;
       rst_n = 1'b0;
       repeat(8) #(ClockPeriod/2) clk = ~clk;  // 8个时钟周期复位
       rst_n = 1'b1;
   ```

2. **内存初始化** (`dram_init` block)
   ```systemverilog
   // 通过 +PRELOAD=xxx.elf 参数加载程序
   void'($value$plusargs("PRELOAD=%s", binary));
   read_elf(binary);  // DPI-C 函数读取 ELF
   
   // 将各 section 写入 SRAM
   while (get_section(address, len)) {
       read_section(address, buffer);
       // 写入 `MAIN_MEM(addr)
   }
   ```

3. **程序执行**
   - CVA6 从 `boot_addr_i` (ROMBase = 0x0001_0000) 取指
   - Boot ROM 中的代码跳转到 DRAM 执行主程序
   - 程序通过 UART 输出调试信息

4. **结束检测**
   ```systemverilog
   always @(posedge clk) begin
       if (exit[0]) begin  // 控制寄存器写入 exit 值
           if (exit >> 1)
               $error("Test FAILED");
           else
               $display("Test SUCCESS");
           $finish;
       end
   end
   ```

### 3.2 关键仿真组件

#### DPI-C 接口 (`tb/dpi/`)

| 文件 | 功能 |
|------|------|
| `elfloader.cc` | 解析 ELF 文件，加载到内存 |
| `uartdpi.c` | UART 仿真，输出到终端和日志文件 |
| `SimJTAG.sv` | JTAG 仿真接口 |

#### 测试台信号

```systemverilog
// Clock/Reset
localparam ClockPeriod      = 2ns;     // 500MHz
localparam RTC_CLOCK_PERIOD = 30.517us; // RTC 时钟

// UART
uartdpi #(.BAUD(6250000), .FREQ(500_000_000)) i_uart0 (...);

// JTAG
SimJTAG i_SimJTAG (...);
```

### 3.3 波形与调试

#### 生成波形

```bash
# VCS - 生成 FSDB 波形（Synopsys 格式）
make vcs-wave app=../software/build/bin/fmatmul
# 生成 waveform.fsdb

# Verilator - 生成 FST 波形（GTKWave 格式）
make verilator-wave app=../software/build/bin/fmatmul
# 生成 waveform.fst
```

#### 查看波形

```bash
# 使用 Verdi 查看 FSDB
make verdi

# 或使用 GTKWave 查看 FST
gtkwave waveform.fst
```

#### 关键信号

在波形调试时关注以下信号：

| 信号路径 | 说明 |
|----------|------|
| `dut.i_ara_system.i_ariane.*` | CVA6 核心信号 |
| `dut.i_ara_system.i_ara.*` | ARA VPU 信号 |
| `dut.i_axi_xbar.*` | AXI 总线信号 |
| `dut.i_sram.*` | 内存访问 |
| `dut.i_ariane_peripherals.i_vmma.*` | **VMMA**（仅 `filelist_minimum_vmma_dma.f`）配置口与 DMA master |
| `dut.i_ariane_peripherals.i_dcim_wrap.*` | **DCIM**（仅 `filelist_minimum_dcim.f`） |
| `dut.i_ariane_peripherals.i_mxu_top_wrapper.*` | **MXU**（`filelist_minimum_my_mxu.f` / `filelist_minimum_my_mxu_axu.f`） |
| `dut.i_ariane_peripherals.i_axu_top_wrapper.*` | **AXU**（仅 `filelist_minimum_my_mxu_axu.f`） |
| `dut.i_ariane_peripherals.i_global_buffer.*` | **global buffer**（仅 `filelist_minimum_my_mxu_axu.f`） |
| `dut.i_ariane_peripherals.i_dma.*` | **iDMA**（`maximum` 或 `minimum_my_mxu_axu`） |
| `i_uart0.*` | UART 通信 |

### 3.4 仿真工作流总结

```
1. 编译软件
   └─► software/build/bin/app.elf

2. 编译仿真环境
   └─► sim/build/vcs/simv (或 verilator 等价物)

3. 运行仿真
   ├─► DPI 加载 ELF 到内存
   ├─► SoC 启动，CVA6 从 ROM 取指
   ├─► 程序执行，通过 UART 输出
   └─► 检测到 exit 信号，仿真结束

4. 分析结果
   ├─► 查看终端输出
   ├─► 查看 uart0.log
   ├─► 查看波形 (Verdi/GTKWave)
   └─► 查看 trace_hart_0.log (指令追踪)
```

### 3.5 各 SoC 配置仿真实操

`sim/Makefile` 默认 `FILELIST=filelist_minimum_my_mxu_axu.f`。切换变体时在 **`sim/`** 下使用完整仿真 filelist（勿仅用 `hardware/soc/filelist_*.f`，否则缺少 testbench 与 IP）。换变体后建议 **`make clean && make vcs FILELIST=…`**。

**Minimum（纯净标量，无加速器）：**

```bash
make -C software hello_world
cd sim && make clean && make vcs FILELIST=filelist_minimum.f
make vcs-run FILELIST=filelist_minimum.f app=../software/build/bin/hello_world
```

**Maximum（CVA6 + ARA VPU + iDMA）：**

```bash
make -C software fmatmul
cd sim && make clean && make vcs FILELIST=filelist.f
make vcs-run FILELIST=filelist.f app=../software/build/bin/fmatmul
```

**Minimum + MXU + AXU（默认配置）：**

```bash
make -C software my_mxu_test my_axu_test
cd sim && make vcs   # 默认 FILELIST=filelist_minimum_my_mxu_axu.f
make vcs-run app=../software/build/bin/my_mxu_test
make vcs-run app=../software/build/bin/my_axu_test
```

**Minimum + MXU（仅 MXU）：**

```bash
make -C software my_mxu_test
cd sim && make clean && make vcs FILELIST=filelist_minimum_my_mxu.f
make vcs-run FILELIST=filelist_minimum_my_mxu.f app=../software/build/bin/my_mxu_test
```

**Minimum + MXU + AXU + iDMA + global buffer 联调：**

```bash
make -C software mxu_idma_gbuf_test
cd sim && make vcs
make vcs-run app=../software/build/bin/mxu_idma_gbuf_test
```

**VMMA（VecMatMul + 内部 DMA）：**

```bash
make -C software vmma_test
cd sim && make clean && make vcs FILELIST=filelist_minimum_vmma_dma.f
make vcs-run FILELIST=filelist_minimum_vmma_dma.f app=../software/build/bin/vmma_test
```

**DCIM wrap：**

```bash
make -C software dcim_test
cd sim && make clean && make vcs FILELIST=filelist_minimum_dcim.f
make vcs-run FILELIST=filelist_minimum_dcim.f app=../software/build/bin/dcim_test
# 或：./dcim_shell.sh
```

建议：

- 若当前应用包含 RVV 指令（如 `fmatmul` / `dotproduct` / `fdotproduct`），在 minimum 系列配置下通常不适用，需使用 **maximum**（`filelist.f`）。
- 片上 iDMA 测试（`dma_desc64_test` / `dma_reg64_1d_test`）属于 **maximum** 场景；`minimum_my_mxu_axu` 上有独立 iDMA，可用 **`mxu_idma_gbuf_test`** 验证 DMA + global buffer + MXU 路径。
- VMMA 使用 **`vmma_test`** + `filelist_minimum_vmma_dma.f`，与 MXU/AXU 变体 **互斥**。
- DCIM 使用 **`dcim_test`** + `filelist_minimum_dcim.f`，与其余加速器变体 **互斥**。
- first bring-up 推荐顺序：`hello_world` → `trap_test` → `clint_test` → `default_slave`。

---

## 4. 扩展资源

### 项目内文档

- [README.md](../README.md) — 项目总览与快速开始
- [README_SYN.md](../README_SYN.md) — Design Compiler 综合流程
- [ASIC_INTEGRATION.md](ASIC_INTEGRATION.md) — 自定义加速器集成指南
- [DEBUG.md](DEBUG.md) — 调试说明
- [如何修改hardware文件夹下的内容？.md](如何修改hardware文件夹下的内容？.md) — 硬件修改指南
- [如何修改softwareware文件夹下的内容？.md](如何修改softwareware文件夹下的内容？.md) — 软件修改指南
- [sim/README.md](../sim/README.md) — 仿真环境说明
- [software/README.md](../software/README.md) — 软件 BSP 说明

### 外部参考

- [RISC-V Vector Extension Spec](https://github.com/riscv/riscv-v-spec)
- [CVA6 文档](https://github.com/openhwgroup/cva6)
- [AXI4 Spec (ARM)](https://developer.arm.com/documentation/ihi0022/latest)

### 相关项目

- [PULP Platform](https://pulp-platform.org/) — 开源 RISC-V 生态系统
- [ARA Project](https://github.com/pulp-platform/ara) — 原始 ARA 项目

