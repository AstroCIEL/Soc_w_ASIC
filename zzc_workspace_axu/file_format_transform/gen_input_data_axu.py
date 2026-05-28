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

# Test case configurations: defines which rows each test case needs
CASE_CONFIGS = {
    "vpu_add": {
        "opa_rows": list(range(0, 10)),
        "opb_rows": list(range(0, 10)),
        "golden_rows": list(range(0, 10)),
    },
    "vpu_sub": {
        "opa_rows": list(range(10, 20)),
        "opb_rows": list(range(10, 20)),
        "golden_rows": list(range(10, 20)),
    },
    "vpu_mul": {
        "opa_rows": list(range(20, 30)),
        "opb_rows": list(range(20, 30)),
        "golden_rows": list(range(20, 30)),
    },
    "vpu_max": {
        "opa_rows": list(range(30, 40)),
        "opb_rows": list(range(30, 40)),
        "golden_rows": list(range(30, 40)),
    },
    "vpu_min": {
        "opa_rows": list(range(40, 50)),
        "opb_rows": list(range(40, 50)),
        "golden_rows": list(range(40, 50)),
    },
    "vpu_reduce_max": {
        "opa_rows": list(range(50, 60)),
        "opb_rows": list(range(50, 60)),
        "golden_rows": list(range(50, 60)),
    },
    "vpu_reduce_sum": {
        "opa_rows": list(range(60, 70)),
        "opb_rows": list(range(60, 70)),
        "golden_rows": list(range(60, 70)),
    },
    "sfu_int2posit": {
        "opa_rows": list(range(80, 90)),
        "opb_rows": list(range(80, 90)),
        "golden_rows": list(range(80, 90)),
    },
    "sfu_rng": {
        "opa_rows": [48, 49],  # seed high/low, lanes 0..15
        "opb_rows": [48, 49],  # seed high/low, lanes 16..31
        "golden_rows": list(range(90, 100)),
    },
    "nli_mish": {
        "opa_rows": list(range(90, 128)),  # full LUT rows 90..95 + compute rows 96..127
        "opb_rows": [50],
        "golden_rows": list(range(100, 132)),
    },
    "nli_tanh": {
        "opa_rows": list(range(128, 166)),  # full LUT rows 128..133 + compute rows 134..165
        "opb_rows": [51],
        "golden_rows": list(range(132, 164)),
    },
    "scheduler": {
        "opa_rows": list(range(166, 182)),  # scheduler input rows 166..181
        "opb_rows": [],
        "golden_rows": list(range(164, 193)),  # scheduler output rows 164..192
    },
}


def validate_case_config(case_name: str) -> None:
    """Validate case-specific row requirements that are easy to under-specify."""
    cfg = CASE_CONFIGS[case_name]

    if case_name == "sfu_rng":
        if cfg["opa_rows"] != [48, 49] or cfg["opb_rows"] != [48, 49]:
            raise ValueError("sfu_rng requires seed rows 48/49 in both OP_A and OP_B")

    if case_name == "scheduler":
        if cfg["opa_rows"] != list(range(166, 182)):
            raise ValueError("scheduler requires OP_A rows 166..181")

    if case_name == "nli_mish":
        if cfg["opa_rows"] != list(range(90, 128)):
            raise ValueError(
                "nli_mish requires OP_A rows 90..127, including full LUT rows 90..95 and compute rows 96..127")

    if case_name == "nli_tanh":
        if cfg["opa_rows"] != list(range(128, 166)):
            raise ValueError(
                "nli_tanh requires OP_A rows 128..165, including full LUT rows 128..133 and compute rows 134..165")


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


