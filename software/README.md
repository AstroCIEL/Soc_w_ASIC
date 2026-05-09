# Ara SoC Software BSP

本目录包含 Ara SoC（RISC-V 向量处理器）的软件板级支持包（BSP），提供应用程序开发所需的基础运行时库、驱动程序和构建系统。

## 目录结构

```
software/
├── app/              # 应用程序目录
│   ├── hello_world/  # 基础测试程序
│   ├── fmatmul/      # 浮点矩阵乘法（RVV 向量指令）
│   ├── dotproduct/   # 向量点积
│   ├── dma_desc64_test/  # DMA 描述符64测试
│   ├── asic_dma_accel_test/ # minimum_asic_dma 网表：片内 DMA ASIC
│   ├── asic_accel_test/  # MMIO ASIC 示例（默认网表未接，见根目录 DOC）
│   └── ...           # 其他测试应用
├── sdk/              # 软件开发套件
│   ├── src/          # SDK 源文件（printf, syscalls, crt0.S 等）
│   └── include/      # 头文件
├── soc/              # SoC 外设驱动
│   ├── src/          # 驱动源文件（serial, plic, clint, dma 等）
│   └── include/       # 驱动头文件
├── common/           # 通用代码
├── scripts/          # 构建脚本和链接器配置
│   ├── toolchain.mk  # 工具链配置
│   ├── rules.mk      # 构建规则
│   └── link.ld       # 链接器脚本
└── Makefile          # 主 Makefile
```

## 构建系统

### 工具链

本项目使用 **LLVM/Clang 17.0.6** 作为 RISC-V 向量扩展（RVV）的编译器，配合 **LLD** 链接器。工具链路径通过 `scripts/toolchain.mk` 自动检测：

1. 优先使用项目本地 LLVM（`ara_soc/install/riscv-llvm`）
2. 使用 `--target=riscv64-unknown-elf` 和 `--sysroot` 配置

### Make 指令

#### 基本用法

```bash
# 构建所有应用程序
make all

# 构建特定应用
make hello_world
make fmatmul
make dma_desc64_test

# 清理构建目录
make clean
```

#### 构建逻辑

1. **应用发现**：自动扫描 `app/` 目录下的 `app.mk` 文件
2. **依赖管理**：
   - 公共运行时：`sdk/src/` 和 `soc/src/` 的基础库
   - 应用特定源文件：`app/<name>/main.c` 及内核代码
   - 数据生成：部分应用使用 Python 脚本生成测试数据（`data.S`）
3. **链接过程**：
   - 使用 `-nostdlib` 避免 newlib 的 LLD 兼容性问题
   - 链接 `libgcc` 和 `libm` 提供数学和运行时支持
   - 自定义系统调用 stub（`syscalls.c`）提供基础 I/O 支持

#### 支持的应用

| 应用 | 说明 | 特性 |
|------|------|------|
| `hello_world` | 基础功能测试 | UART 输出 |
| `fmatmul` | 浮点矩阵乘法 | RVV 向量指令 |
| `dotproduct` | 向量点积 | 整数/浮点向量 |
| `fdotproduct` | 浮点向量点积 | RVV 向量指令 |
| `dma_desc64_test` | DMA 描述符64测试 | 中断、描述符链式传输 |
| `dma_reg64_1d_test` | DMA 寄存器64 1D测试 | 1D 内存拷贝 |
| `asic_dma_accel_test` | 自定义 ASIC（片内 DMA） | 需 `sim/filelist_minimum_asic_dma.f`；驱动 `asic_dma_accel.c` |
| `asic_accel_test` | MMIO ASIC 示例 | 参考用；默认 SoC 未实例化，需自行接 RTL |
| `clint_test` | 定时器测试 | CLINT 中断 |
| `default_slave` | 默认从设备测试 | PLIC 中断 |
| `trap_test` | 异常测试 | 异常处理 |

### 配置选项

在 `config/default.mk` 中可配置：

```makefile
nr_lanes ?= 2    # 向量处理器 lane 数量
vlen     ?= 2048 # 向量寄存器位宽（VLEN）
```

### 第三套网表：ASIC（片内 DMA）

与 **maximum 的 iDMA** 无关；仅在仿真使用 `sim/filelist_minimum_asic_dma.f`（RTL：`hardware/soc/minimum_asic_dma/`）时有效：

```bash
make asic_dma_accel_test
# 在 sim/ 下：make vcs FILELIST=filelist_minimum_asic_dma.f
# make vcs-run FILELIST=filelist_minimum_asic_dma.f app=../software/build/bin/asic_dma_accel_test
```

寄存器与 API 见 `soc/include/asic_dma_accel.h`（基址与 `soc.h` 中 `ASIC_ACCEL_BASE` 一致）。

### 特殊应用配置

DMA 相关测试应用需要特殊配置以避免重定位错误：

```makefile
# app/dma_desc64_test/app.mk
dma_desc64_test_CFLAGS := -mcmodel=medlow -fno-builtin-printf
dma_desc64_test_LDFLAGS := -Wl,--no-relax
```

## 运行时库

### 提供的功能

- **printf**：轻量级格式化输出（通过 UART）
- **string**：基础字符串操作（memcpy, memset 等）
- **serial**：UART 驱动程序
- **soc_ctrl**：SoC 控制寄存器访问
- **plic**：平台级中断控制器驱动
- **clint**：核心本地中断器（定时器、软件中断）
- **dma_desc64/dma_reg64_1d**：iDMA 驱动

### 启动流程

1. `crt0.S`：设置栈指针、清零 BSS、跳转到 `main()`
2. `pre_main()`（弱符号）：初始化 UART、中断控制器等
3. `main()`：应用入口
4. `post_main()`（弱符号）：清理工作

## 注意事项

1. **链接器兼容性**：使用 LLD 而非 GNU ld，预编译的 newlib `libc.a` 可能有重定位问题，因此使用 `-nostdlib` 并自行实现系统调用 stub。

2. **代码模型**：
   - 大多数应用使用 `medany`（默认）
   - DMA 测试应用使用 `medlow` 避免重定位溢出

3. **中断处理**：通过 `plic.c` 和 `clint.c` 注册中断处理程序，启用 `mie` 和 `mstatus.MIE`。
