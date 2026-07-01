#!/usr/bin/env python3
import argparse
import math
from pathlib import Path
from typing import List


def to_s4(v: int) -> int:
    v &= 0xF
    return v - 16 if v & 0x8 else v


def clip_s16(v: int) -> int:
    if v > 32767:
        return 32767
    if v < -32768:
        return -32768
    return v


class Lcg32:
    def __init__(self, seed: int):
        self.state = seed & 0xFFFFFFFF

    def next_u32(self) -> int:
        self.state = (self.state * 1664525 + 1013904223) & 0xFFFFFFFF
        return self.state


def _compact_bits(s: str) -> str:
    return "".join(s.split())


def _twos_complement_int(bits: str) -> int:
    width = len(bits)
    value = int(bits, 2)
    if bits[0] == "1":
        value -= (1 << width)
    return value


def _parse_row_bitstring(row_bits: str, wd: int, cols: int, signed: bool) -> List[int]:
    expected_len = wd * cols
    row_bits = _compact_bits(row_bits)
    if len(row_bits) != expected_len:
        raise ValueError(f"Row length {len(row_bits)} != expected {expected_len}({wd}x{cols})")
    elems: List[int] = []
    for i in range(cols):
        chunk = row_bits[i * wd:(i + 1) * wd]
        elems.append(_twos_complement_int(chunk) if signed else int(chunk, 2))
    return elems


def transfer_weight_lines(lines: List[str], wd: int, rows: int, cols: int, signed: bool) -> List[List[int]]:
    rows_norm = [_compact_bits(x) for x in lines if _compact_bits(x)]
    if rows == -1:
        num_rows = len(rows_norm)
    else:
        if len(rows_norm) < rows:
            raise ValueError(f"Line count {len(rows_norm)} < rows={rows}")
        rows_norm = rows_norm[:rows]
        num_rows = rows
    mat: List[List[int]] = [[0 for _ in range(cols)] for _ in range(num_rows)]
    for r in range(num_rows):
        mat[r] = _parse_row_bitstring(rows_norm[r], wd, cols, signed)
    return mat


def transfer_act_lines(lines: List[str], wd1: int, c: int, cols: int, signed: bool) -> List[List[int]]:
    lines_norm = [_compact_bits(x) for x in lines if _compact_bits(x)]
    groups = len(lines_norm) // c
    if groups == 0:
        raise ValueError(f"Not enough lines for one complete group of {c}")
    usable = lines_norm[:groups * c]
    expected_len = cols * wd1
    for idx, row_bits in enumerate(usable):
        if len(row_bits) != expected_len:
            raise ValueError(f"Line {idx} length {len(row_bits)} != expected {expected_len}")
    result = [[0] * cols for _ in range(groups)]
    for g in range(groups):
        group = usable[g * c:(g + 1) * c]
        for k in range(cols):
            chunks = [row[k * wd1:(k + 1) * wd1] for row in group]
            bits = "".join(chunks)
            result[g][k] = _twos_complement_int(bits) if signed else int(bits, 2)
    return result


def matmul(act_mat: List[List[int]], weight_mat: List[List[int]]) -> List[List[int]]:
    rows = len(act_mat)
    inner = len(weight_mat)
    cols = len(weight_mat[0]) if weight_mat else 0
    out: List[List[int]] = [[0 for _ in range(cols)] for _ in range(rows)]
    for r in range(rows):
        for c in range(cols):
            s = 0
            for k in range(inner):
                s += act_mat[r][k] * weight_mat[k][c]
            out[r][c] = s
    return out


def accumulate_rows(mat: List[List[int]], acc: int) -> List[List[int]]:
    if acc == 0:
        return mat
    groups = len(mat) // acc
    if groups == 0:
        return []
    cols = len(mat[0]) if mat else 0
    out: List[List[int]] = [[0 for _ in range(cols)] for _ in range(groups)]
    for g in range(groups):
        for c in range(cols):
            s = 0
            for r in range(g * acc, (g + 1) * acc):
                s += mat[r][c]
            out[g][c] = s
    return out


def decode_act_row_u32_to_s4(act_u32_row: List[int]) -> List[int]:
    vals = []
    for w in range(7, -1, -1):
        word = act_u32_row[w] & 0xFFFFFFFF
        for nib in range(7, -1, -1):
            vals.append(to_s4((word >> (nib * 4)) & 0xF))
    return vals