def load_single_case(case_name: str,
                     data_dir: Path,
                     golden_dir: Path) -> Tuple[List[List[PackedWord]], 
                                                  List[List[PackedWord]], 
                                                  List[List[PackedWord]]]:
    """Load data for a single test case, extracting only the required rows.
    
    Note: Returns sparse arrays to preserve row indices used in main.c CASES array.
    DEPRECATED: Use load_single_case_compact() instead.
    """
    if case_name not in CASE_CONFIGS:
        raise ValueError("Unknown test case: {}. Available: {}".format(
            case_name, ", ".join(CASE_CONFIGS.keys())))
    
    config = CASE_CONFIGS[case_name]
    
    # Load full data files
    a_path = data_dir / "axu_all_in_one_a.txt"
    b_path = data_dir / "axu_all_in_one_b.txt"
    g_path = golden_dir / "axu_all_in_one_out_reference.txt"
    
    a_sections = parse_blank_sections(a_path)
    b_sections = parse_blank_sections(b_path)
    g_sections = parse_comment_sections(g_path)
    
    # Build full 256-row arrays
    zero_row = [pack_bank_tokens([0] * TOKENS_PER_BANK) for _ in range(BANK_COUNT)]
    full_op_a: List[List[PackedWord]] = [list(zero_row) for _ in range(TOTAL_ROWS)]
    full_op_b: List[List[PackedWord]] = [list(zero_row) for _ in range(TOTAL_ROWS)]
    full_golden: List[List[PackedWord]] = [list(zero_row) for _ in range(TOTAL_ROWS)]
    
    # Fill OP_A
    cur = 0
    for sec in a_sections:
        for r in sec:
            if cur >= TOTAL_ROWS:
                break
            full_op_a[cur] = pack_row(r)
            cur += 1
    
    # Fill OP_B
    cur = 0
    for sec in b_sections:
        for r in sec:
            if cur >= TOTAL_ROWS:
                break
            full_op_b[cur] = pack_row(r)
            cur += 1
    
    # Fill GOLDEN using layout
    GOLDEN_LAYOUT = [
        (0, 10), (10, 10), (20, 10), (30, 10), (40, 10), (50, 10), (60, 10),
        (70, 10), (80, 10), (90, 10), (100, 32), (132, 32), (164, 29),
    ]
    for sec_idx, (row_start, length) in enumerate(GOLDEN_LAYOUT):
        if sec_idx >= len(g_sections):
            break
        sec = g_sections[sec_idx]
        for i in range(min(length, len(sec))):
            full_golden[row_start + i] = pack_row(sec[i])
    
    # Extract only the rows needed for this test case
    opa_rows = config["opa_rows"]
    opb_rows = config["opb_rows"]
    golden_rows = config["golden_rows"]
    
    # Find the maximum row index to determine array size (preserve sparse structure)
    max_row = max(
        max(opa_rows) if opa_rows else 0,
        max(opb_rows) if opb_rows else 0,
        max(golden_rows) if golden_rows else 0
    ) + 1
    
    # Create sparse arrays (with zeros for unused rows)
    compact_op_a: List[List[PackedWord]] = [list(zero_row) for _ in range(max_row)]
    compact_op_b: List[List[PackedWord]] = [list(zero_row) for _ in range(max_row)]
    compact_golden: List[List[PackedWord]] = [list(zero_row) for _ in range(max_row)]
    
    # Copy required rows (preserving their original indices)
    for row in opa_rows:
        if row < len(full_op_a) and row < max_row:
            compact_op_a[row] = full_op_a[row]
    
    for row in opb_rows:
        if row < len(full_op_b) and row < max_row:
            compact_op_b[row] = full_op_b[row]
    
    for row in golden_rows:
        if row < len(full_golden) and row < max_row:
            compact_golden[row] = full_golden[row]
    
    return compact_op_a, compact_op_b, compact_golden


