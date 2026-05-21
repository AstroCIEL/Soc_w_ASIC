#!/usr/bin/env python3
import argparse
from pathlib import Path
from typing import List, Tuple

BANK_COUNT = 8
ACT_BATCHSIZE = 32

PackedWord = Tuple[int, int]
BankRows = List[List[PackedWord]]


def parse_hex_tokens(path, expected_per_row):
    rows = []
    with path.open("r", encoding="utf-8") as f:
        for line_no, line in enumerate(f, start=1):
            line = line.strip()
            if not line:
                continue
            tokens = line.split()
            if len(tokens) != expected_per_row:
                raise ValueError("{}:{}: expected {} tokens, got {}".format(path, line_no, expected_per_row, len(tokens)))
            rows.append([0 if set(tok.lower()) == {"x"} else int(tok, 16) for tok in tokens])
    return rows


def pack_tokens(tokens, token_bits):
    if token_bits == 16:
        if len(tokens) != 8:
            raise ValueError("16-bit packing expects 8 tokens")
        lo_count = 4
    elif token_bits == 8:
        if len(tokens) != 16:
            raise ValueError("8-bit packing expects 16 tokens")
        lo_count = 8
    else:
        raise ValueError("unsupported token width: {}".format(token_bits))

    lo = 0
    hi = 0
    mask = (1 << token_bits) - 1
    for idx, token in enumerate(tokens):
        value = token & mask
        if idx < lo_count:
            lo |= value << (idx * token_bits)
        else:
            hi |= value << ((idx - lo_count) * token_bits)
    return lo, hi


def empty_bank_rows(row_count):
    return [[(0, 0) for _ in range(BANK_COUNT)] for _ in range(row_count)]


def load_posit_inputs(workspace, kind):
    per_bank = []
    for bank in range(BANK_COUNT):
        lane = bank // 2
        half = bank % 2
        path = workspace / "test_data" / "posit_data" / "{}_modified_{}_{}.txt".format(kind, lane, half)
        rows = parse_hex_tokens(path, 8)
        per_bank.append([pack_tokens(row, 16) for row in rows])
    row_count = max(len(rows) for rows in per_bank)
    bank_rows = empty_bank_rows(row_count)
    for bank, rows in enumerate(per_bank):
        for row_idx, value in enumerate(rows):
            bank_rows[row_idx][bank] = value
    return bank_rows


def load_int_inputs(workspace, kind):
    per_bank = [[] for _ in range(BANK_COUNT)]
    for idx, bank in enumerate([1, 3, 5, 7]):
        path = workspace / "test_data" / "int_data" / "{}_modified_{:02d}.hex".format(kind, idx)
        rows = parse_hex_tokens(path, 16)
        per_bank[bank] = [pack_tokens(row, 8) for row in rows]
    row_count = max([len(rows) for rows in per_bank] + [0])
    bank_rows = empty_bank_rows(row_count)
    for bank, rows in enumerate(per_bank):
        for row_idx, value in enumerate(rows):
            bank_rows[row_idx][bank] = value
    return bank_rows


def golden_filename(mode, bank):
    lane = bank // 2
    half = bank % 2
    if mode in {"posit_ff", "posit_bp"}:
        return "mxu_out_lane{}_modified_{}_{}.txt".format(lane, lane, half)
    if mode == "int_ff":
        return "mxu_out_lane{}_{}_{}.txt".format(lane, lane, half)
    raise ValueError("unsupported mode: {}".format(mode))


def load_golden(workspace, mode):
    per_bank = []
    golden_dir = workspace / "gloden_result" / mode
    for bank in range(BANK_COUNT):
        path = golden_dir / golden_filename(mode, bank)
        rows = parse_hex_tokens(path, 8)
        per_bank.append([pack_tokens(row, 16) for row in rows])
    row_count = max(len(rows) for rows in per_bank)
    bank_rows = empty_bank_rows(row_count)
    for bank, rows in enumerate(per_bank):
        for row_idx, value in enumerate(rows):
            bank_rows[row_idx][bank] = value
    return bank_rows


def format_u64(value):
    return "0x{:016x}ull".format(value & ((1 << 64) - 1))


def format_array(name, data):
    row_count = len(data)
    lines = ["static const uint64_t {}[{}][MXU_INPUT_BANK_COUNT][2] = {{".format(name, row_count)]
    for row in data:
        lines.append("    {")
        for lo, hi in row:
            lines.append("        {{{}, {}}},".format(format_u64(lo), format_u64(hi)))
        lines.append("    },")
    lines.append("};")
    return "\n".join(lines)


def mode_config(mode):
    if mode == "int_ff":
        return 0, 1
    if mode == "posit_ff":
        return 0, 0
    if mode == "posit_bp":
        return 1, 0
    raise ValueError("unsupported mode: {}".format(mode))


def build_header(mode, wgt_data, act_data, golden_data):
    flow_mode, data_type = mode_config(mode)
    effective_golden_data = golden_data[:ACT_BATCHSIZE]
    return "\n".join([
        "#ifndef MXU_INPUT_DATA_H",
        "#define MXU_INPUT_DATA_H",
        "",
        "#include <stdint.h>",
        "",
        "#define MXU_TEST_MODE_NAME \"{}\"".format(mode),
        "#define MXU_INPUT_BANK_COUNT 8u",
        "#define MXU_WGT_ROW_START 0u",
        "#define MXU_WGT_ROW_COUNT {}u".format(len(wgt_data)),
        "#define MXU_ACT_ROW_START 0u",
        "#define MXU_ACT_ROW_COUNT {}u".format(len(act_data)),
        "#define MXU_OUT_ROW_START 0u",
        "#define MXU_OUT_ROW_COUNT {}u".format(ACT_BATCHSIZE),
        "#define MXU_CFG_ACT_BATCHSIZE_VALUE {}u".format(ACT_BATCHSIZE),
        "#define MXU_CFG_DATA_FLOW_MODE_VALUE {}u".format(flow_mode),
        "#define MXU_CFG_DATA_TYPE_MODE_VALUE {}u".format(data_type),
        "",
        "static const uint64_t MXU_CFG_WGT_TILE_BASE_VALUES[4] = {0u, 4u, 8u, 12u};",
        "static const uint64_t MXU_CFG_ACT_TILE_BASE_VALUES[4] = {0u, 8u, 16u, 24u};",
        "static const uint64_t MXU_CFG_OUT_TILE_BASE_VALUES[4] = {0u, 8u, 16u, 24u};",
        "",
        format_array("MXU_WGT_DATA", wgt_data),
        "",
        format_array("MXU_ACT_DATA", act_data),
        "",
        format_array("MXU_GOLDEN_DATA", effective_golden_data),
        "",
        "#endif",
        "",
    ])


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--mode", required=True, choices=["int_ff", "posit_ff", "posit_bp"])
    parser.add_argument("--workspace", required=True, type=Path)
    parser.add_argument("--out", required=True, type=Path)
    args = parser.parse_args()

    workspace = args.workspace.resolve()
    if args.mode == "int_ff":
        wgt_data = load_int_inputs(workspace, "wgt")
        act_data = load_int_inputs(workspace, "act")
    else:
        wgt_data = load_posit_inputs(workspace, "wgt")
        act_data = load_posit_inputs(workspace, "act")
    golden_data = load_golden(workspace, args.mode)

    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(build_header(args.mode, wgt_data, act_data, golden_data), encoding="utf-8")
    print("generated {} for mode={}".format(args.out, args.mode))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
