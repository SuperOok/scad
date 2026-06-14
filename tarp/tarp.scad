// =============================================================================
// tarp – Kederschiene punktuell hoeherlegen (Aluprofil-Lever)
// =============================================================================
// Kurze Alu-T-Nut-Profile als Stuetzen legen die Wohnwagen-Kederschiene
// punktuell ~15-20 cm hoeher. Das Profil ragt nach unten ueber die Schiene
// hinaus und lehnt sich an die Wand (Hebel) -> das Alu traegt die Biegung,
// die Druckteil-Clips sehen nur direkte Kraft.
//
// Druckteile:
//   rail_clip  – unten: T-Nut-Schraubbasis + Keder-Fuss in die vorhandene Schiene
//   tarp_clip  – oben : T-Nut-Schraubbasis + kurzes Kederschienen-Stueck (Tarp)
//   wall_pad   – unteres Profilende: breiter Fuss, der sich an die Wand lehnt
//
// ACHTUNG: erste parametrische Fassung mit Default-Massen. Kederprofil der
// vorhandenen Schiene, Tarp-Keder-Durchmesser und Alu-Profil/Nut bitte messen
// und unten anpassen. Last in der Druckebene halten; Hauptlast ueber Metall
// (Hammer-/Nutenstein + Schraube). Material ASA/PC, kein PLA.
//
// Koordinaten: X = entlang der Wand, Y = von der Wand weg (+Y aussen),
// Z = vertikal. Profil-Rueckseite zur Wand (-Y).
// =============================================================================

// ---- Alu-Profil (T-Nut) -----------------------------------------------------
profile_size = 30;        // 30x30 (oder 40)
slot_width = 8;           // Nutoeffnung (Nut 8)

// ---- Schraub-Interface (Hammer-/Nutenstein) ---------------------------------
bolt_clear = 6.6;         // M6 Durchgang
bolt_head = 11;           // M6 Zylinderkopf-Durchmesser
bolt_head_h = 6;          // Kopf-Senkung

// ---- Vorhandene Wohnwagen-Kederschiene (Fuss schiebt hinein) ----------------
rail_keder_d = 7;         // Keder-Bead-Durchmesser der Schiene
rail_keder_neck = 3;      // Steg-/Halsdicke
foot_len = 40;            // Laenge des Keder-Fusses (entlang X)
neck_len = 14;            // Abstand Schiene -> Profilrueckseite (Hebel zur Wand)

// ---- Tarp-Keder (Kanal-Stummel oben) ----------------------------------------
tarp_keder_d = 8;         // Tarp-Kederband-Durchmesser
tarp_clear = 0.6;         // Spiel im Kanal
tarp_slot = 4;            // Schlitzbreite (< Bead -> haelt)
tarp_channel_wall = 3.5;  // Wandstaerke des Kanals
stub_len = 50;            // Laenge des Kederschienen-Stuecks (entlang X)

// ---- Clip-Basis / Aufbau ----------------------------------------------------
clip_width = 28;          // Breite der Clip-Basis (X)
clip_wall = 6;            // Dicke der Clip-Basis (auf der Profilflaeche)
mount_len = 36;           // Laenge der Clip-Basis entlang Profil (Z)
fillet = 2;               // Radius an Lastkanten

raise_height = 180;       // Hoehe tarp_clip ueber rail_clip (15-20 cm)
profile_down_len = 150;   // wie weit das Profil unter die Schiene ragt
wall_gap = 18;            // Standoff Profilrueckseite -> Wand (Pad ueberbrueckt)

// ---- Wand-Pad ---------------------------------------------------------------
pad_w = 70;               // Breite (X)
pad_h = 48;               // Hoehe (Z)
pad_t = 5;                // Dicke an der Wand

// ---- Auswahl / Qualitaet ----------------------------------------------------
part = "assembly"; // [assembly, rail_clip, tarp_clip, wall_pad]
explode = 0;
$fn = 48;
eps = 0.01;

// ---- Abgeleitet -------------------------------------------------------------
front_y = profile_size / 2;             // Profil-Vorderflaeche (+Y)
back_y = -profile_size / 2;             // Profil-Rueckseite (-Y, Wandseite)
wall_y = back_y - wall_gap;             // Wandflaeche

// =============================================================================
// Gemeinsame Module
// =============================================================================

// Schraub-Durchgang + Kopfsenkung, Achse +Y (von aussen in die Nut).
module bolt_y(y_face, z, depth) {
    translate([0, y_face - eps, z]) rotate([-90, 0, 0])
        cylinder(d = bolt_clear, h = depth + 2 * eps);
    translate([0, y_face + depth - bolt_head_h, z]) rotate([-90, 0, 0])
        cylinder(d = bolt_head, h = bolt_head_h + eps);
}

// Clip-Basis auf der Profil-Vorderseite (+Y), Dicke nach +Y.
module mount_front(z_center) {
    difference() {
        translate([-clip_width / 2, front_y, z_center - mount_len / 2])
            cube([clip_width, clip_wall, mount_len]);
        bolt_y(front_y, z_center, clip_wall);
    }
}

