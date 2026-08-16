// =============================================================================
// tarp – Kederschiene punktuell hoeherlegen (Alu-Vierkantrohr als Hebel)
// =============================================================================
// Kurze Stuecke Alu-Vierkantrohr 15x15x1 legen die Wohnwagen-Kederschiene
// punktuell ~15-20 cm hoeher. Das Rohr ragt nach unten ueber die Schiene hinaus
// und stuetzt sich an der Wand ab (Hebel) -> das Alu traegt die Biegung, die
// Druckteile sehen nur direkte Kraft.
//
// Druckteile – alle drei sind Huelsen, die ueber das Rohr geschoben und mit
// je EINER M5-Durchsteckschraube gesichert werden:
//   rail_clip – Huelse + Keder-Fuss in die vorhandene Schiene   (z = 0)
//   tarp_clip – Huelse mit Deckel + Keder-C-Kanal fuers Tarp     (z = raise_height)
//   wall_pad  – Huelse mit Deckel + breiter Fuss gegen die Wand  (z = -tube_down_len)
//
// Koordinaten: X = entlang der Wand, Y = von der Wand weg (+Y aussen),
// Z = vertikal. Rohr-Rueckseite zur Wand (-Y).
//
// -----------------------------------------------------------------------------
// STATIK (Rohr 15x15x1, AlMgSi)
// -----------------------------------------------------------------------------
//   I = (15^4 - 13^4)/12 ~ 1839 mm^4,  W = I/7.5 ~ 245 mm^3
//   sigma_zul ~ 70 MPa (Sicherheit ~2 gegen Rp0.2 ~ 160 MPa) -> M_zul ~ 17 Nm
//   Groesstes Moment sitzt an der Schienen-Anbindung: M = F * raise_height.
//   Bei raise_height = 180 mm -> F_zul ~ 95 N (~9.5 kg) Zug je Stuetze.
//   => Mehrere Stuetzen setzen, Tarp nicht knallhart spannen. Bei Sturm abbauen.
//
//   Auflagerkraefte (F = Zug am oberen Keder, nach aussen):
//     Wand-Pad  R_wand = F * raise_height / tube_down_len   (0.82 F bei 180/220)
//     Schiene   R_rail = F + R_wand                          (1.82 F)
//   Die vorhandene Kederschiene wird also mit ~1.8 F nach AUSSEN gezogen –
//   das ist das schwaechste Glied. Der Keder-Fuss ist trotzdem nur so lang
//   wie die Huelse (~22 mm), weil die vorhandene Schiene am Anfang leicht
//   gebogen ist: ein langes gerades Keder-Stueck laesst sich dort nicht
//   einfaedeln. Damit liegen bei F_zul ~7.7 N/mm auf den Schienenlippen
//   (statt 2.9 N/mm bei 60 mm Fuss) -> das ueber MEHR STUETZEN ausgleichen
//   und weniger stramm spannen, nicht ueber einen laengeren Fuss.
//   Groesseres tube_down_len senkt beide Auflagerkraefte (aber nicht M).
//
// -----------------------------------------------------------------------------
// BOHREN – Richtung ist entscheidend
// -----------------------------------------------------------------------------
//   Alle Bohrungen laufen entlang X (parallel zur Wand), also durch die beiden
//   SEITENwaende des Rohrs. Dort liegt das Material nahe der neutralen Faser:
//     Bohrung 5.5 mm entlang X (Stege)   -> ~1.5 % Verlust an I
//     Bohrung 5.5 mm entlang Y (Gurte)   -> ~29 % Verlust an I
//   Niemals in Lastrichtung (Y) bohren.
//
//   Vorgehen: Huelse aufschieben, ausrichten, durch die Bohrung der Huelse
//   anzeichnen, Huelse abziehen, Rohr bohren (5.5 mm), wieder aufschieben.
//
//   Verschraubung: M5 Zylinderkopf + Scheibe / Nyloc + Scheibe, beides AUSSEN.
//   Bewusst keine Mutterntasche im Bauteil – bei 3.5 mm Huelsenwand wuerde die
//   Senkung in den Rohrquerschnitt schneiden.
//   Mutter nur handfest anziehen (Schraube = Scherstift, kein Klemmverband).
//   Wer fest anziehen will, braucht eine 13 mm lange Distanzhuelse IM Rohr,
//   sonst wird die 1-mm-Wand eingedrueckt.
//
// -----------------------------------------------------------------------------
// DRUCK
// -----------------------------------------------------------------------------
//   Material ASA/PC/PETG-CF, kein PLA (Sonne, Kriechen).
//   Empfohlene Lage: Teil so kippen, dass die KEDER-Achse (Modell-X) senkrecht
//   steht. Dann sind Fuss, Kanal und Wandplatte reine Vertikal-Extrusionen
//   (keine Stuetzen), und der Lastpfad Fuss -> Huelse liegt in der Schichtebene.
//   Einzige Bruecke ist die quadratische Rohroeffnung (15.4 mm) – unkritisch.
//   >= 4 Perimeter, >= 40 % Infill.
//
// -----------------------------------------------------------------------------
// SCHIENENPROFIL (2026-08-02 am Wohnwagen abgenommen)
// -----------------------------------------------------------------------------
//   Bead 9, Schlitz 5, Lippe 2, Bead-Mitte -> Wand 10, Freiraum vor der
//   Schiene 5. Tarp-Keder 9. Der Schlitz steht NICHT waagerecht, sondern
//   oeffnet sich ~10 Grad nach oben-aussen (rail_slot_angle).
//
//   Alle Schienenmasse sind so definiert, dass sie direkt messbar sind:
//     rail_keder_d   Innendurchmesser der runden Nut
//     rail_slot_w    lichte Schlitzbreite
//     rail_lip_depth Lippendicke, ab Bead-AUSSENkante (nicht ab Mitte)
//     rail_depth     Bead-Mitte -> Wandflaeche
//     rail_clear     freie Luft Schienen-Vorderkante -> Rohr
//     rail_slot_angle Neigung des Schlitzes, + = nach oben-aussen
//   rail_reach (Bead-Mitte -> Huelse) wird daraus gerechnet, nicht gemessen.
//
//   Der Fuss bleibt ueber lip_out + neck_extra = 7.5 mm ab Bead-Mitte duenn
//   und weitet sich erst danach auf. Bei rail_clear = 5 startet die
//   Aufweitung 1 mm vor der Schiene, in freier Luft. Wird rail_clear kleiner
//   als neck_extra, schlaegt ein assert an.
//
//   Die Neigung kippt nur Bead und Hals um die Bead-Mitte; die Fusswurzel an
//   der Huelse bleibt waagerecht und das Rohr senkrecht.
// =============================================================================

