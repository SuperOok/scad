// =============================================================================
// windowblock – Zugstrebe gegen das Zuschlagen eines gekippten Fensters
// =============================================================================
// Eine zur Laibung hin offene Gabel wird waagerecht von links auf den geraden
// Teil des (in Kippstellung hochgestellten) Fenstergriffs geschoben. Die
// Strebe laeuft durch die Laibung zur Zimmerwand und hakt um die
// Laibungskante; die Auflage liegt flach auf der Zimmerwand. Will der Fluegel
// zufallen, wandert der Griff nach aussen, die Strebe kommt auf Zug und zieht
// die Auflage gegen die Wand.
//
// Warum eine Gabel statt einer Oese: Die Hebelspitze ist zum Fluegel hin
// gebogen. Eine von oben aufgesteckte Oese braucht dafuer viel Spiel, und mit
// Spiel dreht das Teil weg. Die Gabel umgeht die Biegung und sitzt knapp.
//   - Die Gabel ist fork_h hoch und folgt der Hebelneigung -> kein Abkippen.
//   - Ein Fuss links neben dem Hebel stuetzt sich auf dem Fluegelrahmen ab
//     -> kein waagerechtes Wegschwenken von der Laibung. In die andere
//     Richtung haelt der Laibungsschenkel.
//   - Unter Zug zieht die Strebe Richtung Laibungsecke (+X, +Y): Der Hebel
//     wird tiefer in die Gabel und gegen die Rueckwand gedrueckt. Zwei kleine
//     Rastnoppen an der Oeffnung halten die Gabel ohne Last.
//
// EINBAU: Teil ~25 mm links der Endlage ansetzen, Auflage schon vor der
// Zimmerwand, dann nach rechts auf den Hebel schieben, bis der Schenkel an der
// Laibung anliegt.
//
// Die Strebe ist um `slack` laenger als der Abstand bei voll gekipptem
// Fluegel: Sie haengt also nur lose, bis der Fluegel ein paar mm zufaellt.
//
// Koordinaten (Draufsicht, Griff rechts am Fluegel):
//   X = parallel zum Fenster, +X Richtung rechte Laibung
//   Y = senkrecht zum Fenster, +Y Richtung Zimmer
//   Z = senkrecht nach oben (Einbaulage = Drucklage)
//   Mitte des Griffhebels liegt bei Z = 0 bei (0, 0).
//
// DRUCK: flach liegend wie modelliert, Z = 0 aufs Bett. Die Zugkraft laeuft
// in der Schichtebene, Gabel und Fuss sind um lever_tilt (< 5 Grad) geneigt.
// Stuetzfrei. ASA, >= 4 Perimeter, >= 40 % Infill.
// Bettseite gehoert beim Einbau nach unten, sonst stimmt die Neigung nicht.
// =============================================================================

// ---- Messwerte (am Fenster gemessen 2026-10-19) -----------------------------
lever_w   = 21;    // Breite Griffhebel (X), gerader Teil, Schieblehre
lever_t   = 13.5;  // Dicke Griffhebel (Y), gerader Teil, Schieblehre
lever_len = 100;   // Hebellaenge Drehachse -> Spitze
lever_straight = 70;  // gerader Teil zwischen Halsrundung und Spitzenbiegung
lever_gap = 35;    // Abstand Rueckseite Hebel -> Fluegelflaeche
gap_reveal = 55;   // Laibung -> laibungsseitige Flanke des Hebels
frame_left = 25;   // Fluegelrahmen links neben dem Hebel (ab Hebelflanke)
rosette_w  = lever_w + 2;  // Rosette am Hebelfuss, je Seite 1 mm breiter
// Vorderseite Hebel -> Ebene der Zimmerwand, Fluegel voll gekippt. Der Hebel
// steht in Kippstellung schraeg (oben naeher am Zimmer).
wall_top  = 90;    // an der Hebelspitze
wall_bot  = 98;    // am Hebelfuss

// ---- Lage der Gabel ---------------------------------------------------------
fork_z = 35;  // Hoehe der Strebe (Unterkante Gabel) ueber dem Hebelfuss

// Wandabstand dort, wo die Strebe sitzt (linear zwischen Fuss und Spitze)
x_dist     = gap_reveal + lever_w / 2;   // Mitte Hebel -> Laibung
y_dist     = wall_bot - (wall_bot - wall_top) * fork_z / lever_len
             + lever_t / 2;              // Mitte Hebel -> Zimmerwand
lever_tilt = atan((wall_bot - wall_top) / lever_len);  // Neigung gegen Z

// ---- Passung ----------------------------------------------------------------
fork_clear = 0.5;  // Spiel der Gabel je Seite um den Hebel
snap       = 0.4;  // Ueberdeckung je Rastnoppen (0 = ohne Rastung)
slack      = 2;    // Strebe so viel laenger als y_dist (Einhaengen, Messfehler)
x_clear    = 0.5;  // Luft zwischen Schenkel und Laibung
foot_clear = 0.3;  // Luft zwischen Fuss und Fluegelrahmen

