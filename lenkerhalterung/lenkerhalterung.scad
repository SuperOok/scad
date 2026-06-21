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
// Unter der mittigen Verdickung zeigt eine Lenkstange (~37 mm) nach UNTEN. Das
// untere Schellenteil (clamp_strap) hat deshalb einen nach unten und nach hinten
// (-Y) offenen Kanal (C-Form) und wird seitlich am Rohr vorbeigeschoben.
//
// Alle Teile sind im "seated"/Welt-Frame modelliert. Fuer den Druck einzelne
// Teile im Slicer passend drehen (siehe README).
// =============================================================================

// ---- Lenker -----------------------------------------------------------------
handlebar_diameter = 32;            // Lenker-Durchmesser an der Klemmstelle
handlebar_clearance = 0.2;          // Spiel in der Schelle
// Mittige Verdickung (Stem-Schelle), die ausgespart werden muss. Die Halterung
// ueberbrueckt sie und klemmt auf den geraden Zonen links/rechts.
bulge_width = 40;                   // Breite der Verdickung (entlang Lenker, X)
bulge_thickness = 5.5;              // radialer Ueberstand der Verdickung (Durchmesser +1 mm ggü. 5)
// Die Verdickung (Stem-Schelle) hat oben und unten lokale Schraubaugen, die noch
// weiter herausstehen. Pauschaler Extra-Radius, der zusaetzlich ausgespart wird,
// damit diese Augen frei liegen:
bulge_boss = 5;                     // radialer Extra-Ueberstand der Schraubaugen
bulge_clearance = 1;                // Luft um die Verdickung (radial)
bulge_clearance_x = 1;              // Luft seitlich der Verdickung (X)
mount_zone_width = 15;              // klemmbare, gerade Lenkerlaenge je Seite

// ---- Lenkstange (Vorbau-/Gabelschaftrohr unter der Verdickung) --------------
// Direkt unter der mittigen Verdickung zeigt ein Rohr nach UNTEN (zur Gabel).
// Das untere Schellenteil muss daran vorbeigeschoben werden koennen, ist also
// nach unten UND zu einer Seite hin offen (C-Form, kein geschlossener Ring).
stem_diameter = 37;                 // Rohr-Durchmesser unter der Verdickung
stem_clearance = 1.5;              // radiale Luft um das Rohr (Schiebespiel)
stem_tilt = 2;                      // Neigung nach hinten (Grad); Rohr unten -> -Y
stem_open = "back";                 // offene Schellenseite: "back" (-Y) | "front" (+Y)

// ---- Freistich-Bohrung hinten (Oberteil) -----------------------------------
// Waagerechte Bohrung von hinten (Achse Y) ins Oberteil, damit das nach hinten
// geneigte Rohr frei kommt. Der Bohrdurchmesser ist GROESSER als die Oeffnung:
// der Kreismittelpunkt liegt unter dem Boden, sodass der Schnitt mit der
// Rueckwand unten bore_width breit ist und bei z=bore_height auslaeuft.
bore_width = 40;                    // Breite der Oeffnung an der Rueckwand (X)
bore_height = 10;                   // Hoehe der Oeffnung ab Unterkante (Z)
bore_depth = 15;                    // Bohrtiefe nach vorn (durch die ganze Rueckwand)

// ---- Schelle (Klemme) -------------------------------------------------------
clamp_wall = 5;                     // Wandstaerke um den Lenker
clamp_screw_diameter = 4;           // M4
clamp_screw_clear = 4.6;            // Durchgangsloch M4
clamp_nut_af = 7;                   // M4 Mutter Schluesselweite (SW7)
clamp_nut_thickness = 3.4;          // M4 Mutter Hoehe + etwas Spiel
clamp_screw_head = 7.6;             // M4 Zylinderkopf-Durchmesser (Senkung)
// 4 Klemmschrauben (2 je Seite) mittig in den Klemmzonen, NEBEN dem Lenker und
// jenseits der mittigen Verdickung. Y-Versatz haelt die senkrechten Schrauben
// am Lenker vorbei; X-Versatz setzt sie in die Zonenmitte.
clamp_screw_x = bulge_width / 2 + mount_zone_width / 2;  // Mitte der Klemmzone
clamp_screw_y = 19.5;               // Y-Versatz (> bar_r + Bohrungsradius!)
clamp_split_gap = 0.6;              // Spalt Body/Strap fuer Klemmkraft

