# DCIM Golden Check (SoC Flow)

This checker is intended for **SoC/dcim_test golden validation**, following the
same math/parsing idea as your reference script.

It does **not** create an independent Verilator-only flow.

## Inputs

Place the following files in this directory before running:

- `wei.mem`
- `act.mem`
- `res.mem`

These are expected to be generated from your SoC validation flow.

## CPU-side IO export

`dcim_test` now prints CPU MMIO access markers in UART:

`DCIM_IO <OP> addr=0x........ data=0x................`

You can extract them from SoC `uart0.log`:

```bash
cd software/app/dcim_test/golden
python3 extract_io.py ../../../../sim/uart0.log --out dcim_io_trace.csv
```

This provides a CPU-side read/write transaction trace (source of truth for SoC flow).

Then convert CPU IO trace to checker mem files:

```bash
cd software/app/dcim_test/golden
python3 io_to_mem.py --csv dcim_io_trace.csv
```

By default, converter exports bank0 (`act/wei/out`). You can override:

```bash
python3 io_to_mem.py --csv dcim_io_trace.csv --act-bank 0 --wei-bank 0 --out-bank 0
```

## Run

```bash
cd software/app/dcim_test/golden
python3 check.py
```

Optional config:

```bash
TYPE=INT16 ACC=3 WD1=4 CH_IN=64 CH_OUT=64 R=4 python3 check.py
```

## Outputs

- `weight.txt`, `activation.txt`, `result.txt` (decoded decimal matrices)
- terminal pass/fail report with mismatch details

