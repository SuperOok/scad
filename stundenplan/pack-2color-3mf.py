#!/usr/bin/env python3
"""Packt mehrere STL-Teile als ein 3mf mit Farbzuordnung je Teil.

Jedes Teil wird ein eigenes <object> mit einem Material aus <basematerials>.
PrusaSlicer laedt das als mehrere Objekte an derselben Position; dort laesst
sich je Objekt der Extruder waehlen. Die displaycolor-Werte sind nur eine
Vorschau, die tatsaechliche Farbe kommt aus dem Slicer.

Aufbau bewusst wie in ../export.sh bzw. dem 5-Farben-Export in
~/ws/scad-volt/schnalle, damit die 3mf im Repo gleich aussehen.

Aufruf:
    pack-2color-3mf.py <output.3mf> <name>=<farbe>=<teil.stl> ...

Beispiel:
    pack-2color-3mf.py plan.3mf \\
        "Grundplatte=#F0F0F0FF=plate.stl" \\
        "Beschriftung=#1E1E1EFF=labels.stl"
"""

import datetime
import sys
from pathlib import Path
from xml.sax.saxutils import escape
from zipfile import ZIP_DEFLATED, ZipFile


def parse_ascii_stl(path):
    """Liest ein ASCII-STL und dedupliziert die Vertices."""
    raw = path.read_bytes()
    if raw.lstrip()[:5] != b"solid" or b"facet" not in raw[:512]:
        raise SystemExit(
            f"{path}: kein ASCII-STL. OpenSCAD ab 2023 schreibt binaer; "
            f"dieser Packer (wie der in ../export.sh) kann nur ASCII lesen."
        )

    vertices = []
    vertex_index = {}
    triangles = []
    current = []

    for raw_line in raw.decode("utf-8", "replace").splitlines():
        line = raw_line.strip()
        if not line.startswith("vertex "):
            continue
        _, xs, ys, zs = line.split()
        vertex = (round(float(xs), 9), round(float(ys), 9), round(float(zs), 9))
        if vertex not in vertex_index:
            vertex_index[vertex] = len(vertices)
            vertices.append(vertex)
        current.append(vertex_index[vertex])
        if len(current) == 3:
            triangles.append(tuple(current))
            current = []

    if current:
        raise SystemExit(f"{path}: unvollstaendiges Dreieck am Ende des STL")
    if not vertices or not triangles:
        raise SystemExit(f"{path}: keine Mesh-Daten gefunden")
    return vertices, triangles


def fmt_number(value):
    if abs(value) < 0.0000000005:
        value = 0.0
    text = f"{value:.9f}".rstrip("0").rstrip(".")
    return text or "0"


def attr(value):
    return escape(str(value), {'"': "&quot;"})


def build_model_xml(title, parts):
    lines = [
        '<?xml version="1.0" encoding="UTF-8"?>',
        '<model unit="millimeter" xml:lang="de-DE" '
        'xmlns="http://schemas.microsoft.com/3dmanufacturing/core/2015/02">',
        f'  <metadata name="Title">{attr(title)}</metadata>',
        f'  <metadata name="CreationDate">{datetime.date.today().isoformat()}</metadata>',
        "  <resources>",
        '    <basematerials id="1">',
    ]
    for part in parts:
        lines.append(f'      <base name="{attr(part["name"])}" '
                     f'displaycolor="{attr(part["color"])}"/>')
    lines.append("    </basematerials>")

    for index, part in enumerate(parts):
        vertices, triangles = parse_ascii_stl(part["stl"])
        part["triangles"] = len(triangles)
        part["bbox"] = [
            (min(v[i] for v in vertices), max(v[i] for v in vertices))
            for i in range(3)
        ]
        lines.extend([
            f'    <object id="{part["id"]}" type="model" '
            f'name="{attr(part["name"])}" partnumber="{attr(part["partnumber"])}">',
            "      <mesh>",
            "        <vertices>",
        ])
        for x, y, z in vertices:
            lines.append(f'          <vertex x="{fmt_number(x)}" '
                         f'y="{fmt_number(y)}" z="{fmt_number(z)}"/>')
        lines.extend(["        </vertices>", "        <triangles>"])
        for v1, v2, v3 in triangles:
            lines.append(f'          <triangle v1="{v1}" v2="{v2}" v3="{v3}" '
                         f'pid="1" p1="{index}" p2="{index}" p3="{index}"/>')
        lines.extend(["        </triangles>", "      </mesh>", "    </object>"])

    lines.extend(["  </resources>", "  <build>"])
    for part in parts:
        lines.append(f'    <item objectid="{part["id"]}" printable="1" '
                     f'partnumber="{attr(part["partnumber"])}"/>')
    lines.extend(["  </build>", "</model>"])
    return "\n".join(lines) + "\n"


CONTENT_TYPES = """<?xml version="1.0" encoding="UTF-8"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="model" ContentType="application/vnd.ms-package.3dmanufacturing-3dmodel+xml"/>
</Types>
"""

RELS = """<?xml version="1.0" encoding="UTF-8"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Target="/3D/3dmodel.model" Id="rel0" Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"/>
</Relationships>
"""


def main(argv):
    if len(argv) < 3:
        raise SystemExit(__doc__)

    output = Path(argv[1])
    parts = []
    for index, spec in enumerate(argv[2:]):
        try:
            name, color, stl = spec.split("=", 2)
        except ValueError:
            raise SystemExit(f"Ungueltiges Teil: {spec!r}, "
                             f"erwartet <name>=<farbe>=<teil.stl>")
        parts.append({
            "id": 2 + index,
            "name": name,
            "color": color,
            "stl": Path(stl),
            "partnumber": f"{output.stem}-{name.lower()}",
        })

    model_xml = build_model_xml(output.stem, parts)
    with ZipFile(output, "w", ZIP_DEFLATED) as zf:
        zf.writestr("[Content_Types].xml", CONTENT_TYPES)
        zf.writestr("_rels/.rels", RELS)
        zf.writestr("3D/3dmodel.model", model_xml)

    print(f"Geschrieben: {output}  ({output.stat().st_size / 1024:.1f} kB)")
    for index, part in enumerate(parts):
        box = "  ".join(f"{n}: {lo:.2f}..{hi:.2f}"
                        for n, (lo, hi) in zip("XYZ", part["bbox"]))
        print(f"  Material {index + 1} {part['name']:<14} "
              f"{part['triangles']:>6} Dreiecke   {box}")


if __name__ == "__main__":
    main(sys.argv)
