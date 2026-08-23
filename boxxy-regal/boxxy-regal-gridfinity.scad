// =============================================================================
// boxxy-regal-gridfinity – Gridfinity-Baseplate fuer den 87er Regalboden
// =============================================================================
// Ersetzt in einem Regalboden die Wanne aus boxxy-regal.scad durch eine
// Baseplate, in die handelsuebliche Gridfinity-Boxen einrasten. Die Boxen
// selbst kommen aus einem Generator – hier entsteht nur die Platte.
//
// Aussenform identisch zur Wanne (boxxy-regal-shell.scad): 420 x 87, vorne
// R30, unten aussen R5 freigestellt fuer die Hohlkehle des Regals.
//
// -----------------------------------------------------------------------------
// WARUM 9 x 2 UND NICHT 10 x 2
// -----------------------------------------------------------------------------
//   420 = 10 * 42 geht exakt auf, 87 nimmt zwei Reihen (84 mm) mit 3 mm Rest.
//   Rechnerisch waeren das 20 Zellen – die beiden vorderen Eckzellen fallen
//   aber der R30-Verrundung zum Opfer. Sie beginnt bei y = 87 - 30 = 57; auf
//   der Rasterkante y = 84 reicht das Regal nur bis
//       x = 180 + sqrt(30^2 - 27^2) = 193,1 mm
//   Die naechste Rasterkante darunter liegt bei 168, die vordere Reihe kann
//   also nur 8 Spalten breit sein.
//
//   Damit bleiben zwei gleichwertige Layouts mit je 18 Zellen: 10 hinten /
//   8 vorne (volle Laenge, aber die aeusseren Sockel enden buendig mit der
//   Plattenkante) oder 9 x 2 mittig. Gewaehlt ist 9 x 2: sauberes Rechteck,
//   umlaufender Rand, groesste moegliche Box 2 x 9. Die uebrigen 2 x 21 mm an
//   den Enden sind als flache Mulden nutzbar (end_well).
//
// -----------------------------------------------------------------------------
// GRIDFINITY-MASSE (aus der Spezifikation, nicht anfassen)
// -----------------------------------------------------------------------------
//   Raster            42 x 42 mm
//   Sockelprofil      von unten 0,8 mm 45 Grad, 1,8 mm senkrecht,
//                     2,15 mm 45 Grad -> 4,75 mm hoch, 2,95 mm Ueberhang
//   Eckradius         4,0 mm an der Baseplate (die Box hat 3,75 bei 41,5 mm)
//   Spiel             0,25 mm je Seite, ergibt sich aus 42 - 41,5
//   Magnetloch        6 mm Magnet -> 6,5 mm Bohrung, 2 mm hoch -> 2,4 mm tief
//   Magnetposition    13 mm von der Zellmitte in beiden Achsen (26 mm Abstand)
//
//   Hergeleitet: Sockel-Unterseite 41,5 - 2*2,95 = 35,6 mm, das Loch liegt
//   4,8 mm von deren Kante -> 17,8 - 4,8 = 13,0 mm ab Zellmitte.
//
// -----------------------------------------------------------------------------
// MAGNETE
// -----------------------------------------------------------------------------
//   Die Taschen oeffnen nach OBEN in den Sockelboden. Magnet buendig
//   einkleben, dann liegt er direkt an dem der Box an – das ist die
//   Standardanordnung und die staerkste.
//   Voreingestellt sind 4 Loecher je Zelle (72 Stueck). Leere Loecher schaden
//   nicht, fehlende schon: beim Einkleben entscheidest du, ob 2 oder 4 je
//   Zelle bestueckt werden. magnets_per_cell = 2 laesst nur die Diagonale.
//
// -----------------------------------------------------------------------------
// DRUCKEN
// -----------------------------------------------------------------------------
//   Wie die Wanne: flach, Boden unten, um 45 Grad gedreht (Bounding-Box
//   346,1 mm, 7,0 mm Rand je Seite auf einem 360er Bett), 8 mm Brim.
//   Der einzige Ueberhang ist die Verrundung unten – siehe README.
// =============================================================================

