// =============================================================================
// windowblock – Zugstrebe gegen das Zuschlagen eines gekippten Fensters
// =============================================================================
// Eine Oese (Rohr) wird von oben ueber den (in Kippstellung hochgestellten)
// Fenstergriff geschoben. Die Strebe laeuft durch die Laibung zur Zimmerwand
// und hakt um die Laibungskante; die Auflage liegt flach auf der Zimmerwand.
// Will der Fluegel zufallen, wandert der Griff nach aussen, die Strebe kommt
// auf Zug und zieht die Auflage gegen die Wand.
//
// Die Oese sitzt wegen der ergonomischen Griffform locker. Damit das Teil
// trotzdem nicht wegdreht:
//   - Das Rohr ist eye_h hoch und folgt der Hebelneigung -> kein Abkippen
//     nach unten.
//   - Ein Fuss links neben dem Hebel stuetzt sich auf dem Fluegelrahmen ab
//     -> kein waagerechtes Wegschwenken von der Laibung. In die andere
//     Richtung haelt der Laibungsschenkel.
//
// Die Strebe ist um `slack` laenger als der Abstand bei voll gekipptem
// Fluegel: Sie haengt also nur lose, bis der Fluegel ein paar mm zufaellt.
// Kuerzer geht nicht, sonst laesst sie sich gar nicht einhaengen.
//
// Koordinaten (Draufsicht, Griff rechts am Fluegel):
//   X = parallel zum Fenster, +X Richtung rechte Laibung
//   Y = senkrecht zum Fenster, +Y Richtung Zimmer
//   Z = senkrecht nach oben (Einbaulage = Drucklage)
//   Mitte des Griffhebels liegt bei Z = 0 bei (0, 0).
//
// DRUCK: flach liegend wie modelliert, Z = 0 aufs Bett. Die Zugkraft laeuft
// in der Schichtebene, Oese und Fuss sind um lever_tilt (< 5 Grad) geneigt.
// Stuetzfrei. ASA, >= 4 Perimeter, >= 40 % Infill.
// EINBAU: Bettseite nach unten, sonst stimmt die Neigung nicht.
// =============================================================================

// ---- Messwerte (am Fenster gemessen 2026-10-19) -----------------------------
lever_w   = 20;   // Breite Griffhebel (X)
lever_t   = 15;   // Dicke Griffhebel (Y)
lever_len = 100;  // Hebellaenge Drehachse -> Spitze
lever_gap = 35;   // Abstand Rueckseite Hebel -> Fluegelflaeche
gap_reveal = 55;  // Laibung -> laibungsseitige Flanke des Hebels
frame_left = 25;  // Fluegelrahmen links neben dem Hebel (ab Hebelflanke)
rosette_w  = lever_w + 2;  // Rosette am Hebelfuss, je Seite 1 mm breiter
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
eye_clear  = 1.5;  // Spiel der Oese je Seite um den Hebel
slack      = 3;    // Strebe so viel laenger als y_dist (Einhaengen, Messfehler)
x_clear    = 0.5;  // Luft zwischen Schenkel und Laibung
foot_clear = 0.5;  // Luft zwischen Fuss und Fluegelrahmen (Oese mittig)

// ---- Form -------------------------------------------------------------------
height     = 20;  // Hoehe von Strebe, Schenkel und Auflage
eye_h      = 40;  // Hoehe von Oese und Fuss (Rohr gegen Abkippen)
wall       = 6;   // Wandstaerke Oese, Laibungsschenkel, Auflage
strut_w    = 8;   // Breite der Strebe
eye_back   = min(wall, lever_gap - 1);  // Oesenwand zwischen Hebel und Fluegel
foot_w     = 8;   // Durchmesser der runden Fussspitze
foot_root  = 4;   // Fussansatz: aeusserer Streifen der linken Oesenwand
leg_len    = 40;  // Schenkel entlang der Laibung (ab Kante)
pad_len    = 35;  // Auflage auf der Zimmerwand (ab Kante)
relief_r   = 3;   // Freisparung an der Innenecke: Kante traegt nicht
round_r    = 1.5; // Verrundung der Profilecken

