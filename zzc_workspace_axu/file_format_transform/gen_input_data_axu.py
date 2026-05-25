#!/usr/bin/env python3
"""Generate input_data.h for my_axu_test.

Modes:
  vpu_add  - legacy single-case header (VPU element-wise add, 10 rows).
  all      - all-in-one header: 256-row OP_A / OP_B / GOLDEN packed arrays
             that cover every sub-test executed by axu_top_tb.sv
             (VPU elementwise add/sub/mul/max/min, VPU reduce max/sum,
              SFU sin/cos / int2posit / RNG, NLI MISH / TANH, scheduler).

Input files (under --data-dir / --golden-dir):
  axu_all_in_one_a.txt          : op_a posit data, 64 hex tokens per row.
                                  Sections separated by blank lines.
  axu_all_in_one_b.txt          : op_b posit data, same layout as above.
  axu_all_in_one_out_reference.txt
                                : reference output. Comment lines start with
                                  '//' and act as section delimiters.

Hardware layout (from axu_top.sv loader):
  row_data[token_idx * 16 +: 16] = token
  -> file token i (0..63) goes to bank = i / 8, slot-in-bank = i % 8
     slot 0..3 -> low 64 bit (half64=0); slot 4..7 -> high 64 bit (half64=1)
"""

import argparse
from pathlib import Path
from typing import List, Tuple

TOKENS_PER_ROW   = 64
BANK_COUNT       = 8
TOKENS_PER_BANK  = TOKENS_PER_ROW // BANK_COUNT  # 8
TOTAL_ROWS       = 256

PackedWord = Tuple[int, int]  # (lo, hi) two 64-bit words per (row, bank)


def parse_blank_sections(path: Path) -> List[List[List[int]]]:
    """Parse a data file into sections separated by blank lines only.

    Comment lines (starting with '//') are dropped but do NOT act as
    section separators. Returns list of sections; each section is a list
    of rows; each row is a list of 64 hex tokens.
    """
    sections: List[List[List[int]]] = []
    current: List[List[int]] = []
    with path.open("r", encoding="utf-8") as f:
        for line_no, raw in enumerate(f, start=1):
            line = raw.strip()
            if not line:
                if current:
                    sections.append(current)
                    current = []
                continue
            if line.startswith("//"):
                continue
            tokens = line.split()
            if len(tokens) != TOKENS_PER_ROW:
                raise ValueError(
                    "{}:{}: expected {} tokens, got {}".format(
                        path, line_no, TOKENS_PER_ROW, len(tokens)))
            row = [0 if set(tok.lower()) == {"x"} else int(tok, 16) for tok in tokens]
            current.append(row)
    if current:
        sections.append(current)
    return sections


def parse_comment_sections(path: Path) -> List[List[List[int]]]:
    """Parse a data file using BOTH blank lines and '//' comment lines as
    section separators. Used for the golden reference file."""
    sections: List[List[List[int]]] = []
    current: List[List[int]] = []
    with path.open("r", encoding="utf-8") as f:
        for line_no, raw in enumerate(f, start=1):
            line = raw.strip()
            if not line:
                if current:
                    sections.append(current)
                    current = []
                continue
            if line.startswith("//"):
                if current:
                    sections.append(current)
                    current = []
                continue
            tokens = line.split()
            if len(tokens) != TOKENS_PER_ROW:
                raise ValueError(
                    "{}:{}: expected {} tokens, got {}".format(
                        path, line_no, TOKENS_PER_ROW, len(tokens)))
            row = [0 if set(tok.lower()) == {"x"} else int(tok, 16) for tok in tokens]
            current.append(row)
    if current:
        sections.append(current)
    return sections


def pack_bank_tokens(tokens: List[int]) -> PackedWord:
    if len(tokens) != TOKENS_PER_BANK:
        raise ValueError("bank packing expects {} tokens".format(TOKENS_PER_BANK))
    lo = 0
    hi = 0
    mask = (1 << 16) - 1
    for idx, tok in enumerate(tokens):
        value = tok & mask
        if idx < 4:
            lo |= value << (idx * 16)
        else:
            hi |= value << ((idx - 4) * 16)
    return lo, hi


