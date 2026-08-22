#!/usr/bin/env bash
set -euo pipefail

# Exportiert die beiden druckbaren Teile der Passlehre:
#   boxxy-regal-frame.3mf   – Rahmen 420 x 77 (im Slicer um 45 Grad drehen!)
#   boxxy-regal-corners.3mf – die Ecksegmente in allen Radien, links + rechts
#
# Aufruf:
#   ./export-boxxy-regal.sh              # beide Teile
#   ./export-boxxy-regal.sh frame        # nur den Rahmen
#   ./export-boxxy-regal.sh corners      # nur die Segmente

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
cd "$script_dir"

parts=("$@")
[[ ${#parts[@]} -gt 0 ]] || parts=(frame corners)

for part in "${parts[@]}"; do
    echo ">>> $part"
    "$repo_root/export.sh" "$script_dir/boxxy-regal.scad" \
        "$script_dir/boxxy-regal-$part.3mf" -D "part=\"$part\""
done