// ---- Schwalbenschwanz (Einschub) -------------------------------------------
dovetail_height = 25;               // Einschubtiefe in Z (Eingriffslaenge)
dovetail_depth = 8;                 // Tiefe in Y
dovetail_width_base = 22;           // Breite hinten (breit, zum Lenker)
dovetail_width_top = 14;            // Breite vorne (schmal) -> Hinterschnitt
dovetail_clearance = 0.35;          // FDM-Schiebesitz
dovetail_floor = 4;                 // Bodenanschlag unter der Nut
// Nut UND Zapfen zusaetzlich in den vollbreiten Koerper ziehen: der untere Teil
// des Eingriffs wird dann links/rechts von der vollen Bruecke flankiert (statt
// nur von den duennen Nutwaenden), und die Last verteilt sich auf mehr Layer
// statt genau auf die Uebergangslinie Turm->Koerper. Oberkante bleibt gleich.
dovetail_sink = 6;                  // Eingriff so weit unter z_stop verlaengern
groove_side_wall = 4;               // Wand seitlich der Nut
groove_back_wall = 4;               // Wand hinter der Nut (zum Lenker)

// ---- Platten / Sandwich -----------------------------------------------------
plate_screw_spacing = 37;           // Lochabstand (X), Mitte-zu-Mitte = Korbspalt-Abstand
// plate_width wird unten abgeleitet: breit genug fuer die zwei waagerechten
// Loecher (plate_screw_spacing) plus Mutterntaschen und Randsteg.
plate_thickness = 6;                // Dicke (Y) je Platte
plate_ext_bottom = 9;               // Plattenueberstand unter dem Zapfen
plate_ext_top = 6;                  // Plattenueberstand ueber dem Zapfen
plate_screw_diameter = 4;           // M4
plate_screw_clear = 4.6;            // Durchgangsloch M4
plate_nut_af = 7;                   // M4 Mutter SW7
plate_nut_thickness = 3.4;          // M4 Mutter Hoehe
basket_wall_nominal = 10;           // angenommene Koerbchenwand-Dicke (nur Vorschau)

// ---- Schloss ----------------------------------------------------------------
lock_hole_diameter = 3;             // Buegelloch (Buegel + Spiel)
// Einfacher Diebstahlschutz: ein Buegelloch durch die RUECKWAND der Nut, knapp
// oberhalb des eingeschobenen Zapfens. Der von hinten eingesteckte Schlossbuegel
// ragt in den Nutraum ueber dem Zapfen und sperrt ihn so am Herausziehen (Nut
// und Zapfen sind dabei nicht direkt verbunden). Die Nut wird dafuer nach oben
// verlaengert (gerundeter Kopf), damit ueber dem Loch genug Material bleibt.
lock_top_extra = 10;                // Nut-Verlaengerung nach oben (Z) fuers Buegelloch

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
// Freiraum um die mittige Verdickung (radial bzw. entlang Lenker):
bulge_clear_r = bar_r + bulge_thickness + bulge_boss + bulge_clearance;
bulge_half_clr = bulge_width / 2 + bulge_clearance_x;
stem_cut_r = stem_diameter / 2 + stem_clearance;    // Aussparungsradius f. Rohr
// Kreis (Achse Y) der Rueckwand-Bohrung: Mittelpunkt unter dem Boden, damit die
// Sehne bei z=0 = bore_width breit ist und der Scheitel bei z=bore_height liegt.
// R = ((bore_width/2)^2 + bore_height^2) / (2*bore_height)
bore_r = (pow(bore_width / 2, 2) + pow(bore_height, 2)) / (2 * bore_height);
bore_z = bore_height - bore_r;      // Kreismittelpunkt in Z (negativ -> unter Boden)
clamp_half_w = clamp_screw_x + nut_hex_r + 2;   // halbe Schellenbreite (X)
// Tiefe: Platz fuer die Muttern UND Rand-Stege, die die beiden Klemmseiten
// ueber die Mittenaussparung hinweg verbinden.
clamp_half_d = max(clamp_screw_y + nut_hex_r + 2, bulge_clear_r + 4);

