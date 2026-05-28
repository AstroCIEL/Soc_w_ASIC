from pathlib import Path
import shutil
from typing import List, Tuple

PREFIX = Path("/DISK2/PDK_Tech/TSMC_22NM_RF_ULL/IP/Std_Cell/")
DESTPATH = Path("/DISK1/home/jy_hu30/workspace/tsmc22/stdcell")

stdcell_type = [
    "tcbn22ullbwp7t30p140lvt",
    "tcbn22ullbwp7t30p140sg",
    "tcbn22ullbwp7t30p140sghvt",
    "tcbn22ullbwp7t30p140sglvt",
    "tcbn22ullbwp7t30p140ulvt",
]

CORNER = [
    "ssg0p72v0c",
    "ffg0p88vm40c",
    "ffg0p88v125c",
    "tt0p8v85c",
    "ssg0p72vm40c",
    "tt0p8v25c",
    "ffg0p88v0c",
    "ssg0p72v125c",
]


filetype = [
    "lib",
    "lef",
    "spi",
    "gds",
    "aocvm",
    "v",
    "ndm",
    "milkyway",
]


# example path
# lib: 
# tcbn22ullbwp7t30p140sghvt_110b/digital/Front_End/timing_power_noise/NLDM/tcbn22ullbwp7t30p140sghvt_110b/tcbn22ullbwp7t30p140sghvtffg0p88v0c.lib
# ndm:
# tcbn22ullbwp7t30p140sghvt_110b/digital/Back_End/ndm/tcbn22ullbwp7t30p140sghvt_110a/tcbn22ullbwp7t30p140sghvt_physicalonly.ndm
# v:
# tcbn22ullbwp7t30p140sghvt_110b/digital/Front_End/verilog/tcbn22ullbwp7t30p140sghvt_110a/tcbn22ullbwp7t30p140sghvt.v
# tcbn22ullbwp7t30p140sghvt_110b/digital/Front_End/verilog/tcbn22ullbwp7t30p140sghvt_110a/tcbn22ullbwp7t30p140sghvt_pwr.v
# aocvm:
# tcbn22ullbwp7t30p140sghvt_110b/digital/Front_End/SBOCV/CCS/tcbn22ullbwp7t30p140sghvt_110a/ffg0p88v125c/clock_p_data_p/tcbn22ullbwp7t30p140sghvtffg0p88v125c_hold_P_P_ccs.aocvm
# lef:
# tcbn22ullbwp7t30p140sghvt_110b/digital/Back_End/lef/tcbn22ullbwp7t30p140sghvt_110a/lef/tcbn22ullbwp7t30p140sghvt.lef
# gds:
# tcbn22ullbwp7t30p140sghvt_110b/digital/Back_End/gds/tcbn22ullbwp7t30p140sghvt_110a/tcbn22ullbwp7t30p140sghvt.gds
# spi:
# tcbn22ullbwp7t30p140sghvt_110b/digital/Back_End/spice/tcbn22ullbwp7t30p140sghvt_110a/tcbn22ullbwp7t30p140sghvt_110a.spi
# tcbn22ullbwp7t30p140sghvt_110b/digital/Back_End/lpe_spice/tcbn22ullbwp7t30p140sghvt_110a/tcbn22ullbwp7t30p140sghvt_110a_lpe_cbest_T.spi
# tcbn22ullbwp7t30p140sghvt_110b/digital/Back_End/lpe_spice/tcbn22ullbwp7t30p140sghvt_110a/tcbn22ullbwp7t30p140sghvt_110a_lpe_cworst_T.spi
# tcbn22ullbwp7t30p140sghvt_110b/digital/Back_End/lpe_spice/tcbn22ullbwp7t30p140sghvt_110a/tcbn22ullbwp7t30p140sghvt_110a_lpe_typical.spi
# milkway:
# tcbn22ullbwp7t30p140sghvt_110b/digital/Back_End/milkyway


def pick_release_dir(lib: str) -> Path:
    candidates = sorted(PREFIX.glob(f"{lib}_*"))
    if not candidates:
        raise FileNotFoundError(f"未找到工艺库目录: {lib}_*")
    return candidates[-1]


def copy_one(src: Path, dst_dir: Path) -> bool:
    if not src.exists():
        print(f"[MISS] {src}")
        return False
    dst_dir.mkdir(parents=True, exist_ok=True)
    dst = dst_dir / src.name
    shutil.copy2(src, dst)
    print(f"[COPY] {src} -> {dst}")
    return True


