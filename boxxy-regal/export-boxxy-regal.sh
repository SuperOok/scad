#!/usr/bin/env bash
set -euo pipefail

# Exportiert den Einsatz in beiden Tiefen:
#   boxxy-regal-77.3mf – 420 x 77
#   boxxy-regal-87.3mf – 420 x 87
#
# Beide muessen im Slicer um 45 Grad gedreht werden, siehe README.
#
# Aufruf:
#   ./export-boxxy-regal.sh          # beide Tiefen
#   ./export-boxxy-regal.sh 77       # nur eine

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
cd "$script_dir"

depths=("$@")
[[ ${#depths[@]} -gt 0 ]] || depths=(77 87)

for depth in "${depths[@]}"; do
    echo ">>> Tiefe $depth"
    "$repo_root/export.sh" "$script_dir/boxxy-regal.scad" \
        "$script_dir/boxxy-regal-$depth.3mf" -D "shelf_y=$depth"
done