front_y = clamp_half_d;                         // Vorderflaeche (Nut-Oeffnung)
z_stop = max(clamp_top, bulge_clear_r) + dovetail_floor;  // Sitz ueber Verdickung
groove_top = z_stop + dovetail_height;          // Oberkante Nut/Block (unveraendert)
// Eingriff reicht um dovetail_sink tiefer in den Koerper; Oberkante bleibt fix.
dovetail_seat = z_stop - dovetail_sink;         // tatsaechlicher Nut-/Zapfenboden
dovetail_engage = dovetail_height + dovetail_sink;  // Eingriffslaenge in Z
// Buegelloch in der Rueckwand der Nut, knapp ueber dem sitzenden Zapfen
// (Zapfen-Oberkante = groove_top). Nut+Block dafuer nach oben verlaengert.
lock_block_top = groove_top + lock_top_extra;            // Oberkante der verlaengerten Nut
lock_top_z = groove_top + lock_hole_diameter / 2 + 0.5;  // Buegelloch knapp ueber dem Zapfen
groove_block_y0 = front_y - (dovetail_depth + groove_back_wall);
groove_block_z0 = clamp_top - 2;                // kleiner Ueberlapp zur Schelle
groove_half_w = dovetail_width_base / 2 + groove_side_wall;

plate_back_y = front_y;                         // Plattenrueckseite an Vorderflaeche
plate_front_y = plate_back_y + plate_thickness;
plate_z0 = min(z_stop - plate_ext_bottom, dovetail_seat);  // Platte stuetzt den Zapfen bis zum Boden
plate_z1 = groove_top + plate_ext_top;
// Zwei waagerechte Schraubenloecher (links/rechts), mittig auf Plattenhoehe.
nut_pocket_r = plate_nut_af / cos(30) / 2;              // Aussenradius Mutterntasche
plate_width = max(30, plate_screw_spacing + 2 * (nut_pocket_r + 3.5));  // breit genug
plate_screw_half = plate_screw_spacing / 2;            // X-Versatz je Loch
plate_screw_z = (plate_z0 + plate_z1) / 2;             // Reihe auf halber Plattenhoehe

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
    // unten, Mutter in einer Sechskanttasche. Damit alle 4 Schrauben GLEICH LANG
    // sind, sitzt die Mutter ueberall auf gleicher Hoehe (Oberkante = clamp_top).
    // Auf der Schwalbenschwanz-Seite (sy=+1) deckt die Bruecke die Tasche ab;
    // dort wird die Sechskanttasche als Einschubkanal bis zur Bruecken-Oberkante
    // (z_stop) verlaengert, damit die Mutter von oben eingeschoben werden kann.
    nut_seat_z = clamp_top - clamp_nut_thickness;   // Auflage der Mutter (gleich fuer alle)
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx * clamp_screw_x, sy * clamp_screw_y, 0]) {
            // Durchgangsloch ueber die ganze Hoehe
            translate([0, 0, -clamp_bottom - eps])
                cylinder(d = clamp_screw_clear, h = clamp_bottom + clamp_top + 2 * eps);
            // Mutterntasche / Einschubkanal (oeffnet nach +Z). Hinten bis Body-
            // Oberkante, vorne (unter der Bruecke) bis zur Bruecken-Oberkante.
            pocket_top = (sy > 0) ? z_stop : clamp_top;
            translate([0, 0, nut_seat_z])
                nut_pocket(clamp_nut_af, pocket_top - nut_seat_z + eps);
        }
}