// ---- Form -------------------------------------------------------------------
height     = 20;  // Hoehe von Strebe, Schenkel und Auflage
fork_h     = 40;  // Hoehe von Gabel und Fuss (gegen Abkippen)
wall       = 6;   // Wandstaerke Gabel, Laibungsschenkel, Auflage
strut_w    = 8;   // Breite der Strebe
fork_back  = min(wall, lever_gap - 1);  // Gabelwand zwischen Hebel und Fluegel
nub_r      = 2;   // Radius der Rastnoppen
foot_w     = 8;   // Durchmesser der runden Fussspitze
foot_root  = 4;   // Fussansatz: aeusserer Streifen der linken Gabelwand
leg_len    = 40;  // Schenkel entlang der Laibung (ab Kante)
pad_len    = 35;  // Auflage auf der Zimmerwand (ab Kante)
relief_r   = 3;   // Freisparung an der Innenecke: Kante traegt nicht
round_r    = 1.5; // Verrundung der Profilecken

show_context = false;  // true: Fluegel, Griff und Wand als Geister anzeigen

$fn = 64;

// ---- abgeleitete Werte ------------------------------------------------------
slot_y   = lever_t + 2 * fork_clear;          // lichte Weite der Gabel (Y)
in_left  = -lever_w / 2 - fork_clear;         // Innenflaeche linke Gabelwand
nub_x    = lever_w / 2 + fork_clear + nub_r;  // Noppen knapp hinter der Flanke
arm_end  = nub_x + nub_r + 0.5;               // Ende der Gabelarme (+X)
fork_l   = in_left - wall;                    // Aussenkante links
fork_top = slot_y / 2 + wall;                 // Vorderkante Gabel (+Y)
fork_bot = -slot_y / 2 - fork_back;           // Rueckkante Gabel (-Y)
x_rev    = x_dist - x_clear;          // Aussenflaeche Schenkel (an Laibung)
y_wall   = y_dist + slack;            // Innenflaeche Auflage (an Zimmerwand)
leg_y0   = y_wall - leg_len;          // unteres Schenkelende
y_frame  = -lever_t / 2 - lever_gap;  // Flaeche Fluegelrahmen
foot_x   = -lever_w / 2 - frame_left / 2;  // Fuss mittig auf dem Rahmenstreifen
foot_y   = y_frame + foot_clear + foot_w / 2;  // Mitte der Fussspitze

assert(lever_gap > 2, "lever_gap zu klein fuer eine Gabelwand");
assert(x_rev - wall > arm_end, "x_dist zu klein: Gabel und Schenkel ueberlappen");
assert(foot_x + foot_w / 2 < -rosette_w / 2 - 1,
       "Fuss trifft die Rosette: frame_left zu klein");
assert(fork_h <= lever_straight - 10, "Gabel hoeher als der gerade Hebelteil");

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
// Gabel (zur Laibung hin offen) mit Fuss zum Fluegelrahmen
module fork_profile() {
    difference() {
        rounded(round_r) union() {
            translate([fork_l, fork_bot])
                square([arm_end - fork_l, fork_top - fork_bot]);
            hull() {
                translate([fork_l, fork_bot]) square([foot_root, fork_back]);
                translate([foot_x, foot_y]) circle(d = foot_w);
            }
        }
        // Schlitz, links mit gerundeten Innenecken, rechts offen
        translate([in_left, -slot_y / 2])
            rounded(2) square([arm_end - in_left + 5, slot_y]);
    }
    // Rastnoppen: ragen je `snap` in den Schlitz
    if (snap > 0)
        for (s = [-1, 1])
            intersection() {
                translate([nub_x, s * (slot_y / 2 + nub_r - snap)])
                    circle(r = nub_r);
                translate([fork_l, fork_bot])
                    square([arm_end - fork_l, fork_top - fork_bot]);
            }
}

// Strebe, Laibungsschenkel und Auflage auf der Zimmerwand
module arm_profile() {
    difference() {
        rounded(round_r) union() {
            // Strebe: vorderer Gabelarm -> unteres Ende des Laibungsschenkels.
            // Die Strebe steht senkrecht, die Gabel ist geneigt: Ansatz um die
            // Neigung ueber `height` nach vorn, sonst ragt sie oben in den
            // Schlitz.
            bar([arm_end - strut_w / 2,
                 slot_y / 2 + strut_w / 2 + height * tan(lever_tilt)],
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
lean() linear_extrude(height = fork_h) fork_profile();
linear_extrude(height = height) arm_profile();

// ---- Kontext (nur Ansicht) --------------------------------------------------
if (show_context) %union() {
    lean() {
        // Griffhebel (gerader Teil)
        translate([-lever_w / 2, -lever_t / 2, -fork_z])
            cube([lever_w, lever_t, lever_len]);
        // Fluegelrahmen
        translate([-150, y_frame - 70, -fork_z])
            cube([150 + x_dist - 15, 70, lever_len]);
    }
    // Laibung + Zimmerwand
    translate([x_dist, y_dist - 220, -fork_z]) cube([120, 220, lever_len]);
}
