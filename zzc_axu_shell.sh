#!/bin/bash
# AXU 全测试用例自动化脚本
# 循环运行所有测试用例，每次只编译和运行一个测试用例

# 定义所有测试用例（按执行顺序）
TEST_CASES=(
    "vpu_add"
    "vpu_sub"
    "vpu_mul"
    "vpu_max"
    "vpu_min"
    "vpu_reduce_max"
    "vpu_reduce_sum"
    "sfu_int2posit"
    "sfu_rng"          # 包含 sfu_rng_seed
    "nli_mish"         # 包含 nli_mish_mul, nli_mish_ybnd
    "nli_tanh"         # 包含 nli_tanh_mul, nli_tanh_ybnd
    "scheduler"
)

# 结果统计
TOTAL=0
PASS=0
FAIL=0
FAILED_CASES=()

echo "=========================================="
echo "AXU All Test Cases Runner"
echo "Total cases: ${#TEST_CASES[@]}"
echo "=========================================="

# 循环运行每个测试用例
for CASE in "${TEST_CASES[@]}"; do
    TOTAL=$((TOTAL + 1))
    echo ""
    echo "[$TOTAL/${#TEST_CASES[@]}] Running test case: $CASE"
    echo "------------------------------------------"
    
    # 清理
    cd ./software && make clean > /dev/null 2>&1 && cd ..
    cd ./sim && make clean > /dev/null 2>&1 && cd ..
    
    # 编译
    echo "Compiling $CASE..."
    cd ./software && make my_axu_test AXU_TEST_CASE=$CASE
    if [ $? -ne 0 ]; then
        echo "ERROR: Compilation failed for $CASE"
        FAIL=$((FAIL + 1))
        FAILED_CASES+=("$CASE (compile)")
        cd ..
        continue
    fi
    cd ..
    
    # 仿真
    echo "Running simulation for $CASE..."
    cd ./sim && make vcs-run \
                     app=../software/build/bin/my_axu_test \
                     FILELIST=filelist_minimum_my_mxu_axu.f > /dev/null 2>&1
    
    # 检查结果
    cp uart0.log ./uart_logs/test_$CASE\_uart0.log
    if grep -q "AXU_PASS" uart0.log 2>/dev/null; then
        echo "RESULT: $CASE PASS ✓"
        PASS=$((PASS + 1))
    else
        echo "RESULT: $CASE FAIL ✗"
        FAIL=$((FAIL + 1))
        FAILED_CASES+=("$CASE (sim)")
    fi
    cd ..
done

# 输出总结
echo ""
echo "=========================================="
echo "AXU Test Summary"
echo "=========================================="
echo "Total:  $TOTAL"
echo "Pass:   $PASS"
echo "Fail:   $FAIL"

if [ $FAIL -gt 0 ]; then
    echo ""
    echo "Failed cases:"
    for CASE in "${FAILED_CASES[@]}"; do
        echo "  - $CASE"
    done
    echo ""
    echo "AXU_FAIL"
    exit 1
else
    echo ""
    echo "All tests passed!"
    echo "AXU_PASS"
    exit 0
fi


