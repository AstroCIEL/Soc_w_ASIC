#!/usr/bin/env python3
# gen_sram2.py — based on gen_sram.py
#
# Changes vs gen_sram.py:
#   - Liberty view: Tries ccs_tnv during liberty generation. If it fails, 
#     ALL views for that macro automatically fallback to nldm.
#   - PDK root is a variable (env TSMC22_PDK_ROOT / CLI --pdk-root), not hardcoded
#   - Corners: ssg m40c/125c, ffg m40c, tt 25c only
#   - File Organization: Outputs and logs are placed in their respective target/ subdirectories.
#   - Integrated lib2db: Automatically converts generated .lib files to .db inside the liberty/ directory.
#
# Check before run: sizes, GENERATOR revisions, frequency, corners.

import argparse
import os
import shutil
import subprocess
from collections import namedtuple
from typing import List, Callable

# Default matches the previous hardcoded root; override via env or --pdk-root.
DEFAULT_PDK_ROOT = "/data/data_eda2/PDK_Tech/TSMC_22NM_RF_ULL"

CPU_RF_DEF = namedtuple("CPU_RF_DEF", ["Name", "NumWords", "DataWidth"])
CPU_RAM_DEF = namedtuple("CPU_RAM_DEF", ["Name", "NumWords", "DataWidth"])
RF_DEF = namedtuple("RF_DEF", ["Name", "NumWords", "DataWidth"])
RAM_DEF = namedtuple("RAM_DEF", ["Name", "NumWords", "DataWidth"])
GB_RAM_DEF = namedtuple("GB_RAM_DEF", ["Name", "NumWords", "DataWidth"])

# SOC/CPU macros only (L2 + CVA6 cache + Ara VRF).
cpu_ram_defs = [
    CPU_RAM_DEF("l2", 4096, 64),  # sram_l2_4096x64
# CPU_RAM_DEF("l2", 16384, 64),  # sram_l2_16384x64
]

cpu_rf_defs = [
    CPU_RF_DEF("dcache_half", 64, 128),  # rf_dcache_half_64x128 (2x → 256b)
    CPU_RF_DEF("icache", 64, 128),       # rf_icache_64x128
# CPU_RF_DEF("vrf", 64, 64),           # rf_vrf_64x64
    CPU_RF_DEF("icache_tag", 64, 48),    # rf_icache_tag_64x48
    CPU_RF_DEF("dcache_tag", 64, 46),    # rf_dcache_tag_64x46
]

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
    "postscript",
]

corners = ",".join(
    [
#       "ssg_cworstt_0p72v_0p72v_m40c",
#       "ssg_cworstt_0p72v_0p72v_125c",
#       "ffg_cbestt_0p88v_0p88v_m40c",
        "tt_typical_0p80v_0p80v_25c",
#		"tt_typical_0p80v_0p80v_0c",
#		"tt_typical_0p80v_0p80v_85c",
    ]
)

DEFAULT_LIBERTY_VIEW = "ccs_tnv"
FALLBACK_LIBERTY_VIEW = "nldm"


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


def build_cpu_ram_cmd(ram: CPU_RAM_DEF, target: str, liberty_view: str = DEFAULT_LIBERTY_VIEW) -> List[str]:
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
        "-libertyviewstyle", liberty_view,
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


def build_cpu_rf_cmd(rf: CPU_RF_DEF, target: str, liberty_view: str = DEFAULT_LIBERTY_VIEW) -> List[str]:
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
        "-libertyviewstyle", liberty_view,
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


def run_cmd_in_target_dir(cmd: List[str], target: str, instname: str, base_run_dir: str):
    """Switch to the corresponding target/ directory and execute the Memory Compiler command"""
    target_dir = os.path.join(base_run_dir, target)
    os.makedirs(target_dir, exist_ok=True)
    
    os.chdir(target_dir)
    log_name = f"{instname}_{target}.log"
    cmd_str = " ".join(cmd)
    print(f"[RUN] [{target}/] {cmd_str}")
    
    with open(log_name, "w") as log_f:
        log_f.write(f"CMD: {cmd_str}\n\n")
        log_f.flush()
        result = subprocess.run(cmd, stdout=log_f, stderr=subprocess.STDOUT, universal_newlines=True)
        
    if result.returncode != 0:
        print(f"  [WARN] non-zero exit code {result.returncode}, see {target}/{log_name}")
    else:
        print(f"  [OK] outputs & log -> {target}/{log_name}")
        
    os.chdir(base_run_dir)


