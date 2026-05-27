# 综合指南

本文档说明Soc_w_ASIC项目的 Design Compiler (DC NXT) 综合流程，包括 PDK 准备、SRAM/RF 宏生成，以及 SoC 综合运行方式。

---

## 目录结构

综合依赖独立的 PDK 目录与 SoC 工程目录，当前使用的结构是二者并列放置：

```
$HOME/workspace/
├── tsmc22/          # TSMC 22nm PDK + SRAM/RF 宏库
│   ├── tech/        # 工艺文件
│   ├── sram/        # 生成的 SRAM/RF 宏（.v / .lib / .lef 等）
│   └── compile.sh   # .lib → .db 转换脚本
└── Soc_w_ASIC/      # 本项目
    ├── scripts/     # gen_sram.py 等辅助脚本
    └── syn/         # 综合 Makefile 与 DC 脚本
```

默认 PDK 路径为 `$HOME/workspace/tsmc22`，可通过 `make syn PDK_ROOT=<path>` 覆盖。

---

## 前置准备：获取 PDK

若本地尚无 `tsmc22` 目录，可从 EDA 服务器拷贝：

```bash
cp /data/home/x_long32/data_share/tsmc22.tar.gz <目标路径>
tar xzf tsmc22.tar.gz -C $HOME/workspace/
```

---

## 添加新 SRAM/RF 宏

当设计需要新的 memory 实例时，按下列步骤完成从生成到综合可用的全流程。

### Step 1：生成 SRAM/RF 文件

使用 `scripts/gen_sram.py` 调用 TSMC Memory Compiler，生成 Verilog、Liberty、LEF 等目标文件。

```bash
cd $HOME/workspace/Soc_w_ASIC/scripts
python3 gen_sram.py
```

生成结果默认写入当前目录；日志保存在 `logs/` 下。

**添加新配置时，需修改 `gen_sram.py` 中以下内容：**

| 修改项 | 说明 |
|--------|------|
| `*_GENERATOR` 路径 | Memory Compiler 可执行文件路径 |
| `cpu_*_defs` / `ram_defs` / `rf_defs` | 新增 memory 规格定义（名称、深度、位宽） |
| `corners` | Liberty 角点列表 |
| `build_*_cmd()` 函数 | 对应Memory Compiler 命令行参数 |
| `make_instname()` | 实例命名规则（影响输出文件名） |

新增宏后，还需同步更新：

- `tsmc22/create_sram_milkway.tcl` 中的 `SRAM_MACROS` 列表
- `Soc_w_ASIC/scripts/create_sram_milkway.tcl` 中的 `SRAM_MACROS` 列表（若与本项目脚本不一致）
- 对应 RTL wrapper 与 filelist

### Step 2：Liberty 转 DB

DC 综合需要 `.db` 格式的时序库，使用 `compile.sh` 批量转换：

```bash
cd $HOME/workspace/tsmc22
bash compile.sh sram    # 转换 sram/ 目录下所有 .lib。 也可以指定其他目录名称
```

已存在同名 `.db` 的文件会自动跳过。

### Step 3：编译生成 Milkyway 库

DC topographical mode 需要 Milkyway 物理参考库（FRAM+CEL）：

```bash
cd $HOME/workspace/tsmc22/sram/milkway
Milkyway -galaxy -nullDisplay -tcl -file \
  <path>/create_sram_milkway.tcl
```

输出目录：`$PDK_ROOT/sram/milkway/sram_macro_milkway`。

> 若使用项目内create_sram_milkway脚本，路径为 `Soc_w_ASIC/scripts/create_sram_milkway.tcl`。

### Step 4：更新综合脚本中的宏与物理库

Topo 综合会把 SRAM 宏的 Milkyway 库挂到参考库列表，并在 elaboration 之后对宏单元打 `dont_touch`。新增或改名宏时，需同步改两处（路径均相对于仓库根目录 `Soc_w_ASIC/`）：

| 文件 | 作用 | 典型修改 |
|------|------|----------|
| `syn/scripts/physical.tcl` | 定义 `_phys_MW_REFERENCE_LIBS`（含标准单元 + SRAM MW 库） | 在 `lappend _phys_MW_REFERENCE_LIBS` 段增加一行，指向新生成的 MW 库目录（需与 Step 3 输出路径、库名一致） |
| `syn/setup/setup.tcl` | 定义 `SRAM_MACROS`（Liberty 中的 cell 参考名） | 在 `SRAM_MACROS` 的 `list` 中追加与 `.lib` / RTL 一致的宏单元名 |

当前脚本中的参考写法：

- **物理库路径**：`physical.tcl` 中已有 `${PDK_ROOT}/sram/milkway/sram_macro_milkway`；若 Step 3 使用了别的输出目录或库名，请改成相同路径。
- **宏名列表**：`setup.tcl` 内 `SRAM_MACROS` 与 `create_sram_milkway.tcl` 里的 `SRAM_MACROS`、以及 `mmmc.tcl` 中 link 的 `.db` 应保持一致。

### Step 5：运行综合

```bash
cd $HOME/workspace/Soc_w_ASIC/syn

# 建议先检查 filelist 完整性
make check SOC_CONFIG=<配置名>

# 启动综合
make syn SOC_CONFIG=<配置名>
```

综合日志与输出位于 `syn/build/`。

---

## 综合命令参考

### 常用目标

| 命令 | 说明 |
|------|------|
| `make check SOC_CONFIG=<name>` | 检查 filelist 中所有源文件是否存在 |
| `make syn SOC_CONFIG=<name>` | 从 RTL 启动完整综合 |
| `make syn_incr SOC_CONFIG=<name>` | 从 checkpoint 增量重跑（默认 `post_constraints`） |
| `make clean` | 清除 `build/` 及临时文件 |
| `make help` | 打印完整帮助 |

### 可用 SoC 配置

`SOC_CONFIG` 对应 `hardware/soc/filelist_<name>.f` 与 `filelist_syn_<name>.f`：

| 配置名 | 说明 |
|--------|------|
| `maximum` | 完整 SoC（CVA6 + ARA VPU + iDMA），默认配置 |
| `minimum_my_mxu` | Minimum + 自定义 MXU 加速模块 |
| `minimum_my_mxu_axu` | Minimum + MXU + AXU 加速模块 |

### 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `SOC_CONFIG` | `maximum` | 选择 SoC 网表配置 |
| `PDK_ROOT` | `$HOME/workspace/tsmc22` | PDK 根目录 |
| `INCR_CHECKPOINT` | `post_constraints` | 增量综合起始 checkpoint |

`INCR_CHECKPOINT` 可选值：

- `post_elab` — 重新施加约束并 compile
- `post_constraints` — incremental compile（默认）
- `post_compile` — 仅生成 report
- `final` — 仅输出与 report

> 如果修改了脚本，最好重新syn而不要使用增量综合。

### 示例

```bash
# 综合 minimum + MXU + AXU 配置
make check SOC_CONFIG=minimum_my_mxu_axu
make syn   SOC_CONFIG=minimum_my_mxu_axu

# 指定 PDK 路径
make syn PDK_ROOT=/path/to/tsmc22 SOC_CONFIG=maximum
```

---

## 流程概览

| 顺序 | 动作 |
|------|------|
| ① | `gen_sram.py` 生成源与 Liberty/LEF |
| ② | `compile.sh` 将 `.lib` 转为 `.db` |
| ③ | Milkyway 生成 MW 库 |
| ④ | 更新 `syn/scripts/physical.tcl`、`syn/setup/setup.tcl` |
| ⑤ | `make syn` |