#!/bin/bash

# 确保脚本在遇到任何错误时立即停止执行
set -e

# 获取当前脚本的绝对路径
ROOT_DIR=$(pwd)
OUTPUT_DIR="${ROOT_DIR}/rf64x128"

# 定义各视图的直接子目录名称
LIB_SUB="lib"
DB_SUB="db"
GDS_SUB="gds"
CDL_SUB="cdl"
LEF_SUB="lef"
V_SUB="verilog"
PS_SUB="ps"

# 定义 Memory Compiler 的二进制路径
MC_BIN="/data/data_eda2/PDK_Tech/TSMC_22NM_RF_ULL/IP/Memory_Compiler/rf_sp_hde_svt_mvt/r0p0/bin/rf_sp_hde_svt_mvt"

# 使用 Bash 数组，严格对应你给出的 rf64x128 命令行参数
COMMON_ARGS=(
    -name_case lower
    -mvt BASE
    -bus_notation on
    -ser none
    -site_def off
    -check_instname on
    -frequency 1.0
    -bmux off
    -diodes on
    -activity_factor 50
    -words 64
    -drive 6
    -power_type otc
    -bits 128
    -instname rf64x128
    -retention on
    -libertyviewstyle ccs_tnv
    -write_mask on
    -atf off
    -left_bus_delim "["
    -pwr_gnd_rename vddpe:VDDPE,vddce:VDDCE,vsse:VSSE
    -right_bus_delim "]"
    -wp_size 1
    -redundancy off
    -libname rf64x128
    -write_thru off
    -cust_comment "This is a memory instance"
    -mux 2
    -top_layer m5-m10
    -power_gating off
    -back_biasing off
    -ema on
    -vmin_assist on
    -corners ffg_cbestt_0p88v_0p88v_m40c,ssg_cworstt_0p72v_0p72v_125c,ssg_cworstt_0p72v_0p72v_m40c,tt_typical_0p80v_0p80v_25c
)

echo "=== Creating Output Directory: ${OUTPUT_DIR} ==="
mkdir -p "${OUTPUT_DIR}"

# 1. 生成 时序/功耗/噪声模型 (.lib)
echo "=== Generating Liberty views ==="
mkdir -p "${OUTPUT_DIR}/${LIB_SUB}"
cd "${OUTPUT_DIR}/${LIB_SUB}"
"$MC_BIN" liberty "${COMMON_ARGS[@]}"

# 2. 将刚生成的 lib 文件转换为 db 二进制文件
echo "=== Converting .lib to .db ==="
mkdir -p "${OUTPUT_DIR}/${DB_SUB}"

# 动态生成纯绝对路径控制的 convert.tcl
cat << EOF > "${OUTPUT_DIR}/${DB_SUB}/convert.tcl"
# 获取 lib 文件夹下的所有 .lib 文件
set lib_files [glob -nocomplain ${OUTPUT_DIR}/${LIB_SUB}/*.lib*]

foreach lib \$lib_files {
    # 1. 精准提取不带路径的纯文件名
    set tail_name [file tail \$lib]
    
    # 2. 定位 .lib 精准切出真实的内部库名
    set idx [string first ".lib" \$tail_name]
    if {\$idx != -1} {
        set current_lib [string range \$tail_name 0 [expr \$idx - 1]]
    } else {
        set current_lib [file rootname \$tail_name]
    }
    
    # 3. 替换后缀生成纯粹的文件名
    set db_name [string map {.lib .db} \$tail_name]
    
    # 读入真实 lib 文件
    read_lib \$lib
    
    echo "Writing database for library: \$current_lib -> \$db_name"
    
    # 写出 db 文件到当前目录下
    write_lib -format db \$current_lib -output \$db_name
    
    # 清理内存
    remove_lib \$current_lib
}
exit
EOF

cd "${OUTPUT_DIR}/${DB_SUB}"
if command -v lc_shell &> /dev/null; then
    lc_shell -f convert.tcl
elif command -v dc_shell &> /dev/null; then
    dc_shell -tcl_mode -f convert.tcl
else
    echo "WARNING: Neither lc_shell nor dc_shell found. Skip .db conversion."
fi

# 转换结束，自动清理临时 TCL 脚本
rm -f convert.tcl

# 3. 生成 版图数据 (.gds / .gds2)
echo "=== Generating GDS2 layout ==="
mkdir -p "${OUTPUT_DIR}/${GDS_SUB}"
cd "${OUTPUT_DIR}/${GDS_SUB}"
"$MC_BIN" gds2 "${COMMON_ARGS[@]}"

# 4. 生成 仿真网表 (.cdl / .spi)
echo "=== Generating CDL netlist ==="
mkdir -p "${OUTPUT_DIR}/${CDL_SUB}"
cd "${OUTPUT_DIR}/${CDL_SUB}"
"$MC_BIN" lvs "${COMMON_ARGS[@]}"

# 5. 生成 物理抽象模型 (.lef)
echo "=== Generating LEF view ==="
mkdir -p "${OUTPUT_DIR}/${LEF_SUB}"
cd "${OUTPUT_DIR}/${LEF_SUB}"
"$MC_BIN" lef-fp "${COMMON_ARGS[@]}"

# 6. 生成 行为仿真模型 (.v)
echo "=== Generating Verilog model ==="
mkdir -p "${OUTPUT_DIR}/${V_SUB}"
cd "${OUTPUT_DIR}/${V_SUB}"
"$MC_BIN" verilog "${COMMON_ARGS[@]}"

# 7. 生成 说明文件 (.ps)
echo "=== Generating Postscript file ==="
mkdir -p "${OUTPUT_DIR}/${PS_SUB}"
cd "${OUTPUT_DIR}/${PS_SUB}"
"$MC_BIN" postscript "${COMMON_ARGS[@]}"

# 回到初始工作目录
cd "${ROOT_DIR}"

echo "========================================================="
echo " All IP views generated and nested in: "
echo " ${OUTPUT_DIR} "
echo "========================================================="
