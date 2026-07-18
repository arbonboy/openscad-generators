// Missionary Name Tag Fidget Clicker
// ----------------------------------------------------------------------------
// A two-part fidget toy shaped like a missionary name tag for The Church of
// Jesus Christ of Latter-day Saints:
//   1) TAG  - the name tag itself. Its underside grips the top (cross stem) of
//             one or more Cherry MX style keyboard switches.
//   2) BASE - the same rounded-rectangle outline, with a pocket that holds the
//             base of each MX switch. Press the tag onto the base to "click".
//
// Two-colour aware (single colour change in Z, so it works with an MMU/AMS or a
// manual filament swap):
//   * Positive Text_Depth -> text is RAISED, printed WHITE, tag + base BLACK.
//   * Negative Text_Depth -> text is ENGRAVED, the cut top layers are BLACK and
//     everything below (plus the base) is WHITE.
//
// Each part is modelled in its own print orientation, sitting on the bed (z = 0).

include <BOSL2/std.scad>

/* [Name Tag Size] */
// Width (X) of the tag and base
Width = 70;              // [20:1:200]
// Y-height (Y) of the tag and base
Height = 40;             // [15:1:150]
// Rounding of the vertical (Z) corners
Corner_Radius = 3;       // [0:0.5:20]
// Z-depth of the tag
Tag_Depth = 6;           // [2:0.5:20]
// Z-depth of the base (must be >= the total switch pocket depth + 1)
Base_Depth = 13;         // [3:0.5:40]

/* [Text] */
// mm the text is raised (positive) above, or cut (negative) into, the top face
Text_Depth = -0.4;        // [-10:0.1:10]

// Line 1 - the individual's name
Name_Text = "ÉLDER ANDERSEN";
Name_Font_Size = 7;      // [2:0.5:30]
Name_Font_Family = "League Gothic";
// Nudge the name line up (+) or down (-) in Y
Name_Y_Adjustment = 0;   // [-30:0.5:30]

// Line 2
Church_Label_1_Text = "THE CHURCH OF";
Church_Label_1_Font_Size = 5;   // [2:0.1:30]
Church_Label_1_Font_Family = "PT Serif";
Church_Label_1_Y_Adjustment = 0;  // [-30:0.5:30]

// Line 3 (traditionally the emphasised "JESUS CHRIST")
Church_Label_2_Text = "JESUS CHRIST";
Church_Label_2_Font_Size = 7;     // [2:0.1:30]
Church_Label_2_Font_Family = "PT Serif";
Church_Label_2_Y_Adjustment = -1;  // [-30:0.5:30]

// Line 4
Church_Label_3_Text = "OF LATTER-DAY SAINTS";
Church_Label_3_Font_Size = 3.8;   // [2:0.1:30]
Church_Label_3_Font_Family = "PT Serif";
Church_Label_3_Y_Adjustment = -1;  // [-30:0.5:30]

// Line 5 - optional; leave the text blank to omit it (reclaims its space)
Church_Label_4_Text = "";
Church_Label_4_Font_Size = 3.8;   // [2:0.1:30]
Church_Label_4_Font_Family = "PT Serif";
Church_Label_4_Y_Adjustment = 0;  // [-30:0.5:30]

/* [Text Layout] */
// Extra gap under the name line (kept larger than the church line gap)
Name_Bottom_Gap = 5;     // [0:0.5:20]
// Gap between the three church lines
Church_Line_Gap = 1.5;   // [0:0.5:20]

/* [MX Switch] */
// Number of switch mount points, evenly spaced in one row along X
Number_Of_Switches = 1;  // [1:1:10]
// The base switch pocket is a stepped square hole: a shallow wide mouth, then a
// deeper narrower bore. Outer (mouth) square size / depth:
Switch_Pocket_Outer_Size = 18.5;   // [10:0.1:30]
Switch_Pocket_Outer_Depth = 2.9;   // [0.5:0.1:15]
// Inner (deep bore) square size / depth:
Switch_Pocket_Inner_Size = 14;   // [10:0.1:25]
Switch_Pocket_Inner_Depth = 8.4;   // [1:0.1:30]

