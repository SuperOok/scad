// =============================================================================
// windowblock – Zugstrebe gegen das Zuschlagen eines gekippten Fensters
// =============================================================================
// Eine Oese wird von oben ueber den (in Kippstellung hochgestellten)
// Fenstergriff geschoben. Die Strebe laeuft durch die Laibung zur Zimmerwand
// und hakt um die Laibungskante; die Auflage liegt flach auf der Zimmerwand.
// Will der Fluegel zufallen, wandert der Griff nach aussen, die Strebe kommt
// auf Zug und zieht die Auflage gegen die Wand.
//
// Die Strebe ist um `slack` laenger als der Abstand bei voll gekipptem
// Fluegel: Sie haengt also nur lose, bis der Fluegel ein paar mm zufaellt.
// Kuerzer geht nicht, sonst laesst sie sich gar nicht einhaengen.
//
// Koordinaten (Draufsicht, Griff rechts am Fluegel):
//   X = parallel zum Fenster, +X Richtung rechte Laibung
//   Y = senkrecht zum Fenster, +Y Richtung Zimmer
//   Z = senkrecht (Hoehe der Strebe, = Druckhoehe)
//   Mitte des Griffhebels liegt bei (0, 0).
//
// DRUCK: flach liegend wie modelliert. Die Zugkraft laeuft in der
// Schichtebene, die Oese ist ein senkrechter Durchbruch. Stuetzfrei.
// ASA, >= 4 Perimeter, >= 40 % Infill.
// =============================================================================

// ---- Messwerte (am Fenster gemessen 2026-10-19) -----------------------------
lever_w   = 20;   // Breite Griffhebel (X)
lever_t   = 15;   // Dicke Griffhebel (Y)
lever_len = 100;  // Hebellaenge Drehachse -> Spitze
lever_gap = 35;   // Abstand Rueckseite Hebel -> Fluegelflaeche
gap_reveal = 55;  // Laibung -> laibungsseitige Flanke des Hebels
// Vorderseite Hebel -> Ebene der Zimmerwand, Fluegel voll gekippt. Der Hebel
// steht in Kippstellung schraeg (oben naeher am Zimmer).
wall_top  = 90;   // an der Hebelspitze
wall_bot  = 98;   // am Hebelfuss

// Die Oese rutscht bis an den Hebelfuss, dort ist der Abstand am groessten.
// Auf wall_bot auslegen, sonst laesst sich die Strebe nicht einhaengen.
x_dist     = gap_reveal + lever_w / 2;   // Mitte Hebel -> Laibung
y_dist     = wall_bot + lever_t / 2;     // Mitte Hebel -> Zimmerwand
lever_tilt = atan((wall_bot - wall_top) / lever_len);  // Neigung gegen Z

// ---- Passung ----------------------------------------------------------------
eye_clear = 1.5;  // Spiel der Oese je Seite um den Hebel (zusaetzlich zur
                  // Neigungszugabe in Y, siehe hole_y)
slack     = 3;    // Strebe so viel laenger als y_dist (Einhaengen, Messfehler)
x_clear   = 0.5;  // Luft zwischen Schenkel und Laibung

// ---- Form -------------------------------------------------------------------
height     = 20;  // Hoehe der Strebe (Z, = Druckhoehe)
wall       = 6;   // Wandstaerke Oese, Laibungsschenkel, Auflage
strut_w    = 8;   // Breite der Strebe
eye_back   = min(wall, lever_gap - 1);  // Oesenwand zwischen Hebel und Fluegel
leg_len    = 40;  // Schenkel entlang der Laibung (ab Kante)
pad_len    = 35;  // Auflage auf der Zimmerwand (ab Kante)
relief_r   = 3;   // Freisparung an der Innenecke: Kante traegt nicht
round_r    = 1.5; // Verrundung der Profilecken

show_context = false;  // true: Fluegel, Griff und Wand als Geister anzeigen

$fn = 64;

// ---- abgeleitete Werte ------------------------------------------------------
hole_x  = lever_w + 2 * eye_clear;
// Der schraege Hebel braucht ueber die Oesenhoehe zusaetzlich Luft in Y.
hole_y  = lever_t + 2 * eye_clear + height * tan(lever_tilt);
x_rev   = x_dist - x_clear;           // Aussenflaeche Schenkel (an Laibung)
y_wall  = y_dist + slack;             // Innenflaeche Auflage (an Zimmerwand)
leg_x   = x_rev - wall / 2;           // Mittellinie Schenkel
leg_y0  = y_wall - leg_len;           // unteres Schenkelende
eye_top = hole_y / 2 + wall;          // Oberkante Oese (+Y)

assert(lever_gap > 2, "lever_gap zu klein fuer eine Oesenwand");
assert(leg_x - wall / 2 > hole_x / 2 + wall,
       "x_dist zu klein: Oese und Laibungsschenkel ueberlappen");

// ---- 2D-Profil --------------------------------------------------------------
module bar(p0, p1, w) {
    hull() {
        translate(p0) circle(d = w);
        translate(p1) circle(d = w);
    }
}

module eye_outer() {
    translate([-hole_x / 2 - wall, -hole_y / 2 - eye_back])
        square([hole_x + 2 * wall, hole_y + eye_back + wall]);
}

module eye_hole() {
    offset(r = 2) offset(delta = -2)
        square([hole_x, hole_y], center = true);
}

module profile() {
    difference() {
        offset(r = round_r) offset(delta = -round_r) union() {
            eye_outer();
            // Strebe: Oese -> unteres Ende des Laibungsschenkels
            bar([hole_x / 2, eye_top - strut_w / 2],
                [x_rev - strut_w / 2, leg_y0 + strut_w / 2], strut_w);
            // Schenkel entlang der Laibung, bis ueber die Kante
            translate([x_rev - wall, leg_y0]) square([wall, leg_len + wall]);
            // Auflage auf der Zimmerwand
            translate([x_rev - wall, y_wall]) square([wall + pad_len, wall]);
        }
        eye_hole();
        // Freisparung: Innenecke beruehrt die Putzkante nicht
        translate([x_rev, y_wall]) circle(r = relief_r);
    }
}

// ---- Teil -------------------------------------------------------------------
linear_extrude(height = height) profile();

// ---- Kontext (nur Ansicht) --------------------------------------------------
if (show_context) %union() {
    // Griffhebel
    translate([-lever_w / 2, -lever_t / 2, -40]) cube([lever_w, lever_t, 120]);
    // Fluegelflaeche (Rueckseite des Hebels + lever_gap)
    translate([-150, -lever_t / 2 - lever_gap - 70, -40])
        cube([150 + x_dist - 15, 70, 120]);
    // Laibung + Zimmerwand
    translate([x_dist, y_dist - 220, -40]) cube([120, 220, 120]);
}
