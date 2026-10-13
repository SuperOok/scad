// =============================================================================
// Der Haken – breiter Zughaken mit Gurtschlitz
// =============================================================================
// Ein breiter U-/J-Haken: langer Schenkel mit Schlitz fuer einen Nylon-Gurt
// (zum Ziehen), kurzer Schenkel leicht nach aussen gestellt, sodass sich das
// Hakenmaul vom Scheitel (hook_gap) zur Spitze (hook_mouth) oeffnet.
// Beide Schenkelenden halbrund, alle Kanten mit edge_r verrundet.
//
// Koordinaten (Profil):
//   X = quer zu den Schenkeln (langer Schenkel bei -X)
//   Y = entlang der Schenkel (Biegung unten, Spitzen oben)
//   Z = Hakenbreite (hook_width)
//   Mittelpunkt der Innenrundung im Scheitel liegt bei (0, 0).
//
// DRUCK: so wie modelliert, also auf der Seite liegend (Profil in der
// Schichtebene). Dann laeuft der Zug durch die Biegung entlang der Bahnen,
// nicht ueber Schichtgrenzen. Der Gurtschlitz ist in jeder Schicht ein
// Durchbruch; oben/unten nur eine kurze Bruecke (slot_h). Stuetzfrei.
// ASA, >= 4 Perimeter, >= 40 % Infill.
// =============================================================================

// ---- Grundmasse -------------------------------------------------------------
hook_width  = 60;    // Breite des Hakens (Z, = Druckhoehe)
long_len    = 150;   // langer Schenkel, Aussenmass Biegung unten -> Spitze
short_len   = 70;    // kurzer Schenkel, Aussenmass Biegung unten -> Spitze
wall        = 10;    // Materialstaerke von Schenkeln und Biegung
hook_gap    = 20;    // lichte Weite im Scheitel (Innenrundung)
hook_mouth  = 35;    // lichte Weite an der Spitze des kurzen Schenkels

// ---- Gurtschlitz im langen Schenkel -----------------------------------------
strap_w        = 25;  // Gurtbreite
strap_t        = 2;   // Gurtdicke
strap_clear    = 1.5; // Spiel je Seite in der Breite
slot_h         = 5;   // Schlitzhoehe entlang des Schenkels (Gurtdicke + Luft)
slot_from_tip  = 22;  // Schlitzmitte -> Spitze des langen Schenkels

// ---- Verrundung -------------------------------------------------------------
edge_r   = 2;    // Kantenradius aller Kanten (Minkowski-Kugel)

$fn = 96;
sphere_fn = 16;  // Facetten der Minkowski-Kugel (Renderzeit!)

// ---- abgeleitete Werte ------------------------------------------------------
r_in     = hook_gap / 2;
r_out    = r_in + wall;
r_mid    = r_in + wall / 2;
y_bottom = -r_out;                              // Aussenkante der Biegung
long_tip_y  = y_bottom + long_len - wall / 2;   // Mittelpunkt Endrundung
short_tip_y = y_bottom + short_len - wall / 2;
long_cx  = -r_mid;                              // Mittellinie langer Schenkel

// Der kurze Schenkel ist um short_tilt nach aussen gekippt und schliesst
// tangential an die Biegung an (Bogen endet bei -short_tilt). short_tilt wird
// so bestimmt, dass die lichte Weite (in X) auf Hoehe der Spitze hook_mouth ist.
function mouth_at(a) =
    r_in + r_in * cos(a) + (short_tip_y + r_in * sin(a)) * tan(a);
function solve_tilt(lo = 0, hi = 45, n = 40) =
    n == 0 ? (lo + hi) / 2
  : mouth_at((lo + hi) / 2) < hook_mouth ? solve_tilt((lo + hi) / 2, hi, n - 1)
                                         : solve_tilt(lo, (lo + hi) / 2, n - 1);
short_tilt = solve_tilt();
short_base = r_mid * [cos(short_tilt), -sin(short_tilt)];
short_tip  = short_base
           + (short_tip_y - short_base[1]) / cos(short_tilt)
             * [sin(short_tilt), cos(short_tilt)];
echo(short_tilt = short_tilt, mouth = mouth_at(short_tilt));
slot_y   = long_tip_y + wall / 2 - slot_from_tip;
slot_len = strap_w + 2 * strap_clear;

assert(hook_mouth >= hook_gap, "hook_mouth muss >= hook_gap sein");
assert(slot_h > strap_t, str("slot_h ", slot_h, " <= Gurtdicke ", strap_t));
assert(slot_len + 2 * edge_r + 2 * 5 <= hook_width,
       str("Schlitz ", slot_len, " zu breit fuer hook_width ", hook_width));
assert(slot_from_tip - slot_h / 2 >= 12,
       str("Steg zwischen Schlitz und Spitze nur ",
           slot_from_tip - slot_h / 2, " mm"));
assert(edge_r < wall / 2 && edge_r < hook_width / 2, "edge_r zu gross");

// ---- 2D-Profil --------------------------------------------------------------
module leg(a, b) {
    hull() {
        translate(a) circle(d = wall);
        translate(b) circle(d = wall);
    }
}

module bend() {
    // Kreisring-Bogen von 180 Grad (langer Schenkel) bis -short_tilt
    a1 = 360 - short_tilt;
    steps = 48;
    R = r_out + 1;
    difference() {
        circle(r = r_out);
        circle(r = r_in);
        difference() {
            circle(r = R);
            polygon(concat([[0, 0]],
                [for (i = [0 : steps]) let(a = 180 + (a1 - 180) * i / steps)
                    R * [cos(a), sin(a)]]));
        }
    }
}

module profile() {
    union() {
        bend();
        leg([long_cx, 0], [long_cx, long_tip_y]);
        leg(short_base, short_tip);
    }
}

// ---- 3D ---------------------------------------------------------------------
module slot_cut(grow) {
    // Durchbruch quer durch den langen Schenkel (entlang X)
    translate([long_cx, slot_y, hook_width / 2])
        cube([wall + 2, slot_h + 2 * grow, slot_len + 2 * grow], center = true);
}

module body_core() {
    // um edge_r geschrumpfter Kern; die Minkowski-Kugel bringt ihn auf Mass
    difference() {
        translate([0, 0, edge_r])
            linear_extrude(height = hook_width - 2 * edge_r)
                offset(r = -edge_r) profile();
        slot_cut(edge_r);
    }
}

module haken() {
    minkowski() {
        body_core();
        sphere(r = edge_r, $fn = sphere_fn);
    }
}

haken();
