#!/usr/bin/env bash
set -euo pipefail

# AXU 全测试用例自动化脚本
# 循环运行所有测试用例，每次调用 zzc_axu_shell_single.sh 编译并运行一个测试用例
# 用法: ./zzc_axu_shell.sh [sim|sim_pre_syn|sim_post_syn]

RUN_STAGE=${1:-sim_pre_syn}                                         # sim, sim_pre_syn, sim_post_syn

usage() {
    echo "Usage: $0 [sim|sim_pre_syn|sim_post_syn]"
    echo ""
    echo "Arguments:"
    echo "  stage  simulation stage, default: sim"
}

case "$RUN_STAGE" in
    sim|sim_pre_syn|sim_post_syn)
        ;;
    -h|--help|help)
        usage
        exit 0
        ;;
    *)
        echo "Error: unknown stage '$RUN_STAGE'" >&2
        usage >&2
        exit 1
        ;;
esac

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

if [ "$RUN_STAGE" = "sim" ]; then
    UART_LOG_DIR="./sim/uart_logs"
elif [ "$RUN_STAGE" = "sim_pre_syn" ]; then
    UART_LOG_DIR="./sim_pre_syn/uart_logs"
else
    UART_LOG_DIR="./sim_post_syn/uart_logs"
fi

SINGLE_SCRIPT="./zzc_axu_shell_single.sh"

echo "=========================================="
echo "AXU All Test Cases Runner"
echo "Simulation stage: $RUN_STAGE"
echo "Total cases: ${#TEST_CASES[@]}"
echo "=========================================="

# 循环运行每个测试用例
for CASE in "${TEST_CASES[@]}"; do
    TOTAL=$((TOTAL + 1))
    echo ""
    echo "[$TOTAL/${#TEST_CASES[@]}] Running test case: $CASE"
    echo "------------------------------------------"

    if ! "$SINGLE_SCRIPT" "$CASE" "$RUN_STAGE"; then
        echo "ERROR: $CASE failed while running $RUN_STAGE"
        FAIL=$((FAIL + 1))
        FAILED_CASES+=("$CASE ($RUN_STAGE run)")
        continue
    fi

    UART_LOG="$UART_LOG_DIR/test_axu_${CASE}_uart0.log"
    if grep -q "AXU_PASS" "$UART_LOG" 2>/dev/null; then
        echo "RESULT: $CASE PASS"
        PASS=$((PASS + 1))
    else
        echo "RESULT: $CASE FAIL"
        FAIL=$((FAIL + 1))
        FAILED_CASES+=("$CASE ($RUN_STAGE)")
    fi
done

# 输出总结
echo ""
echo "=========================================="
echo "AXU Test Summary"
echo "=========================================="
echo "Stage:  $RUN_STAGE"
echo "Total:  $TOTAL"
echo "Pass:   $PASS"
echo "Fail:   $FAIL"

if [ "$FAIL" -gt 0 ]; then
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
