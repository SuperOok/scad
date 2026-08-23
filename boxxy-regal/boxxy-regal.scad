// =============================================================================
// boxxy-regal – Passlehre (Probedruck) fuer den Tuerregal-Einsatz
// =============================================================================
// Zielobjekt ist ein rechteckiges Tuerregal:
//   X = 420 mm (Laenge),  Y = 77 mm (Tiefe)
//   Die beiden VORDEREN Ecken (+Y) sind verrundet, Nennradius ~30 mm.
//   Die beiden hinteren Ecken (an der Tuer, y = 0) sind scharfkantig.
//
// Dieses Modell ist noch NICHT der Einsatz, sondern eine Lehre, mit der die
// Masse am Objekt geprueft werden. Rahmen und Segmente zusammen ~55 g, die
// Staebchen noch einmal ~75 g – wer sparen will, kuerzt stick_deltas.
//
//   frame   – umlaufender Rahmen aus einem rim_w breiten Streifen, mit
//             niedriger Aussenwand (wall_h) und Querrippen gegen Verwinden.
//             Die Aussenkante ist unten umlaufend mit bottom_r verrundet.
//             Die beiden vorderen Ecken fehlen; dort werden Segmente gesteckt.
//   corners – die Ecksegmente in mehreren Radien (corner_radii), je links und
//             rechts, mit aufgepraegter Radius-Zahl.
//   sticks-x– Teststaebchen fuer die Laenge, Nennmass shelf_x + stick_deltas
//   sticks-y– dieselben fuer die Tiefe, Nennmass shelf_y + stick_deltas
//   assembly– nur Vorschau (Rahmen + Segmente im Nennradius), nicht drucken.
//
// Damit laesst sich pruefen:
//   * Laenge 420 und Tiefe 77 zusammen              -> Rahmen
//   * Laenge und Tiefe einzeln, mit Zahlenwert      -> Staebchen
//   * der tatsaechliche Eckradius                   -> Segment tauschen
//   * ob die Hoehe irgendwo anstoesst               -> umlaufende Wand
//
// Rahmen und Staebchen ergaenzen sich: der Rahmen sagt "passt / passt nicht",
// die Staebchen sagen, um wie viel – und sie trennen Laenge und Tiefe, die im
// Rahmen zwangslaeufig gleichzeitig anliegen.
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
// UNTERE KANTE (bottom_r)
// -----------------------------------------------------------------------------
//   Die Aussenkante ist unten umlaufend mit bottom_r = 5 verrundet, damit die
//   Lehre ueber eine Hohlkehle am Uebergang Boden/Seitenwand des Regals kommt.
//   Oberhalb von z = bottom_r ist die Kontur exakt shelf_x x shelf_y, gemessen
//   wird also nur dort.
//
//   ACHTUNG, das ist ein Ueberhang: bei z = 0 liegt die Kontur 5 mm weiter
//   innen als oben, und die Flanke laeuft unten waagerecht aus. Von z = 0 auf
//   z = 0,04 wandert sie schon 0,65 mm nach aussen – die ersten rund 1 mm
//   drucken ohne Stuetze nicht sauber. Drei Auswege:
//     bottom_steps = 1  -> gerade 45-Grad-Fase statt Bogen, stuetzfrei
//     bottom_r kleiner  -> weniger Ueberhang
//     mit Stuetzen      -> saubere Form, aber Stuetzspuren genau auf der
//                          Flaeche, mit der eingepasst wird
//   Nebenwirkung der Verrundung: zwischen z = 2 und z = 3 bleibt von der
//   1,6 mm dicken Wand nur 0,6 .. 1,2 mm stehen. Sie sitzt dort auf der
//   vollen Grundplatte und druckt als eine Perimeterbahn – fuer eine Lehre
//   unkritisch, aber nicht belastbar.
//
// -----------------------------------------------------------------------------
// DRUCKEN
// -----------------------------------------------------------------------------
//   Alles flach auf dem Bett; bis auf die Verrundung unten (siehe oben) gibt
//   es keine Ueberhaenge.
//   Der Rahmen ist 420 x 77 gross und passt auf ein 360er Bett nur DIAGONAL:
//   um 45 Grad gedreht ist die Bounding-Box (420 + 77) / sqrt(2) = 351,4 mm.
//   Das ist knapp – ohne Brim, und den Rand im Slicer kontrollieren.
//   Wenn das nicht reicht: end_caps = true. Dann laufen die Trennebenen ueber
//   die volle Tiefe durch, aus den Ecksegmenten werden Endkappen und der
//   Rahmen schrumpft auf 320 x 77 (axial druckbar).
//
//   sticks-x hat dasselbe Problem in klein: die Platte ist 422 x 56, diagonal
//   also 338 mm – passt mit Rand. Der Packer in export.sh schreibt allerdings
//   EIN Objekt mit mehreren Volumina; zum freien Anordnen im Slicer erst
//   "In Objekte aufteilen" / "Split to objects".
// =============================================================================

// "frame" | "corners" | "sticks-x" | "sticks-y" | "assembly"
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

/* [Untere Kante] */
bottom_r     = 5;   // Radius der umlaufenden Verrundung unten aussen
bottom_steps = 12;  // Segmente des Bogens; 1 ergibt eine 45-Grad-Fase

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

/* [Teststaebchen] */
stick_deltas = [-6, -4, -2, 0, 2];  // Abweichungen vom Nennmass je Staebchen
stick_w      = 8;   // Breite (liegend: Y)
stick_t      = 2.5; // Dicke des Stegs zwischen den Endkloetzen
stick_end_l  = 8;   // Laenge eines Endklotzes
stick_end_h  = 12;  // Hoehe eines Endklotzes, = wall_h: gleiche Messhoehe

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

