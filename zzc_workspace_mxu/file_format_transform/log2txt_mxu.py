#!/usr/bin/env python3
import argparse
import re
from pathlib import Path

BANK_BEGIN_RE = re.compile(r"^===MXU_OUT_BANK_BEGIN\s+bank=(\d+)\s+rows=(\d+)===")
BANK_END_RE = re.compile(r"^===MXU_OUT_BANK_END\s+bank=(\d+)===")
ROW_RE = re.compile(r"^row=(\d+)\s+(.+)$")
TOKEN_RE = re.compile(r"^[0-9a-fA-F]{4}$")


def parse_log(path):
    records = []
    current_bank = None
    with path.open("r", encoding="utf-8", errors="ignore") as f:
        for line_no, raw in enumerate(f, start=1):
            line = raw.strip()
            begin_match = BANK_BEGIN_RE.match(line)
            if begin_match:
                current_bank = int(begin_match.group(1))
                continue
            end_match = BANK_END_RE.match(line)
            if end_match:
                current_bank = None
                continue
            if current_bank is None:
                continue
            row_match = ROW_RE.match(line)
            if not row_match:
                continue
            row = int(row_match.group(1))
            tokens = row_match.group(2).split()
            if len(tokens) != 8 or any(TOKEN_RE.match(tok) is None for tok in tokens):
                raise ValueError("{}:{}: malformed MXU_OUT row".format(path, line_no))
            records.append((current_bank, row, [tok.lower() for tok in tokens]))
    if not records:
        raise ValueError("no MXU_OUT bank records found in {}".format(path))
    return records


def write_output(path, records):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as f:
        for bank, row, tokens in records:
            f.write("{} {} {}\n".format(bank, row, " ".join(tokens)))


def write_split(split_dir, records):
    split_dir.mkdir(parents=True, exist_ok=True)
    by_bank = {}
    for bank, row, tokens in records:
        by_bank.setdefault(bank, []).append((row, tokens))
    for bank, rows in by_bank.items():
        rows.sort(key=lambda item: item[0])
        with (split_dir / "bank{}.txt".format(bank)).open("w", encoding="utf-8") as f:
            for _, tokens in rows:
                f.write("  ".join(tokens) + "\n")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--in", dest="input", required=True, type=Path)
    parser.add_argument("--out", required=True, type=Path)
    parser.add_argument("--section", default="MXU_OUT")
    parser.add_argument("--split-dir", type=Path)
    args = parser.parse_args()

    if args.section != "MXU_OUT":
        raise ValueError("only MXU_OUT section is supported")

    records = parse_log(args.input)
    write_output(args.out, records)
    if args.split_dir:
        write_split(args.split_dir, records)
    print("extracted {} rows from {} to {}".format(len(records), args.input, args.out))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
