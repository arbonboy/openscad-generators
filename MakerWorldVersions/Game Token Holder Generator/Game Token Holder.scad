/* [Token Parameters] */
// Diameter of a single token or coin (mm)
Token_Diameter = 44;        // [5:0.5:100]
// Thickness of a single token or coin (mm)
Token_Thickness = 3;        // [1:0.1:10]

/* [Holder Parameters] */
// Number of holes (token stacks) along the holder
Holes = 3;                  // [1:1:20]
// How many tokens each hole can stack
Tokens_Per_Hole = 7;        // [1:1:50]
// Wall of material between adjacent holes and at the ends (mm)
Width_Between_Holes = 3;   // [1:0.5:40]
// Width of the finger slot at the top rim (mm)
Cutout_Width_Top = 30;      // [0:0.5:80]
// Width of the finger slot at the floor (mm)
Cutout_Width_Bottom = 20;   // [0:0.5:80]
// Side-wall thickness beside each token; holder width = token diameter + 2x this (mm)
Finger_Slot_Thickness = 0;  // [0:0.5:20]
// Thickness of the solid floor under the stacks (mm)
Floor_Thickness = 4;        // [1:0.5:10]
// Rounding radius on the four vertical edges (mm)
Z_Rounding = 2;             // [0:0.5:15]

/* [Part Selection] */
// Which part(s) to generate
Part = "Both";              // [Base:Base holder only, Top:Lid only, Both:Base + Lid side by side]

/* [Lid Parameters] */
// Clearance between lid and base so it slides on/off easily (mm, per side)
Lid_Tolerance = 0.4;        // [0:0.05:1.5]
// Wall and roof thickness of the lid (mm)
Lid_Wall_Thickness = 2;     // [1:0.5:6]
// Diameter of the half-circle finger notch on each short end (0 = none) (mm)
Lid_Finger_Hole_Diameter = 20; // [0:1:60]

/* [Lid Text] */
// Add text to the top of the lid
Lid_Text_Enabled = true;    // [true, false]
// The text shown on top of the lid
Lid_Text = "TOKENS";
// Text size / cap height (mm)
Lid_Text_Size = 10;         // [3:0.5:40]
// How the text is applied to the lid top
Lid_Text_Style = "flush";   // [flush:Flush color change (multi-material), engraved:Engraved / recessed]
// Text depth — colored-layer thickness when flush, cut depth when engraved (mm)
Lid_Text_Depth = 0.6;       // [0.2:0.1:5]
// Text color (shown for the flush color-change style)
Lid_Text_Color = "white";   // [white, black, red, orange, yellow, green, blue, purple, pink, gray, silver, gold, brown, cyan, magenta, navy, teal, maroon]
// Font for the lid text — bold, thick-lined fonts print best
Lid_Font = "Anton";         // [Anton, Bangers, Bebas Neue, Archivo Black, Black Ops One, Fredoka One, Lilita One, Luckiest Guy, Passion One, Bowlby One, Bowlby One SC, Titan One, Alfa Slab One, Ultra, Chango, Paytone One, Russo One, Carter One, Sigmar One, Baloo 2, Concert One, Patua One, Staatliches, Righteous, Squada One, Permanent Marker, Bungee, Changa One, Oswald, Montserrat]

/* [Hidden] */
Hole_Tolerance = 0.5;
Hole_Diameter = Token_Diameter + Hole_Tolerance;
Hole_Height = Tokens_Per_Hole * Token_Thickness + 1;
Hole_Spacing = Token_Diameter + Width_Between_Holes;

$fn = 96;
Epsilon = 0.01;

// Derived prism dimensions.
//  - Length (X): a Width_Between_Holes margin on each end, plus Holes openings
//    separated by Width_Between_Holes. Hole centers are Hole_Spacing apart.
//  - Width  (Y): one token wide, with a Finger_Slot_Thickness wall on each side.
//  - Height (Z): a stack of Tokens_Per_Hole tokens plus the bottom floor.
Prism_Length = Holes * Hole_Diameter + (Holes + 1) * Width_Between_Holes;
Prism_Width  = Token_Diameter + 2 * Finger_Slot_Thickness;
Prism_Height = Floor_Thickness + Hole_Height;

// Derived lid dimensions. The lid is a downward-opening cap whose skirt walls are
// exactly as tall as the base (Prism_Height); the roof adds Lid_Wall_Thickness on
// top. The inner cavity is the base outline grown by Lid_Tolerance on every side
// so it slides over the base. Outer corners stay concentric with the base corners.
Lid_Outer_Length   = Prism_Length + 2 * (Lid_Tolerance + Lid_Wall_Thickness);
Lid_Outer_Width    = Prism_Width  + 2 * (Lid_Tolerance + Lid_Wall_Thickness);
Lid_Outer_Rounding = Z_Rounding + Lid_Tolerance + Lid_Wall_Thickness;
Lid_Height         = Prism_Height + Lid_Wall_Thickness;
Lid_Gap            = 10;   // spacing between base and lid when Part == "Both"

