#!/usr/bin/env bash
set -euo pipefail

# Exportiert alle Druckteile der Lenkerhalterung als einzelne .3mf-Dateien.
# Nutzt den gemeinsamen STL->3MF-Packer in ../export.sh und waehlt das jeweilige
# Teil ueber -D part="...".

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir"

scad="lenkerhalterung.scad"
export_sh="$script_dir/../export.sh"

parts=(halterung clamp_strap mount_plate back_plate)

for p in "${parts[@]}"; do
    out="lenkerhalterung-${p//_/-}.3mf"
    echo ">>> $p -> $out"
    "$export_sh" "$scad" "$out" -D "part=\"$p\""
done

echo "Fertig:"
ls -lh lenkerhalterung-*.3mf