def pack_row(row: List[int]) -> List[PackedWord]:
    if len(row) != TOKENS_PER_ROW:
        raise ValueError("row must contain {} tokens".format(TOKENS_PER_ROW))
    return [
        pack_bank_tokens(row[bank * TOKENS_PER_BANK : (bank + 1) * TOKENS_PER_BANK])
        for bank in range(BANK_COUNT)
    ]


def pack_rows(rows: List[List[int]]) -> List[List[PackedWord]]:
    return [pack_row(row) for row in rows]


def format_u64(value: int) -> str:
    return "0x{:016x}ull".format(value & ((1 << 64) - 1))


def format_array_fixed_size(name: str,
                            rows: int,
                            packed: List[List[PackedWord]]) -> str:
    """Emit a fixed-size [rows][BANK_COUNT][2] array, padding with zeros."""
    lines = ["static const uint64_t {}[{}][AXU_INPUT_BANK_COUNT][2] = {{".format(
        name, rows)]
    zero_pair = (0, 0)
    for r in range(rows):
        row_data = packed[r] if r < len(packed) else [zero_pair] * BANK_COUNT
        lines.append("    /* row {} */ {{".format(r))
        for lo, hi in row_data:
            lines.append("        {{{}, {}}},".format(format_u64(lo), format_u64(hi)))
        lines.append("    },")
    lines.append("};")
    return "\n".join(lines)


# -------------------- legacy vpu_add mode --------------------

def format_array(name: str, packed: List[List[PackedWord]]) -> str:
    lines = ["static const uint64_t {}[{}][AXU_INPUT_BANK_COUNT][2] = {{".format(
        name, len(packed))]
    for row in packed:
        lines.append("    {")
        for lo, hi in row:
            lines.append("        {{{}, {}}},".format(format_u64(lo), format_u64(hi)))
        lines.append("    },")
    lines.append("};")
    return "\n".join(lines)


def build_header_vpu_add(op_a_packed: List[List[PackedWord]],
                         op_b_packed: List[List[PackedWord]],
                         golden_packed: List[List[PackedWord]]) -> str:
    row_count = len(op_a_packed)
    return "\n".join([
        "#ifndef AXU_INPUT_DATA_H",
        "#define AXU_INPUT_DATA_H",
        "",
        "#include <stdint.h>",
        "#include \"my_axu.h\"",
        "",
        "#define AXU_TEST_MODE_NAME    \"vpu_add\"",
        "#define AXU_INPUT_BANK_COUNT  8u",
        "#define AXU_OP_A_ROW_START    0u",
        "#define AXU_OP_A_ROW_COUNT    {}u".format(row_count),
        "#define AXU_OP_B_ROW_START    0u",
        "#define AXU_OP_B_ROW_COUNT    {}u".format(row_count),
        "#define AXU_OUT_ROW_START     0u",
        "#define AXU_OUT_ROW_COUNT     {}u".format(row_count),
        "#define AXU_BATCH_SIZE_VALUE  {}u".format(row_count),
        "#define AXU_UNIT_SEL_VALUE    AXU_UNIT_VPU",
        "#define AXU_FUNC_SEL_VALUE    AXU_VPU_ADD",
        "",
        format_array("AXU_OP_A_DATA", op_a_packed),
        "",
        format_array("AXU_OP_B_DATA", op_b_packed),
        "",
        format_array("AXU_GOLDEN_DATA", golden_packed),
        "",
        "#endif",
        "",
    ])


