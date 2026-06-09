// =============================================================================
// Lenkerhalterung mit abschliessbarem Koerbchen-Gegenstueck
// =============================================================================
// Zwei Baugruppen:
//   * Halterung  -> wird mit einer Schelle fest an den Lenker geschraubt
//                   (bleibt am Rad), traegt vorne eine Schwalbenschwanz-Nut.
//   * Gegenstueck -> zwei Platten (mount_plate + back_plate), die eine
//                   Koerbchenwand zwischen sich klemmen (M4 + versenkte Mutter).
//                   Die mount_plate traegt den Schwalbenschwanz-Zapfen und
//                   haengt sich von oben in die Halterung ein. Ein kleines
//                   Vorhaengeschloss durch die fluchtenden Oesen blockiert das
//                   Herausziehen nach oben -> Diebstahlschutz.
//
// Koordinaten (Einbaulage):
//   X = entlang der Lenkerachse (quer zum Rad)
//   Y = vor/zurueck (+Y = Fahrtrichtung, Koerbchen vorne)
//   Z = oben; Schwalbenschwanz gleitet in -Z ein, loesen = +Z.
//
// Alle Teile sind im "seated"/Welt-Frame modelliert. Fuer den Druck einzelne
// Teile im Slicer passend drehen (siehe README).
// =============================================================================

// ---- Lenker -----------------------------------------------------------------
handlebar_diameter = 25.4;          // Lenker-Durchmesser an der Klemmstelle
handlebar_clearance = 0.2;          // Spiel in der Schelle

// ---- Schelle (Klemme) -------------------------------------------------------
clamp_wall = 5;                     // Wandstaerke um den Lenker
clamp_screw_diameter = 4;           // M4
clamp_screw_clear = 4.6;            // Durchgangsloch M4
clamp_nut_af = 7;                   // M4 Mutter Schluesselweite (SW7)
clamp_nut_thickness = 3.4;          // M4 Mutter Hoehe + etwas Spiel
clamp_screw_head = 7.6;             // M4 Zylinderkopf-Durchmesser (Senkung)
// 4 Klemmschrauben an den Ecken, bewusst NEBEN dem Lenker. Der Y-Versatz haelt
// die senkrechten Schrauben am massiven Lenker vorbei, der X-Versatz frei vom
// Schwalbenschwanz-Block.
clamp_screw_x = 18;                 // X-Versatz (> Nut-Block-Halbbreite)
clamp_screw_y = 15.5;               // Y-Versatz (> bar_r + Bohrungsradius!)
clamp_split_gap = 0.6;              // Spalt Body/Strap fuer Klemmkraft

// ---- Schwalbenschwanz (Einschub) -------------------------------------------
dovetail_height = 30;               // Einschubtiefe in Z (Eingriffslaenge)
dovetail_depth = 8;                 // Tiefe in Y
dovetail_width_base = 22;           // Breite hinten (breit, zum Lenker)
dovetail_width_top = 14;            // Breite vorne (schmal) -> Hinterschnitt
dovetail_clearance = 0.35;          // FDM-Schiebesitz
dovetail_floor = 4;                 // Bodenanschlag unter der Nut
groove_side_wall = 4;               // Wand seitlich der Nut
groove_back_wall = 4;               // Wand hinter der Nut (zum Lenker)

// ---- Platten / Sandwich -----------------------------------------------------
plate_width = 30;                   // Breite (X)
plate_thickness = 6;                // Dicke (Y) je Platte
plate_ext_bottom = 12;              // Plattenueberstand unter dem Zapfen
plate_ext_top = 8;                  // Plattenueberstand ueber dem Zapfen
plate_screw_diameter = 4;           // M4
plate_screw_clear = 4.6;            // Durchgangsloch M4
plate_nut_af = 7;                   // M4 Mutter SW7
plate_nut_thickness = 3.4;          // M4 Mutter Hoehe
basket_wall_nominal = 10;           // angenommene Koerbchenwand-Dicke (nur Vorschau)

// ---- Schloss ----------------------------------------------------------------
shackle_diameter = 2;               // Buegeldurchmesser des Vorhaengeschlosses
lock_hole_diameter = 3;             // Oesen-Loch (Buegel + Spiel)
ear_width = 9;                      // Oesenbreite (X)
ear_depth = 6;                      // Oesentiefe (Y)
ear_gap = 1;                        // Y-Spalt zwischen den beiden Oesen
ear_thickness = 7;                  // Oesenhoehe (Z)

// ---- Auswahl / Qualitaet ----------------------------------------------------
part = "assembly"; // [assembly, halterung, clamp_strap, mount_plate, back_plate]
explode = 0;        // Explosionsabstand fuer die Vorschau (mm), 0 = zusammengebaut
$fn = 64;
eps = 0.01;

