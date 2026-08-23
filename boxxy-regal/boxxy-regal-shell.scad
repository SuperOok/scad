// =============================================================================
// boxxy-regal-shell – gemeinsame Aussenform der Einsaetze
// =============================================================================
// Alles, was ein Einsatz fuer dieses Tuerregal an Aussenform braucht, damit
// boxxy-regal.scad (Wanne) und boxxy-regal-gridfinity.scad (Baseplate) nicht
// zwei Kopien derselben Geometrie pflegen.
//
// Enthaelt:
//   shell_outline_2d – Umriss: vorne (+Y) verrundet, hinten scharfkantig
//   shell_envelope   – Huellkoerper mit unten aussen verrundeter Kante
//   shell_inset_at   – wie weit die Verrundung auf Hoehe z einzieht
//
// Koordinaten: X mittig, y = 0 hinten (Tuerseite), y = depth vorne, z = 0 unten.
//
// Zur Verrundung: der Bogen wird aus geraden Kegelstuempfen (hull zwischen zwei
// offset-Scheiben) zusammengesetzt, steps Stueck ueber 90 Grad. Bei steps = 1
// entstuende eine 45-Grad-Fase – die kappt aber tieferliegende Waende, siehe
// den Assert in den aufrufenden Dateien.
// =============================================================================

// Aussenkontur. Nur die beiden vorderen Ecken (+Y) werden verrundet.
module shell_outline_2d(len, depth, r) {
    hx = len / 2;
    union() {
        translate([-hx, 0])              square([len, depth - r]);
        translate([-hx + r, 0])          square([len - 2 * r, depth]);
        translate([-hx + r, depth - r])  circle(r = r);
        translate([ hx - r, depth - r])  circle(r = r);
    }
}

// Huellkoerper: volle Grundflaeche, unten aussen umlaufend mit br verrundet.
// Das Teil wird damit verschnitten, statt jede Kante einzeln zu verrunden.
//
// Bogen in der Ebene (u = Abstand nach aussen, z), Mittelpunkt (-br, br),
// Radius br:  u(b) = br (cos b - 1),  z(b) = br (1 + sin b),
// b von -90 (unten, br nach innen) bis 0 (Endkontur erreicht).
module shell_envelope(len, depth, r, h, br, steps) {
    for (i = [0 : steps - 1]) {
        b0 = -90 + 90 * i / steps;
        b1 = -90 + 90 * (i + 1) / steps;
        hull() {
            translate([0, 0, br * (1 + sin(b0))])
                linear_extrude(0.01)
                    offset(delta = br * (cos(b0) - 1))
                        shell_outline_2d(len, depth, r);
            translate([0, 0, br * (1 + sin(b1))])
                linear_extrude(0.01)
                    offset(delta = br * (cos(b1) - 1))
                        shell_outline_2d(len, depth, r);
        }
    }
    translate([0, 0, br])
        linear_extrude(h - br + 1) shell_outline_2d(len, depth, r);
}

// Stuetzstellen des Bogens, genau wie shell_envelope() ihn baut.
function shell_band_z(i, br, steps)  = br * (1 + sin(-90 + 90 * i / steps));
function shell_band_in(i, br, steps) = br * (1 - cos(-90 + 90 * i / steps));

// Einzug der unteren Flanke auf Hoehe z. Zwischen zwei Stuetzstellen ist die
// Flanke gerade (hull), also linear interpoliert.
function shell_inset_at(z, br, steps, i = 0) =
      z >= br ? 0
    : shell_band_z(i + 1, br, steps) >= z
        ? shell_band_in(i, br, steps)
          + (shell_band_in(i + 1, br, steps) - shell_band_in(i, br, steps))
          * (z - shell_band_z(i, br, steps))
          / (shell_band_z(i + 1, br, steps) - shell_band_z(i, br, steps))
    : shell_inset_at(z, br, steps, i + 1);