/* [MX Stem Socket] */
// Nominal MX cross-stem arm length / thickness (female socket, before tolerance)
Stem_Cross_Length = 4.0;      // [3:0.1:5]
Stem_Cross_Thickness = 1.17;  // [0.8:0.01:2]
// How far the "+" stem socket goes up into the tag (grip depth)
Stem_Socket_Depth = 3.8;      // [2:0.1:6]
// Clearance added to the cross socket (tune for grip)
Stem_Socket_Tolerance = 0.2;  // [0:0.05:1]
// Diameter of the circular housing that holds the "+" socket
Tag_Housing_Diameter = 5.5;     // [4.5:0.1:13]
// The housing sits in a rounded-square clearance recess cut into the tag underside.
// Recess square size / corner rounding / depth (the housing is inset this deep):
Tag_Recess_Size = 15;         // [8:0.1:30]
Tag_Recess_Rounding = 4;      // [0:0.1:7]
Tag_Recess_Depth = 2.9;       // [0.5:0.1:15]

/* [Base Border] */
// Add a raised border/shell around the base that extends up to surround the tag
Add_Base_Border = true;       // [true, false]
// How far the border rises above the top of the base (to surround the tag)
Border_Extension = 7;         // [0:0.5:40]
// Wall thickness of the border
Border_Wall_Thickness = 2;    // [0.5:0.5:10]
// Gap between the inside of the border and the outside of the tag
Border_Tolerance = 0.5;       // [0:0.05:2]

/* [Output] */
// Which part(s) to render
Render_Part = "both";    // [both, tag, base]
// Gap between the parts when rendering both
Part_Gap = 8;            // [0:1:40]

/* [Hidden] */
$fn = 64;
eps = 0.02;

// ---- Derived geometry ------------------------------------------------------
raised        = Text_Depth > 0;
td_abs        = abs(Text_Depth);
socket_len    = Stem_Cross_Length    + Stem_Socket_Tolerance;
socket_thick  = Stem_Cross_Thickness + Stem_Socket_Tolerance;
pocket_total  = Switch_Pocket_Outer_Depth + Switch_Pocket_Inner_Depth;  // total base hole depth
tag_feature_depth = max(Tag_Recess_Depth, Stem_Socket_Depth);          // deepest cut into the tag
z_top         = Tag_Depth;   // top (text) surface of the tag

// Border: inner opening clears the tag by Border_Tolerance; outer adds the wall thickness.
border_open_w = Width  + 2 * Border_Tolerance;                          // tag-clearance opening
border_open_h = Height + 2 * Border_Tolerance;
border_open_r = Corner_Radius + Border_Tolerance;
border_out_w  = border_open_w + 2 * Border_Wall_Thickness;              // outer footprint
border_out_h  = border_open_h + 2 * Border_Wall_Thickness;
border_out_r  = border_open_r + Border_Wall_Thickness;
// Footprint width of each part (for the side-by-side "both" layout).
base_footprint_w = Add_Base_Border ? border_out_w : Width;

// ---- Validation ------------------------------------------------------------
Min_Top_Skin = 1.0;
assert(Text_Depth >= 0 || abs(Text_Depth) <= Tag_Depth - 1,
       "Engraved (negative) Text_Depth must be at least 1mm less than Tag_Depth.");
assert(Tag_Depth >= tag_feature_depth + Min_Top_Skin,
       "Tag_Depth is too small: it must exceed the stem-socket / recess depth by >= 1mm.");
assert(Base_Depth >= pocket_total + 1,
       "Base_Depth must be at least 1mm greater than the total switch-pocket depth.");
assert(Width / Number_Of_Switches >= Switch_Pocket_Outer_Size + 1,
       "Too many switches to fit across Width (pockets would overlap the edges/each other).");
assert(Height >= Switch_Pocket_Outer_Size + 2,
       "Height is too small to hold the switch pocket.");

