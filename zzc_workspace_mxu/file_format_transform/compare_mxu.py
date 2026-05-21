#!/usr/bin/env python3
import argparse
from pathlib import Path

BANK_COUNT = 8
DEFAULT_ROWS = 32


def golden_filename(mode, bank):
    lane = bank // 2
    half = bank % 2
    if mode in {"posit_ff", "posit_bp"}:
        return "mxu_out_lane{}_modified_{}_{}.txt".format(lane, lane, half)
    if mode == "int_ff":
        return "mxu_out_lane{}_{}_{}.txt".format(lane, lane, half)
    raise ValueError("unsupported mode: {}".format(mode))


def read_golden(golden_dir, mode, rows):
    data = {}
    for bank in range(BANK_COUNT):
        path = golden_dir / golden_filename(mode, bank)
        with path.open("r", encoding="utf-8") as f:
            for row, line in enumerate(f):
                if row >= rows:
                    break
                line = line.strip()
                if not line:
                    continue
                tokens = [tok.lower() for tok in line.split()]
                if len(tokens) != 8:
                    raise ValueError("{}:{}: expected 8 tokens, got {}".format(path, row + 1, len(tokens)))
                data[(bank, row)] = tokens
    return data


def read_output(path):
    data = {}
    with path.open("r", encoding="utf-8") as f:
        for line_no, line in enumerate(f, start=1):
            line = line.strip()
            if not line:
                continue
            parts = line.split()
            if len(parts) != 10:
                raise ValueError("{}:{}: expected bank row plus 8 tokens".format(path, line_no))
            bank = int(parts[0], 0)
            row = int(parts[1], 0)
            data[(bank, row)] = [tok.lower() for tok in parts[2:]]
    return data


def compare(golden, output, max_mismatches, rows):
    total = 0
    mismatch_count = 0
    shown = []
    keys = sorted(set(golden) | set(output))
    for bank, row in keys:
        if row >= rows:
            if (bank, row) in output:
                mismatch_count += 1
                if len(shown) < max_mismatches:
                    shown.append("extra output beyond compared rows bank={} row={}".format(bank, row))
            continue
        expected = golden.get((bank, row))
        actual = output.get((bank, row))
        if expected is None:
            mismatch_count += 1
            if len(shown) < max_mismatches:
                shown.append("extra output bank={} row={}".format(bank, row))
            continue
        if actual is None:
            mismatch_count += 1
            if len(shown) < max_mismatches:
                shown.append("missing output bank={} row={}".format(bank, row))
            continue
        for token_idx, (exp_tok, act_tok) in enumerate(zip(expected, actual)):
            total += 1
            if set(exp_tok) == {"x"}:
                continue
            if exp_tok != act_tok:
                mismatch_count += 1
                if len(shown) < max_mismatches:
                    shown.append(
                        "bank={} row={} token={} actual={} expected={}".format(
                            bank, row, token_idx, act_tok, exp_tok
                        )
                    )
    return total, mismatch_count, shown


def write_report(path, mode, rows, total, mismatch_count, shown):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as f:
        f.write("mode: {}\n".format(mode))
        f.write("compared_rows: {}\n".format(rows))
        f.write("total_tokens: {}\n".format(total))
        f.write("mismatches: {}\n".format(mismatch_count))
        if mismatch_count == 0:
            f.write("result: PASS\n")
        else:
            f.write("result: FAIL\n")
            f.write("first_mismatches:\n")
            for item in shown:
                f.write("  {}\n".format(item))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--mode", required=True, choices=["int_ff", "posit_ff", "posit_bp"])
    parser.add_argument("--golden-dir", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--report", required=True, type=Path)
    parser.add_argument("--max-mismatches", type=int, default=50)
    parser.add_argument("--rows", type=int, default=DEFAULT_ROWS)
    args = parser.parse_args()

    golden = read_golden(args.golden_dir, args.mode, args.rows)
    output = read_output(args.output)
    total, mismatch_count, shown = compare(golden, output, args.max_mismatches, args.rows)
    write_report(args.report, args.mode, args.rows, total, mismatch_count, shown)
    if mismatch_count:
        print("MXU compare FAIL: {} mismatches, report={}".format(mismatch_count, args.report))
        return 1
    print("MXU compare PASS: {} tokens, report={}".format(total, args.report))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
