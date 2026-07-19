#!/usr/bin/env python3
# gen_sram2.py — based on gen_sram.py
#
# Changes vs gen_sram.py:
#   - Liberty view: ccs_tnv (was nldm)
#   - PDK root is a variable (env TSMC22_PDK_ROOT / CLI --pdk-root), not hardcoded
#   - Corners: ssg m40c/125c, ffg m40c, tt 25c only
#
# Usage:
#   export TSMC22_PDK_ROOT=/path/to/TSMC_22NM_RF_ULL
#   cd <output_dir> && python3 <path>/gen_sram2.py
#   # or:
#   python3 gen_sram2.py --pdk-root /path/to/TSMC_22NM_RF_ULL
#
# Check before run: sizes, GENERATOR revisions, frequency, corners.

import argparse
import os
import subprocess
from collections import namedtuple
from typing import List

# Default matches the previous hardcoded root; override via env or --pdk-root.
DEFAULT_PDK_ROOT = "/data/data_eda2/PDK_Tech/TSMC_22NM_RF_ULL"

CPU_RF_DEF = namedtuple("CPU_RF_DEF", ["Name", "NumWords", "DataWidth"])
CPU_RAM_DEF = namedtuple("CPU_RAM_DEF", ["Name", "NumWords", "DataWidth"])
RF_DEF = namedtuple("RF_DEF", ["Name", "NumWords", "DataWidth"])
RAM_DEF = namedtuple("RAM_DEF", ["Name", "NumWords", "DataWidth"])
GB_RAM_DEF = namedtuple("GB_RAM_DEF", ["Name", "NumWords", "DataWidth"])

# SOC/CPU macros only (L2 + CVA6 cache + Ara VRF).
cpu_ram_defs = [
#    CPU_RAM_DEF("l2", 4096, 64),  # sram_l2_4096x64
    CPU_RAM_DEF("l2", 16384, 64),  # sram_l2_16384x64
]

cpu_rf_defs = [
#    CPU_RF_DEF("dcache_half", 64, 128),  # rf_dcache_half_64x128 (2x → 256b)
#    CPU_RF_DEF("icache", 64, 128),       # rf_icache_64x128
#    CPU_RF_DEF("vrf", 64, 64),           # rf_vrf_64x64
#    CPU_RF_DEF("icache_tag", 64, 48),    # rf_icache_tag_64x48
#    CPU_RF_DEF("dcache_tag", 64, 46),    # rf_dcache_tag_64x46
]

# Custom IP macros — disabled
# ram_defs = [
#     RAM_DEF("sramdp", 272, 16),
# ]
# rf_defs = [
#     RF_DEF("rf2p", 256, 128),
# ]
# gb_ram_defs = [
#     GB_RAM_DEF("sp", 4096, 64),
# ]

# Relative paths under PDK_ROOT (filled in resolve_generators).
_CPU_RAM_REL = "IP/Memory_Compiler/sram_sp_hde_svt_mvt/r1p0/bin/sram_sp_hde_svt_mvt"
_CPU_RF_REL = "IP/Memory_Compiler/rf_sp_hde_shvt_mvt/r3p1/bin/rf_sp_hde_shvt_mvt"
_RAM_REL = "IP/Memory_Compiler/sram_dp_hde_svt_svt/r0p1/bin/sram_dp_hde_svt_svt"
_RF_REL = "IP/Memory_Compiler/rf_2p_hdc_svt_mvt/r0p0/bin/rf_2p_hdc_svt_mvt"
_GB_RAM_REL = "IP/Memory_Compiler/sram_sp_hde_svt_mvt/r1p0/bin/sram_sp_hde_svt_mvt"

CPU_RAM_GENERATOR = ""
CPU_RF_GENERATOR = ""
RAM_GENERATOR = ""
RF_GENERATOR = ""
GB_RAM_GENERATOR = ""

