// =============================================================================
// windowblock – Buegel gegen das Zuschlagen eines gekippten Fensters
// =============================================================================
// Ein flacher Buegel liegt waagerecht hinter dem (in Kippstellung
// hochgestellten) Fenstergriff und stuetzt sich an drei Stellen ab:
//   - Fuss:  auf dem Fluegelrahmen links neben dem Griff   (drueckt zum Zimmer)
//   - Wiege: an der Rueckseite des Griffs                  (drueckt zum Fenster)
//   - Feder: flach auf der Zimmerwand neben der Laibung    (drueckt zum Zimmer)
// Das ist ein Dreipunkt-Biegebalken: Fuss und Feder halten, die Wiege wird
// vom Griff belastet. Will der Fluegel zufallen, drueckt der Griff gegen die
// Wiege, der Buegel stemmt sich ueber die Feder gegen die Wand.
//
// Warum eine Feder: Die Vorgaenger (Oese, Gabel) hatten Spiel an Griff,
// Rahmen und Wand, weil drei Kontakte mit Messtoleranz nie gleichzeitig
// anliegen. Hier ist die Blattfeder an der Wand ungespannt um `preload` zu
// lang. Eingebaut drueckt sie alle drei Kontakte an -> kein Spiel, und
// Messfehler bis +-leaf_gap / preload werden ausgeglichen. Bei einer Boee
// federt der Buegel hoechstens `leaf_gap` ein, dann liegt die Federwurzel
// starr an der Wand.
//
// EINBAU: Wiege hinter den Griff schieben, Fuss auf den Fluegelrahmen.
// Dann das Wandende um die Laibungskante schwenken und die Feder flach auf die
// Wand druecken. AUSBAU: Wandende zum Zimmer ziehen.
//
// Koordinaten (Draufsicht, Griff rechts am Fluegel):
//   X = parallel zum Fenster, +X Richtung rechte Laibung
//   Y = senkrecht zum Fenster, +Y Richtung Zimmer
//   Z = senkrecht nach oben (Einbaulage = Drucklage)
//   Mitte des Griffhebels liegt bei Z = 0 bei (0, 0).
//
// DRUCK: flach liegend wie modelliert, Z = 0 aufs Bett. Die Feder biegt sich
// in der Schichtebene. Stuetzfrei. ASA, >= 4 Perimeter, >= 40 % Infill.
// Bettseite gehoert beim Einbau nach unten, sonst stimmt die Neigung nicht.
// =============================================================================

// ---- Messwerte (am Fenster gemessen 2026-10-27, Fluegel voll gekippt) ------
// Hoehen Z ab Austritt des Hebels aus der Rosette (~ Drehpunkt), entlang des
// Hebels. Alle Masse auf Hoehe H = 35 mm, wo der Buegel sitzt.
lever_w   = 29.5;  // Breite Griffhebel (X), Schieblehre
lever_t   = 14;    // Dicke Griffhebel (Y), Rueckseite flach
lever_straight = 70;  // gerader Teil (bis hier gemessen)
lever_gap = 41;    // Rueckseite Hebel -> Fluegelflaeche
gap_reveal = 56;   // laibungsseitige Flanke des Hebels -> Laibung
frame_left = 27;   // ebener Fluegelrahmen links neben dem Hebel (ab Flanke)
rosette_top = 32.5;  // Rosette 65 hoch, mittig um den Drehpunkt
// Rueckseite Hebel -> Ebene der Zimmerwand (Lineal auf der Wand). Der Hebel
// steht in Kippstellung schraeg (oben naeher am Zimmer).
wall_a = 105;  wall_a_z = 35;
wall_b = 103;  wall_b_z = 70;

// ---- Lage des Buegels -------------------------------------------------------
bar_z = 35;  // Hoehe der Buegelunterkante (H)

// Wandabstand dort, wo der Buegel sitzt (linear ueber die Hebelhoehe)
lever_tilt = atan((wall_a - wall_b) / (wall_b_z - wall_a_z));  // gegen Z
x_dist     = gap_reveal + lever_w / 2;   // Mitte Hebel -> Laibung
y_dist     = wall_a - (bar_z - wall_a_z) * tan(lever_tilt)
             - lever_t / 2;              // Mitte Hebel -> Zimmerwand

// ---- Feder ------------------------------------------------------------------
preload  = 4;   // Federspitze ragt ungespannt so weit hinter die Wandflaeche
leaf_gap = 4;   // Luft Federwurzel -> Wand, eingebaut (= Federweg bis Block)
leaf_t   = 3.5; // Dicke der Blattfeder
leaf_len = 55;  // freie Laenge der Blattfeder

// ---- Passung ----------------------------------------------------------------
rib      = 1;    // Rippen neben dem Hebel ragen so weit vor die Rueckseite
rib_clear = 0.5; // Luft zwischen Rippe und Hebelflanke
x_clear  = 3;    // Luft Laibungsschenkel -> Laibung (fuehrt nur, traegt nicht)

