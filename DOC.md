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
│   ├── fmatmul/       # 浮点矩阵乘法
│   ├── dotproduct/    # 向量点积
│   ├── fdotproduct/   # 浮点点积
│   ├── dma_desc64_test/  # DMA描述符测试
│   ├── dma_reg64_1d_test/# DMA寄存器测试
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
│   │   └── dma_reg64_1d.c# DMA寄存器接口
│   └── include/       # 驱动头文件
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

---

## 2. 硬件部分 (hardware/)

### 2.1 SoC 组织架构

```
┌─────────────────────────────────────────────────────────────┐
│                    ariane_soc_top                           │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐      │
│  │   CVA6      │◄──►│   AXI       │◄──►│  AXI Xbar   │      │
│  │  (标量核)    │    │  宽度转换    │    │  交叉开关     │      │
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
│  ┌─────────────┐    ┌─────────────┐              │          │
│  │  Default    │    │   DMA       │◄─────────────┘          │
│  │  Slave      │    │  (max only) │                         │
│  │ 0x5000_0000 │    │ 0x6000_0000 │                         │
│  └─────────────┘    └─────────────┘                         │
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
| DefaultSlave | 0x5000_0000 | 4KB | 默认从设备 + IRQ |
| DMA | 0x6000_0000 | 4KB | DMA 配置 (max only) |
| DRAM | 0x8000_0000 | 128KB | 主内存 |
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

在本项目里，`maximum` 和 `minimum` 共用大量 `soc/common/` 逻辑，核心区别是顶层系统集成是否接入 ARA VPU 和 DMA。  
可通过不同 filelist 进行切换：

- `hardware/soc/filelist_maximum.f`：选择 `soc/maximum/*`
- `hardware/soc/filelist_minimum.f`：选择 `soc/minimum/*`

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
- 不包含 DMA 外设，地址空间中不使用 `0x6000_0000` DMA 窗口。
- 适合跑 `hello_world`、`trap_test`、`clint_test`、`default_slave` 等基础/标量测试。
- 可作为自定义 ASIC 的轻量集成基线，先通标量系统再逐步扩展加速器。

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

要为 SoC 添加自定义 ASIC，需要修改以下文件：

#### 步骤 1: 创建 ASIC RTL

在 `hardware/user_ip/my_accelerator/` 创建：

```systemverilog
// my_accelerator.sv
module my_accelerator (
    input  logic        clk_i,
    input  logic        rst_ni,
    // AXI Slave 接口 - 配置寄存器
    AXI_BUS.Slave       cfg,
    // AXI Master 接口 - 数据访问 (可选)
    AXI_BUS.Master      data_mst,
    // 中断输出
    output logic        irq_o
);
    // 实现你的加速器逻辑
endmodule
```

#### 步骤 2: 添加到 AXI 总线

修改 `hardware/soc/maximum/ariane_soc_pkg.sv`：

```systemverilog
typedef enum int unsigned {
    // ... 现有设备 ...
    DMA      = 10,
    MyAccel  = 11,        // <-- 添加新设备
    NB_PERIPHERALS = 12  // <-- 更新数量
} axi_slaves_t;

localparam logic[63:0] MyAccelLength = 64'h1000;

typedef enum logic [63:0] {
    // ... 现有基地址 ...
    DMABase      = 64'h6000_0000,
    MyAccelBase  = 64'h7000_0000,  // <-- 添加新基地址
    DRAMBase     = 64'h8000_0000,
    // ...
} soc_bus_start_t;
```

#### 步骤 3: 在 SoC 顶层实例化

修改 `hardware/soc/maximum/ariane_soc_top.sv`：

```systemverilog
// 在 AXI Xbar 的 addr_map 中添加新设备
assign addr_map = '{
    // ... 现有映射 ...
    '{ idx: ariane_soc::DMA,      start_addr: ariane_soc::DMABase, ... },
    '{ idx: ariane_soc::MyAccel,  start_addr: ariane_soc::MyAccelBase, 
       end_addr: ariane_soc::MyAccelBase + ariane_soc::MyAccelLength },
    // ...
};

// 更新 NB_PERIPHERALS 并实例化加速器
// (参考现有外设的实例化方式)
```

#### 步骤 4: 添加软件支持

创建 `software/soc/src/my_accelerator.c`：

```c
#include "my_accelerator.h"

#define MYACCEL_BASE  0x70000000UL
#define MYACCEL_START (MYACCEL_BASE + 0x00)
#define MYACCEL_STATUS (MYACCEL_BASE + 0x08)

void myaccel_init(void) {
    // 初始化加速器
}

void myaccel_start(uint64_t src_addr, uint64_t dst_addr, uint32_t size) {
    // 配置并启动传输
}
```

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

### 3.5 Minimum 配置仿真实操（不使用 ARA VPU）

默认 `sim/filelist.f` 指向 maximum 方案。若要切换到 minimum，直接在命令行覆盖 filelist：

```bash
# 1) 编译软件（建议先使用标量应用）
make -C software hello_world

# 2) 进入仿真目录
cd sim

# 3) 以 minimum SoC 编译 VCS 仿真
make vcs FILELIST=../hardware/soc/filelist_minimum.f

# 4) 运行 minimum SoC + 指定程序
make vcs-run FILELIST=../hardware/soc/filelist_minimum.f app=../software/build/bin/hello_world
```

建议：

- 若当前应用包含 RVV 指令（如 `fmatmul` / `dotproduct` / `fdotproduct`），在 minimum 配置下通常不适用。
- DMA 相关测试（`dma_desc64_test` / `dma_reg64_1d_test`）属于 maximum 场景，minimum 下不建议作为首轮 bring-up 用例。
- first bring-up 推荐顺序：`hello_world` → `trap_test` → `clint_test` → `default_slave`。

---

## 4. 扩展资源

### 参考文档

- [RISC-V Vector Extension Spec](https://github.com/riscv/riscv-v-spec)
- [CVA6 文档](https://github.com/openhwgroup/cva6)
- [AXI4 Spec (ARM)](https://developer.arm.com/documentation/ihi0022/latest)

### 相关项目

- [PULP Platform](https://pulp-platform.org/) - 开源 RISC-V 生态系统
- [ARA Project](https://github.com/pulp-platform/ara) - 原始 ARA 项目

