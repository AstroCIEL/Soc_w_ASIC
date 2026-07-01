#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILELIST="${FILELIST:-filelist_minimum_dcim.f}"
APP="${APP:-dcim_test}"
TOPO="${DCIM_TEST_TOPO:-3}"
RUN_GOLDEN="${DCIM_RUN_GOLDEN:-0}"
GOLDEN_DIR="${ROOT}/software/app/dcim_test/golden"

echo "[dcim] build software app=${APP} DCIM_TEST_TOPO=${TOPO}"
make -C "${ROOT}/software" "${APP}" DCIM_TEST_TOPO="${TOPO}"

echo "[dcim] build simv FILELIST=${FILELIST}"
make -C "${ROOT}/sim" clean vcs FILELIST="${FILELIST}"

ELF="${ROOT}/software/build/bin/${APP}"
echo "[dcim] run sim with ${ELF}"
make -C "${ROOT}/sim" vcs-run FILELIST="${FILELIST}" app="${ELF}" | tee "${ROOT}/sim/dcim_uart.log"

if grep -q 'DCIM_PASS' "${ROOT}/sim/dcim_uart.log" || grep -q 'DCIM_PASS' "${ROOT}/sim/uart0.log" 2>/dev/null; then
    echo "[dcim] PASS marker found"
else
    echo "[dcim] FAIL: DCIM_PASS not found in log"
    exit 1
fi

if [[ "${RUN_GOLDEN}" == "1" ]]; then
    if [[ "${APP}" != "dcim_test" ]]; then
        echo "[dcim] skip golden: APP=${APP} (golden flow is for dcim_test)"
        exit 0
    fi

    echo "[dcim] run golden pipeline in ${GOLDEN_DIR}"
    pushd "${GOLDEN_DIR}" >/dev/null

    UART_LOG="${ROOT}/sim/dcim_uart.log"
    if [[ ! -f "${UART_LOG}" ]]; then
        UART_LOG="${ROOT}/sim/uart0.log"
    fi

    python3 extract_io.py "${UART_LOG}" --out dcim_io_trace.csv
    python3 io_to_mem.py --csv dcim_io_trace.csv
    python3 check.py

    popd >/dev/null
    echo "[dcim] GOLDEN_CHECK_PASS"
fi

echo "[dcim] PASS"
