# TPU-Lite-SoC

完整项目报告位于 [TPU_Lite_SoC.pdf](./TPU_Lite_SoC.pdf)，LaTeX 源代码位于 [TPU-Lite-SoC.zip](TPU-Lite-SoC.zip)。

This project implements a lightweight TPU (Tensor Processing Unit) integrated into a RISC-V SoC (System on Chip).

## 验证方法 (Verification Methods)

本项目提供了两个层级的验证环境，分别针对 TPU 模块级功能和 SoC 系统级集成进行测试。

### 1. TPU 模块级验证 (Unit Verification)
位于 `sim_tpu/` 目录下。该验证环境将 TPU 作为一个独立的模块进行测试，不包含 CPU。
- 详细说明请参考: [sim_tpu/README.md](sim_tpu/README.md)
- **运行方式**: 在 `sim_tpu/` 目录下运行 `make all`。
- **特点**: 使用 `+define+LOAD_TXT` 宏自动加载测试数据到寄存器/SRAM中，输出结果可直接与 `data/` 目录下的 Golden Reference (`layer1_output_before_relu.txt`) 进行比对。

### 2. SoC 系统级验证 (System Verification)
位于 `sim_soc/` 目录下。该环境仿真整个 SoC 系统，包含 CVA6 RISC-V CPU、TPU、DMA 模块、总线互联及存储器。
- 详细说明请参考: [sim_soc/README.md](sim_soc/README.md)
- **运行方式**: Testbench 位于 [src/tb/test_soc_mlp_first_layer_tb.sv](src/tb/test_soc_mlp_first_layer_tb.sv)。
- **流程**: CPU 执行编译好的 C 代码 (从 `CPU_C_code` 编译生成的 hex 文件)，通过 DMA 控制 TPU 进行计算，并读取结果进行校验。

## 目录结构 (Directory Structure)

```
.
├── src/                # RTL 源文件 (SystemVerilog)
│   ├── soc/            # SoC 系统相关组件 (CPU cva6, Interconnect, etc.)
│   ├── tpu/            # TPU 核心组件
│   ├── tb/             # Testbench 文件
│   └── filelist.f      # 仿真文件列表
│
├── sim_tpu/            # TPU 独立仿真工作目录 (Makefile, 波形配置等)
├── sim_soc/            # SoC 系统仿真工作目录
│
├── CPU_C_code/         # SoC 级验证的 C 源码
│                       # 包含 main.c, 驱动程序，需要 RISC-V GCC 编译
│
├── software/           # MLP 软件层设计
│
├── instruction/        # TPU 指令生成工具
│                       # 包含将 Excel 指令表转换为二进制/机器码的脚本
│
└── data/               # 模型参数与 Golden 数据
    ├── hex_to_c.py     # 脚本: 将 hex 数据转换为 C 数组 (用于 SoC 验证)
    └── *.txt           # 权重、输入、参考输出数据的文本格式
```
