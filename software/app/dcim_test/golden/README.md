# DCIM Golden Data Flow

This directory uses a single generator script: `gen_dcim_golden_data.py`.

## What gets generated

Run:

```bash
python3 gen_dcim_golden_data.py --outdir ../../../../software/build/app/dcim_test/gen
```

It generates:

- `wei.hex`
- `act.hex`
- `out.hex`
- `input_data.h`

Current constraints for this generator:

- `--ch-in 64 --ch-out 64 --wd1 4`
- `--r 4`
- `--wei-rows 8` (matches RTL load_wei CYCLE=8 behavior)
- `--acc` in `[0, 4]`
- `--act-rows` must be divisible by `C` where `C=1/2/4` for `TYPE=*_4/*_8/*_16`
- `--act-row-order` controls multi-row ACT consumption order for golden compute (`normal`/`reverse`/`last_first`)

## End-to-end validation flow

1. Software includes generated `input_data.h` (from `software/build/app/dcim_test/gen`).
2. CPU writes `wei.hex` and `act.hex` payloads into DCIM MMIO buffers.
3. CPU triggers `load_wei` and `start`.
4. CPU reads DCIM output buffer and compares with generated `out.hex` (packed in `input_data.h`).
5. UART only reports final result: `DCIM_PASS` or `DCIM_FAIL`.

There is no UART transaction extraction or offline checker in this flow.

