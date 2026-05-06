# Ara SoC 仿真环境

本目录包含 Ara SoC 的仿真测试环境，支持 **Synopsys VCS** 和 **Verilator** 两种仿真工具。

## 目录结构

```
sim/
├── Makefile                # 主 Makefile，定义仿真规则和命令
├── filelist.f             # VCS 仿真文件列表（包含所有硬件源文件）
├── filelist_verilator.f   # Verilator 仿真文件列表
└── build/                 # 仿真构建输出目录（自动生成）
    ├── vcs/              # VCS 编译输出
    └── verilator/        # Verilator 编译输出
```

## 快速开始

### 前置要求

1. **编译软件程序**：在运行仿真前，需要先编译软件应用
   ```bash
   cd ../software
   make hello_world   # 或 make all 编译所有应用
   cd ../sim
   ```

2. **设置环境变量**（如果需要）：
   ```bash
   # VCS 和 Verdi 路径已在 Makefile 中配置
   # VCS_HOME: /home/EDAtools/synopsys/vcs/V-2023.12-SP1
   # VERDI_HOME: /home/EDAtools/synopsys/verdi/V-2023.12-SP1
   ```

---

## VCS 仿真（推荐用于波形调试）

VCS 提供完整的 SystemVerilog 支持、FSDB 波形输出和 Verdi 集成调试。

### 基本命令

```bash
# 编译仿真（仅编译，不运行）
make vcs

# 编译并运行仿真（默认使用 hello_world）
make vcs-run

# 编译并运行指定应用
make vcs-run app=../software/build/bin/fmatmul

# 编译并运行，同时生成 FSDB 波形文件
make vcs-wave app=../software/build/bin/dma_desc64_test

# 使用 Verdi 查看波形（需先运行 vcs-wave 生成波形）
make verdi
```

### VCS 配置说明

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `app` | `../software/build/bin/hello_world` | 要加载的软件二进制文件 |
| `VCS_TOP` | `ara_tb` | 顶层测试台模块 |
| `VCS_BUILD` | `build/vcs` | 编译输出目录 |

### VCS 编译选项

- `-full64`：64位模式
- `-sverilog`：SystemVerilog 支持
- `-debug_access+all -kdb`：启用调试和 Verdi 数据库
- `-timescale=1ns/1ps`：时间精度
- `+vcs+lic+wait`：等待许可证

---

## Verilator 仿真（开源免费，仿真速度快）

Verilator 将 Verilog 代码编译为 C++ 模型，执行速度快但部分 SystemVerilog 特性支持有限。

### 基本命令

```bash
# 编译仿真（Elaborate + C++ 编译）
make verilate

# 运行仿真（默认使用 hello_world）
make verilator-run

# 运行指定应用
make verilator-run app=../software/build/bin/dotproduct

# 运行并生成 FST 波形文件
make verilator-wave app=../software/build/bin/fmatmul
```

### Verilator 配置说明

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `app` | `../software/build/bin/hello_world` | 要加载的软件二进制文件 |
| `VERIL_TOP` | `ara_tb_verilator` | 顶层测试台模块 |
| `VERIL_BUILD` | `build/verilator` | 编译输出目录 |

### Verilator 特点

- 使用 `--no-timing` 禁用时序检查（提升速度）
- 使用 `--trace-fst` 生成 FST 格式波形（比 VCD 更小）
- 支持 ccache 加速 C++ 编译

---

## 文件列表说明

### `filelist.f`（VCS）

包含完整的硬件设计文件：
- **Technology**：工艺库文件
- **IPs**：各种 IP 核（AXI、OBI、APB、FPnew、CVA6、ARA 等）
- **SoC**：SoC 顶层集成
- **User IP**：用户自定义 IP（如 default_slave）
- **Testbench**：仿真测试台（`ara_tb.sv`、`uartdpi.sv`、`SimJTAG.sv`）

### `filelist_verilator.f`（Verilator）

针对 Verilator 优化的文件列表：
- 部分 IP 被简化或替换（如 `axi_stream`、`axi_slice`、`iDMA` 等未包含）
- 使用专门的 Verilator 测试台 `ara_tb_verilator.sv`

---

## 测试台架构

### VCS 测试台（`ara_tb.sv`）

- **DPI 接口**：
  - `uartdpi`：UART 仿真接口，连接标准输出
  - `SimJTAG`：JTAG 调试接口
- **内存加载**：通过 `+PRELOAD` 参数加载软件二进制到 RAM
- **波形输出**：支持 FSDB 格式（Synopsys 专用）

### Verilator 测试台（`ara_tb_verilator.sv`）

- 简化版测试台，专注于纯 RTL 仿真
- 使用 C++ 测试台（`ara_tb.cpp`）控制仿真流程
- 支持 FST 波形输出

---

## DPI（Direct Programming Interface）

测试台使用 DPI-C 接口连接 C/C++ 代码：

- **源文件位置**：`../tb/dpi/`
- **编译方式**：自动编译为共享库链接到仿真器
- **功能**：提供 printf 输出、JTAG 仿真、内存初始化等

---

## 常用工作流

### 1. 开发调试流程（VCS + Verdi）

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

### 2. 批量回归测试（Verilator）

```bash
# 编译所有软件测试
make -C ../software all

# 运行所有测试（脚本示例）
for app in ../software/build/bin/*; do
    echo "Testing: $app"
    make verilator-run app=$app
done
```

### 3. 性能对比测试

```bash
# VCS 仿真（波形）
time make vcs-wave app=../software/build/bin/fmatmul

# Verilator 仿真（波形）
time make verilator-wave app=../software/build/bin/fmatmul
```

---

## 故障排查

### 许可证问题

```bash
# 检查 VCS 许可证
lmstat -c 27000@license_server -a | grep vcs

# 如果许可证不足，Verilator 是免费替代方案
make verilate
```

### 编译错误

1. **文件找不到**：检查 `filelist.f` 中的相对路径是否正确
2. **DPI 编译错误**：确保 C++ 编译器支持 C++17（`-std=c++17`）
3. **内存不足**：VCS 编译需要较大内存，尝试减少并行编译任务

### 波形查看

- **FSDB 文件**：必须使用 Synopsys Verdi 打开
- **FST 文件**：使用 GTKWave 打开：`gtkwave waveform.fst`

---

## 清理构建

```bash
# 删除所有仿真输出（保留源代码）
make clean

# 手动清理（如果 make clean 不完整）
rm -rf build/
rm -f *.fsdb *.fst *.vcd ucli.key novas.*
```