show_context = false;  // true: Fluegel, Griff und Wand als Geister anzeigen

$fn = 64;

// ---- abgeleitete Werte ------------------------------------------------------
hole_x  = lever_w + 2 * eye_clear;
hole_y  = lever_t + 2 * eye_clear;
x_rev   = x_dist - x_clear;           // Aussenflaeche Schenkel (an Laibung)
y_wall  = y_dist + slack;             // Innenflaeche Auflage (an Zimmerwand)
leg_y0  = y_wall - leg_len;           // unteres Schenkelende
eye_out = hole_x / 2 + wall;          // halbe Aussenbreite Oese (X)
eye_top = hole_y / 2 + wall;          // Vorderkante Oese (+Y)
eye_bot = -hole_y / 2 - eye_back;     // Rueckkante Oese (-Y)
y_frame = -lever_t / 2 - lever_gap;   // Flaeche Fluegelrahmen
foot_x  = -lever_w / 2 - frame_left / 2;  // Fuss mittig auf dem Rahmenstreifen
foot_y  = y_frame + foot_clear + foot_w / 2;  // Mitte der Fussspitze

assert(lever_gap > 2, "lever_gap zu klein fuer eine Oesenwand");
assert(x_rev - wall > eye_out, "x_dist zu klein: Oese und Schenkel ueberlappen");
assert(foot_x + foot_w / 2 < -rosette_w / 2 - 1,
       "Fuss trifft die Rosette: frame_left zu klein");

// ---- Hilfen -----------------------------------------------------------------
module bar(p0, p1, w) {
    hull() {
        translate(p0) circle(d = w);
        translate(p1) circle(d = w);
    }
}

module rounded(r) {
    offset(r = r) offset(delta = -r) children();
}

// Neigt Z-Extrusionen wie den Hebel: oben weiter Richtung Zimmer (+Y).
module lean() {
    multmatrix([[1, 0, 0, 0],
                [0, 1, tan(lever_tilt), 0],
                [0, 0, 1, 0]]) children();
}

// ---- 2D-Profile -------------------------------------------------------------
// Oese (aussen) mit Fuss zum Fluegelrahmen
module eye_profile() {
    rounded(round_r) union() {
        translate([-eye_out, eye_bot]) square([2 * eye_out, eye_top - eye_bot]);
        hull() {
            translate([-eye_out, eye_bot]) square([foot_root, eye_back]);
            translate([foot_x, foot_y]) circle(d = foot_w);
        }
    }
}

module eye_hole() {
    rounded(2) square([hole_x, hole_y], center = true);
}

// Strebe, Laibungsschenkel und Auflage auf der Zimmerwand
module arm_profile() {
    difference() {
        rounded(round_r) union() {
            // Strebe: Oese -> unteres Ende des Laibungsschenkels
            bar([hole_x / 2, eye_top - strut_w / 2],
                [x_rev - strut_w / 2, leg_y0 + strut_w / 2], strut_w);
            // Schenkel entlang der Laibung, bis ueber die Kante
            translate([x_rev - wall, leg_y0]) square([wall, leg_len + wall]);
            // Auflage auf der Zimmerwand
            translate([x_rev - wall, y_wall]) square([wall + pad_len, wall]);
        }
        // Freisparung: Innenecke beruehrt die Putzkante nicht
        translate([x_rev, y_wall]) circle(r = relief_r);
    }
}

// ---- Teil -------------------------------------------------------------------
difference() {
    union() {
        lean() linear_extrude(height = eye_h) eye_profile();
        linear_extrude(height = height) arm_profile();
    }
    lean() translate([0, 0, -1]) linear_extrude(height = eye_h + 2) eye_hole();
}

// ---- Kontext (nur Ansicht) --------------------------------------------------
if (show_context) %union() {
    lean() {
        // Griffhebel
        translate([-lever_w / 2, -lever_t / 2, -20])
            cube([lever_w, lever_t, lever_len]);
        // Fluegelrahmen
        translate([-150, y_frame - 70, -20])
            cube([150 + x_dist - 15, 70, lever_len]);
    }
    // Laibung + Zimmerwand
    translate([x_dist, y_dist - 220, -20]) cube([120, 220, lever_len]);
}