// ---- Abgeleitete Groessen ---------------------------------------------------
bar_r = handlebar_diameter / 2;
bar_hole_r = bar_r + handlebar_clearance;
clamp_top = bar_r + clamp_wall;                 // Oberkante Schellen-Body (+Z)
clamp_bottom = bar_r + clamp_wall;              // Unterkante Schellen-Strap (-Z)
nut_hex_r = clamp_nut_af / cos(30) / 2;         // Aussenradius der Mutterntasche
clamp_half_w = clamp_screw_x + nut_hex_r + 2;   // halbe Schellenbreite (X)
clamp_half_d = clamp_screw_y + nut_hex_r + 2;   // halbe Schellentiefe (Y)

front_y = clamp_half_d;                         // Vorderflaeche (Nut-Oeffnung)
z_stop = clamp_top + dovetail_floor;            // Sitzanschlag (Zapfen-Unterkante)
groove_top = z_stop + dovetail_height;          // Oberkante Nut/Block
groove_block_y0 = front_y - (dovetail_depth + groove_back_wall);
groove_block_z0 = clamp_top - 2;                // kleiner Ueberlapp zur Schelle
groove_half_w = dovetail_width_base / 2 + groove_side_wall;

plate_back_y = front_y;                         // Plattenrueckseite an Vorderflaeche
plate_front_y = plate_back_y + plate_thickness;
plate_z0 = z_stop - plate_ext_bottom;
plate_z1 = groove_top + plate_ext_top;
plate_screw_z_lo = z_stop - plate_ext_bottom / 2 - 1;   // unter dem Zapfen
plate_screw_z_hi = groove_top + plate_ext_top / 2 + 1;  // ueber dem Zapfen

ear_x = plate_width / 2 + ear_gap + ear_width / 2;      // Oesen-X (ausserhalb Platte)
lock_z = (z_stop + groove_top) / 2;                     // Schlosshoehe (Buegel)
halt_ear_y1 = front_y;                                  // Halterungs-Oese hinten
halt_ear_y0 = front_y - ear_depth;
plate_ear_y0 = front_y + ear_gap;                       // Platten-Oese vorne
plate_ear_y1 = plate_ear_y0 + ear_depth;

// =============================================================================
// Hilfsmodule
// =============================================================================

// Sechskant-Tasche fuer eine Mutter (Schluesselweite af, Hoehe h), Achse +Z.
module nut_pocket(af, h) {
    rotate([0, 0, 30])
        cylinder(d = af / cos(30) + 0.2, h = h, $fn = 6);
}

// Schwalbenschwanz-Prisma: Oeffnung (schmal, w_top) bei y=0, Basis (breit,
// w_base) bei y=-depth; extrudiert in Z von 0..h.
module dovetail_prism(w_top, w_base, depth, h) {
    linear_extrude(height = h)
        polygon([
            [-w_top / 2, 0],
            [ w_top / 2, 0],
            [ w_base / 2, -depth],
            [-w_base / 2, -depth],
        ]);
}

// =============================================================================
// Halterung (am Lenker, fest verschraubt)
// =============================================================================

module clamp_screw_holes() {
    // 4 senkrechte M4-Schrauben an den Ecken, NEBEN dem Lenker. Schraube von
    // unten, Mutter in einer Sechskanttasche oben im Body.
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx * clamp_screw_x, sy * clamp_screw_y, 0]) {
            // Durchgangsloch ueber die ganze Hoehe
            translate([0, 0, -clamp_bottom - eps])
                cylinder(d = clamp_screw_clear, h = clamp_bottom + clamp_top + 2 * eps);
            // Mutterntasche oben (oeffnet nach +Z)
            translate([0, 0, clamp_top - clamp_nut_thickness])
                nut_pocket(clamp_nut_af, clamp_nut_thickness + eps);
        }
}

module halterung() {
    difference() {
        union() {
            // Schellen-Body ueber dem Lenker
            translate([-clamp_half_w, -clamp_half_d, 0])
                cube([2 * clamp_half_w, 2 * clamp_half_d, clamp_top]);
            // Schwalbenschwanz-Block vorne oben
            translate([-groove_half_w, groove_block_y0, groove_block_z0])
                cube([2 * groove_half_w, front_y - groove_block_y0, groove_top - groove_block_z0]);
            // Schloss-Oese (seitlich, +X), hinterer Part des Oesenpaares
            lock_ear(halt_ear_y0, halt_ear_y1);
        }
        // Lenker-Aussparung (Mulde + Klemmspalt unten)
        rotate([0, 90, 0])
            translate([0, 0, -clamp_half_w - eps])
                cylinder(r = bar_hole_r, h = 2 * clamp_half_w + 2 * eps);
        // Schwalbenschwanz-Nut (oben offen)
        translate([0, front_y, z_stop])
            dovetail_prism(dovetail_width_top, dovetail_width_base, dovetail_depth,
                           dovetail_height + eps);
        clamp_screw_holes();
        lock_hole();
    }
}