// Clip-Basis auf der Profil-Rueckseite (-Y, Wandseite), Dicke nach -Y.
module mount_back(z_center, len = mount_len) {
    difference() {
        translate([-clip_width / 2, back_y - clip_wall, z_center - len / 2])
            cube([clip_width, clip_wall, len]);
        // Bolzen von der Wandseite (-Y) in die Nut (+Y)
        translate([0, back_y - clip_wall - eps, z_center]) rotate([-90, 0, 0])
            cylinder(d = bolt_clear, h = clip_wall + 2 * eps);
        translate([0, back_y - clip_wall - eps, z_center]) rotate([-90, 0, 0])
            cylinder(d = bolt_head, h = bolt_head_h + eps);
    }
}

// Keder-Bead (Rundprofil) entlang X mit Hals -> in die vorhandene Schiene.
module keder_foot() {
    // Bead an der Wand (-Y), Hals verbindet zur Profilrueckseite.
    bead_y = back_y - neck_len;
    // Hals (Steg)
    translate([-foot_len / 2, bead_y, -rail_keder_neck / 2])
        cube([foot_len, neck_len, rail_keder_neck]);
    // Bead (Zylinder entlang X)
    translate([-foot_len / 2, bead_y, 0]) rotate([0, 90, 0])
        cylinder(d = rail_keder_d, h = foot_len);
}

// Kurzer Keder-Kanal (C-Profil) entlang X, Schlitz nach unten (-Z).
module keder_channel() {
    outer = tarp_keder_d + 2 * tarp_channel_wall;
    difference() {
        translate([-stub_len / 2, -outer / 2, -outer / 2])
            cube([stub_len, outer, outer]);
        // Bohrung (Bead)
        translate([-stub_len / 2 - eps, 0, 0]) rotate([0, 90, 0])
            cylinder(d = tarp_keder_d + tarp_clear, h = stub_len + 2 * eps);
        // Schlitz nach unten
        translate([-stub_len / 2 - eps, -tarp_slot / 2, -outer])
            cube([stub_len + 2 * eps, tarp_slot, outer]);
    }
}

// =============================================================================
// Druckteile
// =============================================================================

module rail_clip() {
    mount_front(0);
    // Fuss greift von der Profilrueckseite zur Schiene an der Wand
    keder_foot();
    // Verbindung Basis (vorne) -> Fuss (hinten) ueber das Profil hinweg
    translate([-clip_width / 2, back_y - neck_len, -rail_keder_neck / 2])
        cube([clip_width, profile_size + neck_len + clip_wall, rail_keder_neck]);
}

module tarp_clip() {
    mount_front(raise_height);
    // Kanal vor dem Profil, oberhalb der Basismitte
    translate([0, front_y + clip_wall + (tarp_keder_d + 2 * tarp_channel_wall) / 2,
               raise_height])
        keder_channel();
    // Anbindung Basis -> Kanal
    translate([-clip_width / 2, front_y, raise_height - tarp_slot])
        cube([clip_width, clip_wall + (tarp_keder_d) / 2 + eps, 2 * tarp_slot]);
}

module wall_pad() {
    z = -profile_down_len;
    mount_back(z, pad_h);
    // breiter Pad an der Wand
    translate([-pad_w / 2, wall_y, z - pad_h / 2])
        cube([pad_w, pad_t, pad_h]);
    // Arm Profilrueckseite -> Wand
    translate([-clip_width / 2, wall_y, z - clip_wall / 2])
        cube([clip_width, wall_gap + clip_wall, clip_wall]);
}

// =============================================================================
// Vorschau / Dispatch
// =============================================================================

module ghost_profile() {
    color([0.7, 0.7, 0.75, 0.5])
        translate([-profile_size / 2, back_y, -profile_down_len - 25])
            cube([profile_size, profile_size, raise_height + profile_down_len + 60]);
}

module ghost_wall() {
    color([0.85, 0.8, 0.7, 0.35])
        translate([-120, wall_y - 6, -profile_down_len - 40])
            cube([240, 6, raise_height + profile_down_len + 90]);
}

module ghost_rail() {
    // grobe Andeutung der vorhandenen Kederschiene an der Wand bei z=0
    color([0.6, 0.6, 0.6, 0.5])
        translate([-120, back_y - neck_len - 2, -8])
            cube([240, 6, 16]);
}

module assembly() {
    ghost_wall();
    ghost_rail();
    ghost_profile();
    color("SteelBlue")    translate([0, 0, -explode]) rail_clip();
    color("Goldenrod")    translate([0, explode, explode]) tarp_clip();
    color("IndianRed")    translate([0, -explode, -2 * explode]) wall_pad();
}

if (part == "rail_clip")      rail_clip();
else if (part == "tarp_clip") tarp_clip();
else if (part == "wall_pad")  wall_pad();
else                          assembly();
