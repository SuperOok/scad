// =============================================================================
// boxxy-regal – Einsatz fuer das Tuerregal
// =============================================================================
// Wanne mit durchgehendem duennem Boden und umlaufender Bordwand.
//
// Alle Masse sind mit der Passlehre am Objekt geprueft. Die Lehre (Rahmen,
// Ecksegmente, Teststaebchen) ist aus dem Repo entfernt, liegt aber in der
// Git-Historie bis Commit c7de360:
//   X  = 420 mm          genau richtig, keine Zugabe noetig
//   Y  = 77 bzw. 87 mm   zwei Varianten, ueber shelf_y einstellen
//   Eckradius   = 30 mm  bestaetigt, nur vorne (+Y)
//   Bordwand    = 12 mm  bestaetigt
//
// -----------------------------------------------------------------------------
// KOORDINATEN
// -----------------------------------------------------------------------------
//   X = Laengsrichtung, in der Mitte zentriert (-210 .. +210)
//   Y = Tiefe,  y = 0 hinten (Tuerseite),  y = shelf_y vorne (verrundet)
//   Z = Hoehe,  Boden bei z = 0
//   Die beiden hinteren Ecken sind scharfkantig, nur vorne wird verrundet.
//
// -----------------------------------------------------------------------------
// UNTERE KANTE (bottom_r)
// -----------------------------------------------------------------------------
//   Die Aussenkante ist unten umlaufend mit bottom_r = 5 verrundet, damit der
//   Einsatz ueber die Hohlkehle am Uebergang Boden/Seitenwand des Regals kommt.
//   Oberhalb von z = bottom_r ist die Kontur exakt shelf_x x shelf_y – dort
//   liegt der Einsatz an, und dort hat auch die Lehre gemessen.
//
//   ACHTUNG, das ist ein Ueberhang: bei z = 0 liegt die Kontur 5 mm weiter
//   innen als oben, und die Flanke laeuft unten waagerecht aus. Von z = 0 auf
//   z = 0,04 wandert sie schon 0,65 mm nach aussen – die ersten rund 1 mm
//   drucken ohne Stuetze nicht sauber. Zwei Auswege:
//     bottom_steps = 1  -> gerade 45-Grad-Fase statt Bogen, stuetzfrei
//     bottom_r kleiner  -> weniger Ueberhang, weniger Freigang
//
//   Die Verrundung frisst in die Bordwand: erst ab z = 1,75 steht mehr als
//   0,8 mm davon. Deshalb ist wall_t hier 2,0 statt der 1,6 der Lehre – mit
//   1,6 bliebe an der Nahtstelle zum Boden eine Schneide von 0,27 mm.
//
// -----------------------------------------------------------------------------
// DRUCKEN
// -----------------------------------------------------------------------------
//   Flach auf dem Bett, Boden unten. Ausser der Verrundung (siehe oben) gibt
//   es keine Ueberhaenge, Stuetzen sind nicht noetig.
//
//   Der Einsatz passt auf ein 360er Bett nur DIAGONAL, um 45 Grad gedreht:
//     shelf_y = 77 -> (420 + 77) / sqrt(2) = 351,4 mm   (so gedruckt, ging)
//     shelf_y = 87 -> (420 + 87) / sqrt(2) = 358,5 mm   (praktisch zu gross)
//   45 Grad ist dabei das Optimum, jeder andere Winkel wird groesser. Fuer die
//   87er Variante heisst das: entweder ein groesseres Bett, oder das Teil muss
//   geteilt werden – das ist hier bewusst nicht eingebaut.
//
//   Kein Brim: bei 351 mm Diagonale ist auf einem 360er Bett kein Platz dafuer.
//   Der Boden ist gross und duenn, also auf Haftung achten.
// =============================================================================

/* [Regalmasse] */
shelf_x  = 420;     // Laenge in X
shelf_y  = 77;      // Tiefe in Y – 77 oder 87
corner_r = 30;      // Radius der beiden vorderen Ecken
fit_gap  = 0;       // Untermass je Seite. 0, weil die gedruckte 420er Lehre
                    // ohne Kraft hineinging – klemmt es doch, hier 0,3 setzen.

/* [Wanne] */
floor_t = 1.6;      // Dicke des durchgehenden Bodens
wall_t  = 2.0;      // Dicke der Bordwand
wall_h  = 12;       // Hoehe der Bordwand (ab z = 0)

/* [Untere Kante] */
bottom_r     = 5;   // Radius der umlaufenden Verrundung unten aussen
bottom_steps = 12;  // Segmente des Bogens; 1 ergibt eine 45-Grad-Fase

$fa = 1;
$fs = 0.5;

// -----------------------------------------------------------------------------
// Abgeleitete Groessen
// -----------------------------------------------------------------------------
gx = shelf_x - 2 * fit_gap;     // effektive Laenge
gy = shelf_y - 2 * fit_gap;     // effektive Tiefe

assert(bottom_r < corner_r, "bottom_r muss kleiner als corner_r sein");
assert(bottom_r <= wall_h,  "bottom_r darf die Bordwand nicht ueberragen");
assert(corner_r < gy,       "corner_r muss kleiner als die Tiefe sein");
assert(floor_t < wall_h,    "floor_t muss unter der Bordwandhoehe liegen");

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

// -----------------------------------------------------------------------------
// Verrundung der unteren Aussenkante
// -----------------------------------------------------------------------------
// Huellkoerper: volle Grundflaeche, unten aussen umlaufend mit bottom_r
// verrundet. Die Wanne wird damit verschnitten, statt jede Kante einzeln zu
// verrunden.
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
// Einsatz
// -----------------------------------------------------------------------------

module tray() {
    intersection() {
        outer_envelope(corner_r);
        union() {
            linear_extrude(floor_t) outline_2d(corner_r);
            linear_extrude(wall_h)  ring_2d(corner_r, wall_t);
        }
    }
}

tray();