def load_single_case_compact(case_name: str,
                             data_dir: Path,
                             golden_dir: Path) -> Tuple[List[List[PackedWord]], 
                                                          List[List[PackedWord]], 
                                                          List[List[PackedWord]],
                                                          dict, dict, dict]:
    """Load data for a single test case, generating compact arrays.
    
    Returns:
        (compact_op_a, compact_op_b, compact_golden, opa_map, opb_map, golden_map)
        where *_map is {original_row: compact_index}
    """
    if case_name not in CASE_CONFIGS:
        raise ValueError("Unknown test case: {}. Available: {}".format(
            case_name, ", ".join(CASE_CONFIGS.keys())))
    
    config = CASE_CONFIGS[case_name]
    
    # Load full 256-row data
    a_path = data_dir / "axu_all_in_one_a.txt"
    b_path = data_dir / "axu_all_in_one_b.txt"
    g_path = golden_dir / "axu_all_in_one_out_reference.txt"
    
    a_sections = parse_blank_sections(a_path)
    b_sections = parse_blank_sections(b_path)
    g_sections = parse_comment_sections(g_path)
    
    # Build full arrays
    zero_row = [pack_bank_tokens([0] * TOKENS_PER_BANK) for _ in range(BANK_COUNT)]
    full_op_a: List[List[PackedWord]] = [list(zero_row) for _ in range(TOTAL_ROWS)]
    full_op_b: List[List[PackedWord]] = [list(zero_row) for _ in range(TOTAL_ROWS)]
    full_golden: List[List[PackedWord]] = [list(zero_row) for _ in range(TOTAL_ROWS)]
    
    # Fill OP_A
    cur = 0
    for sec in a_sections:
        for r in sec:
            if cur >= TOTAL_ROWS:
                break
            full_op_a[cur] = pack_row(r)
            cur += 1
    
    # Fill OP_B
    cur = 0
    for sec in b_sections:
        for r in sec:
            if cur >= TOTAL_ROWS:
                break
            full_op_b[cur] = pack_row(r)
            cur += 1
    
    # Fill GOLDEN
    GOLDEN_LAYOUT = [
        (0, 10), (10, 10), (20, 10), (30, 10), (40, 10), (50, 10), (60, 10),
        (70, 10), (80, 10), (90, 10), (100, 32), (132, 32), (164, 29),
    ]
    for sec_idx, (row_start, length) in enumerate(GOLDEN_LAYOUT):
        if sec_idx >= len(g_sections):
            break
        sec = g_sections[sec_idx]
        for i in range(min(length, len(sec))):
            full_golden[row_start + i] = pack_row(sec[i])
    
    # Extract only needed rows and create compact arrays
    opa_rows = sorted(config["opa_rows"])
    opb_rows = sorted(config["opb_rows"])
    golden_rows = sorted(config["golden_rows"])
    
    # Build compact arrays (only valid data, no zeros)
    compact_op_a = [full_op_a[r] for r in opa_rows] if opa_rows else [list(zero_row)]
    compact_op_b = [full_op_b[r] for r in opb_rows] if opb_rows else [list(zero_row)]
    compact_golden = [full_golden[r] for r in golden_rows] if golden_rows else [list(zero_row)]
    
    # Create index mappings: original_row -> compact_index
    opa_map = {old: new for new, old in enumerate(opa_rows)} if opa_rows else {}
    opb_map = {old: new for new, old in enumerate(opb_rows)} if opb_rows else {}
    golden_map = {old: new for new, old in enumerate(golden_rows)} if golden_rows else {}
    
    return compact_op_a, compact_op_b, compact_golden, opa_map, opb_map, golden_map


def build_header_all(op_a: List[List[PackedWord]],
                     op_b: List[List[PackedWord]],
                     golden: List[List[PackedWord]],
                     case_name: str = "all_in_one",
                     total_rows: int = None) -> str:
    if total_rows is None:
        total_rows = TOTAL_ROWS
    
    return "\n".join([
        "#ifndef AXU_INPUT_DATA_H",
        "#define AXU_INPUT_DATA_H",
        "",
        "#include <stdint.h>",
        "#include \"my_axu.h\"",
        "",
        "#define AXU_TEST_MODE_NAME    \"{}\"".format(case_name),
        "#define AXU_INPUT_BANK_COUNT  8u",
        "#define AXU_TOTAL_ROW_COUNT   {}u".format(total_rows),
        "",
        format_array_fixed_size("AXU_OP_A_DATA", total_rows, op_a),
        "",
        format_array_fixed_size("AXU_OP_B_DATA", total_rows, op_b),
        "",
        format_array_fixed_size("AXU_GOLDEN_DATA", total_rows, golden),
        "",
        "#endif",
        "",
    ])