// Switch X positions: evenly spaced, centred on X, single row at y = 0.
function switch_xs() =
    let (n = Number_Of_Switches, pitch = Width / n)
    [ for (i = [0 : n - 1]) (i + 0.5) * pitch - Width / 2 ];

// ---- Text line Y positions (block centred on the tag, y = 0) ---------------
name_h = Name_Font_Size;
c1_h   = Church_Label_1_Font_Size;
c2_h   = Church_Label_2_Font_Size;
c3_h   = Church_Label_3_Font_Size;
c4_h   = Church_Label_4_Font_Size;
has_c4 = Church_Label_4_Text != "";   // optional 4th church line

block_h = name_h + Name_Bottom_Gap + c1_h + Church_Line_Gap
          + c2_h + Church_Line_Gap + c3_h
          + (has_c4 ? Church_Line_Gap + c4_h : 0);

y_name = block_h / 2 - name_h / 2;
y_c1   = y_name - name_h / 2 - Name_Bottom_Gap  - c1_h / 2;
y_c2   = y_c1   - c1_h / 2   - Church_Line_Gap  - c2_h / 2;
y_c3   = y_c2   - c2_h / 2   - Church_Line_Gap  - c3_h / 2;
y_c4   = y_c3   - c3_h / 2   - Church_Line_Gap  - c4_h / 2;

// ===========================================================================
//  Text
// ===========================================================================

// One text line, centred horizontally and vertically at the given Y.
module text_line(txt, size, font, y) {
    translate([0, y, 0])
        text(txt, size = size, font = font, halign = "center", valign = "center");
}

// All text lines as a single 2D shape, centred on the tag. The 4th church line is optional.
module all_text_2d() {
    text_line(Name_Text,           Name_Font_Size,           Name_Font_Family,           y_name + Name_Y_Adjustment);
    text_line(Church_Label_1_Text, Church_Label_1_Font_Size, Church_Label_1_Font_Family, y_c1   + Church_Label_1_Y_Adjustment);
    text_line(Church_Label_2_Text, Church_Label_2_Font_Size, Church_Label_2_Font_Family, y_c2   + Church_Label_2_Y_Adjustment);
    text_line(Church_Label_3_Text, Church_Label_3_Font_Size, Church_Label_3_Font_Family, y_c3   + Church_Label_3_Y_Adjustment);
    if (has_c4)
        text_line(Church_Label_4_Text, Church_Label_4_Font_Size, Church_Label_4_Font_Family, y_c4 + Church_Label_4_Y_Adjustment);
}

// ===========================================================================
//  Tag (upper part)
// ===========================================================================

// MX cross ("+") stem socket profile.
module stem_cross_2d(len, thick) {
    square([len, thick], center = true);
    square([thick, len], center = true);
}

// Rounded-square clearance recesses cut into the tag underside (z = 0 upward). Each clears
// the top housing of an MX switch and surrounds the circular stem housing.
module tag_recesses() {
    for (x = switch_xs())
        translate([x, 0, -eps])
            linear_extrude(height = Tag_Recess_Depth + eps)
                rect([Tag_Recess_Size, Tag_Recess_Size], rounding = Tag_Recess_Rounding);
}

// Circular housings that sit inside the recesses (flush with the underside), giving the "+"
// socket its gripping walls. They join the tag body at the top of the recess.
module tag_housings() {
    for (x = switch_xs())
        translate([x, 0, 0])
            cylinder(d = Tag_Housing_Diameter, h = Tag_Recess_Depth + eps);
}

// The "+" stem sockets, cut up from the underside through the housings into the body.
module stem_sockets() {
    for (x = switch_xs())
        translate([x, 0, -eps])
            linear_extrude(height = Stem_Socket_Depth + eps)
                stem_cross_2d(socket_len, socket_thick);
}

// Uncoloured tag geometry: body, minus the clearance recesses, plus the circular housings,
// minus the "+" sockets.
module tag_geo() {
    difference() {
        union() {
            difference() {
                cuboid([Width, Height, Tag_Depth], rounding = Corner_Radius, edges = "Z", anchor = BOTTOM);
                tag_recesses();
            }
            tag_housings();
        }
        stem_sockets();
    }
}

