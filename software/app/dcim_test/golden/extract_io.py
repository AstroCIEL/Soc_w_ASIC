#!/usr/bin/env python3
import argparse
import re
from pathlib import Path


LINE_RE = re.compile(
    r"DCIM_IO\s+(?P<op>[A-Z_]+)\s+addr=0x(?P<addr>[0-9a-fA-F]+)\s+data=0x(?P<data>[0-9a-fA-F]+)"
)


def _resolve_uart_log(path_str: str) -> Path:
    user_path = Path(path_str)
    if user_path.exists():
        return user_path

    script_dir = Path(__file__).resolve().parent
    candidates = [
        script_dir / path_str,
        script_dir / "../../../../sim/uart0.log",
        script_dir / "../../../sim/uart0.log",
    ]
    for p in candidates:
        p = p.resolve()
        if p.exists():
            return p

    raise FileNotFoundError(
        f"uart log not found: {path_str}\n"
        f"Try: ../../../../sim/uart0.log (from software/app/dcim_test/golden)"
    )


def main():
    parser = argparse.ArgumentParser(description="Extract CPU-side DCIM MMIO IO from uart log.")
    parser.add_argument("uart_log", help="Path to uart0.log")
    parser.add_argument(
        "--out",
        default="dcim_io_trace.csv",
        help="Output csv path (default: dcim_io_trace.csv)",
    )
    args = parser.parse_args()

    uart_log = _resolve_uart_log(args.uart_log)

    rows = []
    with open(uart_log, "r", encoding="utf-8", errors="ignore") as f:
        for idx, line in enumerate(f, start=1):
            m = LINE_RE.search(line)
            if not m:
                continue
            op = m.group("op")
            addr = int(m.group("addr"), 16)
            data = int(m.group("data"), 16)
            rows.append((idx, op, addr, data))

    with open(args.out, "w", encoding="utf-8") as f:
        f.write("line,op,addr_hex,data_hex\n")
        for line_no, op, addr, data in rows:
            f.write(f"{line_no},{op},0x{addr:08x},0x{data:016x}\n")

    print(f"Using uart log: {uart_log}")
    print(f"Extracted {len(rows)} DCIM_IO transactions to {args.out}")


if __name__ == "__main__":
    main()