def generate_macro(cmd_builder_fn: Callable, item, prefix: str, base_run_dir: str):
    """Generates all views for a single macro. Tests ccs_tnv on 'liberty' first; if failed, fallbacks all views to nldm."""
    instname = make_cpu_instname(prefix, item.Name, item.NumWords, item.DataWidth)
    chosen_view = DEFAULT_LIBERTY_VIEW
    liberty_already_generated = False

    # 1. 优先在 liberty 步骤中尝试 ccs_tnv 精度
    if "liberty" in targets:
        target_dir = os.path.join(base_run_dir, "liberty")
        os.makedirs(target_dir, exist_ok=True)
        os.chdir(target_dir)

        log_name = f"{instname}_liberty.log"
        cmd = cmd_builder_fn(item, "liberty", DEFAULT_LIBERTY_VIEW)
        cmd_str = " ".join(cmd)

        print(f"[CHECK] [liberty/] Testing '{DEFAULT_LIBERTY_VIEW}' style for {instname}...")
        with open(log_name, "w") as log_f:
            log_f.write(f"CMD ({DEFAULT_LIBERTY_VIEW}): {cmd_str}\n\n")
            log_f.flush()
            res = subprocess.run(cmd, stdout=log_f, stderr=subprocess.STDOUT, universal_newlines=True)

        os.chdir(base_run_dir)

        if res.returncode == 0:
            print(f"  [OK] '{DEFAULT_LIBERTY_VIEW}' succeeded for {instname} in liberty target.")
            liberty_already_generated = True
        else:
            print(f"  [WARN] '{DEFAULT_LIBERTY_VIEW}' failed for {instname} during liberty generation.")
            print(f"  [FALLBACK] Changing ALL views for {instname} to '{FALLBACK_LIBERTY_VIEW}'!")
            chosen_view = FALLBACK_LIBERTY_VIEW

    # 2. 使用确定好的精度（ccs_tnv 或 nldm）生成该 Macro 的所有 Targets
    for target in targets:
        if target == "liberty" and liberty_already_generated:
            # 已经成功生成过，直接跳过重复运行
            continue

        cmd = cmd_builder_fn(item, target, chosen_view)
        run_cmd_in_target_dir(cmd, target, instname, base_run_dir)


def auto_convert_lib_to_db(base_run_dir: str):
    """Automatically scan all .lib files in liberty/ directory and convert them to .db inside db/ directory"""
    liberty_dir = os.path.join(base_run_dir, "liberty")
    db_dir = os.path.join(base_run_dir, "db")
    
    if not os.path.isdir(liberty_dir):
        return

    os.makedirs(db_dir, exist_ok=True)

    eda_cmd = ""
    if shutil.which("lc_shell"):
        eda_cmd = "lc_shell"
    elif shutil.which("dc_shell"):
        eda_cmd = "dc_shell"
    else:
        print("\n[WARNING] Neither lc_shell nor dc_shell found. Skipping .db conversion.")
        return

    print(f"\n=== [Integration Step] Automatically converting .lib files in liberty/ to .db inside db/ (using {eda_cmd}) ===")
    
    os.chdir(liberty_dir)

    lib_files = [f for f in os.listdir(".") if f.endswith(".lib") or ".lib_" in f]
    if not lib_files:
        print("[INFO] No .lib files found in liberty/ directory.")
        os.chdir(base_run_dir)
        return

    tcl_lines = ["# Generated dynamically by gen_sram2.py"]
    for lib in lib_files:
        if ".lib" in lib:
            current_lib = lib.split(".lib")[0]
        else:
            current_lib = os.path.splitext(lib)[0]
            
        pure_db_name = lib.replace(".lib", ".db")
        abs_db_path = os.path.join(db_dir, pure_db_name)
        
        tcl_lines.append(f"read_lib {lib}")
        tcl_lines.append(f'echo "Writing database for library: {current_lib} -> db/{pure_db_name}"')
        tcl_lines.append(f"write_lib -format db {current_lib} -output {abs_db_path}")
        tcl_lines.append(f"remove_lib {current_lib}")
    
    tcl_lines.append("exit")
    tcl_content = "\n".join(tcl_lines)

    tcl_filename = "convert.tcl"
    with open(tcl_filename, "w") as f:
        f.write(tcl_content)

    if eda_cmd == "lc_shell":
        run_args = ["lc_shell", "-f", tcl_filename]
    else:
        run_args = ["dc_shell", "-tcl_mode", "-f", tcl_filename]

    print(f"[RUN] [{eda_cmd}] LIB2DB Format Conversion...")
    res = subprocess.run(run_args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True)
    
    log_path = os.path.join(db_dir, "lib2db_conversion.log")
    with open(log_path, "w") as log_f:
        log_f.write(res.stdout)

    if res.returncode != 0:
        print(f"  [WARN] .lib to .db conversion failed. Check db/lib2db_conversion.log")
    else:
        print(f"  [OK] .db File & Conversion Log Generated in db/ Successfully.")

    if os.path.exists(tcl_filename):
        os.remove(tcl_filename)

    os.chdir(base_run_dir)


def parse_args():
    parser = argparse.ArgumentParser(
        description="Generate SRAM/RF views with CCS_TNV (fallback to NLDM for all views if failed) (gen_sram2)."
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
    
    base_run_dir = os.getcwd()
    
    print(f"[INFO] PDK_ROOT={os.path.abspath(os.path.expanduser(args.pdk_root))}")
    print(f"[INFO] Primary Liberty view: {DEFAULT_LIBERTY_VIEW} (Fallback: {FALLBACK_LIBERTY_VIEW})")
    print(f"[INFO] Corners={corners}")

    for gen in (CPU_RAM_GENERATOR, CPU_RF_GENERATOR):
        if not os.path.isfile(gen):
            print(f"[WARN] Generator not found: {gen}")

    # 1. Generate all views for CPU RAM
    for cpu_ram in cpu_ram_defs:
        generate_macro(build_cpu_ram_cmd, cpu_ram, "sram", base_run_dir)

    # 2. Generate all views for CPU RF
    for cpu_rf in cpu_rf_defs:
        generate_macro(build_cpu_rf_cmd, cpu_rf, "rf", base_run_dir)

    # 3. Integration Step: Once files for all targets are generated, trigger lib2db conversion inline
    if "liberty" in targets:
        auto_convert_lib_to_db(base_run_dir)


if __name__ == "__main__":
    main()