// Mittige Aussparung fuer die Verdickung (Zylinder um die Lenkerachse).
module bulge_recess() {
    rotate([0, 90, 0])
        translate([0, 0, -bulge_half_clr])
            cylinder(r = bulge_clear_r, h = 2 * bulge_half_clr);
}

// Vertikaler Kanal fuer die nach unten zeigende Lenkstange. Nach unten UND zu
// einer Seite (stem_open) offen -> das untere Schellenteil wird seitlich am
// Rohr vorbeigeschoben (C-Form). Achse 2 Grad nach hinten geneigt (Rohr unten
// Richtung -Y), daher rotate([-stem_tilt, ...]).
module stem_recess() {
    h = 4 * clamp_bottom;                   // deckt die ganze Straphoehe reichlich ab
    slot_len = 2 * clamp_half_d;            // Schlitz sicher ueber den Rand hinaus
    slot_y0 = (stem_open == "front") ? 0 : -slot_len;
    rotate([-stem_tilt, 0, 0]) {
        // Rohr selbst (vertikaler Zylinder, bildet die runde Schlitz-Innenseite)
        translate([0, 0, -h / 2])
            cylinder(r = stem_cut_r, h = h);
        // Schlitz zur offenen Seite hin
        translate([-stem_cut_r, slot_y0, -h / 2])
            cube([2 * stem_cut_r, slot_len, h]);
    }
}

// Waagerechte Bohrung von hinten: grosser Zylinder (Achse Y), dessen Mittelpunkt
// unter dem Boden liegt. Schneidet die Rueckwand als liegendes Kreissegment an
// (unten bore_width breit, bis z=bore_height) und geht durch die ganze Wand
// inkl. der inneren Woelbung (Verdickungs-Aussparung).
module rear_bore() {
    translate([0, -clamp_half_d - eps, bore_z])
        rotate([-90, 0, 0])
            cylinder(r = bore_r, h = bore_depth + eps);
}

// Schwalbenschwanz-Block, nach oben verlaengert mit flachem, an den Ober-Vorder-
// und -Hinterkanten gerundetem Kopf. Die hohe Rueckwand traegt das Buegelloch und
// behaelt darueber Material; der Nut-Schlitz wird im difference() oben offen
// durchgezogen (Einschub bleibt moeglich).
module dovetail_lock_lug() {
    rf = 2.5;                                   // Rundung der oberen Kanten
    hull() {
        translate([-groove_half_w, groove_block_y0, groove_block_z0])
            cube([2 * groove_half_w, front_y - groove_block_y0,
                  (lock_block_top - rf) - groove_block_z0]);
        for (yy = [groove_block_y0 + rf, front_y - rf])
            translate([0, yy, lock_block_top - rf])
                rotate([0, 90, 0])
                    cylinder(r = rf, h = 2 * groove_half_w, center = true);
    }
}

module halterung() {
    difference() {
        union() {
            // Klemm-Body ueber dem Lenker; die Mitte wird unten ausgespart,
            // sodass zwei Klemmbloecke (links/rechts) stehen bleiben.
            translate([-clamp_half_w, -clamp_half_d, 0])
                cube([2 * clamp_half_w, 2 * clamp_half_d, clamp_top]);
            // Bruecke vorne-oben: verbindet die beiden Klemmseiten ueber die
            // Verdickung hinweg und traegt den Schwalbenschwanz-Block.
            translate([-clamp_half_w, groove_block_y0, clamp_top - 3])
                cube([2 * clamp_half_w, front_y - groove_block_y0,
                      z_stop - (clamp_top - 3)]);
            // Schwalbenschwanz-Block vorne oben (nach oben verlaengert fuers Schloss)
            dovetail_lock_lug();
        }
        // Lenker-Aussparung (Mulde + Klemmspalt unten)
        rotate([0, 90, 0])
            translate([0, 0, -clamp_half_w - eps])
                cylinder(r = bar_hole_r, h = 2 * clamp_half_w + 2 * eps);
        // Mittige Verdickung aussparen
        bulge_recess();
        // Schwalbenschwanz-Nut: unten dovetail_sink in den Koerper, oben bis zur
        // verlaengerten Blockoberkante durchgezogen (Schlitz bleibt oben offen).
        translate([0, front_y, dovetail_seat])
            dovetail_prism(dovetail_width_top, dovetail_width_base, dovetail_depth,
                           lock_block_top - dovetail_seat + eps);
        // Buegelloch von hinten durch die Rueckwand in den Nutraum ueber dem
        // Zapfen (Achse Y). Der Buegel ragt dort hinein und sperrt den Zapfen.
        translate([0, groove_block_y0 - eps, lock_top_z])
            rotate([-90, 0, 0])
                cylinder(d = lock_hole_diameter, h = groove_back_wall + 4 + eps);
        clamp_screw_holes();
        // Waagerechte Bohrung von hinten fuer das geneigte Rohr
        rear_bore();
    }
}

