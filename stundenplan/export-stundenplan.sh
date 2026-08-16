#!/usr/bin/env bash
set -euo pipefail

# Exportiert einen Stundenplan als Zweifarb-3mf.
#
# Das Schild besteht aus zwei Teilen, die sich bei z = table_depth beruehren:
#   plate  – Grundplatte                              -> Farbe 1
#   labels – Wochentage, Uhrzeiten, Faecher-Kaestchen -> Farbe 2
# Die Fachnamen sind Aussparungen in den Kaestchen und scheinen deshalb in
# der Farbe der Grundplatte durch.
#
# Aufruf:
#   ./export-stundenplan.sh                 # Klasse 7d -> stundenplan-7d.3mf
#   ./export-stundenplan.sh klasse_6d       # -> stundenplan-6d.3mf
#   ./export-stundenplan.sh klasse_6d out.3mf
#
# Achtung: der labels-Teil braucht ein paar Minuten (viel Text-CSG).

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir"

scad="Stundenplan.scad"
klasse="${1:-klasse_7d}"
output_3mf="${2:-stundenplan-${klasse#klasse_}.3mf}"

# Vorschaufarben im 3mf. Die echte Farbe waehlt man im Slicer je Objekt.
plate_color="#F0F0F0FF"
label_color="#1E1E1EFF"

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Missing required command: $1" >&2
        exit 1
    fi
}

require_command openscad
require_command python3

[[ -f "$scad" ]] || { echo "Missing OpenSCAD source: $scad" >&2; exit 1; }

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

for part in plate labels; do
    echo ">>> $part"
    openscad -D "part=\"$part\"" -D "klasse=$klasse" \
        -o "$tmpdir/$part.stl" "$scad"
done

python3 pack-2color-3mf.py "$output_3mf" \
    "Grundplatte=$plate_color=$tmpdir/plate.stl" \
    "Beschriftung=$label_color=$tmpdir/labels.stl"
