#!/usr/bin/env bash
set -euo pipefail

RUN_STAGE=${1:-sim_post_syn}                                         # sim, sim_post_syn
FILELIST=${FILELIST:-filelist_minimum_my_mxu_axu.f}
APP=${APP:-../software/build/bin/mxu_idma_gbuf_test}

usage() {
    echo "Usage: $0 [sim|sim_post_syn]"
    echo ""
    echo "Environment variables:"
    echo "  APP       test binary, default: ../software/build/bin/mxu_idma_gbuf_test"
    echo "  FILELIST  simulation filelist, default: filelist_minimum_my_mxu_axu.f"
}

build_software() {
    cd ./software
    make clean
    make mxu_idma_gbuf_test
    cd ..
}

run_sim() {
    cd ./sim
    make clean
    make vcs-wave \
        app="$APP" \
        FILELIST="$FILELIST"
    cd ..
    cp ./sim/uart0.log ./sim/uart_logs/test_idma_gbuf_uart0.log
}

run_sim_post_syn() {
    cd ./sim_post_syn
    make run-gate \
        APP="$APP" \
        FILELIST="$FILELIST"
    cd ..
    cp ./sim_post_syn/uart0.log ./sim_post_syn/uart_logs/test_idma_gbuf_uart0.log
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
    -h|--help|help)
        usage
        ;;
    *)
        echo "Error: unknown stage '$RUN_STAGE'" >&2
        usage >&2
        exit 1
        ;;
esac
