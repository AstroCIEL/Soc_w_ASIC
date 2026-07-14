# dcim_topo0_test

Topo0 (`2'b00`) DCIM software test:

- Generates 4 independent macro datasets (ACT/WEI/OUT) via Python.
- Writes ACT/WEI to all 4 banks.
- Compares OUT from all 4 banks against generated golden.

Build/run example from repo root:

```bash
make -C software dcim_topo0_test
```

Important knobs (same style as `dcim_test`):

- `DCIM_TYPE`, `DCIM_ACC`, `DCIM_ACT_ROWS`, `DCIM_WEI_ROWS`
- `DCIM_ACT_ROW_ORDER`
- `DCIM_SEED`