/* [Regalmasse] */
shelf_x  = 420;     // Laenge in X
shelf_y  = 87;      // Tiefe in Y – nur die 87er Variante ist sinnvoll
corner_r = 30;      // Radius der beiden vorderen Ecken
fit_gap  = 0;       // Untermass je Seite, wie bei der Wanne

/* [Platte] */
floor_t = 3.2;      // Boden unter den Sockeln, nimmt die Magnettaschen auf

/* [Untere Kante] */
bottom_r     = 5;   // Radius der umlaufenden Verrundung unten aussen
bottom_steps = 12;  // Segmente des Bogens

/* [Raster] */
grid_cols = 9;
grid_rows = 2;

/* [Magnete] */
magnets_per_cell = 4;   // 4, 2 (Diagonale) oder 0
magnet_d = 6.5;         // Bohrung fuer 6-mm-Magnet
magnet_t = 2.4;         // Tiefe fuer 2-mm-Magnet plus zwei Lagen

/* [Endmulden] */
end_well = true;    // die 21-mm-Streifen an den Enden aussparen
well_web = 2;       // Steg zwischen letztem Sockel und Mulde
well_rim = 2;       // Rand der Mulde zur Plattenkante

$fa = 1;
$fs = 0.5;

// -----------------------------------------------------------------------------
// Gridfinity-Konstanten – Spezifikation, keine Parameter
// -----------------------------------------------------------------------------
GF_PITCH      = 42;
GF_BOT_CHAM   = 0.8;    // unterste 45-Grad-Stufe
GF_STRAIGHT   = 1.8;    // senkrechter Abschnitt
GF_TOP_CHAM   = 2.15;   // obere 45-Grad-Stufe
GF_SOCKET_H   = GF_BOT_CHAM + GF_STRAIGHT + GF_TOP_CHAM;   // 4.75
GF_RUN        = GF_BOT_CHAM + GF_TOP_CHAM;                 // 2.95
GF_TOP_R      = 4.0;    // Eckradius der Sockeloeffnung
GF_MAGNET_OFF = 13;     // Magnet ab Zellmitte

use <boxxy-regal-shell.scad>

// -----------------------------------------------------------------------------
// Abgeleitete Groessen
// -----------------------------------------------------------------------------
gx = shelf_x - 2 * fit_gap;
gy = shelf_y - 2 * fit_gap;

plate_h    = floor_t + GF_SOCKET_H;         // 7.95
grid_w     = grid_cols * GF_PITCH;          // 378
grid_d     = grid_rows * GF_PITCH;          // 84
grid_half  = grid_w / 2;                    // 189
grid_y0    = (gy - grid_d) / 2;             // 1.5 – mittig in der Tiefe

function cell_x(i) = GF_PITCH * (i - (grid_cols - 1) / 2);
function cell_y(j) = grid_y0 + GF_PITCH * (j + 0.5);

// Freiraum zwischen der aeusseren vorderen Sockelecke und der R30-Ecke des
// Regals. Beide Ecken sind verrundet, es zaehlt also der Abstand der beiden
// Bogenmittelpunkte plus/minus die Radien.
sock_cx    = grid_half - GF_TOP_R;
sock_cy    = grid_y0 + grid_d - GF_TOP_R;
shelf_cx   = gx / 2 - corner_r;
shelf_cy   = gy - corner_r;
corner_gap = corner_r - GF_TOP_R
           - sqrt(pow(sock_cx - shelf_cx, 2) + pow(sock_cy - shelf_cy, 2));

assert(corner_gap >= 0.5, str(
    "Die vordere Eckzelle kollidiert mit der R", corner_r, "-Verrundung: ",
    corner_gap, " mm Rand. Abhilfe: grid_cols verkleinern."));