assert(bottom_r < rim_w,  "bottom_r muss kleiner als rim_w sein");
assert(bottom_r <= wall_h, "bottom_r darf die Wand nicht ueberragen");
assert(bottom_r < min(corner_radii), "bottom_r muss kleiner als der kleinste Eckradius sein");
assert(stick_end_h > bottom_r, "stick_end_h muss ueber der Verrundung liegen");
assert(stick_end_l > bottom_r, "stick_end_l muss die Verrundung aufnehmen koennen");

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
// Die untere Aussenkante ist hier noch scharf, die macht outer_envelope().
module gauge_body(r) {
    linear_extrude(base_t) ring_2d(r, rim_w);
    linear_extrude(wall_h) ring_2d(r, wall_t);
}

// Huellkoerper: volle Grundflaeche, unten aussen umlaufend mit bottom_r
// verrundet. Alles, was zur Lehre gehoert, wird damit verschnitten – so
// bekommen Rahmen, Rippen und Ecksegmente denselben Rand, ohne dass die
// Trennebenen der Steckverbindung angetastet werden.
//
// Bogen in der Ebene (u = Abstand nach aussen, z), Mittelpunkt (-bottom_r,
// bottom_r), Radius bottom_r:  u(b) = R (cos b - 1),  z(b) = R (1 + sin b),
// b von -90 (unten, R nach innen) bis 0 (Endkontur erreicht).
// Zwischen zwei Bogenpunkten wird gehullt, die Flanke ist also ein gerader
// Kegelstumpf – bei bottom_steps = 1 genau eine 45-Grad-Fase.
module outer_envelope(r) {
    for (i = [0 : bottom_steps - 1]) {
        b0 = -90 + 90 * i / bottom_steps;
        b1 = -90 + 90 * (i + 1) / bottom_steps;
        hull() {
            translate([0, 0, bottom_r * (1 + sin(b0))])
                linear_extrude(0.01)
                    offset(delta = bottom_r * (cos(b0) - 1)) outline_2d(r);
            translate([0, 0, bottom_r * (1 + sin(b1))])
                linear_extrude(0.01)
                    offset(delta = bottom_r * (cos(b1) - 1)) outline_2d(r);
        }
    }
    translate([0, 0, bottom_r])
        linear_extrude(wall_h - bottom_r + 1) outline_2d(r);
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
    intersection() {
        // corner_r ist hier beliebig: die Bogenstuecke liegen komplett in den
        // herausgetrennten Ecken.
        outer_envelope(corner_r);
        difference() {
            union() {
                gauge_body(corner_r);
                ribs();
            }
            corner_box(1);
            corner_box(-1);
            at_joints(1)  slot_solid();
            at_joints(-1) slot_solid();
        }
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
        outer_envelope(r);
        union() {
            intersection() {
                gauge_body(r);
                corner_box(s);
            }
            at_joints(s) tongue_solid();
            corner_label(r, s);
        }
    }
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
// Teststaebchen
// -----------------------------------------------------------------------------
// Steg mit einem Klotz an jedem Ende. Gemessen wird mit den beiden aeusseren
// Stirnflaechen; die Kloetze sind stick_end_h = wall_h hoch und unten aussen
// mit demselben bottom_r freigestellt wie der Rahmen. Beide Lehren tasten die
// Wand damit im selben Hoehenband an (ab z = bottom_r) und nicht in einer
// Hohlkehle am Boden.

// Der wegzunehmende Bereich ausserhalb des Viertelkreises, Ecke bei (0, 0),
// Material links davon und darueber.
module round_cut_2d() {
    difference() {
        translate([-bottom_r, -0.1]) square([bottom_r + 0.1, bottom_r + 0.1]);
        translate([-bottom_r, bottom_r]) circle(r = bottom_r);
    }
}

// Seitenansicht des Staebchens in der Ebene (Laenge, Hoehe).
module stick_profile(len) {
    hl = len / 2;
    difference() {
        union() {
            translate([-hl, 0])               square([len, stick_t]);
            translate([-hl, 0])               square([stick_end_l, stick_end_h]);
            translate([hl - stick_end_l, 0])  square([stick_end_l, stick_end_h]);
        }
        for (s = [-1, 1])
            translate([s * hl, 0]) scale([s, 1]) round_cut_2d();
    }
}

// Ein Staebchen der Gesamtlaenge len, liegend, mittig auf x = 0.
module stick(len) {
    translate([0, stick_w / 2, 0])
        rotate([90, 0, 0])
            linear_extrude(stick_w) stick_profile(len);
    translate([0, 0, stick_t])
        linear_extrude(label_h)
            text(str(len), size = label_size, halign = "center", valign = "center");
}

// Alle Varianten zu einem Nennmass, nebeneinander aufgereiht.
module stick_set(nominal) {
    pitch = stick_w + 4;
    for (i = [0 : len(stick_deltas) - 1])
        translate([0, i * pitch, 0]) stick(nominal + stick_deltas[i]);
}

// -----------------------------------------------------------------------------
// Ausgabe
// -----------------------------------------------------------------------------

module assembly() {
    frame_part();
    corner_piece(corner_r,  1);
    corner_piece(corner_r, -1);
}

if      (part == "frame")    frame_part();
else if (part == "corners")  corner_set();
else if (part == "sticks-x") stick_set(shelf_x);
else if (part == "sticks-y") stick_set(shelf_y);
else                         assembly();
