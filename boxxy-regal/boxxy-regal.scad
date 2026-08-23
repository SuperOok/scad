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
//   drucken ohne Stuetze nicht sauber. Das Mittel dagegen ist ein BRIM, kein
//   Stuetzmaterial: die erste Schicht liegt 5 mm innen, ein Brim gibt der
//   zweiten Schicht (1,4 mm weiter aussen) eine Auflage und kostet dabei
//   kaum Bauraum. Siehe README.
//
//   KEINE 45-GRAD-FASE STATT DES BOGENS (bottom_steps = 1). Das zerlegt das
//   Teil: eine gerade Flanke ist auf Hoehe der Bodenoberkante (z = floor_t)
//   noch 5 - floor_t = 3,4 mm eingezogen, also mehr als wall_t – die
//   Bordwand haengt dann frei in der Luft, CGAL liefert zwei getrennte
//   Koerper. Der Bogen ist bei z = 1,6 nur 1,35 mm eingezogen.
//   Das laesst sich auch nicht anders loesen: stuetzfrei heisst Steigung
//   <= 45 Grad, und wer bei z = 0 um bottom_r eingezogen startet, ist bei
//   z = floor_t zwangslaeufig noch >= bottom_r - floor_t eingezogen. Mit
//   5 / 1,6 / 2,0 gibt es keine stuetzfreie Unterkante. Der Bogen ist das
//   Optimum – er schmiegt sich an die Hohlkehle und nimmt am wenigsten weg.
//   Der Assert weiter unten faengt den Fall ab.
//
//   Die Verrundung frisst trotzdem in die Bordwand: erst ab z = 1,75 steht
//   mehr als 0,8 mm davon. Deshalb ist wall_t hier 2,0 statt der 1,6 der
//   Lehre – mit 1,6 bliebe an der Nahtstelle zum Boden eine Schneide von
//   0,27 mm.
//
// -----------------------------------------------------------------------------
// DRUCKEN
// -----------------------------------------------------------------------------
//   Flach auf dem Bett, Boden unten. Ausser der Verrundung (siehe oben) gibt
//   es keine Ueberhaenge, Stuetzen sind nicht noetig.
//
//   Der Einsatz passt auf ein 360er Bett nur DIAGONAL, um 45 Grad gedreht.
//   Am Modell gemessene Bounding-Box (nicht (L+B)/sqrt(2) rechnen – die beiden
//   R30-Ecken ziehen den diagonalen Extrempunkt um 30*(sqrt(2)-1) = 12,4 mm
//   herein, sonst kommt man 12 mm zu gross heraus):
//     shelf_y = 77 -> 339,0 x 339,0 mm,  10,5 mm Rand je Seite
//     shelf_y = 87 -> 346,1 x 346,1 mm,   7,0 mm Rand je Seite
//   45 Grad ist das Optimum und der Winkel ist empfindlich: bei 40 oder 50
//   Grad passt die 87er Variante schon nicht mehr (365 mm).
//
//   Fuer ein Brim ist damit Platz (5 mm sind bei beiden drin). Der Boden ist
//   gross und duenn – im Zweifel eins setzen.
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

// Stuetzstellen des Bogens, genau wie outer_envelope() ihn baut.
function band_z(i)  = bottom_r * (1 + sin(-90 + 90 * i / bottom_steps));
function band_in(i) = bottom_r * (1 - cos(-90 + 90 * i / bottom_steps));

// Einzug der unteren Flanke auf Hoehe z. Zwischen zwei Stuetzstellen ist die
// Flanke gerade (hull), also linear interpoliert.
function inset_at(z, i = 0) =
      z >= bottom_r      ? 0
    : band_z(i + 1) >= z ? band_in(i) + (band_in(i + 1) - band_in(i))
                                      * (z - band_z(i))
                                      / (band_z(i + 1) - band_z(i))
    : inset_at(z, i + 1);

// Wenn die Flanke auf Hoehe der Bodenoberkante tiefer einzieht als die
// Bordwand dick ist, haengt die Wand frei und das Teil zerfaellt in zwei
// Koerper. Passiert z. B. bei bottom_steps = 1.
wall_left = wall_t - inset_at(floor_t);
assert(wall_left >= 0.4, str(
    "Die untere Verrundung kappt die Bordwand am Boden – dort blieben nur ",
    wall_left, " mm stehen. Abhilfe: bottom_steps erhoehen (>= 4), ",
    "bottom_r verkleinern, wall_t vergroessern oder floor_t erhoehen."));

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
