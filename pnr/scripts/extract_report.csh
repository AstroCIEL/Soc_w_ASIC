#!/bin/csh
#####################################################################################
# Description:  Extracting Timing Report Script
# Author:       Mingxuan Li <mingxuanli_siris@163.com> [Peking University]
#####################################################################################
if ($#argv != 1) then
    echo "Usage: extract_report.csh <directory>"
    exit 1
endif

set directory = $argv[1]

foreach file (`find "$directory" -type f -name "*.gz"`)
    echo "Extracting $file..."
    gzip -df "$file"
end

echo "All .gz files have been extracted recursively."