// ---- Alu-Vierkantrohr (gemessen) --------------------------------------------
tube_w      = 15;    // Aussenmass, quadratisch
tube_wall   = 1;     // Wandstaerke (nur Doku/Statik)
tube_fit    = 0.4;   // Spiel Huelse <-> Rohr (Schiebesitz)

// ---- Huelse ------------------------------------------------------------------
sleeve_wall = 3.5;   // Wandstaerke der gedruckten Huelse
sleeve_r    = 2;     // Kantenradius aussen

// ---- Durchsteckschraube (Achse X, durch die Rohr-Seitenwaende) ---------------
pin_d       = 5.4;   // M5 Durchgang im Druckteil (Rohr: 5.5 mm bohren)

// ---- Vorhandene Wohnwagen-Kederschiene (Fuss schiebt hinein) ----------------
rail_keder_d   = 9;    // GEMESSEN Keder-Bead-Durchmesser der Schiene
rail_slot_w    = 5;    // GEMESSEN Schlitzbreite der Schiene
rail_lip_depth = 2;    // GEMESSEN Lippendicke der Schiene:
                       // Bead-AUSSENKANTE -> Schienen-Aussenflaeche (nicht ab Mitte!)
neck_extra     = 1;    // Hals bleibt so viel laenger duenn als die Lippe dick ist,
                       // damit die Aufweitung nicht an der Lippenkante klemmt
rail_slot_angle = 10;  // GEMESSEN Neigung des Schienenschlitzes gegen die
                       // Waagerechte. POSITIV = Schlitz oeffnet sich nach
                       // OBEN-aussen, d.h. der Fuss laeuft von der Huelse aus
                       // nach innen leicht abwaerts. Das Rohr bleibt senkrecht.
