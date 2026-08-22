// =============================================================================
// boxxy-regal – Passlehre (Probedruck) fuer den Tuerregal-Einsatz
// =============================================================================
// Zielobjekt ist ein rechteckiges Tuerregal:
//   X = 420 mm (Laenge),  Y = 77 mm (Tiefe)
//   Die beiden VORDEREN Ecken (+Y) sind verrundet, Nennradius ~30 mm.
//   Die beiden hinteren Ecken (an der Tuer, y = 0) sind scharfkantig.
//
// Dieses Modell ist noch NICHT der Einsatz, sondern eine materialarme Lehre
// (~50 g), mit der die Masse am Objekt geprueft werden:
//
//   frame   – umlaufender Rahmen aus einem rim_w breiten Streifen, mit
//             niedriger Aussenwand (wall_h) und Querrippen gegen Verwinden.
//             Die beiden vorderen Ecken fehlen; dort werden Segmente gesteckt.
//   corners – die Ecksegmente in mehreren Radien (corner_radii), je links und
//             rechts, mit aufgepraegter Radius-Zahl.
//   assembly– nur Vorschau (Rahmen + Segmente im Nennradius), nicht drucken.
//
// Damit laesst sich in einem Durchgang pruefen:
//   * Laenge 420 und Tiefe 77                       -> Rahmen
//   * der tatsaechliche Eckradius                   -> Segment tauschen
//   * ob die Hoehe irgendwo anstoesst               -> umlaufende Wand
//
// -----------------------------------------------------------------------------
// KOORDINATEN
// -----------------------------------------------------------------------------
//   X = Laengsrichtung, in der Mitte zentriert (-210 .. +210)
//   Y = Tiefe,  y = 0 hinten (Tuerseite),  y = shelf_y vorne (verrundet)
//   Z = Hoehe,  Boden bei z = 0
//
// -----------------------------------------------------------------------------
// STECKVERBINDUNG
// -----------------------------------------------------------------------------
//   Die Segmente sitzen mit einer Feder (tongue) in der Ebene der Grundplatte
//   in einem Schlitz des Rahmens. Bewusst KEIN Stufenfalz: der waere auf einer
//   der beiden Seiten eine 12 mm lange Bruecke in der Luft und nicht stuetzfrei
//   druckbar. Die Feder liegt in der Plattenebene, damit haben beide Teile nur
//   senkrechte Flaechen.
//   Folge: die Verbindung ist in X/Y und gegen Verdrehen fixiert, aber nicht
//   gegen Abheben. Der Presssitz (joint_gap) haelt normalerweise; sonst einen
//   Streifen Tape ueber die Fuge.
//
// -----------------------------------------------------------------------------
// DRUCKEN
// -----------------------------------------------------------------------------
//   Alles flach auf dem Bett, keine Stuetzen, kein Ueberhang.
//   Der Rahmen ist 420 x 77 gross und passt auf ein 360er Bett nur DIAGONAL:
//   um 45 Grad gedreht ist die Bounding-Box (420 + 77) / sqrt(2) = 351,4 mm.
//   Das ist knapp – ohne Brim, und den Rand im Slicer kontrollieren.
//   Wenn das nicht reicht: end_caps = true. Dann laufen die Trennebenen ueber
//   die volle Tiefe durch, aus den Ecksegmenten werden Endkappen und der
//   Rahmen schrumpft auf 320 x 77 (axial druckbar).
// =============================================================================

// Welches Teil gerendert wird: "frame" | "corners" | "assembly"
part = "assembly";

/* [Regalmasse] */
shelf_x = 420;      // Laenge in X
shelf_y = 77;       // Tiefe in Y
corner_r = 30;      // Nennradius der vorderen Ecken (nur Vorschau/Rahmen)

/* [Lehre] */
rim_w   = 10;       // Breite des umlaufenden Streifens
base_t  = 2.0;      // Dicke der Grundplatte
wall_t  = 1.6;      // Dicke der Aussenwand
wall_h  = 12;       // Hoehe der Aussenwand (ab z = 0)
fit_gap = 0;        // Untermass je Seite, 0 = Nennmass messen

/* [Ecksegmente] */
corner_cut   = 50;          // Kantenlaenge des herausgetrennten Eckquadrats
corner_radii = [25, 30, 35];// Varianten, die "corners" ausgibt
end_caps     = false;       // true: Trennung ueber die volle Tiefe (Endkappen)

/* [Steckverbindung] */
tongue_w  = 4.5;    // Breite der Feder
tongue_l  = 12;     // Einstecktiefe
joint_gap = 0.15;   // Spiel je Seite im Schlitz (Presssitz)

/* [Versteifung] */
rib_count = 3;      // Querrippen zwischen den beiden Steckstellen
rib_w     = 8;

/* [Beschriftung] */
label_size = 5;
label_h    = 0.6;

$fa = 1;
$fs = 0.5;

// -----------------------------------------------------------------------------
// Abgeleitete Groessen
// -----------------------------------------------------------------------------
gx = shelf_x - 2 * fit_gap;             // effektive Laenge
gy = shelf_y - 2 * fit_gap;             // effektive Tiefe
cut_x = gx / 2 - corner_cut;            // Trennebene senkrecht zu X
cut_y = gy - corner_cut;                // Trennebene senkrecht zu Y (nur L-Schnitt)
band_c = wall_t + (rim_w - wall_t) / 2; // Mitte des Streifens ohne Wand, von aussen
rib_x = cut_x - tongue_l - 3 - rib_w / 2;   // Rippe direkt hinter der Steckstelle