targets = [
    "verilog",
    "liberty",
    "gds2",
    "lef-fp",
    "lvs",
]

# User shorthand → Memory Compiler full corner names:
#   ssg_0p72v_m40c  → ssg_cworstt_0p72v_0p72v_m40c
#   ssg_0p72v_125c  → ssg_cworstt_0p72v_0p72v_125c
#   ffg_0p88v_m40c  → ffg_cbestt_0p88v_0p88v_m40c
#   tt_0p80v_25c    → tt_typical_0p80v_0p80v_25c
corners = ",".join(
    [
        "ssg_cworstt_0p72v_0p72v_m40c",
        "ssg_cworstt_0p72v_0p72v_125c",
        "ffg_cbestt_0p88v_0p88v_m40c",
        "tt_typical_0p80v_0p80v_25c",
    ]
)

LIBERTY_VIEW = "ccs_tnv"
LOG_DIR = "logs"


def resolve_generators(pdk_root: str) -> None:
    global CPU_RAM_GENERATOR, CPU_RF_GENERATOR, RAM_GENERATOR, RF_GENERATOR, GB_RAM_GENERATOR
    pdk_root = os.path.abspath(os.path.expanduser(pdk_root))
    CPU_RAM_GENERATOR = os.path.join(pdk_root, _CPU_RAM_REL)
    CPU_RF_GENERATOR = os.path.join(pdk_root, _CPU_RF_REL)
    RAM_GENERATOR = os.path.join(pdk_root, _RAM_REL)
    RF_GENERATOR = os.path.join(pdk_root, _RF_REL)
    GB_RAM_GENERATOR = os.path.join(pdk_root, _GB_RAM_REL)


def make_cpu_instname(prefix, name, num_words, data_width):
    return f"{prefix}_{name}_{num_words}x{data_width}"


def make_gb_instname(prefix, name, num_words, data_width):
    return f"{prefix}{name}_{num_words}_{data_width}"


def make_instname(name, num_words, data_width):
    return f"{name}_{num_words}_{data_width}"


def build_cpu_ram_cmd(ram: CPU_RAM_DEF, target: str) -> List[str]:
    instname = make_cpu_instname("sram", ram.Name, ram.NumWords, ram.DataWidth)
    return [
        CPU_RAM_GENERATOR, target,
        "-name_case", "upper",
        "-mvt", "BASE",
        "-ser", "none",
        "-site_def", "off",
        "-check_instname", "off",
        "-frequency", "1000",
        "-bmux", "off",
        "-diodes", "on",
        "-activity_factor", "50",
        "-words", str(ram.NumWords),
        "-bits", str(ram.DataWidth),
        "-drive", "6",
        "-write_mask", "on",
        "-redundancy", "off",
        "-instname", instname,
        "-libname", instname,
        "-cust_comment", "",
        "-prefix", "",
        "-retention", "on",
        "-atf", "off",
        "-libertyviewstyle", LIBERTY_VIEW,
        "-pwr_gnd_rename", "vddpe:VDDPE,vddce:VDDCE,vsse:VSSE",
        "-power_gating", "off",
        "-write_thru", "off",
        "-wp_size", "1",
        "-mux", "16",
        "-rows_p_bl", "256",
        "-flexible_banking", "4",
        "-ema", "on",
        "-back_biasing", "off",
        "-vmin_assist", "on",
        "-corners", corners,
    ]


