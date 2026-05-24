#!/usr/bin/env bash
set -euo pipefail

MODE=${1:-posit_ff}
case "${MODE}" in
    int_ff|posit_ff|posit_bp) ;;
    *)
        echo "Usage: $0 {int_ff|posit_ff|posit_bp}" >&2
        exit 2
        ;;
esac

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
WS="${ROOT_DIR}/zzc_workspace_mxu"
RESULT_DIR="${WS}/test_result/${MODE}"
UART_LOG="${ROOT_DIR}/sim/uart0.log"
APP_TARGET=${APP_TARGET:-my_mxu_test}
APP_BIN_OVERRIDE=${APP_BIN:-}
APP_BIN=${APP_BIN_OVERRIDE:-../software/build/bin/${APP_TARGET}}
FILELIST=${FILELIST:-filelist_minimum_my_mxu.f}

GEN_INPUT="${WS}/file_format_transform/gen_input_data.py"
LOG2TXT="${WS}/file_format_transform/log2txt_mxu.py"
COMPARE="${WS}/file_format_transform/compare_mxu.py"
GOLDEN_DIR="${WS}/gloden_result/${MODE}"
OUTPUT="${RESULT_DIR}/output.txt"
REPORT="${RESULT_DIR}/compare_report.txt"
SPLIT_DIR="${RESULT_DIR}/banks"

mkdir -p "${RESULT_DIR}"

for required in "${GEN_INPUT}" "${LOG2TXT}" "${COMPARE}"; do
    if [[ ! -f "${required}" ]]; then
        echo "ERROR: ${required} not found." >&2
        exit 5
    fi
done

if [[ ! -d "${GOLDEN_DIR}" ]]; then
    echo "ERROR: ${GOLDEN_DIR} not found." >&2
    exit 6
fi

if [[ ! -f "${ROOT_DIR}/software/app/${APP_TARGET}/app.mk" ]]; then
    echo "ERROR: software/app/${APP_TARGET}/app.mk not found." >&2
    exit 3
fi

if [[ ! -f "${ROOT_DIR}/sim/${FILELIST}" ]]; then
    echo "ERROR: sim/${FILELIST} not found." >&2
    exit 4
fi

cd "${ROOT_DIR}/software"
make clean
make "${APP_TARGET}" MXU_TEST_MODE="${MODE}"
cd "${ROOT_DIR}"

rm -f "${UART_LOG}" "${ROOT_DIR}"/sim/*.log
rm -rf "${ROOT_DIR}/sim/simv" "${ROOT_DIR}/sim/csrc"

cd "${ROOT_DIR}/sim"
make clean
make vcs-run \
    app="${APP_BIN}" \
    FILELIST="${FILELIST}"
cd "${ROOT_DIR}"

cp "${UART_LOG}" "${RESULT_DIR}/uart0.log"

python3 "${LOG2TXT}" \
    --in "${UART_LOG}" \
    --out "${OUTPUT}" \
    --section MXU_OUT \
    --split-dir "${SPLIT_DIR}"

python3 "${COMPARE}" \
    --mode "${MODE}" \
    --golden-dir "${GOLDEN_DIR}" \
    --output "${OUTPUT}" \
    --report "${REPORT}" \
    --rows 32
