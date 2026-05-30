#!/usr/bin/env bash
set -euo pipefail

# 运行单个 AXU 测试用例
# 用法: ./zzc_axu_shell_single.sh [case_name] [sim|sim_post_syn]
# 示例: ./zzc_axu_shell_single.sh vpu_add sim
# 示例: ./zzc_axu_shell_single.sh vpu_add sim_post_syn

CASE_NAME=${1:-vpu_add}
RUN_STAGE=${2:-sim_post_syn}                                         # sim, sim_post_syn
FILELIST=${FILELIST:-filelist_minimum_my_mxu_axu.f}
APP=${APP:-../software/build/bin/my_axu_test}

usage() {
    echo "Usage: $0 [case_name] [sim|sim_post_syn]"
    echo ""
    echo "Arguments:"
    echo "  case_name  AXU test case, default: vpu_add"
    echo "  stage      simulation stage, default: sim"
    echo ""
    echo "Environment variables:"
    echo "  APP       test binary, default: ../software/build/bin/my_axu_test"
    echo "  FILELIST  simulation filelist, default: filelist_minimum_my_mxu_axu.f"
}

build_software() {
    cd ./software
    make clean
    make my_axu_test AXU_TEST_CASE="$CASE_NAME"
    cd ..
}

run_sim() {
    cd ./sim
    make clean
    make vcs-run \
        app="$APP" \
        FILELIST="$FILELIST"
    cd ..
    cp ./sim/uart0.log ./sim/uart_logs/test_axu_${CASE_NAME}_uart0.log
}

run_sim_post_syn() {
    cd ./sim_post_syn
    make run-gate \
        APP="$APP" \
        FILELIST="$FILELIST"
    cd ..
    cp ./sim_post_syn/uart0.log ./sim_post_syn/uart_logs/test_axu_${CASE_NAME}_uart0.log
}

case "$CASE_NAME" in
    -h|--help|help)
        usage
        exit 0
        ;;
esac

echo "=========================================="
echo "Running AXU test case: $CASE_NAME"
echo "Simulation stage: $RUN_STAGE"
echo "=========================================="

case "$RUN_STAGE" in
    sim)
        build_software
        run_sim
        ;;
    sim_post_syn)
        build_software
        run_sim_post_syn
        ;;
    -h|--help|help)
        usage
        ;;
    *)
        echo "Error: unknown stage '$RUN_STAGE'" >&2
        usage >&2
        exit 1
        ;;
esac

echo ""
echo "=========================================="
echo "Test case $CASE_NAME completed"
echo "=========================================="
