#!/bin/bash
# 运行单个 AXU 测试用例
# 用法: ./zzc_axu_shell_single.sh <case_name>
# 示例: ./zzc_axu_shell_single.sh vpu_add

CASE_NAME=${1:-vpu_add}

echo "=========================================="
echo "Running AXU test case: $CASE_NAME"
echo "=========================================="

cd ./software && make clean && cd ..
cd ./sim && make clean && cd ..

# input_data.h is regenerated for the specific test case by
# software/app/my_axu_test/app.mk before main.c is compiled.
# Generator script: zzc_workspace_axu/file_format_transform/gen_input_data_axu.py

cd ./software && make my_axu_test AXU_TEST_CASE=$CASE_NAME && cd ..

cd ./sim && make vcs-run \
                 app=../software/build/bin/my_axu_test \
                 FILELIST=filelist_minimum_my_mxu_axu.f \
         && cd ..

echo ""
echo "=========================================="
echo "Test case $CASE_NAME completed"
echo "=========================================="