// Fussabdruck eines Segments (fuer die flache Anordnung)
seg_y0 = end_caps ? 0 : cut_y - tongue_l;
seg_w  = corner_cut + tongue_l;
seg_h  = gy - seg_y0;

// -----------------------------------------------------------------------------
// 2D-Grundformen
// -----------------------------------------------------------------------------

// Aussenkontur: vorne (+Y) mit Radius r verrundet, hinten scharfkantig.
module outline_2d(r) {
    hx = gx / 2;
    union() {
        translate([-hx, 0])          square([gx, gy - r]);
        translate([-hx + r, 0])      square([gx - 2 * r, gy]);
        translate([-hx + r, gy - r]) circle(r = r);
        translate([ hx - r, gy - r]) circle(r = r);
    }
}

// Umlaufender Streifen der Breite w entlang der Aussenkontur.
module ring_2d(r, w) {
    difference() {
        outline_2d(r);
        offset(delta = -w) outline_2d(r);
    }
}

// Vollstaendige Lehre (noch ungetrennt): Grundplatte + Aussenwand.
module gauge_solid(r) {
    linear_extrude(base_t) ring_2d(r, rim_w);
    linear_extrude(wall_h) ring_2d(r, wall_t);
}

// -----------------------------------------------------------------------------
// Trennung und Steckverbindung
// -----------------------------------------------------------------------------

// Der Bereich, der zum Ecksegment gehoert. s = +1 rechts, -1 links.
module corner_box(s) {
    y0 = end_caps ? -1 : cut_y;
    translate([s > 0 ? cut_x : -gx / 2 - 1, y0, -1])
        cube([corner_cut + 1, gy - y0 + 1, wall_h + 2]);
}

// Lage der Fugen fuer die rechte Seite: [x, y, Drehung].
// Die lokale +X-Richtung zeigt jeweils vom Segment in den Rahmen hinein.
function joints_right() = end_caps
    ? [[cut_x, gy - band_c, 180], [cut_x, band_c, 180]]
    : [[cut_x, gy - band_c, 180], [gx / 2 - band_c, cut_y, -90]];

// Setzt children() an jede Fuge der Seite s.
module at_joints(s) {
    for (j = joints_right())
        translate([s * j[0], j[1], 0])
            rotate([0, 0, s > 0 ? j[2] : 180 - j[2]])
                children();
}

module tongue_solid() {
    translate([0, -tongue_w / 2, 0]) cube([tongue_l, tongue_w, base_t]);
}

module slot_solid() {
    translate([-1, -(tongue_w + 2 * joint_gap) / 2, -0.5])
        cube([tongue_l + joint_gap + 1, tongue_w + 2 * joint_gap, base_t + 1]);
}

// -----------------------------------------------------------------------------
// Rahmen
// -----------------------------------------------------------------------------

module ribs() {
    // je eine Rippe dicht hinter den beiden Steckstellen
    for (s = [-1, 1])
        translate([s * rib_x - rib_w / 2, 0, 0]) cube([rib_w, gy, base_t]);
    // gleichmaessig verteilte Rippen dazwischen
    for (i = [1 : rib_count])
        translate([-rib_x + 2 * rib_x * i / (rib_count + 1) - rib_w / 2, 0, 0])
            cube([rib_w, gy, base_t]);
}

module frame_part() {
    difference() {
        union() {
            gauge_solid(corner_r);
            ribs();
        }
        corner_box(1);
        corner_box(-1);
        at_joints(1)  slot_solid();
        at_joints(-1) slot_solid();
    }
}

// -----------------------------------------------------------------------------
// Ecksegmente
// -----------------------------------------------------------------------------

// Aufgepraegte Radius-Zahl auf dem geraden Stueck des vorderen Streifens.
module corner_label(r, s) {
    translate([s * (cut_x + gx / 2 - r) / 2, gy - band_c, base_t])
        linear_extrude(label_h)
            text(str(r), size = label_size, halign = "center", valign = "center");
}

module corner_piece(r, s) {
    intersection() {
        gauge_solid(r);
        corner_box(s);
    }
    at_joints(s) tongue_solid();
    corner_label(r, s);
}

// Ein Segment in den ersten Quadranten geschoben, Ecke auf (0, 0).
module corner_flat(r, s) {
    translate([s > 0 ? -(cut_x - tongue_l) : gx / 2, -seg_y0, 0])
        corner_piece(r, s);
}

// Alle Varianten nebeneinander: eine Reihe rechte, eine Reihe linke Segmente.
module corner_set() {
    px = seg_w + 8;
    py = seg_h + 8;
    for (i = [0 : len(corner_radii) - 1])
        for (k = [0 : 1])
            translate([i * px, k * py, 0])
                corner_flat(corner_radii[i], k == 0 ? 1 : -1);
}

// -----------------------------------------------------------------------------
// Ausgabe
// -----------------------------------------------------------------------------

module assembly() {
    frame_part();
    corner_piece(corner_r,  1);
    corner_piece(corner_r, -1);
}

if      (part == "frame")   frame_part();
else if (part == "corners") corner_set();
else                        assembly();
