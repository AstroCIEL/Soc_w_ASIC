import argparse
import re
import subprocess
import sys
from bisect import bisect_right


TRACE_RE = re.compile(
    r"^\s*(?P<time>\d+)ns\s+\d+\s+\S+\s+"
    r"(?P<pc>[0-9a-fA-F]+)\s+\d+\s+(?P<hex>[0-9a-fA-F]+)\s+"
    r"(?P<mnem>\S+)(?:\s+(?P<rest>.*))?$"
)


def load_symbols(elf, readelf="riscv64-unknown-elf-readelf"):
    try:
        out = subprocess.check_output(
            [readelf, "-sW", elf], stderr=subprocess.DEVNULL
        ).decode()
    except FileNotFoundError:
        out = subprocess.check_output(["readelf", "-sW", elf]).decode()

    syms = {}  # addr -> (name, size, is_func)
    for line in out.splitlines():
        parts = line.split()
        # Num: Value Size Type Bind Vis Ndx Name
        if len(parts) < 8 or not parts[0].endswith(":"):
            continue
        try:
            addr = int(parts[1], 16)
            size = int(parts[2])
        except ValueError:
            continue
        typ = parts[3]
        name = parts[7]
        if name.startswith("$") or name in ("", "_"):
            continue
        if typ not in ("FUNC", "NOTYPE"):
            continue
        # Prefer FUNC over NOTYPE, prefer entries with non-zero size
        prev = syms.get(addr)
        score = (typ == "FUNC", size > 0)
        if prev is None or score > prev[2]:
            syms[addr] = (name, size, score)

    addr2name = {a: v[0] for a, v in syms.items()}
    # also keep size info for range matching
    addr2size = {a: v[1] for a, v in syms.items()}
    addrs = sorted(addr2name.keys())
    return addrs, addr2name, addr2size


def resolve(addr, addrs, addr2name, addr2size):
    """Return (symbol_name, offset) for addr, or (None, 0)."""
    if not addrs:
        return None, 0
    i = bisect_right(addrs, addr) - 1
    if i < 0:
        return None, 0
    base = addrs[i]
    name = addr2name[base]
    size = addr2size.get(base, 0)
    off = addr - base
    if size and off >= size:
        # too far from symbol; still return but mark
        return name, off
    return name, off


def fmt_sym(name, off):
    if name is None:
        return "???"
    return f"{name}" if off == 0 else f"{name}+0x{off:x}"


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("trace", help="instruction execution trace log")
    ap.add_argument("elf", help="ELF file with symbol table")
    ap.add_argument("-o", "--output", default="-", help="output file (default: stdout)")
    ap.add_argument("--readelf", default="readelf",
                    help="readelf binary to use")
    ap.add_argument("--indent", default="  ", help="indent string per level")
    ap.add_argument("--max-depth", type=int, default=None,
                    help="skip events deeper than this depth")
    ap.add_argument("--no-time", action="store_true", help="do not print time column")
    args = ap.parse_args()

    addrs, addr2name, addr2size = load_symbols(args.elf, args.readelf)
    if not addrs:
        print("warning: no symbols found", file=sys.stderr)

    out = sys.stdout if args.output == "-" else open(args.output, "w")

    # Stack of (callee_addr, callee_name_at_entry, call_time)
    stack = []

    def write_line(time, from_pc, depth, text):
        if args.max_depth is not None and depth > args.max_depth:
            return
        indent = args.indent * depth
        pc_col = f"{from_pc:016x}" if from_pc is not None else " " * 16
        if args.no_time:
            out.write(f"[{pc_col}] {indent}{text}\n")
        else:
            out.write(f"[{time:>10}ns] [{pc_col}] {indent}{text}\n")

    prev = None  # previous parsed record dict
    first_pc = None

    with open(args.trace, "r", errors="replace") as f:
        for raw in f:
            m = TRACE_RE.match(raw)
            if not m:
                continue
            cur = {
                "time": int(m.group("time")),
                "pc": int(m.group("pc"), 16),
                "mnem": m.group("mnem"),
                "rest": (m.group("rest") or "").strip(),
            }

            if prev is None:
                # Emit entry for the very first instruction's function
                name, off = resolve(cur["pc"], addrs, addr2name, addr2size)
                write_line(cur["time"], None, 0, f"{fmt_sym(name, off)}() {{")
                stack.append((cur["pc"], name, cur["time"]))
                prev = cur
                continue

            # Check if prev instruction was a control transfer whose target
            # is cur["pc"] (i.e. pc does NOT simply fall through).
            # We detect calls/returns based on prev's mnemonic.
            mnem = prev["mnem"]
            rest = prev["rest"]

            is_call = False
            is_ret = False

            # Calls: jal rd,... / jalr rd,... / c.jal / c.jalr rs1
            # where rd is ra(x1) or t0(x5).
            if mnem in ("jal", "c.jal"):
                # operands: "ra, <offset>" for jal; c.jal is always ra
                if mnem == "c.jal":
                    is_call = True
                else:
                    # rest starts with destination register
                    first_op = rest.split(",", 1)[0].strip()
                    if first_op in ("ra", "x1", "t0", "x5"):
                        is_call = True
            elif mnem == "jalr":
                first_op = rest.split(",", 1)[0].strip()
                if first_op in ("ra", "x1", "t0", "x5"):
                    is_call = True
            elif mnem == "c.jalr":
                # c.jalr rs1  -> implicit rd = ra
                is_call = True
            elif mnem == "ret":
                is_ret = True
            elif mnem == "c.jr":
                # c.jr rs1 -- it's a return only if rs1 is ra or t0
                first_op = rest.split(",", 1)[0].strip()
                # Some disassemblies: "x0, ra, 0"  (rd=x0 implicit form)
                # Normalize: find ra/t0 in rest.
                toks = [t.strip() for t in rest.replace(",", " ").split()]
                if "ra" in toks or "x1" in toks or "t0" in toks or "x5" in toks:
                    is_ret = True

            if is_call:
                depth = len(stack)
                name, off = resolve(cur["pc"], addrs, addr2name, addr2size)
                write_line(cur["time"], prev["pc"], depth,
                           f"{fmt_sym(name, off)}() {{")
                stack.append((cur["pc"], name, cur["time"]))
            elif is_ret:
                if stack:
                    _, name, _ = stack.pop()
                    depth = len(stack)
                    # describe where we returned to
                    to_name, to_off = resolve(cur["pc"], addrs, addr2name, addr2size)
                    write_line(cur["time"], prev["pc"], depth,
                               f"}} -> {fmt_sym(to_name, to_off)}")
                else:
                    write_line(cur["time"], prev["pc"], 0, "} // unmatched return")

            prev = cur

    # Close any still-open frames
    while stack:
        _, name, _ = stack.pop()
        depth = len(stack)
        write_line(prev["time"] if prev else 0,
                   prev["pc"] if prev else None,
                   depth, f"}} // (eof) {name}")

    if out is not sys.stdout:
        out.close()


if __name__ == "__main__":
    main()