rail_depth     = 10;   // GEMESSEN Bead-Mitte -> Wandflaeche
rail_clear     = 5;    // GEMESSEN freie Luft zwischen Schienen-VORDERKANTE und
                       // Rohr/Huelse. Das ist die real messbare Groesse; der
                       // Wandabstand des Rohrs faellt daraus ab (s. Abgeleitet).
                       // Muss > neck_extra sein, sonst weitet sich der Fuss
                       // schon in der Schiene auf.
rail_fit       = 0.4;  // Untermass von Bead und Hals
foot_extra     = 0;    // Fusslaenge = Huelsenbreite + 2*foot_extra (s. Abgeleitet).
                       // Kurz halten! Die vorhandene Schiene ist am Anfang
                       // gebogen, ein langes gerades Keder-Stueck haengt fest.
foot_chamfer   = 1.2;  // Anfasung an den Fussenden (Einfaedelhilfe)
foot_web_t     = 6;    // Stegdicke ausserhalb der Schiene
foot_root_h    = 12;   // Steghoehe am Uebergang zur Huelse (Kerbentschaerfung)

// ---- Tarp-Keder (C-Kanal oben) ----------------------------------------------
tarp_keder_d      = 9;    // GEMESSEN Tarp-Kederband-Durchmesser
tarp_fit          = 0.6;  // Spiel im Kanal
tarp_slot_w       = 4;    // Schlitzbreite (< Bead -> haelt)
tarp_channel_wall = 3.5;  // Wandstaerke des Kanals
stub_len          = 60;   // Laenge des Kederschienen-Stuecks (X)
stub_web_t        = 6;    // Steg Huelse -> Kanal

// ---- Huelsenlaengen ----------------------------------------------------------
rail_sleeve_len = 45;
tarp_sleeve_len = 45;
pad_sleeve_len  = 55;
cap_t           = 3;   // Deckelstaerke am Rohrende (tarp_clip / wall_pad)

// ---- Wand-Pad ----------------------------------------------------------------
pad_w      = 70;   // Breite an der Wand (X)
pad_h      = 50;   // Hoehe an der Wand (Z)
pad_t      = 5;    // Dicke der Wandplatte
pad_root_h = 18;   // Hoehe der Rippe an der Huelse
gusset_w   = 30;   // Breite der Rippe (X)

// ---- Aufbau ------------------------------------------------------------------
raise_height  = 180;  // tarp_clip ueber rail_clip (15-20 cm)
tube_down_len = 220;  // wie weit das Rohr unter die Schiene ragt
                      // 180 + 220 + Ueberstand -> 2 Stuetzen je Meter Rohr

// ---- Auswahl / Qualitaet -----------------------------------------------------
part = "assembly"; // [assembly, rail_clip, tarp_clip, wall_pad]
explode = 0;
$fn = 48;
eps = 0.01;

// ---- Abgeleitet --------------------------------------------------------------
sleeve_in   = tube_w + tube_fit;             // lichte Weite der Huelse
sleeve_out  = sleeve_in + 2 * sleeve_wall;   // Aussenmass der Huelse
sleeve_half = sleeve_out / 2;
front_y     =  sleeve_half;                  // Huelsen-Vorderseite (+Y)
back_y      = -sleeve_half;                  // Huelsen-Rueckseite  (-Y, Wandseite)
foot_len    = sleeve_out + 2 * foot_extra;   // Fuss nur so breit wie die Huelse
// Bead-Mitte -> Schienen-Vorderkante: halber Bead plus Lippendicke.
lip_out     = rail_keder_d / 2 + rail_lip_depth;
// Bead-Mitte -> Huelsen-Rueckseite. Faellt aus dem gemessenen Freiraum ab.
rail_reach  = lip_out + rail_clear;
y_bead       = back_y - rail_reach;          // Bead-Mitte in der vorhandenen Schiene
rail_front_y = y_bead + lip_out;             // Vorderkante der vorhandenen Schiene
// Laenge ab Bead-MITTE, ueber die der Hals duenn bleiben muss. Erst danach
// darf der Fuss aufgehen – sonst klemmt er an der Lippe.
neck_len    = lip_out + neck_extra;
wall_y      = y_bead - rail_depth;           // Wandflaeche
ch_out      = tarp_keder_d + tarp_fit + 2 * tarp_channel_wall;  // Kanal aussen
y_ch        = front_y + ch_out / 2;          // Kanalachse vor der Huelse

