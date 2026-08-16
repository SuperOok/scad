// =============================================================================
// Stundenplan-Schild
// =============================================================================
// Duenne Platte mit erhabenen Wochentagen und Uhrzeiten; je Stunde ein
// erhabenes Kaestchen, in das der Fachname vertieft eingelassen ist.
//
// -----------------------------------------------------------------------------
// EINE NEUE KLASSE ANLEGEN
// -----------------------------------------------------------------------------
//   1. Eine der vorhandenen Listen kopieren und umbenennen (klasse_8b o. ae.).
//   2. Faecher eintragen.
//   3. Unten bei "klasse =" die neue Liste auswaehlen.
//
//   Aufbau je Wochentag:   [ "Tagesname", [ Stunde1, Stunde2, ... ] ]
//   Eine Stunde ist entweder nur der Fachname          "Musik"
//   oder ein Paar aus Name und Verkleinerungsfaktor    ["Philosophie", 0.85]
//   oder "" fuer eine Freistunde (kein Kaestchen).
//
//   ACHTUNG Textbreite: Der Fachname wird vom Kaestchen abgezogen. Ist er
//   breiter als das Kaestchen (col_width - 2 = 31.3 mm bei 5 Tagen), wird der
//   Ueberstand STILL abgeschnitten – es gibt keine Fehlermeldung, man sieht es
//   erst im Druck. Dafuer ist der Faktor da.
//
//   Gemessene Faktoren bei text_size = 4.76 mm (Breite bei Faktor 1 in mm):
//     ohne Faktor   Sport 16.5, Musik 17.6, Mathe 18.9, Deutsch 24.1,
//                   Englisch 24.3, Biologie 24.4
//     0.9           Informatik 31.6, Geschichte 32.8
//     0.85          Franzoesisch 34.3, Geographie 34.6, Philosophie 34.8
//     0.8           Mathematik 36.4
//     0.7           Klassenlehrer 41.3
//   Faustregel: bis ~29.5 mm ohne Faktor, darueber Faktor = 29.5 / Breite,
//   auf 0.05 abgerundet. "Informatik" liegt mit 31.6 mm nur knapp ueber der
//   Zelle – solche Faelle sieht man ohne Messen nicht.
//
//   Die Zahl der Spalten faellt aus der Klasse ab (Tage + 1 Spalte fuer die
//   Uhrzeiten), die Zahl der Zeilen aus den Uhrzeiten. Ein Plan mit 6 Tagen
//   oder 7 Stunden passt sich also selbst an.
// =============================================================================

// ---- Klasse 6d ---------------------------------------------------------------
klasse_6d = [
    ["Montag",     [["Klassenlehrer", 0.7], "Musik", "Musik", "Sport",
                    ["Geschichte", 0.9], "Deutsch"]],
    ["Dienstag",   ["Kunst", ["Philosophie", 0.85], ["Philosophie", 0.85],
                    "Mathe", "Mathe", ["Geschichte", 0.9]]],
    ["Mittwoch",   ["Englisch", "Deutsch", "Deutsch", ["Geographie", 0.85],
                    ["Geographie", 0.85], "Sport"]],
    ["Donnerstag", ["Biologie", "Mathe", "Mathe", "Englisch", "Englisch",
                    "Kunst"]],
    ["Freitag",    ["Sport", "Englisch", "Englisch", "Mathe", "Deutsch",
                    "Biologie"]],
];

// ---- Klasse 7d ---------------------------------------------------------------
// Montag, Mittwoch und Freitag enden nach der 5. Stunde.
klasse_7d = [
    ["Montag",     [["Informatik", 0.9], "Sport", "Sport",
                    ["Geographie", 0.85], ["Französisch", 0.85], ""]],
    ["Dienstag",   ["Deutsch", ["Philosophie", 0.85], ["Philosophie", 0.85],
                    ["Informatik", 0.9], "Musik", ["Französisch", 0.85]]],
    ["Mittwoch",   ["Mathe", "Englisch", ["Französisch", 0.85], "Deutsch",
                    "Deutsch", ""]],
    ["Donnerstag", ["Mathe", "Biologie", "Biologie", ["Geographie", 0.85],
                    "Englisch", "Musik"]],
    ["Freitag",    [["Französisch", 0.85], "Mathe", "Mathe",
                    "Englisch", "Deutsch", ""]],
];

// ---- Was gedruckt wird -------------------------------------------------------
klasse = klasse_7d;

// ---- Stundenzeiten (eine je Zeile) -------------------------------------------
times = ["07:55-08:40", "08:45-09:30", "09:30-10:15",
         "10:30-11:15", "11:20-12:05", "12:25-13:10"];

// Parameter
table_width = 200;  // Gesamtbreite der Tabelle
table_height = 65; // Gesamthöhe der Tabelle
row_height = 8;    // Höhe einer Zeile
cols = len(klasse) + 1;      // Wochentage + Spalte fuer die Uhrzeiten
col_width = table_width / cols; // Breite einer Spalte
text_size = col_width / 7;