def load_vpu_add(data_dir: Path, golden_dir: Path,
                 row_count: int = 10) -> Tuple[List[List[PackedWord]],
                                               List[List[PackedWord]],
                                               List[List[PackedWord]]]:
    a_sections = parse_blank_sections(data_dir / "axu_all_in_one_a.txt")
    b_sections = parse_blank_sections(data_dir / "axu_all_in_one_b.txt")
    g_sections = parse_comment_sections(
        golden_dir / "axu_all_in_one_out_reference.txt")

    if not a_sections or not b_sections or not g_sections:
        raise ValueError("input files do not contain any data sections")

    a_rows = a_sections[0][:row_count]
    b_rows = b_sections[0][:row_count]
    g_rows = g_sections[0][:row_count]

    for name, rows in (("op_a", a_rows), ("op_b", b_rows), ("golden", g_rows)):
        if len(rows) != row_count:
            raise ValueError(
                "{} section has {} rows, expected {}".format(name, len(rows), row_count))

    return pack_rows(a_rows), pack_rows(b_rows), pack_rows(g_rows)


# -------------------- all-in-one mode --------------------

# Mapping from reference-file section index to (start_row, length) in the
# 256-row output address space. Indices follow the order in
# axu_all_in_one_out_reference.txt:
#   0: VPU add        -> rows 0..9
#   1: VPU sub        -> rows 10..19
#   2: VPU mul        -> rows 20..29
#   3: VPU max        -> rows 30..39
#   4: VPU min        -> rows 40..49
#   5: VPU reduce_max -> rows 50..59 (bank0 token0 only)
#   6: VPU reduce_sum -> rows 60..69 (bank0 token0 only)
#   7: SFU sin/cos    -> rows 70..79
#   8: SFU int2posit  -> rows 80..89 (first 32 lanes valid)
#   9: SFU rng        -> rows 90..99
#  10: NLI MISH       -> rows 100..131 (first 32 lanes valid)
#  11: NLI TANH       -> rows 132..163 (first 32 lanes valid)
#  12: scheduler      -> rows 164..192 (bank0 first 4 tokens only)
GOLDEN_LAYOUT = [
    (0,   10),
    (10,  10),
    (20,  10),
    (30,  10),
    (40,  10),
    (50,  10),
    (60,  10),
    (70,  10),
    (80,  10),
    (90,  10),
    (100, 32),
    (132, 32),
    (164, 29),
]


