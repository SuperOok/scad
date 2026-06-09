#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Usage: export.sh <file.scad> [output.3mf] [extra openscad args...]
# Zusaetzliche Argumente (z. B. -D part="halterung") werden an openscad
# durchgereicht, sodass derselbe STL->3MF-Packer fuer einzelne Parts taugt.
scad_file="${1:?Usage: $0 <file.scad> [output.3mf] [-D key=val ...]}"
shift
# Resolve relative paths against the caller's working directory
[[ "$scad_file" = /* ]] || scad_file="$(pwd)/$scad_file"

# Optionales Ausgabeziel: das naechste Argument, sofern es keine Option ist.
output_3mf=""
if [[ $# -ge 1 && "$1" != -* ]]; then
    output_3mf="$1"
    shift
fi
output_3mf="${output_3mf:-${scad_file%.scad}.3mf}"
[[ "$output_3mf" = /* ]] || output_3mf="$(pwd)/$output_3mf"
# Verbleibende Argumente werden unveraendert an openscad uebergeben.
openscad_extra=("$@")

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Missing required command: $1" >&2
        exit 1
    fi
}

require_command openscad
require_command python3

[[ -f "$scad_file" ]] || { echo "Missing OpenSCAD source: $scad_file" >&2; exit 1; }

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

part_stl="$tmpdir/model.stl"
echo "Rendering STL..."
openscad "${openscad_extra[@]}" -o "$part_stl" "$scad_file"

echo "Writing 3MF..."
python3 - "$output_3mf" "$part_stl" <<'PY'
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile
from xml.sax.saxutils import escape
import datetime
import sys

output_3mf = Path(sys.argv[1])
part_stl = Path(sys.argv[2])


def parse_ascii_stl(path):
    vertices = []
    vertex_index = {}
    triangles = []
    current_triangle = []

    for raw_line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        line = raw_line.strip()
        if not line.startswith("vertex "):
            continue
        _, xs, ys, zs = line.split()
        vertex = (round(float(xs), 9), round(float(ys), 9), round(float(zs), 9))
        if vertex not in vertex_index:
            vertex_index[vertex] = len(vertices)
            vertices.append(vertex)
        current_triangle.append(vertex_index[vertex])
        if len(current_triangle) == 3:
            triangles.append(tuple(current_triangle))
            current_triangle = []

    if current_triangle:
        raise ValueError(f"{path}: incomplete triangle at end of STL")
    if not vertices or not triangles:
        raise ValueError(f"{path}: no mesh data found")
    return vertices, triangles


def fmt_number(value):
    if abs(value) < 0.0000000005:
        value = 0.0
    text = f"{value:.9f}".rstrip("0").rstrip(".")
    return text or "0"


def attr(value):
    return escape(str(value), {'"': "&quot;"})


vertices, triangles = parse_ascii_stl(part_stl)
model_name = output_3mf.stem

model_lines = [
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<model unit="millimeter" xml:lang="en" xmlns="http://schemas.microsoft.com/3dmanufacturing/core/2015/02">',
    f'  <metadata name="Title">{attr(model_name)}</metadata>',
    f'  <metadata name="CreationDate">{datetime.date.today().isoformat()}</metadata>',
    "  <resources>",
    f'    <object id="1" type="model" name="{attr(model_name)}">',
    "      <mesh>",
    "        <vertices>",
]

for x, y, z in vertices:
    model_lines.append(
        f'          <vertex x="{fmt_number(x)}" y="{fmt_number(y)}" z="{fmt_number(z)}"/>'
    )

model_lines.extend(["        </vertices>", "        <triangles>"])

for v1, v2, v3 in triangles:
    model_lines.append(f'          <triangle v1="{v1}" v2="{v2}" v3="{v3}"/>')

model_lines.extend([
    "        </triangles>",
    "      </mesh>",
    "    </object>",
    "  </resources>",
    "  <build>",
    '    <item objectid="1" printable="1"/>',
    "  </build>",
    "</model>",
])
model_xml = "\n".join(model_lines) + "\n"

content_types_xml = """<?xml version="1.0" encoding="UTF-8"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="model" ContentType="application/vnd.ms-package.3dmanufacturing-3dmodel+xml"/>
</Types>
"""

rels_xml = """<?xml version="1.0" encoding="UTF-8"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Target="/3D/3dmodel.model" Id="rel0" Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"/>
</Relationships>
"""

with ZipFile(output_3mf, "w", ZIP_DEFLATED) as zf:
    zf.writestr("[Content_Types].xml", content_types_xml)
    zf.writestr("_rels/.rels", rels_xml)
    zf.writestr("3D/3dmodel.model", model_xml)
PY

echo "Generated:"
ls -lh -- "$output_3mf"
