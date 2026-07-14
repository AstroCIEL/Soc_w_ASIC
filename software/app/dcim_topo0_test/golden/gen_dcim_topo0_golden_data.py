#!/usr/bin/env python3
import argparse
import math
import sys
from pathlib import Path
from typing import List, Tuple

# Reuse core parsing/math helpers from existing dcim_test generator.
THIS_DIR = Path(__file__).resolve().parent
REUSE_DIR = THIS_DIR.parents[1] / "dcim_test" / "golden"
sys.path.insert(0, str(REUSE_DIR))

from gen_dcim_golden_data import (  # type: ignore
    Lcg32,
    accumulate_rows,
    matmul,
    transfer_act_lines,
    transfer_weight_lines,
    write_hex_words,
)


DCIM_MACRO_COUNT = 4


def _build_mode_c(type_name: str) -> Tuple[int, int, bool]:
    t = type_name.upper()
    mode_map = {
        "UINT4": 0,
        "UINT8": 2,
        "UINT16": 3,
        "INT4": 4,
        "INT8": 6,
        "INT16": 7,
    }
    if t not in mode_map:
        raise ValueError(f"Unsupported TYPE={type_name}")
    if t in {"INT4", "UINT4"}:
        c = 1
    elif t in {"INT8", "UINT8"}:
        c = 2
    else:
        c = 4
    signed = t.startswith("INT")
    return mode_map[t], c, signed


def _emit_header(
    path: Path,
    cfg_mode: int,
    topo: int,
    acc: int,
    act_rows: int,
    out_rows: int,
    wei_rows: int,
    wd3: int,
    c: int,
    all_act_words: List[List[int]],
    all_wei_words: List[List[int]],
    all_out_words: List[List[int]],
) -> None:
    with path.open("w", encoding="utf-8") as f:
        f.write("#ifndef DCIM_TOPO0_INPUT_DATA_H\n")
        f.write("#define DCIM_TOPO0_INPUT_DATA_H\n\n")
        f.write("#include <stdint.h>\n\n")
        f.write(f"#define DCIM_MACRO_COUNT {DCIM_MACRO_COUNT}u\n")
        f.write(f"#define DCIM_ACT_ROWS {act_rows}u\n")
        f.write(f"#define DCIM_OUT_ROWS {out_rows}u\n")
        f.write(f"#define DCIM_WEI_ROWS {wei_rows}u\n")
        f.write(f"#define DCIM_GOLDEN_ACC {acc}u\n\n")
        f.write(f"#define DCIM_GOLDEN_CFG_TOPO {topo}u\n")
        f.write(f"#define DCIM_GOLDEN_CFG_MODE {cfg_mode}u\n")
        f.write(f"#define DCIM_GOLDEN_CFG_ACC {acc}u\n")
        f.write(f"#define DCIM_GOLDEN_CFG_ACT_LEN {act_rows}u\n")
        f.write(f"#define DCIM_GOLDEN_CFG_OUT_LEN {out_rows}u\n")
        f.write("#define DCIM_GOLDEN_CFG_LOOP 0u\n\n")
        f.write(f"#define DCIM_GOLDEN_WD3 {wd3}u\n")
        f.write(f"#define DCIM_GOLDEN_C {c}u\n\n")
        f.write(f"#define DCIM_ACT_WORD_COUNT {len(all_act_words[0])}u\n")
        f.write(f"#define DCIM_WEI_WORD_COUNT {len(all_wei_words[0])}u\n")
        f.write(f"#define DCIM_OUT_WORD_COUNT {len(all_out_words[0])}u\n\n")

        def emit_2d(name: str, data: List[List[int]]) -> None:
            rows = len(data)
            cols = len(data[0]) if data else 0
            f.write(f"static const uint64_t {name}[{rows}][{cols}] = {{\n")
            for r in range(rows):
                f.write("    {")
                f.write(", ".join(f"0x{v & 0xFFFFFFFFFFFFFFFF:016x}ULL" for v in data[r]))
                f.write("}")
                f.write(",\n" if r + 1 != rows else "\n")
            f.write("};\n\n")

        emit_2d("DCIM_ACT_WORDS", all_act_words)
        emit_2d("DCIM_WEI_WORDS", all_wei_words)
        emit_2d("DCIM_OUT_GOLDEN_WORDS", all_out_words)
        f.write("#endif\n")