assert(grid_w <= gx && grid_d <= gy, "Raster passt nicht in den Umriss");
assert(floor_t > magnet_t, "floor_t muss dicker sein als die Magnettasche");
assert(shell_inset_at(floor_t, bottom_r, bottom_steps) < grid_y0,
       "Die untere Verrundung schneidet in den vorderen Sockel");

// -----------------------------------------------------------------------------
// Sockel
// -----------------------------------------------------------------------------

// Sockelquerschnitt, d = Einzug gegenueber der vollen Zelle.
// offset(r) auf ein Quadrat der Kantenlaenge PITCH - 2*R ergibt genau das
// abgerundete 42er Quadrat, offset(delta) schrumpft Groesse und Radius zugleich.
module socket_2d(d) {
    offset(delta = -d)
        offset(r = GF_TOP_R)
            square(GF_PITCH - 2 * GF_TOP_R, center = true);
}

// Aussparung fuer eine Zelle, als Negativ von unten nach oben aufgebaut.
module socket() {
    z0 = floor_t;
    hull() {
        translate([0, 0, z0])
            linear_extrude(0.01) socket_2d(GF_RUN);
        translate([0, 0, z0 + GF_BOT_CHAM])
            linear_extrude(0.01) socket_2d(GF_TOP_CHAM);
    }
    translate([0, 0, z0 + GF_BOT_CHAM])
        linear_extrude(GF_STRAIGHT) socket_2d(GF_TOP_CHAM);
    hull() {
        translate([0, 0, z0 + GF_BOT_CHAM + GF_STRAIGHT])
            linear_extrude(0.01) socket_2d(GF_TOP_CHAM);
        translate([0, 0, z0 + GF_SOCKET_H])
            linear_extrude(0.01) socket_2d(0);
    }
    // ueber die Plattenoberkante hinaus, damit sauber geschnitten wird
    translate([0, 0, z0 + GF_SOCKET_H])
        linear_extrude(2) socket_2d(0);
}

// Magnettaschen einer Zelle, nach oben in den Sockelboden geoeffnet.
module magnets() {
    signs = magnets_per_cell == 4 ? [[1, 1], [1, -1], [-1, 1], [-1, -1]]
          : magnets_per_cell == 2 ? [[1, 1], [-1, -1]]
          : [];
    for (s = signs)
        translate([s[0] * GF_MAGNET_OFF, s[1] * GF_MAGNET_OFF,
                   floor_t - magnet_t])
            cylinder(h = magnet_t + 0.01, d = magnet_d);
}

// -----------------------------------------------------------------------------
// Endmulden
// -----------------------------------------------------------------------------
// Die 21 mm links und rechts vom Raster waeren sonst massiver Klotz. Sie
// werden auf Sockelbodenhoehe ausgehoehlt – spart Material und gibt zwei
// flache Ablagen.
module end_well_solid(s) {
    translate([0, 0, floor_t])
        linear_extrude(GF_SOCKET_H + 2)
            intersection() {
                offset(delta = -well_rim) shell_outline_2d(gx, gy, corner_r);
                translate([s > 0 ? grid_half + well_web : -gx / 2 - 10, -10])
                    square([gx / 2 + 10 - grid_half - well_web, gy + 20]);
            }
}

// -----------------------------------------------------------------------------
// Baseplate
// -----------------------------------------------------------------------------

module baseplate() {
    intersection() {
        shell_envelope(gx, gy, corner_r, plate_h, bottom_r, bottom_steps);
        difference() {
            linear_extrude(plate_h) shell_outline_2d(gx, gy, corner_r);
            for (i = [0 : grid_cols - 1], j = [0 : grid_rows - 1])
                translate([cell_x(i), cell_y(j), 0]) {
                    socket();
                    magnets();
                }
            if (end_well) {
                end_well_solid(1);
                end_well_solid(-1);
            }
        }
    }
}

baseplate();