// A large slab spanning the whole XY footprint between z0 and z1 (for colour splits).
module z_slab(z0, z1) {
    translate([-Width, -Height, z0])
        cube([2 * Width, 2 * Height, z1 - z0]);
}

// The text glyphs extruded between z0 and z0 + h.
module text_prism(z0, h) {
    translate([0, 0, z0])
        linear_extrude(height = h)
            all_text_2d();
}

// The full, coloured tag part.
module tag_part() {
    if (raised) {
        // Black tag, white raised text.
        color("dimgrey") tag_geo();
        color("white") text_prism(z_top - eps, Text_Depth + eps);
    } else {
        // Engraved: the top td_abs layers are black (with the text cut out, revealing the
        // white below); everything below - and the base - is white. The two colours meet on a
        // single plane at z_split, which is exactly one filament colour-change for the printer.
        // The white block is drawn first and the black cap last so the fast preview (F5)
        // composites the (physically topmost) black layers over the white instead of z-fighting.
        z_split = z_top - td_abs;
        color("white")
            intersection() { tag_geo(); z_slab(-eps, z_split); }
        color("dimgrey")
            difference() {
                intersection() { tag_geo(); z_slab(z_split, z_top + eps); }
                text_prism(z_split, td_abs + eps);
            }
    }
}

// ===========================================================================
//  Base (lower part)
// ===========================================================================

// The stepped switch pockets, cut from the base top face (z = Base_Depth) downward.
module base_pockets() {
    for (x = switch_xs()) {
        // Outer mouth: Switch_Pocket_Outer_Size square, Switch_Pocket_Outer_Depth deep.
        translate([x, 0, Base_Depth - Switch_Pocket_Outer_Depth / 2 + eps])
            cube([Switch_Pocket_Outer_Size, Switch_Pocket_Outer_Size, Switch_Pocket_Outer_Depth + 2 * eps], center = true);
        // Inner bore: Switch_Pocket_Inner_Size square, continues Switch_Pocket_Inner_Depth deeper.
        translate([x, 0, Base_Depth - Switch_Pocket_Outer_Depth - Switch_Pocket_Inner_Depth / 2])
            cube([Switch_Pocket_Inner_Size, Switch_Pocket_Inner_Size, Switch_Pocket_Inner_Depth + eps], center = true);
    }
}

// Base with a raised border/shell: a single solid outer block (base + border height) with a
// rounded-rectangular tray cavity milled into the top, leaving Border_Tolerance of clearance
// around the tag and walls of Border_Wall_Thickness. Built as one solid minus cavities (rather
// than unioned/stacked prisms) so there are no coincident faces -> a clean, slicer-safe mesh.
module base_bordered_geo() {
    difference() {
        // Full outer block, base + border height.
        linear_extrude(height = Base_Depth + Border_Extension)
            rect([border_out_w, border_out_h], rounding = border_out_r);
        // Tray cavity: the tag-clearance opening, from the top down to the base top face.
        translate([0, 0, Base_Depth])
            linear_extrude(height = Border_Extension + eps)
                rect([border_open_w, border_open_h], rounding = border_open_r);
    }
}

// Base body with a stepped switch pocket at each switch position, plus optional border.
module base_geo() {
    difference() {
        if (Add_Base_Border)
            base_bordered_geo();
        else
            cuboid([Width, Height, Base_Depth], rounding = Corner_Radius, edges = "Z", anchor = BOTTOM);
        base_pockets();
    }
}

// The full, coloured base part (white when text is engraved, black when raised).
module base_part() {
    color(raised ? "dimgrey" : "white") base_geo();
}

// ===========================================================================
//  Layout
// ===========================================================================

module main() {
    if (Render_Part == "tag") {
        tag_part();
    } else if (Render_Part == "base") {
        base_part();
    } else {  // both, side by side (spaced by each part's own footprint)
        translate([-(Width / 2 + Part_Gap / 2), 0, 0]) tag_part();
        translate([  base_footprint_w / 2 + Part_Gap / 2, 0, 0]) base_part();
    }
}

main();
