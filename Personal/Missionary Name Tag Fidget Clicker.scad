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
//
// The reusable geometry lives in two libraries:
//   * lib/missionary_tag.scad     - the name-tag body, text layout, two-colour
//                                    split, and base border.
//   * lib/mx_keyboard_switch.scad - the MX switch clicker mechanism (stem
//                                    sockets on the tag, pockets on the base).

include <BOSL2/std.scad>
include <lib/missionary_tag.scad>
include <lib/mx_keyboard_switch.scad>

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

// ---- Derived geometry ------------------------------------------------------
raised        = Text_Depth > 0;
socket_len    = mx_socket_len(Stem_Cross_Length, Stem_Socket_Tolerance);
socket_thick  = mx_socket_thick(Stem_Cross_Thickness, Stem_Socket_Tolerance);
pocket_total  = mx_pocket_total_depth(Switch_Pocket_Outer_Depth, Switch_Pocket_Inner_Depth);
tag_feature_depth = max(Tag_Recess_Depth, Stem_Socket_Depth);  // deepest cut into the tag
xs            = mx_switch_xs(Width, Number_Of_Switches);        // switch X positions

// Footprint width of each part (for the side-by-side "both" layout).
base_footprint_w = Add_Base_Border
    ? mtag_border_outer_w(Width, Border_Tolerance, Border_Wall_Thickness)
    : Width;

// The five customizer text lines, as [text, size, font, y_adjust, gap_below].
// Blank lines are dropped by mtag_text_block and reclaim their space.
text_lines = [
    [Name_Text,           Name_Font_Size,           Name_Font_Family,           Name_Y_Adjustment,           Name_Bottom_Gap],
    [Church_Label_1_Text, Church_Label_1_Font_Size, Church_Label_1_Font_Family, Church_Label_1_Y_Adjustment, Church_Line_Gap],
    [Church_Label_2_Text, Church_Label_2_Font_Size, Church_Label_2_Font_Family, Church_Label_2_Y_Adjustment, Church_Line_Gap],
    [Church_Label_3_Text, Church_Label_3_Font_Size, Church_Label_3_Font_Family, Church_Label_3_Y_Adjustment, Church_Line_Gap],
    [Church_Label_4_Text, Church_Label_4_Font_Size, Church_Label_4_Font_Family, Church_Label_4_Y_Adjustment, 0],
];

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

// ===========================================================================
//  Parts
// ===========================================================================

// Uncoloured tag geometry: the name-tag body with the MX gripper cut into its
// underside (clearance recesses, stem housings, and "+" sockets).
module tag_solid() {
    mx_tag_grip(xs,
                Tag_Recess_Size, Tag_Recess_Rounding, Tag_Recess_Depth,
                Tag_Housing_Diameter, socket_len, socket_thick, Stem_Socket_Depth)
        mtag_body(Width, Height, Tag_Depth, Corner_Radius);
}

// The full, coloured tag part (raised or engraved two-colour text).
module tag_part() {
    mtag_two_color_tag(Width, Height, Tag_Depth, Text_Depth, "dimgrey", "white") {
        tag_solid();
        mtag_text_block(text_lines);
    }
}

// Uncoloured base geometry: the name-tag body (optionally bordered) with a
// stepped MX switch pocket at each switch position.
module base_solid() {
    difference() {
        if (Add_Base_Border)
            mtag_base_border(Width, Height, Corner_Radius, Base_Depth,
                             Border_Extension, Border_Wall_Thickness, Border_Tolerance);
        else
            mtag_body(Width, Height, Base_Depth, Corner_Radius);
        mx_base_pockets(xs, Base_Depth,
                        Switch_Pocket_Outer_Size, Switch_Pocket_Outer_Depth,
                        Switch_Pocket_Inner_Size, Switch_Pocket_Inner_Depth);
    }
}

// The full, coloured base part (matches the tag's colour split).
module base_part() {
    color(mtag_body_color(Text_Depth, "dimgrey", "white")) base_solid();
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