// X center of hole i (0-indexed), measured from the prism center.
function hole_x(i) =
    -Prism_Length / 2 + Width_Between_Holes + Hole_Diameter / 2 + i * Hole_Spacing;

// Rectangular prism with the four vertical (Z) edges rounded, sitting on z = 0.
module rounded_prism(length, width, height, radius) {
    hull()
        for (x = [-length / 2 + radius, length / 2 - radius])
            for (y = [-width / 2 + radius, width / 2 - radius])
                translate([x, y, 0])
                    cylinder(h = height, r = radius);
}

// Trapezoidal finger slot cut through the side walls at one hole, so a stacked
// token can be pushed up and out. Wider (Cutout_Width_Top) at the rim, narrower
// (Cutout_Width_Bottom) at the floor. Sits on top of the floor.
module access_cutout() {
    translate([0, 0, Floor_Thickness])
        rotate([90, 0, 0])
            translate([0, 0, -(Prism_Width / 2 + Epsilon)])
                linear_extrude(height = Prism_Width + 2 * Epsilon)
                    polygon([
                        [-Cutout_Width_Bottom / 2, -Epsilon],
                        [ Cutout_Width_Bottom / 2, -Epsilon],
                        [ Cutout_Width_Top / 2,    Hole_Height + Epsilon],
                        [-Cutout_Width_Top / 2,    Hole_Height + Epsilon],
                    ]);
}

module coin_token_holder() {
    difference() {
        rounded_prism(Prism_Length, Prism_Width, Prism_Height, Z_Rounding);

        for (i = [0 : Holes - 1])
            translate([hole_x(i), 0, Floor_Thickness])
                cylinder(h = Hole_Height + Epsilon, d = Hole_Diameter);

        for (i = [0 : Holes - 1])
            translate([hole_x(i), 0, 0])
                access_cutout();
    }
}

// Text on top of the lid, centered on length and width and reading along the
// length (X). Returned as a 2D shape that callers extrude into a pocket or insert.
module lid_text_2d() {
    text(Lid_Text, size = Lid_Text_Size, font = Lid_Font,
         halign = "center", valign = "center");
}

// Travel lid: a rounded cap that slides over the top of the base to retain the
// tokens. Modeled open-side-down, sitting on z = 0. The text is either engraved
// into the top, or set flush as a separate color for multi-material printing.
module coin_token_lid() {
    difference() {
        rounded_prism(Lid_Outer_Length, Lid_Outer_Width, Lid_Height, Lid_Outer_Rounding);

        // Cavity that receives the base, open at the bottom.
        translate([0, 0, -Epsilon])
            rounded_prism(
                Prism_Length + 2 * Lid_Tolerance,
                Prism_Width  + 2 * Lid_Tolerance,
                Prism_Height + Epsilon,
                Z_Rounding + Lid_Tolerance);

        // Pocket for the text — used by both the flush and engraved styles.
        if (Lid_Text_Enabled)
            translate([0, 0, Lid_Height - Lid_Text_Depth])
                linear_extrude(height = Lid_Text_Depth + Epsilon)
                    lid_text_2d();

        // Half-circle finger notch cut into the open rim of each short end, so the
        // lid is easy to lift off the base. Centered on the rim (z = 0), the lower
        // half of the cylinder falls outside the part, leaving a half circle.
        if (Lid_Finger_Hole_Diameter > 0)
            for (sx = [-1, 1])
                translate([sx * Lid_Outer_Length / 2, 0, 0])
                    rotate([0, 90, 0])
                        cylinder(h = 3 * Lid_Wall_Thickness,
                                 d = Lid_Finger_Hole_Diameter, center = true);
    }

    // Flush style: drop a colored insert into the pocket, level with the top.
    if (Lid_Text_Enabled && Lid_Text_Style == "flush")
        color(Lid_Text_Color)
            translate([0, 0, Lid_Height - Lid_Text_Depth])
                linear_extrude(height = Lid_Text_Depth)
                    lid_text_2d();
}

if (Part == "Base" || Part == "Both")
    coin_token_holder();

if (Part == "Top" || Part == "Both")
    translate([0, (Part == "Both") ? (Prism_Width / 2 + Lid_Outer_Width / 2 + Lid_Gap) : 0, 0])
        // Flip the lid roof-down onto the bed so it prints without supports (and
        // lays the flush text flat on the build plate for clean multi-material).
        translate([0, 0, Lid_Height])
            rotate([180, 0, 0])
                coin_token_lid();

