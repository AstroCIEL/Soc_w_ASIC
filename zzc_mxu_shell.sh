#!/usr/bin/env bash
set -euo pipefail

TEST_MODE=${TEST_MODE:-int_ff}                                       #posit_ff, posit_bp, int_ff
RUN_STAGE=${1:-sim_pre_syn}                                         # sim, sim_post_syn
FILELIST=${FILELIST:-filelist_minimum_my_mxu_axu.f}
APP=${APP:-../software/build/bin/my_mxu_test}

usage() {
    echo "Usage: $0 [sim|sim_pre_syn|sim_post_syn]"
    echo ""
    echo "Environment variables:"
    echo "  TEST_MODE  MXU test mode, default: int_ff"
    echo "  FILELIST   simulation filelist, default: filelist_minimum_my_mxu_axu.f"
}

build_software() {
    cd ./software
    make clean
    make my_mxu_test MXU_TEST_MODE="$TEST_MODE"
    cd ..
}

run_sim() {
    cd ./sim
    make clean
    make vcs-wave \
        app="$APP" \
        FILELIST="$FILELIST"
    cd ..
    cp ./sim/uart0.log ./sim/uart_logs/test_mxu_${TEST_MODE}_uart0.log
}
run_sim_pre_syn() {
    cd ./sim_pre_syn
    make run \
        app="$APP"
    cd ..
    cp ./sim_pre_syn/uart0.log ./sim_pre_syn/uart_logs/test_mxu_${TEST_MODE}_uart0.log
}
run_sim_post_syn() {
    cd ./sim_post_syn
    # 如果 netlist 已经编译过，可以不执行 make compile-gate；注意不要 make clean，否则需要重新编译。
    make run-gate \
        app="$APP"     #FILELIST是默认的网表文件，不需要指定
    cd ..
    cp ./sim_post_syn/uart0.log ./sim_post_syn/uart_logs/test_mxu_${TEST_MODE}_uart0.log
}

case "$RUN_STAGE" in
    sim)
        build_software
        run_sim
        ;;
    sim_post_syn)
        build_software
        run_sim_post_syn
        ;;
    sim_pre_syn)
        build_software
        run_sim_pre_syn
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