table_depth = 0.5;
letter_depth = 0.5;

text_font = "Ubuntu:style=Bold";

// ---- Grundlinie --------------------------------------------------------------
// valign = "center" zentriert in OpenSCAD die tatsaechliche Glyphen-Bounding-
// Box. Damit haengt die Grundlinie am Wortinhalt: "Mittwoch" hat keine
// Unterlaenge, "Donnerstag" schon – die beiden standen dadurch 0.81 mm
// versetzt. Deshalb wird ueberall auf valign = "baseline" gesetzt und um
// einen festen, nur von der Schriftgroesse abhaengigen Betrag verschoben.
//
// Gemessen fuer Ubuntu Bold (Glyphen einzeln gerendert und ausgemessen):
asc_ratio  = 1.0778;   // Oberlaenge / size  – "h l k b d f ß"; NICHT die
                       // Versalhoehe ("M" = 0.9625), die ist niedriger und
                       // wuerde die Oberlaengen oben aus dem Kaestchen
                       // schneiden lassen.
desc_ratio = 0.2611;   // Unterlaenge / size – "g" (p/q/y sind minimal kuerzer)
// Zentriert wird der Bereich Unterlaenge..Oberlaenge, damit der Text
// symmetrisch im Kaestchen sitzt: bei text_size = 4.76 mm reicht er
// +-3.19 mm, das Kaestchen +-3.4 mm.
baseline_offset = -(asc_ratio - desc_ratio) / 2;

// Ein Grossbuchstabe mit Umlaut ginge bis 1.2567 * size und wuerde damit
// oben anstossen (3.61 > 3.4 mm). Kommt in den aktuellen Fachnamen nicht vor
// ("Französisch" hat ein kleines ö mit 1.0371); sonst text_size senken.
assert((asc_ratio + desc_ratio) * text_size <= row_height - 1.2,
       "Text hoeher als das Faecher-Kaestchen – text_size oder row_height anpassen.");

// Text auf fester Grundlinie, horizontal zentriert.
module label_text(txt, size) {
    translate([0, baseline_offset * size])
        text(txt, size = size, halign = "center", valign = "baseline",
             font = text_font);
}

// Zugriff auf die Stundenplan-Daten
function day_name(d)      = klasse[d][0];
function day_lessons(d)   = klasse[d][1];
function lesson_name(e)   = is_string(e) ? e : e[0];
function lesson_factor(e) = is_string(e) ? 1 : e[1];

// ---- Auswahl fuer den Export -------------------------------------------------
// Der Zweifarb-Druck besteht aus genau diesen beiden Teilen, die sich bei
// z = table_depth beruehren:
//   plate  – die Grundplatte              (Farbe 1)
//   labels – Wochentage, Uhrzeiten, Faecher-Kaestchen (Farbe 2)
// Die Fachnamen sind Aussparungen in den Kaestchen, scheinen also in der
// Farbe der Grundplatte durch. export-stundenplan.sh baut daraus das 3mf.
part = "all"; // [all, plate, labels]

// Hintergrundplatte
module plate() {
    cube([table_width, table_height, table_depth]);
}

function xpos(x) = x * col_width + col_width/2;
function ypos(y) = table_height - y * row_height;



// Wochentage (erhabener Text)
module day_label(day, x) {
    translate([xpos(x) , ypos(1), table_depth])
        linear_extrude(height = letter_depth)
            label_text(day, text_size);
}

// Fächer (Beispiel für eine Zeile)
module time_label(subject, x_pos, y_pos, size) {
    translate([x_pos + col_width/2, y_pos, table_depth])
        linear_extrude(height = letter_depth)
            label_text(subject, size);
}

module subject(subject, col, row, factor=1){
    x = xpos(col);
    y = ypos(row+1);

    difference(){
        translate([x, y, table_depth+letter_depth/2]) // wegen center = true, um die hälfte der dicke nach oben schieben
            cube([col_width-2,row_height-1.2,letter_depth],center=true);


        translate([x, y, table_depth])
            linear_extrude(height = 1) // ragt bewusst ueber das Kaestchen hinaus
                label_text(subject, text_size*factor);

    }
}


module time(text, row){
    xpos = 0;
    ypos = ypos(row+1);
    time_label(text, xpos , ypos, 4);
}

// Alles, was auf der Grundplatte steht: Wochentage, Uhrzeiten, Faecher.
module labels() {
    for (d = [0 : len(klasse) - 1])
        day_label(day_name(d), d + 1);

    for (r = [0 : len(times) - 1])
        time(times[r], r + 1);

    // Faecher aus der oben gewaehlten Klasse
    for (d = [0 : len(klasse) - 1])
        let (lessons = day_lessons(d))
            for (r = [0 : len(lessons) - 1])
                let (e = lessons[r])
                    if (lesson_name(e) != "")
                        subject(lesson_name(e), d + 1, r + 1, lesson_factor(e));
}

if (part == "plate")       plate();
else if (part == "labels") labels();
else                       { plate(); labels(); }
