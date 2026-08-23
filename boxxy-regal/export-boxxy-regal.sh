#!/usr/bin/env bash
set -euo pipefail

# Exportiert alle Einsaetze:
#   boxxy-regal-77.3mf         – Wanne 420 x 77
#   boxxy-regal-87.3mf         – Wanne 420 x 87
#   boxxy-regal-gridfinity.3mf – Gridfinity-Baseplate 9 x 2 fuer den 87er
#
# Alle muessen im Slicer um 45 Grad gedreht werden, siehe README.
#
# Aufruf:
#   ./export-boxxy-regal.sh              # alles
#   ./export-boxxy-regal.sh 77           # nur eine Wanne
#   ./export-boxxy-regal.sh gridfinity   # nur die Baseplate

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
cd "$script_dir"

targets=("$@")
[[ ${#targets[@]} -gt 0 ]] || targets=(77 87 gridfinity)

for target in "${targets[@]}"; do
    echo ">>> $target"
    if [[ "$target" == "gridfinity" ]]; then
        "$repo_root/export.sh" "$script_dir/boxxy-regal-gridfinity.scad" \
            "$script_dir/boxxy-regal-gridfinity.3mf"
    else
        "$repo_root/export.sh" "$script_dir/boxxy-regal.scad" \
            "$script_dir/boxxy-regal-$target.3mf" -D "shelf_y=$target"
    fi
done