// ---- Form -------------------------------------------------------------------
height   = 20;  // Hoehe des Buegels
arm_w    = 10;  // Breite von Wiege und Arm
wall     = 6;   // Wandstaerke Laibungsschenkel
root_len = 12;  // Federwurzel entlang der Wand ab Schenkelaussenseite
root_t   = 6;   // Dicke der Federwurzel
foot_w   = 8;   // Durchmesser der runden Fussspitze
leg_len  = 25;  // Schenkel entlang der Laibung (ab Wandflaeche)
rib_r    = 2;   // Radius der Rippen
round_r  = 1.5; // Verrundung der Profilecken

show_context = false;  // true: Fluegel, Griff und Wand als Geister anzeigen

$fn = 64;

// ---- abgeleitete Werte ------------------------------------------------------
y_back  = -lever_t / 2;                       // Rueckseite Hebel (Wiege)
y_frame = y_back - lever_gap;                 // Flaeche Fluegelrahmen
rib_x   = lever_w / 2 + rib_clear + rib_r;    // Mitte der Rippen
cr_x    = rib_x + rib_r;                      // halbe Laenge der Wiege
foot_x  = -lever_w / 2 - frame_left / 2;      // Fuss mittig auf dem Rahmenstreifen
foot_y  = y_frame + foot_w / 2;               // Mitte der Fussspitze
x_rev   = x_dist - x_clear;                   // Aussenflaeche Schenkel
root_y  = y_dist + leaf_gap;                  // Innenflaeche Federwurzel
leaf_x0 = x_rev + root_len;                   // Federansatz
lean_dy = height * tan(lever_tilt);           // Versatz der Wiege oben

assert(bar_z > rosette_top, "Buegel auf Hoehe der Rosette");
assert(x_rev - wall > cr_x + arm_w, "x_dist zu klein fuer den Arm");
assert(bar_z + height <= lever_straight, "Buegel hoeher als der gerade Hebelteil");

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
// Wiege hinter dem Hebel, Fuss zum Fluegelrahmen (beide folgen der Neigung)
module cradle_profile() {
    rounded(round_r) union() {
        translate([-cr_x, y_back - arm_w]) square([2 * cr_x, arm_w]);
        hull() {
            translate([-cr_x, y_back - arm_w]) square([3, arm_w]);
            translate([foot_x, foot_y]) circle(d = foot_w);
        }
    }
    // Rippen links und rechts neben dem Hebel
    for (s = [-1, 1])
        intersection() {
            translate([s * rib_x, y_back + rib - rib_r]) circle(r = rib_r);
            translate([-cr_x, y_back - arm_w]) square([2 * cr_x, arm_w + rib]);
        }
}

// Arm, Laibungsschenkel, Federwurzel (starr)
module arm_profile() {
    rounded(round_r) union() {
        // Arm: rechtes Wiegenende -> unteres Schenkelende. Der Ansatz liegt
        // rechts der Rippe und um die Neigung ueber `height` vorn, sonst
        // ragt er oben in den Hebel.
        bar([cr_x + arm_w / 2 - rib_r, y_back - arm_w / 2 + lean_dy],
            [x_rev - wall / 2, y_dist - leg_len + wall / 2], arm_w);
        // Schenkel entlang der Laibung, bis ueber die Wandflaeche
        translate([x_rev - wall, y_dist - leg_len])
            square([wall, leg_len + leaf_gap + root_t]);
        // Federwurzel entlang der Wand
        translate([x_rev - wall, root_y])
            square([wall + root_len + leaf_t, root_t]);
    }
}

// Blattfeder: ungespannt schraeg, Spitze `preload` hinter der Wandflaeche
module leaf_profile() {
    bar([leaf_x0, root_y + leaf_t / 2],
        [leaf_x0 + leaf_len, y_dist - preload + leaf_t / 2], leaf_t);
}

// ---- Teil -------------------------------------------------------------------
module part() {
    lean() linear_extrude(height = height) cradle_profile();
    linear_extrude(height = height) {
        arm_profile();
        leaf_profile();
    }
}

// ---- Kontext (nur Ansicht) --------------------------------------------------
module context_lever() {
    lean() translate([-lever_w / 2, -lever_t / 2, -bar_z])
        cube([lever_w, lever_t, lever_straight + 30]);
}
module context_frame() {
    lean() translate([-150, y_frame - 70, -bar_z])
        cube([150 + x_dist - 15, 70, lever_straight + 30]);
}
module context_wall() {
    translate([x_dist, y_dist - 220, -bar_z]) cube([120, 220, lever_straight + 30]);
}

part();
if (show_context) %union() {
    context_lever();
    context_frame();
    context_wall();
}