def _gen_one_macro(
    rng: Lcg32,
    *,
    act_rows: int,
    wei_rows: int,
    ch_in: int,
    ch_out: int,
    wd1: int,
    c: int,
    signed: bool,
    acc: int,
    act_row_order: str,
    bits_per_elem: int,
) -> Tuple[List[int], List[int], List[int]]:
    act_rows_u32 = [[rng.next_u32() for _ in range(8)] for _ in range(act_rows)]
    wei_rows_u32 = [[rng.next_u32() for _ in range(64)] for _ in range(wei_rows)]

    act_words: List[int] = []
    for row in act_rows_u32:
        for i in range(0, 8, 2):
            act_words.append((row[i] & 0xFFFFFFFF) | ((row[i + 1] & 0xFFFFFFFF) << 32))

    wei_words: List[int] = []
    for row in wei_rows_u32:
        for i in range(0, 64, 2):
            wei_words.append((row[i] & 0xFFFFFFFF) | ((row[i + 1] & 0xFFFFFFFF) << 32))

    wei_mem_lines: List[str] = []
    for ch_i in range(63, -1, -1):
        vals = []
        for ch_o in range(63, -1, -1):
            idx = (ch_o * 64 + ch_i) * 4
            idx1 = idx // 2048
            idx2 = (idx % 2048) // 32
            nib_shift = ((idx % 32) // 4) * 4
            word = wei_rows_u32[idx1][idx2]
            vals.append(f"{(word >> nib_shift) & 0xF:04b}")
        wei_mem_lines.append(" ".join(vals))

    act_mem_lines: List[str] = []
    for row in act_rows_u32:
        chunks = [f"{row[i] & 0xFFFFFFFF:032b}" for i in range(7, -1, -1)]
        act_mem_lines.append(" ".join(chunks))

    cols = ch_out // c
    weight_mat = transfer_weight_lines(
        wei_mem_lines, wd=wd1 * c, rows=ch_in, cols=cols, signed=signed
    )
    act_mat = transfer_act_lines(
        act_mem_lines, wd1=wd1, c=c, cols=ch_in, signed=signed
    )
    if act_row_order == "reverse":
        act_mat = list(reversed(act_mat))
    elif act_row_order == "last_first" and len(act_mat) > 1:
        act_mat = [act_mat[-1]] + act_mat[:-1]

    calculated = matmul(act_mat, weight_mat)
    calculated = accumulate_rows(calculated, acc)

    out_words: List[int] = []
    mask = (1 << bits_per_elem) - 1
    for row in calculated:
        row_vals = [int(v) & mask for v in row]
        bits = "".join(f"{v:0{bits_per_elem}b}" for v in row_vals)
        if len(bits) < 1024:
            bits = bits + ("0" * (1024 - len(bits)))
        elif len(bits) > 1024:
            raise ValueError(f"Output row bitwidth {len(bits)} exceeds 1024")
        # Match mmio read order: word0 reads int_rdata[63:0].
        for i in range(15, -1, -1):
            out_words.append(int(bits[i * 64:(i + 1) * 64], 2))

    return act_words, wei_words, out_words


def main() -> None:
    p = argparse.ArgumentParser(description="Generate topo0(2'b00) multi-macro DCIM golden vectors.")
    p.add_argument("--outdir", required=True)
    p.add_argument("--type", default="UINT4")
    p.add_argument("--acc", type=int, default=0)
    p.add_argument("--wd1", type=int, default=4)
    p.add_argument("--ch-in", type=int, default=64)
    p.add_argument("--ch-out", type=int, default=64)
    p.add_argument("--r", type=int, default=4)
    p.add_argument("--act-rows", type=int, default=4)
    p.add_argument("--wei-rows", type=int, default=8)
    p.add_argument(
        "--act-row-order",
        choices=["normal", "reverse", "last_first"],
        default="normal",
        help="ACT row order used by golden compute path",
    )
    p.add_argument("--seed", type=int, default=1)
    p.add_argument("--topo", type=int, default=0)
    args = p.parse_args()

    if args.topo != 0:
        raise ValueError("dcim_topo0_test requires --topo 0")
    if args.ch_in != 64 or args.ch_out != 64 or args.wd1 != 4:
        raise ValueError("Current script supports ch_in=64, ch_out=64, wd1=4")
    if args.r != 4:
        raise ValueError("Current path fixes R=4 for output width; please use --r 4")
    if args.wei_rows != 8:
        raise ValueError("Current load_wei path expects --wei-rows 8")
    if args.act_rows <= 0:
        raise ValueError("--act-rows must be > 0")
    if args.acc < 0 or args.acc > 4:
        raise ValueError("--acc must be in [0, 4]")

    cfg_mode, c, signed = _build_mode_c(args.type)
    if args.act_rows % c != 0:
        raise ValueError(
            f"--act-rows {args.act_rows} is incompatible with TYPE={args.type.upper()} (multiple of {c} required)"
        )

    wd2 = 2 * args.wd1 + int(math.log2(args.ch_in))
    wd3 = wd2 + int(math.log2(args.r))
    bits_per_elem = wd3 * c
    out_rows = (args.act_rows // c) if args.acc == 0 else (args.act_rows // c) // args.acc

    outdir = Path(args.outdir)
    outdir.mkdir(parents=True, exist_ok=True)

    rng = Lcg32(args.seed)
    all_act_words: List[List[int]] = []
    all_wei_words: List[List[int]] = []
    all_out_words: List[List[int]] = []

    for bank in range(DCIM_MACRO_COUNT):
        act_words, wei_words, out_words = _gen_one_macro(
            rng,
            act_rows=args.act_rows,
            wei_rows=args.wei_rows,
            ch_in=args.ch_in,
            ch_out=args.ch_out,
            wd1=args.wd1,
            c=c,
            signed=signed,
            acc=args.acc,
            act_row_order=args.act_row_order,
            bits_per_elem=bits_per_elem,
        )
        all_act_words.append(act_words)
        all_wei_words.append(wei_words)
        all_out_words.append(out_words)
        write_hex_words(outdir / f"act_bank{bank}.hex", act_words)
        write_hex_words(outdir / f"wei_bank{bank}.hex", wei_words)
        write_hex_words(outdir / f"out_bank{bank}.hex", out_words)

    _emit_header(
        outdir / "input_data.h",
        cfg_mode=cfg_mode,
        topo=args.topo,
        acc=args.acc,
        act_rows=args.act_rows,
        out_rows=out_rows,
        wei_rows=args.wei_rows,
        wd3=wd3,
        c=c,
        all_act_words=all_act_words,
        all_wei_words=all_wei_words,
        all_out_words=all_out_words,
    )

    print(f"Generated: {outdir / 'input_data.h'}")
    for bank in range(DCIM_MACRO_COUNT):
        print(f"Generated: {outdir / f'act_bank{bank}.hex'}")
        print(f"Generated: {outdir / f'wei_bank{bank}.hex'}")
        print(f"Generated: {outdir / f'out_bank{bank}.hex'}")


if __name__ == "__main__":
    main()
