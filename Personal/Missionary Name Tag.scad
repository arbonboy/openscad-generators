// Missionary Name Tag
// ----------------------------------------------------------------------------
// A z-rounded rectangular name tag for The Church of Jesus Christ of Latter-day
// Saints. The tag carries a centred, vertically-stacked block of text: the
// individual's name (line 1, with a larger gap beneath it) followed by 3-4
// church name/logo lines. Leave the optional last church line blank and the
// remaining lines reclaim its space.
//
// Two-colour aware (a single colour change in Z, so it prints with an MMU/AMS
// or one manual filament swap):
//   * Positive Text_Depth -> text is RAISED, printed WHITE, tag body DIMGREY.
//   * Negative Text_Depth -> text is ENGRAVED into the top; the cut top layers
//     are DIMGREY and everything below is WHITE.
//
// All reusable geometry lives in lib/missionary_tag.scad.

include <BOSL2/std.scad>
include <lib/missionary_tag.scad>

/* [Name Tag Size] */
// Width (X) of the tag
Width = 78;              // [20:1:200]
// Y-height (Y) of the tag
Height = 50;             // [15:1:150]
// Z-depth of the tag
Tag_Depth = 3;           // [1:0.5:20]
// Rounding of the vertical (Z) corners
Corner_Radius = 3;       // [0:0.5:20]

/* [Text] */
// mm the text is raised (positive) above, or cut (negative) into, the top face.
// When negative, its absolute value must be at least 1mm less than Tag_Depth.
Text_Depth = -0.6;       // [-10:0.1:10]

// Line 1 - the individual's name
Name_Text = "ÉLDER ANDERSEN";
Name_Font_Size = 8;      // [2:0.5:30]
Name_Font_Family = "League Gothic";
// Nudge the name line up (+) or down (-) in Y
Name_Y_Adjustment = 0;   // [-30:0.5:30]

// Line 2
Church_Label_1_Text = "THE CHURCH OF";
Church_Label_1_Font_Size = 5.5;   // [2:0.1:30]
Church_Label_1_Font_Family = "PT Serif";
Church_Label_1_Y_Adjustment = 0;  // [-30:0.5:30]

// Line 3 (traditionally the emphasised "JESUS CHRIST")
Church_Label_2_Text = "JESUS CHRIST";
Church_Label_2_Font_Size = 8;     // [2:0.1:30]
Church_Label_2_Font_Family = "PT Serif";
Church_Label_2_Y_Adjustment = -1;  // [-30:0.5:30]

// Line 4
Church_Label_3_Text = "OF LATTER-DAY SAINTS";
Church_Label_3_Font_Size = 4.2;   // [2:0.1:30]
Church_Label_3_Font_Family = "PT Serif";
Church_Label_3_Y_Adjustment = -1;  // [-30:0.5:30]

// Line 5 - optional; leave the text blank to omit it (reclaims its space)
Church_Label_4_Text = "";
Church_Label_4_Font_Size = 4.2;   // [2:0.1:30]
Church_Label_4_Font_Family = "PT Serif";
Church_Label_4_Y_Adjustment = 0;  // [-30:0.5:30]

/* [Text Layout] */
// Extra gap under the name line (kept larger than the church line gap)
Name_Bottom_Gap = 5;     // [0:0.5:20]
// Gap between the church lines
Church_Line_Gap = 1.5;   // [0:0.5:20]

/* [Colours] */
// Colour of the tag body (and, when engraved, the cut top layers)
Tag_Color = "dimgrey";
// Colour of the text (raised text, or the surface revealed by engraving)
Text_Color = "white";

/* [Hidden] */
$fn = 64;

// ---- Validation ------------------------------------------------------------
assert(Text_Depth >= 0 || abs(Text_Depth) <= Tag_Depth - 1,
       "Engraved (negative) Text_Depth must be at least 1mm less than Tag_Depth.");

// The five customizer text lines, as [text, size, font, y_adjust, gap_below].
// The name line carries the larger Name_Bottom_Gap; the church lines share
// Church_Line_Gap. Blank lines are dropped and reclaim their space.
text_lines = [
    [Name_Text,           Name_Font_Size,           Name_Font_Family,           Name_Y_Adjustment,           Name_Bottom_Gap],
    [Church_Label_1_Text, Church_Label_1_Font_Size, Church_Label_1_Font_Family, Church_Label_1_Y_Adjustment, Church_Line_Gap],
    [Church_Label_2_Text, Church_Label_2_Font_Size, Church_Label_2_Font_Family, Church_Label_2_Y_Adjustment, Church_Line_Gap],
    [Church_Label_3_Text, Church_Label_3_Font_Size, Church_Label_3_Font_Family, Church_Label_3_Y_Adjustment, Church_Line_Gap],
    [Church_Label_4_Text, Church_Label_4_Font_Size, Church_Label_4_Font_Family, Church_Label_4_Y_Adjustment, 0],
];

// ---- Model -----------------------------------------------------------------
mtag_two_color_tag(Width, Height, Tag_Depth, Text_Depth, Tag_Color, Text_Color) {
    mtag_body(Width, Height, Tag_Depth, Corner_Radius);
    mtag_text_block(text_lines);
}