def build_gb_ram_cmd(ram: GB_RAM_DEF, target: str) -> List[str]:
    instname = make_gb_instname("sram", ram.Name, ram.NumWords, ram.DataWidth)
    return [
        GB_RAM_GENERATOR, target,
        "-name_case", "lower",
        "-mvt", "BASE",
        "-bus_notation", "on",
        "-ser", "none",
        "-site_def", "off",
        "-check_instname", "off",
        "-frequency", "1000",
        "-bmux", "off",
        "-diodes", "on",
        "-activity_factor", "50",
        "-words", str(ram.NumWords),
        "-bits", str(ram.DataWidth),
        "-drive", "6",
        "-write_mask", "off",
        "-redundancy", "off",
        "-instname", instname,
        "-libname", instname,
        "-cust_comment", "",
        "-prefix", "",
        "-retention", "on",
        "-atf", "off",
        "-libertyviewstyle", LIBERTY_VIEW,
        "-left_bus_delim", "[",
        "-pwr_gnd_rename", "vddpe:VDDPE,vddce:VDDCE,vsse:VSSE",
        "-right_bus_delim", "]",
        "-rows_p_bl", "256",
        "-flexible_banking", "4",
        "-power_gating", "off",
        "-write_thru", "off",
        "-mux", "16",
        "-ema", "on",
        "-back_biasing", "off",
        "-vmin_assist", "on",
        "-corners", corners,
    ]


def build_cpu_rf_cmd(rf: CPU_RF_DEF, target: str) -> List[str]:
    instname = make_cpu_instname("rf", rf.Name, rf.NumWords, rf.DataWidth)
    return [
        CPU_RF_GENERATOR, target,
        "-name_case", "lower",
        "-mvt", "BASE",
        "-ser", "none",
        "-site_def", "off",
        "-check_instname", "off",
        "-frequency", "1000",
        "-bmux", "off",
        "-diodes", "on",
        "-activity_factor", "50",
        "-words", str(rf.NumWords),
        "-bits", str(rf.DataWidth),
        "-drive", "6",
        "-write_mask", "on",
        "-redundancy", "off",
        "-instname", instname,
        "-libname", instname,
        "-cust_comment", "This is a memory instance",
        "-retention", "on",
        "-atf", "off",
        "-libertyviewstyle", LIBERTY_VIEW,
        "-pwr_gnd_rename", "vddpe:VDDPE,vddce:VDDCE,vsse:VSSE",
        "-power_gating", "off",
        "-power_type", "otc",
        "-write_thru", "off",
        "-mux", "2",
        "-top_layer", "m5-m10",
        "-ema", "on",
        "-back_biasing", "off",
        "-bit_blast", "off",
        "-single_domain_only", "on",
        "-vmin_assist", "on",
        "-corners", corners,
    ]


def build_ram_cmd(ram: RAM_DEF, target: str) -> List[str]:
    instname = make_instname(ram.Name, ram.NumWords, ram.DataWidth)
    return [
        RAM_GENERATOR, target,
        "-name_case", "lower",
        "-mvt", "LL",
        "-ser", "none",
        "-bus_notation", "on",
        "-site_def", "off",
        "-check_instname", "off",
        "-frequency", "1000",
        "-bmux", "on",
        "-diodes", "on",
        "-activity_factor", "50",
        "-words", str(ram.NumWords),
        "-drive", "6",
        "-power_type", "otc",
        "-bits", str(ram.DataWidth),
        "-instname", instname,
        "-retention", "on",
        "-libertyviewstyle", LIBERTY_VIEW,
        "-write_mask", "off",
        "-atf", "off",
        "-left_bus_delim", "[",
        "-pwr_gnd_rename", "vddpe:VDDPE,vddce:VDDCE,vsse:VSSE",
        "-right_bus_delim", "]",
        "-rows_p_bl", "256",
        "-redundancy", "off",
        "-libname", instname,
        "-write_thru", "off",
        "-cust_comment", "This is a memory instance",
        "-pipeline", "off",
        "-mux", "4",
        "-top_layer", "m5-m10",
        "-power_gating", "off",
        "-back_biasing", "off",
        "-ema", "on",
        "-wa", "off",
        "-corners", corners,
    ]