// Unteres Schellenteil (separat), kappt den Lenker von unten.
module clamp_strap() {
    difference() {
        translate([-clamp_half_w, -clamp_half_d, -clamp_bottom])
            cube([2 * clamp_half_w, 2 * clamp_half_d, clamp_bottom - clamp_split_gap]);
        // Lenker-Aussparung
        rotate([0, 90, 0])
            translate([0, 0, -clamp_half_w - eps])
                cylinder(r = bar_hole_r, h = 2 * clamp_half_w + 2 * eps);
        // Schraubenloecher + Kopfsenkung unten
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * clamp_screw_x, sy * clamp_screw_y, 0]) {
                translate([0, 0, -clamp_bottom - eps])
                    cylinder(d = clamp_screw_clear, h = clamp_bottom + 2 * eps);
                translate([0, 0, -clamp_bottom - eps])
                    cylinder(d = clamp_screw_head, h = clamp_wall);
            }
    }
}

// =============================================================================
// Schloss-Oesen (eine seitlich aussen, +X)
// =============================================================================

// Eine Oese als Quader im Y-Bereich [y0,y1], zentriert auf ear_x / lock_z.
module lock_ear(y0, y1) {
    translate([ear_x - ear_width / 2, y0, lock_z - ear_thickness / 2])
        cube([ear_width, y1 - y0, ear_thickness]);
    // Steg zur Verbindung mit dem Koerper (von der Blockkante bis zur Oese)
    bridge_x0 = groove_half_w - eps;
    translate([bridge_x0, y0, lock_z - ear_thickness / 2])
        cube([ear_x - ear_width / 2 - bridge_x0 + eps, y1 - y0, ear_thickness]);
}

module lock_hole() {
    // Querloch durch beide Oesen (Achse Y), fuer den Schlossbuegel.
    translate([ear_x, halt_ear_y0 - eps, lock_z])
        rotate([-90, 0, 0])
            cylinder(d = lock_hole_diameter, h = plate_ear_y1 - halt_ear_y0 + 2 * eps);
}

// =============================================================================
// Gegenstueck: mount_plate (Zapfen + Oese) und back_plate
// =============================================================================

module plate_blank() {
    translate([-plate_width / 2, 0, plate_z0])
        cube([plate_width, plate_thickness, plate_z1 - plate_z0]);
}

module plate_screw_positions() {
    for (z = [plate_screw_z_lo, plate_screw_z_hi])
        translate([0, 0, z]) children();
}

module mount_plate() {
    difference() {
        union() {
            translate([0, plate_back_y, 0]) plate_blank();
            // Schwalbenschwanz-Zapfen (mit Spiel) auf der -Y-Seite
            translate([0, front_y, z_stop])
                dovetail_prism(
                    dovetail_width_top - 2 * dovetail_clearance,
                    dovetail_width_base - 2 * dovetail_clearance,
                    dovetail_depth - dovetail_clearance,
                    dovetail_height);
            // Schloss-Oese (vorderer Part), seitlich +X
            lock_ear(plate_ear_y0, plate_ear_y1);
        }
        // M4-Durchgang + Mutterntasche (oeffnet zur Koerbchenseite, +Y)
        plate_screw_positions() {
            rotate([-90, 0, 0])
                translate([0, 0, plate_back_y - eps])
                    cylinder(d = plate_screw_clear, h = plate_thickness + 2 * eps);
            translate([0, plate_front_y - plate_nut_thickness, 0])
                rotate([-90, 0, 0])
                    nut_pocket(plate_nut_af, plate_nut_thickness + eps);
        }
        lock_hole();
    }
}

module back_plate() {
    back_y = plate_front_y + basket_wall_nominal;   // Position in der Vorschau
    difference() {
        translate([0, back_y, 0]) plate_blank();
        // M4-Durchgang (Kopf liegt auf der +Y-Aussenseite)
        plate_screw_positions()
            rotate([-90, 0, 0])
                translate([0, 0, back_y - eps])
                    cylinder(d = plate_screw_clear, h = plate_thickness + 2 * eps);
    }
}

// =============================================================================
// Vorschau / Dispatch
// =============================================================================

module ghost_handlebar() {
    color([0.6, 0.6, 0.6, 0.35])
        rotate([0, 90, 0])
            translate([0, 0, -clamp_half_w - 15])
                cylinder(r = bar_r, h = 2 * clamp_half_w + 30);
}

module assembly() {
    ghost_handlebar();
    color("SteelBlue")      halterung();
    color("LightSteelBlue") translate([0, 0, -explode]) clamp_strap();
    // Gegenstueck zur Vorschau nach oben (Einschubrichtung) herausgezogen
    translate([0, 0, explode]) {
        color("Goldenrod")  mount_plate();
        color("DarkKhaki")  back_plate();
    }
}

if (part == "halterung")        halterung();
else if (part == "clamp_strap") clamp_strap();
else if (part == "mount_plate") mount_plate();
else if (part == "back_plate")  back_plate();
else                            assembly();
