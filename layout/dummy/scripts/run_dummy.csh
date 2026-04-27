#!/bin/csh -f
#####################################################################################
# Description:  Virtuoso Startup Makefile
# Author:     	Mingxuan Li <mingxuanli_siris@163.com> [Peking University]
# Acknowledge:  Meng Wu [Peking University]
#####################################################################################

set in_file = $argv[1]
set in_top = $argv[2]
set out_file = $argv[3]
set out_top = $argv[4]

cd dummy/build

# generate dummy metal & dummy odpo gds
calibre -hyper -turbo -hier -drc ../scripts/Dummy_FEOL_Calibre_22nm_001.13a | tee ../logs/FEOL_DODPO.log
calibre -hyper -turbo -hier -drc ../scripts/Dummy_BEOL_Calibre_22nm_001.13a | tee ../logs/BEOL_DM.log

# merge gds
calibredrv -a layout filemerge -in ../../${in_file} -in DODPO.gds -in DM.gds -rename -createtop $out_top -out ../../${out_file}

# b calibredrv -a layout filemerge -in file1.gds -in file2.gds -rename -createtop new_top -out out.gds
# b calibredrv -shell
# layout filemerge -in A.gds -indir gdsdir/ -out TOP.gds

