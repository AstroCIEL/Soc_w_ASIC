#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILELIST="${FILELIST:-filelist_minimum_dcim_postpnr.f}"
APP="${APP:-dcim_test}"
TOPO="${DCIM_TEST_TOPO:-3}"

echo "[dcim-postpnr] build software app=${APP} DCIM_TEST_TOPO=${TOPO}"
make -C "${ROOT}/software" "${APP}" DCIM_TEST_TOPO="${TOPO}"

echo "[dcim-postpnr] build simv FILELIST=${FILELIST}"
make -C "${ROOT}/sim" clean vcs FILELIST="${FILELIST}" VCS_TOP="io_top_postpnr_tb"

ELF="${ROOT}/software/build/bin/${APP}"
echo "[dcim-postpnr] run sim with ${ELF}"
make -C "${ROOT}/sim" vcs-run FILELIST="${FILELIST}" VCS_TOP="io_top_postpnr_tb" app="${ELF}" | tee "${ROOT}/sim/dcim_postpnr_uart.log"

if grep -q 'PASS' "${ROOT}/sim/dcim_postpnr_uart.log" || grep -q 'PASS' "${ROOT}/sim/uart0.log" 2>/dev/null; then
    echo "[dcim-postpnr] PASS marker found"
else
    echo "[dcim-postpnr] FAIL: PASS not found in log"
    exit 1
fi

echo "[dcim-postpnr] PASS"