// ---- Kontrollausgaben / Plausibilitaet (bei jedem Render im Log) -------------
echo(str("Hals ", rail_slot_w - rail_fit, " x ", neck_len,
         " mm, Schlitzneigung ", rail_slot_angle, " Grad"));
echo(str("Freiraum Schienenvorderkante -> Huelse: ", rail_clear,
         " mm  (darin weitet sich der Fuss von ", rail_slot_w - rail_fit,
         " auf ", foot_root_h, " mm auf)"));
echo(str("Bead-Mitte -> Huelse: ", rail_reach,
         " mm, Huelsen-Rueckseite -> Wand: ", back_y - wall_y, " mm"));

assert(rail_clear > neck_extra,
       "rail_clear <= neck_extra: der Fuss wuerde sich schon in der Schiene aufweiten.");
assert(rail_slot_w - rail_fit < rail_keder_d - rail_fit,
       "Hals nicht schmaler als der Bead – der Fuss wuerde durch den Schlitz rutschen.");
assert(rail_depth > rail_keder_d / 2,
       "rail_depth zu klein: der Bead wuerde hinten aus der Schiene in die Wand ragen.");

// =============================================================================
// Hilfsmodule
// =============================================================================

// Extrudiert ein 2D-Profil entlang X, zentriert um x = 0.
// Das 2D-Profil wird in [y, z] gezeichnet: 2D-x -> Modell-Y, 2D-y -> Modell-Z.
module x_extrude(len) {
    translate([-len / 2, 0, 0]) rotate([90, 0, 90])
        linear_extrude(height = len) children();
}

// Vollmaterial der Huelse (Achse Z, zentriert um z = 0), Kanten gerundet.
module sleeve_solid(len) {
    translate([0, 0, -len / 2]) linear_extrude(height = len)
        offset(r = sleeve_r) square(sleeve_out - 2 * sleeve_r, center = true);
}

// Quadratischer Rohrkanal als Abzug. cap_top/cap_bot > 0 schliesst das Ende.
module tube_cavity(len, cap_top = 0, cap_bot = 0) {
    h = len + 2 * eps - cap_top - cap_bot;
    translate([0, 0, -len / 2 - eps + cap_bot + h / 2])
        cube([sleeve_in, sleeve_in, h], center = true);
}

// Durchsteckschraube, Achse X (durch die Seitenwaende des Rohrs).
module pin_hole(z = 0) {
    translate([-sleeve_out, 0, z]) rotate([0, 90, 0])
        cylinder(d = pin_d, h = 2 * sleeve_out);
}

// =============================================================================
// 2D-Profile (gezeichnet in [y, z])
// =============================================================================

// Keder-Fuss: Bead in der vorhandenen Schiene, duenner Hals durch den Schlitz,
// danach Verbreiterung zur Huelse.
// Bead und Hals sind um rail_slot_angle um die BEAD-MITTE gekippt (der Schlitz
// der Schiene steht schraeg); die Wurzel an der Huelse bleibt waagerecht, den
// Versatz faengt der Uebergang auf. Der Bead selbst ist rund, die Drehung
// wirkt sich nur auf Hals und Aufweitung aus.
module foot_profile_2d() {
    neck = rail_slot_w - rail_fit;
    union() {
        translate([y_bead, 0]) circle(d = rail_keder_d - rail_fit);
        translate([y_bead, 0]) rotate(rail_slot_angle)
            translate([0, -neck / 2]) square([neck_len, neck]);
        hull() {
            translate([y_bead, 0]) rotate(rail_slot_angle)
                translate([neck_len - eps, -neck / 2]) square([eps, neck]);
            translate([back_y + sleeve_wall - eps, -foot_root_h / 2])
                square([eps, foot_root_h]);
        }
    }
}

