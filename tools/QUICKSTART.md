# RISC-V Toolchain Quick Start

## 现状

✅ **工具链已就绪**: 你的 `~/tools/riscv/` 目录包含完整的 RISC-V GCC 13.2.0 工具链。

⚠️ **已知问题**: 预装的 LLVM/Clang 缺少动态库 (`libtinfo.so.6`)，在 CentOS 7 上无法运行。

**解决方案**: 当前配置自动使用 GCC 作为编译器。

## 快速开始

### 1. 设置环境

```bash
source /data/home/rh_xu30/Work/ara_soc/tools/setup-env.sh
```

这会设置：
- `PATH` 包含 `~/tools/riscv/bin`
- 代理设置用于网络访问

### 2. 验证工具链

```bash
riscv64-unknown-elf-gcc --version
```

预期输出:
```
riscv64-unknown-elf-gcc () 13.2.0
```

### 3. 构建应用程序

```bash
cd /data/home/rh_xu30/Work/ara_soc/software

# 构建所有应用
make all

# 或构建特定应用
make hello_world
```

## 故障排除

### 问题: "riscv64-unknown-elf-gcc: command not found"

**解决**: 确保已 source 环境设置脚本
```bash
source /data/home/rh_xu30/Work/ara_soc/tools/setup-env.sh
```

### 问题: 代理/网络连接失败

**检查 SSH 隧道**:
在你的本地机器上（有互联网连接的机器）:
```bash
ssh -N -R 2345:127.0.0.1:7890 rh_xu30@<remote-host>
```

**测试代理**:
```bash
curl -I --proxy http://127.0.0.1:2345 https://github.com
```

### 问题: 需要 LLVM/Clang 而不是 GCC

如果需要 LLVM 特性，可以从源码构建兼容的版本：

```bash
cd /data/home/rh_xu30/Work/ara_soc/tools
make llvm
```

构建完成后，Makefile 会自动检测并使用新构建的 LLVM。

## 文件变更总结

已更新的文件:
- `software/sdk/mk/toolchain.mk` - 工具链检测逻辑
- `tools/Makefile` - LLVM 源码构建（可选）
- `tools/setup-env.sh` - 环境设置脚本
- `tools/README.md` - 完整文档
- `tools/check-deps.sh` - 依赖检查

## 下一步

1. Source 环境脚本
2. 尝试构建 `hello_world`
3. 验证生成的 ELF 文件可以运行或仿真
