# /DISK1/home/jy_hu30/workspace/memory_compiler/sram_sp_hde_shvt_mvt/r5p0/bin/sram_sp_hde_shvt_mvt verilog 
# -name_case upper -mvt BASE -ser none -site_def off -check_instname on -frequency 500 -bmux off -diodes on -activity_factor 50 
# -words 16384 -bits 64 -drive 6 -write_mask on -redundancy off
# -instname sram_l2_16384x64 -libname sram_l2_16384x64 -cust_comment "" -prefix "" 
# -retention on
# -atf off -libertyviewstyle nldm
# -pwr_gnd_rename vddpe:VDDPE,vddce:VDDCE,vsse:VSSE -power_gating off 
# -write_thru off -wp_size 1 -mux 16 -rows_p_bl 256 -flexible_banking 4 
# -ema on -back_biasing off -bit_blast off -single_domain_only on -vmin_assist on 
# -corners ffg_cbestt_0p88v_0p88v_0c,ffg_cbestt_0p88v_0p88v_125c,ffg_cbestt_0p88v_0p88v_m40c,ssg_cworstt_0p72v_0p72v_0c,ssg_cworstt_0p72v_0p72v_125c,ssg_cworstt_0p72v_0p72v_m40c,tt_typical_0p80v_0p80v_25c,tt_typical_0p80v_0p80v_85c

# /DISK1/home/jy_hu30/workspace/memory_compiler/rf_sp_hde_shvt_mvt/r3p1/bin/rf_sp_hde_shvt_mvt  verilog 
# -name_case lower -mvt BASE -ser none -site_def off -check_instname on -frequency 500 -bmux off -diodes on -activity_factor 50 
# -words 64 -bits 128 -drive 6 -write_mask on -redundancy off
# -instname rf_icache_64x128 -libname rf_icache_64x128 -cust_comment "This is a memory instance" 
# -retention on 
# -atf off -libertyviewstyle nldm  
# -pwr_gnd_rename vddpe:VDDPE,vddce:VDDCE,vsse:VSSE -power_gating off -power_type otc 
# -write_thru off -mux 2 -top_layer m5-m10 
# -ema on -back_biasing off -bit_blast off -single_domain_only on -vmin_assist on  
# -corners ffg_cbestt_0p88v_0p88v_0c,ffg_cbestt_0p88v_0p88v_125c,ffg_cbestt_0p88v_0p88v_m40c,ssg_cworstt_0p72v_0p72v_0c,ssg_cworstt_0p72v_0p72v_125c,ssg_cworstt_0p72v_0p72v_m40c,tt_typical_0p80v_0p80v_25c,tt_typical_0p80v_0p80v_85c

import os
import subprocess
from collections import namedtuple
from typing import List


RF_DEF = namedtuple('RF_DEF', ["Name", "NumWords", "DataWidth"])
RAM_DEF = namedtuple('RAM_DEF', ["Name", "NumWords", "DataWidth"])

ram_defs = [
    RAM_DEF("l2", 16384, 64)
]

rf_defs = [
    RF_DEF("dcache_half", 64, 128), # actually need 256bit
    RF_DEF("icache", 64, 128),
    RF_DEF("vrf", 64, 64),
    RF_DEF("icache_tag", 64, 48), # actually need 47bit
    RF_DEF("dcache_tag", 64, 46),
]

RAM_GENERATOR = "/DISK1/home/jy_hu30/workspace/memory_compiler/sram_sp_hde_shvt_mvt/r5p0/bin/sram_sp_hde_shvt_mvt"
RF_GENERATOR  = "/DISK1/home/jy_hu30/workspace/memory_compiler/rf_sp_hde_shvt_mvt/r3p1/bin/rf_sp_hde_shvt_mvt"

targets = [
    "verilog",
    "liberty",
    "gds2",
    "lef-fp",
    "lvs",
]

corners = "ffg_cbestt_0p88v_0p88v_0c,ffg_cbestt_0p88v_0p88v_125c,ffg_cbestt_0p88v_0p88v_m40c,ssg_cworstt_0p72v_0p72v_0c,ssg_cworstt_0p72v_0p72v_125c,ssg_cworstt_0p72v_0p72v_m40c,tt_typical_0p80v_0p80v_25c,tt_typical_0p80v_0p80v_85c"

LOG_DIR = "logs"


def make_instname(prefix, name, num_words, data_width):
    return f"{prefix}_{name}_{num_words}x{data_width}"


def build_ram_cmd(ram: RAM_DEF, target: str) -> List[str]:
    instname = make_instname("sram", ram.Name, ram.NumWords, ram.DataWidth)
    return [
        RAM_GENERATOR, target,
        "-name_case", "upper",
        "-mvt", "BASE",
        "-ser", "none",
        "-site_def", "off",
        "-check_instname", "off",
        "-frequency", "500",
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
        "-libertyviewstyle", "nldm",
        "-pwr_gnd_rename", "vddpe:VDDPE,vddce:VDDCE,vsse:VSSE",
        "-power_gating", "off",
        "-write_thru", "off",
        "-wp_size", "1",
        "-mux", "16",
        "-rows_p_bl", "256",
        "-flexible_banking", "4",
        "-ema", "on",
        "-back_biasing", "off",
        "-bit_blast", "off",
        "-single_domain_only", "on",
        "-vmin_assist", "on",
        "-corners", corners,
    ]


def build_rf_cmd(rf: RF_DEF, target: str) -> List[str]:
    instname = make_instname("rf", rf.Name, rf.NumWords, rf.DataWidth)
    return [
        RF_GENERATOR, target,
        "-name_case", "lower",
        "-mvt", "BASE",
        "-ser", "none",
        "-site_def", "off",
        "-check_instname", "off",
        "-frequency", "500",
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
        "-libertyviewstyle", "nldm",
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


def run_cmd(cmd: List[str], log_path: str):
    cmd_str = " ".join(cmd)
    print(f"[RUN] {cmd_str}")
    os.makedirs(os.path.dirname(log_path), exist_ok=True)
    with open(log_path, "w") as log_f:
        log_f.write(f"CMD: {cmd_str}\n\n")
        log_f.flush()
        result = subprocess.run(cmd, stdout=log_f, stderr=subprocess.STDOUT, universal_newlines=True)
    if result.returncode != 0:
        print(f"  [WARN] non-zero exit code {result.returncode}, see {log_path}")
    else:
        print(f"  [OK]  log -> {log_path}")


def main():
    os.makedirs(LOG_DIR, exist_ok=True)

    for ram in ram_defs:
        instname = make_instname("sram", ram.Name, ram.NumWords, ram.DataWidth)
        for target in targets:
            cmd = build_ram_cmd(ram, target)
            log_path = os.path.join(LOG_DIR, f"{instname}_{target}.log")
            run_cmd(cmd, log_path)

    for rf in rf_defs:
        instname = make_instname("rf", rf.Name, rf.NumWords, rf.DataWidth)
        for target in targets:
            cmd = build_rf_cmd(rf, target)
            log_path = os.path.join(LOG_DIR, f"{instname}_{target}.log")
            run_cmd(cmd, log_path)


if __name__ == "__main__":
    main()
