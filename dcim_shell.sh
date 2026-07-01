#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILELIST="${FILELIST:-filelist_minimum_dcim.f}"
APP="${APP:-dcim_test}"
TOPO="${DCIM_TEST_TOPO:-3}"

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

echo "[dcim] PASS"