def copy_tree(src: Path, dst_dir: Path) -> bool:
    if not src.exists():
        print(f"[MISS] {src}")
        return False
    dst = dst_dir / src.name
    if dst.exists():
        shutil.rmtree(dst)
    shutil.copytree(src, dst)
    print(f"[COPY] {src} -> {dst}")
    return True


def collect_and_copy_for_lib(lib: str) -> Tuple[int, int]:
    found = 0
    missing = 0

    rel_110b = pick_release_dir(lib)
    rel_110a = rel_110b / "digital" / "Front_End" / "verilog"
    ver_candidates = sorted(rel_110a.glob(f"{lib}_*"))
    if not ver_candidates:
        raise FileNotFoundError(f"未找到 verilog 版本目录: {rel_110a}/{lib}_*")
    rel_ver = ver_candidates[-1].name

    paths = []  # type: List[Tuple[str, Path]]

    # lib
    if "lib" in filetype:
        for corner in CORNER:
            paths.append(
                (
                    "lib",
                    rel_110b
                    / "digital"
                    / "Front_End"
                    / "timing_power_noise"
                    / "NLDM"
                    / rel_110b.name
                    / f"{lib}{corner}.lib",
                )
            )

    # v
    if "v" in filetype:
        paths.append(
            (
                "v",
                rel_110b
                / "digital"
                / "Front_End"
                / "verilog"
                / rel_ver
                / f"{lib}.v",
            )
        )
        paths.append(
            (
                "v",
                rel_110b
                / "digital"
                / "Front_End"
                / "verilog"
                / rel_ver
                / f"{lib}_pwr.v",
            )
        )

    # aocvm
    if "aocvm" in filetype:
        for corner in CORNER:
            paths.append(
                (
                    "aocvm",
                    rel_110b
                    / "digital"
                    / "Front_End"
                    / "SBOCV"
                    / "CCS"
                    / rel_ver
                    / corner
                    / "clock_p_data_p"
                    / f"{lib}{corner}_hold_P_P_ccs.aocvm",
                )
            )

    # lef
    if "lef" in filetype:
        paths.append(
            (
                "lef",
                rel_110b
                / "digital"
                / "Back_End"
                / "lef"
                / rel_ver
                / "lef"
                / f"{lib}.lef",
            )
        )

    # gds
    if "gds" in filetype:
        paths.append(
            (
                "gds",
                rel_110b
                / "digital"
                / "Back_End"
                / "gds"
                / rel_ver
                / f"{lib}.gds",
            )
        )

    # spi
    if "spi" in filetype:
        paths.append(
            (
                "spi",
                rel_110b
                / "digital"
                / "Back_End"
                / "spice"
                / rel_ver
                / f"{rel_ver}.spi",
            )
        )
        paths.append(
            (
                "spi",
                rel_110b
                / "digital"
                / "Back_End"
                / "lpe_spice"
                / rel_ver
                / f"{rel_ver}_lpe_cbest_T.spi",
            )
        )
        paths.append(
            (
                "spi",
                rel_110b
                / "digital"
                / "Back_End"
                / "lpe_spice"
                / rel_ver
                / f"{rel_ver}_lpe_cworst_T.spi",
            )
        )
        paths.append(
            (
                "spi",
                rel_110b
                / "digital"
                / "Back_End"
                / "lpe_spice"
                / rel_ver
                / f"{rel_ver}_lpe_typical.spi",
            )
        )

    # ndm
    if "ndm" in filetype:
        paths.append(
            (
                "ndm",
                rel_110b
                / "digital"
                / "Back_End"
                / "ndm"
                / rel_ver
                / f"{lib}_physicalonly.ndm",
            )
        )

    for kind, src in paths:
        dst_root = DESTPATH / lib / kind
        if copy_one(src, dst_root):
            found += 1
        else:
            missing += 1

    # milkyway (directory copy)
    if "milkyway" in filetype:
        src_mw = rel_110b / "digital" / "Back_End" / "milkyway"
        dst_mw = DESTPATH / lib
        if copy_tree(src_mw, dst_mw):
            found += 1
        else:
            missing += 1

    return found, missing


def main() -> None:
    total_found = 0
    total_missing = 0
    for lib in stdcell_type:
        print(f"\n==== 处理 {lib} ====")
        try:
            found, missing = collect_and_copy_for_lib(lib)
            total_found += found
            total_missing += missing
            print(f"[DONE] {lib}: found={found}, missing={missing}")
        except FileNotFoundError as err:
            print(f"[ERROR] {lib}: {err}")

    print("\n==== 总结 ====")
    print(f"copy成功: {total_found}")
    print(f"未找到: {total_missing}")


if __name__ == "__main__":
    main()