def decode_wei_words_to_s4_matrix(wei_words: List[List[int]]) -> List[List[int]]:
    # Inverse of save_cache mapping used by existing flow:
    # idx = (ch_out * 64 + ch_in) * 4
    # idx1 = idx / 2048   (row in wei_words, 0..7)
    # idx2 = (idx % 2048) / 32 (u32 word in row, 0..63)
    # nib = (idx % 32) / 4
    mat = [[0 for _ in range(64)] for _ in range(64)]  # [ch_in][ch_out]
    for ch_in in range(64):
        for ch_out in range(64):
            idx = (ch_out * 64 + ch_in) * 4
            idx1 = idx // 2048
            idx2 = (idx % 2048) // 32
            nib = ((idx % 32) // 4) & 0x7
            raw = (wei_words[idx1][idx2] >> (nib * 4)) & 0xF
            mat[ch_in][ch_out] = to_s4(raw)
    return mat


def pack_out_row_s16_to_u64_words(row_vals: List[int]) -> List[int]:
    # 64 x s16 -> 16 x u64 (little-endian 16-bit lanes per u64)
    words = []
    for i in range(16):
        base = i * 4
        w = 0
        for lane in range(4):
            v = row_vals[base + lane] & 0xFFFF
            w |= v << (lane * 16)
        words.append(w)
    return words


def write_hex_words(path: Path, words: List[int]) -> None:
    with path.open("w", encoding="utf-8") as f:
        for w in words:
            f.write(f"{w & 0xFFFFFFFFFFFFFFFF:016x}\n")


def emit_header(path: Path, topo: int, cfg_mode: int, loop: int, wd3: int, c: int,
                act_rows: int, out_rows: int, wei_rows: int,
                acc: int, act_words: List[int], wei_words_flat: List[int],
                out_words: List[int]) -> None:
    with path.open("w", encoding="utf-8") as f:
        f.write("#ifndef DCIM_INPUT_DATA_H\n")
        f.write("#define DCIM_INPUT_DATA_H\n\n")
        f.write("#include <stdint.h>\n\n")
        f.write(f"#define DCIM_ACT_ROWS {act_rows}u\n")
        f.write(f"#define DCIM_OUT_ROWS {out_rows}u\n")
        f.write(f"#define DCIM_WEI_ROWS {wei_rows}u\n")
        f.write(f"#define DCIM_GOLDEN_ACC {acc}u\n\n")
        f.write(f"#define DCIM_GOLDEN_CFG_TOPO {topo}u\n")
        f.write(f"#define DCIM_GOLDEN_CFG_MODE {cfg_mode}u\n")
        f.write(f"#define DCIM_GOLDEN_CFG_ACC {acc}u\n")
        f.write(f"#define DCIM_GOLDEN_CFG_ACT_LEN {act_rows}u\n")
        f.write(f"#define DCIM_GOLDEN_CFG_OUT_LEN {out_rows}u\n")
        f.write(f"#define DCIM_GOLDEN_CFG_LOOP {loop}u\n\n")
        f.write(f"#define DCIM_GOLDEN_WD3 {wd3}u\n")
        f.write(f"#define DCIM_GOLDEN_C {c}u\n\n")
        f.write(f"#define DCIM_ACT_WORD_COUNT {len(act_words)}u\n")
        f.write(f"#define DCIM_WEI_WORD_COUNT {len(wei_words_flat)}u\n")
        f.write(f"#define DCIM_OUT_WORD_COUNT {len(out_words)}u\n\n")

        def emit_arr(name: str, arr: List[int]) -> None:
            f.write(f"static const uint64_t {name}[{len(arr)}] = {{\n")
            for i, v in enumerate(arr):
                sep = "," if i + 1 != len(arr) else ""
                f.write(f"    0x{v & 0xFFFFFFFFFFFFFFFF:016x}ULL{sep}\n")
            f.write("};\n\n")

        emit_arr("DCIM_ACT_WORDS", act_words)
        emit_arr("DCIM_WEI_WORDS", wei_words_flat)
        emit_arr("DCIM_OUT_GOLDEN_WORDS", out_words)
        f.write("#endif\n")


def main() -> None:
    p = argparse.ArgumentParser(description="Generate independent DCIM golden vectors.")
    p.add_argument("--outdir", required=True)
    p.add_argument("--type", default="INT16")
    p.add_argument("--acc", type=int, default=3)
    p.add_argument("--wd1", type=int, default=4)
    p.add_argument("--ch-in", type=int, default=64)
    p.add_argument("--ch-out", type=int, default=64)
    p.add_argument("--r", type=int, default=4)
    p.add_argument("--act-rows", type=int, default=16)
    p.add_argument("--wei-rows", type=int, default=8)
    p.add_argument("--seed", type=int, default=1)
    p.add_argument("--topo", type=int, default=3)
    args = p.parse_args()

    if args.ch_in != 64 or args.ch_out != 64 or args.wd1 != 4:
        raise ValueError("Current script supports ch_in=64, ch_out=64, wd1=4")
    if args.wei_rows != 8:
        raise ValueError("Current DCIM cache mapping expects wei_rows=8")

    mode_map = {
        "UINT4": 0,
        "UINT8": 2,
        "UINT16": 3,
        "INT4": 4,
        "INT8": 6,
        "INT16": 7,
    }
    if args.type.upper() not in mode_map:
        raise ValueError(f"Unsupported TYPE={args.type}")
    cfg_mode = mode_map[args.type.upper()]

    outdir = Path(args.outdir)
    outdir.mkdir(parents=True, exist_ok=True)

    rng = Lcg32(args.seed)

    # Physical ACT words: each row has 8 x u32 => 4 x u64.
    act_rows_u32 = [[rng.next_u32() for _ in range(8)] for _ in range(args.act_rows)]
    act_words: List[int] = []
    for row in act_rows_u32:
        for i in range(0, 8, 2):
            lo = row[i] & 0xFFFFFFFF
            hi = row[i + 1] & 0xFFFFFFFF
            act_words.append(lo | (hi << 32))

    # Physical WEI words: 8 rows x 64 u32 => 256 u64.
    wei_rows_u32 = [[rng.next_u32() for _ in range(64)] for _ in range(args.wei_rows)]
    wei_words_flat: List[int] = []
    for row in wei_rows_u32:
        for i in range(0, 64, 2):
            lo = row[i] & 0xFFFFFFFF
            hi = row[i + 1] & 0xFFFFFFFF
            wei_words_flat.append(lo | (hi << 32))

    # Build checker-format wei.mem lines (save_cache style), then parse via check.py semantics.
    wei_mem_lines: List[str] = []
    for ch_in in range(63, -1, -1):
        vals = []
        for ch_out in range(63, -1, -1):
            idx = (ch_out * 64 + ch_in) * 4
            idx1 = idx // 2048
            idx2 = (idx % 2048) // 32
            nib_shift = ((idx % 32) // 4) * 4
            word = wei_rows_u32[idx1][idx2]
            vals.append(f"{(word >> nib_shift) & 0xF:04b}")
        wei_mem_lines.append(" ".join(vals))

    # Build checker-format act.mem lines (each row: 8 u32, reversed, as 32-bit binary chunks)
    act_mem_lines: List[str] = []
    for row in act_rows_u32:
        chunks = [f"{row[i] & 0xFFFFFFFF:032b}" for i in range(7, -1, -1)]
        act_mem_lines.append(" ".join(chunks))

    signed = args.type.upper() in {"INT4", "INT8", "INT16"}
    if args.type.upper() in {"INT4", "UINT4"}:
        c = 1
    elif args.type.upper() in {"INT8", "UINT8"}:
        c = 2
    elif args.type.upper() in {"INT16", "UINT16"}:
        c = 4
    else:
        raise ValueError(f"Unsupported TYPE={args.type}")

    wd2 = 2 * args.wd1 + int(math.log2(args.ch_in))
    wd3 = wd2 + int(math.log2(args.r))
    bits_per_elem = wd3 * c
    cols = args.ch_out // c

    # Strictly mirror check.py compute pipeline.
    weight_mat = transfer_weight_lines(
        wei_mem_lines, wd=args.wd1 * c, rows=args.ch_in, cols=cols, signed=signed
    )
    act_mat = transfer_act_lines(
        act_mem_lines, wd1=args.wd1, c=c, cols=args.ch_in, signed=signed
    )
    calculated = matmul(act_mat, weight_mat)
    calculated = accumulate_rows(calculated, args.acc)

    # Convert calculated matrix to 1024-bit output rows.
    out_rows = len(calculated)
    out_words: List[int] = []
    out_mem_lines: List[str] = []
    mask = (1 << bits_per_elem) - 1
    for r in range(out_rows):
        row_vals = [int(calculated[r][cidx]) & mask for cidx in range(cols)]
        bits = "".join(f"{v:0{bits_per_elem}b}" for v in row_vals)
        if len(bits) < 1024:
            bits = bits + ("0" * (1024 - len(bits)))
        elif len(bits) > 1024:
            raise ValueError(f"Output row bitwidth {len(bits)} exceeds 1024")
        out_mem_lines.append(" ".join(bits[i:i + 32] for i in range(0, 1024, 32)))
        for i in range(16):
            chunk = bits[i * 64:(i + 1) * 64]
            out_words.append(int(chunk, 2))

    write_hex_words(outdir / "act.hex", act_words)
    write_hex_words(outdir / "wei.hex", wei_words_flat)
    write_hex_words(outdir / "out.hex", out_words)
    with (outdir / "act.mem").open("w", encoding="utf-8") as f:
        for line in act_mem_lines:
            f.write(line + "\n")
    with (outdir / "wei.mem").open("w", encoding="utf-8") as f:
        for line in wei_mem_lines:
            f.write(line + "\n")
    with (outdir / "res.mem").open("w", encoding="utf-8") as f:
        for line in out_mem_lines:
            f.write(line + "\n")

    emit_header(outdir / "input_data.h",
                topo=args.topo,
                cfg_mode=cfg_mode,
                loop=0,
                wd3=wd3,
                c=c,
                act_rows=args.act_rows,
                out_rows=out_rows,
                wei_rows=args.wei_rows,
                acc=args.acc,
                act_words=act_words,
                wei_words_flat=wei_words_flat,
                out_words=out_words)

    print(f"Generated: {outdir / 'act.hex'}")
    print(f"Generated: {outdir / 'wei.hex'}")
    print(f"Generated: {outdir / 'out.hex'}")
    print(f"Generated: {outdir / 'act.mem'}")
    print(f"Generated: {outdir / 'wei.mem'}")
    print(f"Generated: {outdir / 'res.mem'}")
    print(f"Generated: {outdir / 'input_data.h'}")


if __name__ == "__main__":
    main()