def build_rf_cmd(rf: RF_DEF, target: str) -> List[str]:
    instname = make_instname(rf.Name, rf.NumWords, rf.DataWidth)
    return [
        RF_GENERATOR, target,
        "-name_case", "lower",
        "-mvt", "HP",
        "-ser", "none",
        "-bus_notation", "on",
        "-site_def", "off",
        "-check_instname", "on",
        "-frequency", "1000",
        "-bmux", "off",
        "-diodes", "on",
        "-activity_factor", "50",
        "-words", str(rf.NumWords),
        "-bits", str(rf.DataWidth),
        "-drive", "6",
        "-instname", instname,
        "-retention", "on",
        "-libertyviewstyle", LIBERTY_VIEW,
        "-write_mask", "on",
        "-atf", "off",
        "-left_bus_delim", "[",
        "-pwr_gnd_rename", "vddpe:VDDPE,vddce:VDDCE,vsse:VSSE",
        "-right_bus_delim", "]",
        "-flexible_banking", "2",
        "-redundancy", "off",
        "-wp_size", "1",
        "-libname", instname,
        "-cust_comment", "",
        "-pipeline", "off",
        "-prefix", "",
        "-mux", "2",
        "-power_gating", "off",
        "-back_biasing", "off",
        "-ema", "on",
        "-vmin_assist", "off",
        "-corners", corners,
    ]


def run_cmd(cmd: List[str], log_path: str):
    cmd_str = " ".join(cmd)
    print(f"[RUN] {cmd_str}")
    os.makedirs(os.path.dirname(log_path) or ".", exist_ok=True)
    with open(log_path, "w") as log_f:
        log_f.write(f"CMD: {cmd_str}\n\n")
        log_f.flush()
        result = subprocess.run(cmd, stdout=log_f, stderr=subprocess.STDOUT, universal_newlines=True)
    if result.returncode != 0:
        print(f"  [WARN] non-zero exit code {result.returncode}, see {log_path}")
    else:
        print(f"  [OK]  log -> {log_path}")


def parse_args():
    parser = argparse.ArgumentParser(
        description="Generate SRAM/RF views with CCS_TNV Liberty (gen_sram2)."
    )
    parser.add_argument(
        "--pdk-root",
        default=os.environ.get("TSMC22_PDK_ROOT", DEFAULT_PDK_ROOT),
        help="TSMC_22NM_RF_ULL root (env TSMC22_PDK_ROOT or this flag). "
        f"Default: {DEFAULT_PDK_ROOT}",
    )
    return parser.parse_args()


def main():
    args = parse_args()
    resolve_generators(args.pdk_root)
    print(f"[INFO] PDK_ROOT={os.path.abspath(os.path.expanduser(args.pdk_root))}")
    print(f"[INFO] libertyviewstyle={LIBERTY_VIEW}")
    print(f"[INFO] corners={corners}")

    for gen in (CPU_RAM_GENERATOR, CPU_RF_GENERATOR):
        if not os.path.isfile(gen):
            print(f"[WARN] generator not found: {gen}")

    os.makedirs(LOG_DIR, exist_ok=True)

    for cpu_ram in cpu_ram_defs:
        instname = make_cpu_instname("sram", cpu_ram.Name, cpu_ram.NumWords, cpu_ram.DataWidth)
        for target in targets:
            cmd = build_cpu_ram_cmd(cpu_ram, target)
            log_path = os.path.join(LOG_DIR, f"{instname}_{target}.log")
            run_cmd(cmd, log_path)

    for cpu_rf in cpu_rf_defs:
        instname = make_cpu_instname("rf", cpu_rf.Name, cpu_rf.NumWords, cpu_rf.DataWidth)
        for target in targets:
            cmd = build_cpu_rf_cmd(cpu_rf, target)
            log_path = os.path.join(LOG_DIR, f"{instname}_{target}.log")
            run_cmd(cmd, log_path)

    # Custom IP macros — disabled
    # for ram in ram_defs: ...
    # for rf in rf_defs: ...
    # for gb_ram in gb_ram_defs: ...


if __name__ == "__main__":
    main()