// Begrenzungskoerper, der die X-Enden des Fusses um c anfast (Einfaedelhilfe).
// Zurueckgenommen werden nur die Bead-Nase (-Y) und die Stegkanten; die Wurzel
// an der Huelse (+Y) bleibt auf voller Breite stehen.
module foot_end_taper(len, c) {
    y_lo = y_bead - (rail_keder_d - rail_fit) / 2;
    y_hi = back_y + sleeve_wall;
    z_h  = foot_root_h / 2;
    hull() {
        translate([-(len / 2 - c), y_lo, -z_h])
            cube([len - 2 * c, y_hi - y_lo, 2 * z_h]);
        translate([-len / 2, y_lo + c, -z_h + c])
            cube([len, y_hi - y_lo - c, 2 * z_h - 2 * c]);
    }
}

// Kurzes Kederschienen-Stueck fuers Tarp: runder C-Kanal, Schlitz nach unten,
// plus Ruecken-Steg zur Huelse.
module channel_profile_2d() {
    difference() {
        union() {
            translate([y_ch, 0]) circle(d = ch_out);
            translate([front_y - sleeve_wall, -stub_web_t / 2])
                square([y_ch - front_y + sleeve_wall, stub_web_t]);
        }
        translate([y_ch, 0]) circle(d = tarp_keder_d + tarp_fit);
        translate([y_ch - tarp_slot_w / 2, -ch_out]) square([tarp_slot_w, ch_out]);
    }
}

// Wandplatte (flach an der Wand).
module pad_profile_2d() {
    translate([wall_y, -pad_h / 2]) square([pad_t, pad_h]);
}

// Rippe Wandplatte -> Huelse.
module gusset_profile_2d() {
    hull() {
        translate([wall_y, -pad_h / 2]) square([pad_t + eps, pad_h]);
        translate([back_y + sleeve_wall - eps, -pad_root_h / 2])
            square([eps, pad_root_h]);
    }
}

// =============================================================================
// Druckteile (jeweils im Ursprung modelliert)
// =============================================================================

module rail_clip() {
    difference() {
        union() {
            sleeve_solid(rail_sleeve_len);
            intersection() {
                x_extrude(foot_len) foot_profile_2d();
                foot_end_taper(foot_len, foot_chamfer);
            }
        }
        tube_cavity(rail_sleeve_len);
        pin_hole();
    }
}

module tarp_clip() {
    difference() {
        union() {
            sleeve_solid(tarp_sleeve_len);
            x_extrude(stub_len) channel_profile_2d();
        }
        tube_cavity(tarp_sleeve_len, cap_top = cap_t);
        pin_hole();
    }
}

module wall_pad() {
    difference() {
        union() {
            sleeve_solid(pad_sleeve_len);
            x_extrude(pad_w) pad_profile_2d();
            x_extrude(gusset_w) gusset_profile_2d();
        }
        tube_cavity(pad_sleeve_len, cap_bot = cap_t);
        pin_hole();
    }
}

// =============================================================================
// Vorschau / Dispatch
// =============================================================================

module ghost_tube() {
    // Das Rohr endet in beiden Deckeln, es steht nirgends heraus.
    top =  raise_height  + tarp_sleeve_len / 2 - cap_t;
    bot = -tube_down_len - pad_sleeve_len  / 2 + cap_t;
    color([0.7, 0.7, 0.75, 0.5])
        translate([0, 0, bot]) linear_extrude(height = top - bot)
            square(tube_w, center = true);
}

module ghost_wall() {
    color([0.85, 0.8, 0.7, 0.35])
        translate([-130, wall_y - 6, -tube_down_len - 60])
            cube([260, 6, raise_height + tube_down_len + 120]);
}

// Grobe Andeutung der vorhandenen Kederschiene an der Wand bei z = 0.
// Reicht bis rail_front_y, damit man im Preview den Spalt zur Huelse sieht.
module ghost_rail() {
    color([0.6, 0.6, 0.6, 0.5])
        translate([-130, wall_y, -12])
            cube([260, rail_front_y - wall_y, 24]);
}

module assembly() {
    ghost_wall();
    ghost_rail();
    ghost_tube();
    color("SteelBlue") translate([0, 0, -explode])                 rail_clip();
    color("Goldenrod") translate([0, explode, raise_height + explode])   tarp_clip();
    color("IndianRed") translate([0, -explode, -tube_down_len - 2 * explode]) wall_pad();
}

if (part == "rail_clip")      rail_clip();
else if (part == "tarp_clip") tarp_clip();
else if (part == "wall_pad")  wall_pad();
else                          assembly();