// Unteres Schellenteil (separat), kappt den Lenker von unten. Die nach unten
// zeigende Lenkstange erzwingt einen nach unten und nach hinten (stem_open)
// offenen Kanal: das Teil ist daher eine C-Form aus zwei Klemmbloecken, die nur
// noch ueber den Steg auf der geschlossenen Seite verbunden sind. Jeder Block
// wird ohnehin separat mit 2 Schrauben gegen die Halterung gezogen.
module clamp_strap() {
    difference() {
        translate([-clamp_half_w, -clamp_half_d, -clamp_bottom])
            cube([2 * clamp_half_w, 2 * clamp_half_d, clamp_bottom - clamp_split_gap]);
        // Lenker-Aussparung
        rotate([0, 90, 0])
            translate([0, 0, -clamp_half_w - eps])
                cylinder(r = bar_hole_r, h = 2 * clamp_half_w + 2 * eps);
        // Mittige Verdickung aussparen
        bulge_recess();
        // Kanal fuer die nach unten zeigende Lenkstange (unten + hinten offen)
        stem_recess();
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
// Gegenstueck: mount_plate (Zapfen) und back_plate
// =============================================================================

module plate_blank() {
    translate([-plate_width / 2, 0, plate_z0])
        cube([plate_width, plate_thickness, plate_z1 - plate_z0]);
}

module plate_screw_positions() {
    // Zwei Loecher nebeneinander (X), beide auf halber Plattenhoehe.
    for (x = [-plate_screw_half, plate_screw_half])
        translate([x, 0, plate_screw_z]) children();
}

module mount_plate() {
    difference() {
        union() {
            translate([0, plate_back_y, 0]) plate_blank();
            // Schwalbenschwanz-Zapfen (mit Spiel) auf der -Y-Seite
            translate([0, front_y, dovetail_seat])
                dovetail_prism(
                    dovetail_width_top - 2 * dovetail_clearance,
                    dovetail_width_base - 2 * dovetail_clearance,
                    dovetail_depth - dovetail_clearance,
                    dovetail_engage);
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
    color([0.6, 0.6, 0.6, 0.35]) {
        rotate([0, 90, 0])
            translate([0, 0, -clamp_half_w - 15])
                cylinder(r = bar_r, h = 2 * clamp_half_w + 30);
        // mittige Verdickung
        rotate([0, 90, 0])
            translate([0, 0, -bulge_width / 2])
                cylinder(r = bar_r + bulge_thickness, h = bulge_width);
        // Schraubaugen oben/unten (angedeutete Huellkurve, +/-Z)
        for (sz = [-1, 1])
            translate([0, 0, sz * (bar_r + bulge_thickness)])
                rotate([0, 90, 0])
                    translate([0, 0, -bulge_width / 4])
                        cylinder(r = bulge_boss, h = bulge_width / 2);
        // Lenkstange: Rohr nach unten (2 Grad nach hinten geneigt)
        rotate([-stem_tilt, 0, 0])
            translate([0, 0, -70])
                cylinder(r = stem_diameter / 2, h = 70);
    }
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