def load_all_in_one(data_dir: Path,
                    golden_dir: Path) -> Tuple[List[List[PackedWord]],
                                               List[List[PackedWord]],
                                               List[List[PackedWord]]]:
    """Build 256-row packed OP_A / OP_B / GOLDEN arrays.

    OP_A: sections of axu_all_in_one_a.txt are concatenated linearly
          starting at row 0, matching the base addresses programmed by
          axu_top_tb.sv:
            sec  0..5  -> rows 0..59   (VPU add/sub/mul/max/min/reduce_max op_a)
            sec  6     -> rows 60..69  (reduce_sum op_a)
            sec  7     -> rows 70..79  (CORDIC op_a)
            sec  8     -> rows 80..89  (ITP op_a)
            sec  9     -> rows 90..95  (MISH mul_lut@90, ybnd_lut@91, ...)
            sec 10     -> rows 96..127 (MISH input)
            sec 11     -> rows 128..133 (TANH mul_lut@128, ybnd_lut@129, ...)
            sec 12     -> rows 134..165 (TANH input)
            sec 13     -> rows 166..181 (scheduler input)
    OP_B: sections of axu_all_in_one_b.txt likewise concatenated starting
          at row 0; only the first ~52 rows have meaningful data, the rest
          stay zero.
    GOLDEN: each reference section is placed at the address declared by
            the test bench (see GOLDEN_LAYOUT above).
    """
    a_sections = parse_blank_sections(data_dir / "axu_all_in_one_a.txt")
    b_sections = parse_blank_sections(data_dir / "axu_all_in_one_b.txt")
    g_sections = parse_comment_sections(
        golden_dir / "axu_all_in_one_out_reference.txt")

    zero_pair: PackedWord = (0, 0)
    zero_row: List[PackedWord] = [zero_pair] * BANK_COUNT

    op_a: List[List[PackedWord]] = [list(zero_row) for _ in range(TOTAL_ROWS)]
    op_b: List[List[PackedWord]] = [list(zero_row) for _ in range(TOTAL_ROWS)]
    golden: List[List[PackedWord]] = [list(zero_row) for _ in range(TOTAL_ROWS)]

    # OP_A: linear concatenation
    cur = 0
    for sec_idx, sec in enumerate(a_sections):
        for r in sec:
            if cur >= TOTAL_ROWS:
                raise ValueError(
                    "axu_all_in_one_a.txt overflows 256 rows at section {}".format(sec_idx))
            op_a[cur] = pack_row(r)
            cur += 1

    # OP_B: linear concatenation
    cur = 0
    for sec_idx, sec in enumerate(b_sections):
        for r in sec:
            if cur >= TOTAL_ROWS:
                raise ValueError(
                    "axu_all_in_one_b.txt overflows 256 rows at section {}".format(sec_idx))
            op_b[cur] = pack_row(r)
            cur += 1

    # GOLDEN: placed by explicit (row_start, length) layout
    if len(g_sections) < len(GOLDEN_LAYOUT):
        raise ValueError(
            "reference file has {} sections, expected at least {}".format(
                len(g_sections), len(GOLDEN_LAYOUT)))
    for sec_idx, (row_start, length) in enumerate(GOLDEN_LAYOUT):
        sec = g_sections[sec_idx]
        if len(sec) < length:
            raise ValueError(
                "reference section {} has {} rows, expected {}".format(
                    sec_idx, len(sec), length))
        for i in range(length):
            golden[row_start + i] = pack_row(sec[i])

    return op_a, op_b, golden


def build_header_all(op_a: List[List[PackedWord]],
                     op_b: List[List[PackedWord]],
                     golden: List[List[PackedWord]]) -> str:
    return "\n".join([
        "#ifndef AXU_INPUT_DATA_H",
        "#define AXU_INPUT_DATA_H",
        "",
        "#include <stdint.h>",
        "#include \"my_axu.h\"",
        "",
        "#define AXU_TEST_MODE_NAME    \"all_in_one\"",
        "#define AXU_INPUT_BANK_COUNT  8u",
        "#define AXU_TOTAL_ROW_COUNT   {}u".format(TOTAL_ROWS),
        "",
        format_array_fixed_size("AXU_OP_A_DATA", TOTAL_ROWS, op_a),
        "",
        format_array_fixed_size("AXU_OP_B_DATA", TOTAL_ROWS, op_b),
        "",
        format_array_fixed_size("AXU_GOLDEN_DATA", TOTAL_ROWS, golden),
        "",
        "#endif",
        "",
    ])


# -------------------- main --------------------

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--mode", required=True, choices=["vpu_add", "all"])
    parser.add_argument("--data-dir", required=True, type=Path,
                        help="directory containing axu_all_in_one_{a,b}.txt")
    parser.add_argument("--golden-dir", required=True, type=Path,
                        help="directory containing axu_all_in_one_out_reference.txt")
    parser.add_argument("--out", required=True, type=Path,
                        help="output input_data.h path")
    args = parser.parse_args()

    data_dir = args.data_dir.resolve()
    golden_dir = args.golden_dir.resolve()

    if args.mode == "vpu_add":
        op_a, op_b, golden = load_vpu_add(data_dir, golden_dir, row_count=10)
        header = build_header_vpu_add(op_a, op_b, golden)
    elif args.mode == "all":
        op_a, op_b, golden = load_all_in_one(data_dir, golden_dir)
        header = build_header_all(op_a, op_b, golden)
    else:
        raise ValueError("unsupported mode: {}".format(args.mode))

    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(header, encoding="utf-8")
    print("generated {} for mode={}".format(args.out, args.mode))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