def build_header_compact(case_name: str,
                        op_a: List[List[PackedWord]],
                        op_b: List[List[PackedWord]],
                        golden: List[List[PackedWord]],
                        opa_map: dict,
                        opb_map: dict,
                        golden_map: dict) -> str:
    """Build header with compact arrays and index mapping macros."""
    
    lines = [
        "#ifndef AXU_INPUT_DATA_H",
        "#define AXU_INPUT_DATA_H",
        "",
        "#include <stdint.h>",
        "#include \"my_axu.h\"",
        "",
        "#define AXU_TEST_MODE_NAME    \"{}\"".format(case_name),
        "#define AXU_INPUT_BANK_COUNT  8u",
        "",
        "/* Compact array sizes (only valid data rows) */",
        "#define AXU_TOTAL_ROW_COUNT_OPA    {}u".format(len(op_a)),
        "#define AXU_TOTAL_ROW_COUNT_OPB    {}u".format(len(op_b)),
        "#define AXU_TOTAL_ROW_COUNT_GOLDEN {}u".format(len(golden)),
        "",
        "/* Index mapping macros: original row -> compact index */",
    ]
    
    # Generate mapping macros for OP_A
    if opa_map:
        for old_row, new_idx in sorted(opa_map.items()):
            lines.append("#define AXU_MAP_OPA_{}  {}u".format(old_row, new_idx))
    
    # Generate mapping macros for OP_B
    if opb_map:
        for old_row, new_idx in sorted(opb_map.items()):
            lines.append("#define AXU_MAP_OPB_{}  {}u".format(old_row, new_idx))
    
    # Generate mapping macros for GOLDEN
    if golden_map:
        for old_row, new_idx in sorted(golden_map.items()):
            lines.append("#define AXU_MAP_GOLDEN_{}  {}u".format(old_row, new_idx))
    
    lines.extend([
        "",
        "/* Compact data arrays */",
        format_array_fixed_size("AXU_OP_A_DATA", len(op_a), op_a),
        "",
        format_array_fixed_size("AXU_OP_B_DATA", len(op_b), op_b),
        "",
        format_array_fixed_size("AXU_GOLDEN_DATA", len(golden), golden),
        "",
        "#endif",
        "",
    ])
    
    return "\n".join(lines)


# -------------------- main --------------------

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--mode", required=True, choices=["vpu_add", "all"])
    parser.add_argument("--case", required=False, default=None,
                        help="specific test case name (e.g., vpu_add, sfu_rng, nli_mish)")
    parser.add_argument("--data-dir", required=True, type=Path,
                        help="directory containing axu_all_in_one_{a,b}.txt")
    parser.add_argument("--golden-dir", required=True, type=Path,
                        help="directory containing axu_all_in_one_out_reference.txt")
    parser.add_argument("--out", required=True, type=Path,
                        help="output input_data.h path")
    args = parser.parse_args()

    data_dir = args.data_dir.resolve()
    golden_dir = args.golden_dir.resolve()

    # Handle single test case with compact arrays
    if args.case and args.case != "all":
        validate_case_config(args.case)
        op_a, op_b, golden, opa_map, opb_map, golden_map = \
            load_single_case_compact(args.case, data_dir, golden_dir)
        header = build_header_compact(args.case, op_a, op_b, golden,
                                      opa_map, opb_map, golden_map)
        args.out.parent.mkdir(parents=True, exist_ok=True)
        args.out.write_text(header, encoding="utf-8")
        print("generated {} for case={} (compact: {}/{}/{} rows)".format(
            args.out, args.case, len(op_a), len(op_b), len(golden)))
        return 0

    # Legacy modes (deprecated, but kept for reference)
    if args.mode == "vpu_add":
        op_a, op_b, golden = load_vpu_add(data_dir, golden_dir, row_count=10)
        header = build_header_vpu_add(op_a, op_b, golden)
    elif args.mode == "all":
        raise ValueError("mode=all is deprecated, use --case=<test_name> instead")
    else:
        raise ValueError("unsupported mode: {}".format(args.mode))

    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(header, encoding="utf-8")
    print("generated {} for mode={}".format(args.out, args.mode))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
