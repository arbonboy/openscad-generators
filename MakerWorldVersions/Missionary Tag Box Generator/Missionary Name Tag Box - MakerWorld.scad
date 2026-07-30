// Missionary Name Tag Box - MakerWorld single-file build
// (self-contained: lib/missionary_tag.scad inlined; BOSL2 kept as an include)
// ----------------------------------------------------------------------------
// A two-piece box (base + lid) shaped like a z-rounded rectangular missionary
// name tag for The Church of Jesus Christ of Latter-day Saints. The lid's top
// face carries the name-tag text (the individual's name plus 3-4 church lines),
// rendered with the shared lib/missionary_tag.scad library.
//
// Closure style: SHOULDER NECK. The base has a thin inner neck rising above a
// shoulder ledge; the lid drops over the neck so its outer walls sit FLUSH with
// the base and rest on the shoulder. Fit-tolerance, retention-detent, and
// finger-cutout parameters tune the closure.
//
// Two-color aware (a single color change in Z on the lid top):
//   * Positive Text_Depth -> text is RAISED, printed WHITE, box body DIMGREY.
//   * Negative Text_Depth -> text is ENGRAVED; the cut top layers are DIMGREY
//     and everything below is WHITE.
//
// NOTE ON PRINTING: the lid is modelled in its assembled orientation (text up,
// skirt down) so the two-color split reads correctly. That is not how it should
// be printed - use Render_Part = "printing", which lays the base out as-modelled
// (floor down, opening up) with the lid turned over beside it, tag face on the
// bed, ready to slice.

include <BOSL2/std.scad>

/* [Box Size] */
// Interior width (X)
Inner_Width = 120;       // [20:1:250]
// Interior length (Y)
Inner_Length = 80;       // [20:1:250]
// Interior depth (Z) - clear height from the floor to the underside of the lid
Inner_Depth = 20;        // [10:1:200]

/* [Box Construction] */
// Side-wall thickness
Wall_Thickness = 3.5;    // [1:0.1:8]
// Floor thickness of the base
Floor_Thickness = 2;     // [1:0.1:10]
// Solid thickness of the lid top (the "tag" face the text lives on)
Lid_Top_Thickness = 4;   // [1.5:0.1:12]
// Rounding of the outer vertical (Z) corners
Corner_Radius = 8;       // [0:0.5:40]

/* [Lid Fit] */
// Vertical engagement: how far the neck / lid skirt overlaps
Lid_Engagement = 10;     // [3:0.5:80]
// Clearance between the neck and the lid skirt (per side)
Fit_Tolerance = 0.2;     // [0:0.05:1]

/* [Retention Detent] */
// Add a snap ridge on the neck (with a matching groove in the lid)
Add_Retention = true;    // [true, false]
// How far the ridge protrudes
Retention_Protrusion = 0.25;   // [0.2:0.05:2]
// Vertical size of the ridge
Retention_Height = 2.0;       // [0.5:0.1:6]
// Where along the engagement the ridge sits (0 = bottom, 1 = top)
Retention_Z_Fraction = 0.5;   // [0.1:0.05:0.9]

/* [Finger Cutout] */
// Add a thumb scallop at the front seam to help open the box
Add_Finger_Cutout = false;    // [true, false]
// Width of the scallop (along X)
Finger_Cutout_Width = 24;    // [5:1:80]
// Radius / depth of the scallop
Finger_Cutout_Depth = 8;     // [2:0.5:25]

/* [Text] */
// mm the text is raised (positive) above, or cut (negative) into, the lid top.
// When negative, its absolute value must be at least 1mm less than Lid_Top_Thickness.
Text_Depth = -0.6;       // [-10:0.1:10]

// Line 1 - the individual's name
Name_Text = "SISTER SMITH";
Name_Font_Size = 12;      // [2:0.5:30]
Name_Font_Family = "League Gothic";
// Nudge the name line up (+) or down (-) in Y
Name_Y_Adjustment = 10;   // [-30:0.5:30]

// Line 2
Church_Label_1_Text = "THE CHURCH OF";
Church_Label_1_Font_Size = 7.5;   // [2:0.1:30]
Church_Label_1_Font_Family = "PT Serif:Bold";
Church_Label_1_Y_Adjustment = 0;  // [-30:0.5:30]

// Line 3 (traditionally the emphasised "JESUS CHRIST")
Church_Label_2_Text = "JESUS CHRIST";
Church_Label_2_Font_Size = 10;     // [2:0.1:30]
Church_Label_2_Font_Family = "PT Serif:Bold";
Church_Label_2_Y_Adjustment = -1;  // [-30:0.5:30]

// Line 4
Church_Label_3_Text = "OF LATTER-DAY SAINTS";
Church_Label_3_Font_Size = 5.5;   // [2:0.1:30]
Church_Label_3_Font_Family = "PT Serif:Bold";
Church_Label_3_Y_Adjustment = -1;  // [-30:0.5:30]

// Line 5 - optional; leave the text blank to omit it (reclaims its space)
Church_Label_4_Text = "";
Church_Label_4_Font_Size = 4.2;   // [2:0.1:30]
Church_Label_4_Font_Family = "PT Serif:Bold";
Church_Label_4_Y_Adjustment = 0;  // [-30:0.5:30]

/* [Text Layout] */
// Extra gap under the name line (kept larger than the church line gap)
Name_Bottom_Gap = 5;     // [0:0.5:20]
// Gap between the church lines
Church_Line_Gap = 1.5;   // [0:0.5:20]

/* [Colors] */
// Body color (and, when engraved, the cut top layers)
Tag_Color = "dimgrey";
// Text color (raised text, or the surface revealed by engraving)
Text_Color = "white";

/* [Output] */
// Which part(s) to render
Render_Part = "both";    // [both:Both - exploded assembly view, base:Base only, lid:Lid only, printing:Printing View - both parts laid out on the bed]
// Vertical gap between the parts in the "both" (exploded) view
Explode_Gap = 40;        // [0:1:120]

/* [Hidden] */
$fn = 64;
eps = 0.02;
// Gap between the base and the flipped lid in the Printing View layout
Print_Part_Gap = 5;

// ===========================================================================
//  Derived geometry
// ===========================================================================
wall      = Wall_Thickness;
Rout      = Corner_Radius;
Rin       = max(0, Rout - wall);
outer_w   = Inner_Width  + 2 * wall;
outer_l   = Inner_Length + 2 * wall;
floor_t   = Floor_Thickness;
top_t     = Lid_Top_Thickness;
depth     = Inner_Depth;
tol       = Fit_Tolerance;
E         = Lid_Engagement;

// Shoulder plane: the lid's local z = 0 maps to this assembled height. The
// outer wall rises to here; the neck rises E above it to the lid underside.
lid_base_z = floor_t + depth - E;

// Thin inner neck the lid slips over.
neck_wall  = wall / 2;
neck_out_w = Inner_Width  + 2 * neck_wall;
neck_out_l = Inner_Length + 2 * neck_wall;
neck_out_r = Rin + neck_wall;

// Lid local geometry (skirt bottom at local z = 0, top face at lid_local_h).
lid_local_h = E + top_t;

// Highest point of the lid in its local frame: the top face, or the tips of the
// text when it is raised. Flipping the lid about this puts that surface on the bed.
lid_print_h = lid_local_h + max(0, Text_Depth);

// Retention ridge (male) footprint + assembled Z: on the neck's outer face.
det_z = lid_base_z + E * Retention_Z_Fraction;

// ===========================================================================
//  Validation
// ===========================================================================
assert(Text_Depth >= 0 || abs(Text_Depth) <= top_t - 1,
       "Engraved (negative) Text_Depth must be at least 1mm less than Lid_Top_Thickness.");
assert(E + 1 <= depth,
       "Lid_Engagement must be at least 1mm less than Inner_Depth.");
assert(wall / 2 > tol,
       "Wall_Thickness / 2 must exceed Fit_Tolerance (needed for the flush neck joint).");

// The five customizer text lines, as [text, size, font, y_adjust, gap_below].
text_lines = [
    [Name_Text,           Name_Font_Size,           Name_Font_Family,           Name_Y_Adjustment,           Name_Bottom_Gap],
    [Church_Label_1_Text, Church_Label_1_Font_Size, Church_Label_1_Font_Family, Church_Label_1_Y_Adjustment, Church_Line_Gap],
    [Church_Label_2_Text, Church_Label_2_Font_Size, Church_Label_2_Font_Family, Church_Label_2_Y_Adjustment, Church_Line_Gap],
    [Church_Label_3_Text, Church_Label_3_Font_Size, Church_Label_3_Font_Family, Church_Label_3_Y_Adjustment, Church_Line_Gap],
    [Church_Label_4_Text, Church_Label_4_Font_Size, Church_Label_4_Font_Family, Church_Label_4_Y_Adjustment, 0],
];

// ===========================================================================
//  Primitive helpers
// ===========================================================================

// 2D rounded rectangle.
module rr(w, l, r) { rect([w, l], rounding = r); }

// Rounded-rect prism from z = 0 up `h`.
module prism(w, l, r, h) { linear_extrude(height = h) rr(w, l, r); }

// A hollow rounded-rect band (outer profile minus inner profile) of height h.
module band(ow, ol, or_, iw, il, ir_, h) {
    linear_extrude(height = h)
        difference() { rr(ow, ol, or_); rr(iw, il, ir_); }
}

// ---------------------------------------------------------------------------
//  Retention detent
// ---------------------------------------------------------------------------

// A thin perimeter outline of `band_w` following rr(w,l,r), bulged outward by
// `grow`.
module _det_band(w, l, r, band_w, grow) {
    difference() {
        offset(r = grow) rr(w, l, r);
        rr(w - 2 * band_w, l - 2 * band_w, max(0, r - band_w));
    }
}

// A rounded ridge that runs around the outside of rr(w,l,r), protruding `prot`
// at its mid-height and tapering to flush over height `h`, centred at z = zc.
module detent_ridge(w, l, r, zc, prot, h, band_w) {
    hull() {
        translate([0, 0, zc - h / 2]) linear_extrude(eps) _det_band(w, l, r, band_w, 0);
        translate([0, 0, zc])         linear_extrude(eps) _det_band(w, l, r, band_w, prot);
        translate([0, 0, zc + h / 2]) linear_extrude(eps) _det_band(w, l, r, band_w, 0);
    }
}

// The ridge to ADD to the neck (in the given local frame).
module retention_male(z_local) {
    if (Add_Retention)
        detent_ridge(neck_out_w, neck_out_l, neck_out_r, z_local,
                     Retention_Protrusion, Retention_Height, Retention_Protrusion + wall);
}

// The groove to SUBTRACT from the lid skirt (in the given local frame). Cut a
// touch deeper/taller so the ridge seats with clearance.
module retention_female(z_local) {
    if (Add_Retention)
        detent_ridge(neck_out_w, neck_out_l, neck_out_r, z_local,
                     Retention_Protrusion + tol, Retention_Height + 2 * tol, Retention_Protrusion + wall);
}

// ---------------------------------------------------------------------------
//  Finger cutout
// ---------------------------------------------------------------------------

// A rounded (ellipsoidal) thumb scallop centred on the front (min-Y) wall at
// z = z0, penetrating `r` inward and arching `r` in z. Unlike a half-pipe this
// tapers away at its ends, so the opening reads as a rounded scoop rather than
// a rectangular slot. `front_l` is the outer length used to reach the wall.
module finger_notch(front_l, z0, r) {
    if (Add_Finger_Cutout)
        translate([0, -front_l / 2, z0])
            scale([Finger_Cutout_Width / 2, r, r])
                sphere(r = 1, $fn = 64);
}

// The base scoop is capped so it can never cut deeper than the wall thickness
// (it must not breach the cavity into the interior).
base_finger_depth = min(Finger_Cutout_Depth, wall);

// ===========================================================================
//  Base geometry (assembled coords, floor at z = 0)
// ===========================================================================
// Outer wall up to the shoulder, then a thin inner neck the lid slips over.
module base_geo() {
    difference() {
        difference() {
            union() {
                prism(outer_w, outer_l, Rout, lid_base_z);
                translate([0, 0, lid_base_z])
                    band(neck_out_w, neck_out_l, neck_out_r, Inner_Width, Inner_Length, Rin, E);
                retention_male(det_z);                       // ridge on the neck
            }
            translate([0, 0, floor_t]) prism(Inner_Width, Inner_Length, Rin, depth + eps);
        }
        // Finger scallop in the base's outer wall, just below the shoulder.
        // Capped to the wall thickness and clipped below the shoulder plane so
        // it stays in the full-thickness wall and never opens into the cavity.
        intersection() {
            finger_notch(outer_l, lid_base_z, base_finger_depth/2);
            translate([-outer_w, -outer_l, floor_t])
                cube([2 * outer_w, 2 * outer_l, lid_base_z - floor_t]);
        }
    }
}

// ===========================================================================
//  Lid geometry (local coords, skirt bottom at z = 0, top face at lid_local_h)
// ===========================================================================
// Flush outer wall wrapping the neck (inner face clears the neck by tol).
module lid_solid_local() {
    z_det = det_z - lid_base_z;   // detent height in the lid's local frame
    difference() {
        union() {
            band(outer_w, outer_l, Rout, neck_out_w + 2 * tol, neck_out_l + 2 * tol, neck_out_r + tol, E);
            translate([0, 0, E]) prism(outer_w, outer_l, Rout, top_t);
        }
        retention_female(z_det);                         // groove for the neck ridge
        finger_notch(outer_l, 0, Finger_Cutout_Depth);   // scallop in the front skirt bottom
    }
}

// The colored lid (two-color split on its top face), in local coords.
module lid_part() {
    mtag_two_color_tag(outer_w, outer_l, lid_local_h, Text_Depth, Tag_Color, Text_Color) {
        lid_solid_local();
        mtag_text_block(text_lines);
    }
}

// The colored base.
module base_part() {
    color(mtag_body_color(Text_Depth, Tag_Color, Text_Color)) base_geo();
}

// ===========================================================================
//  Layout
// ===========================================================================
// ===========================================================================
//  MERGED LIBRARY: missionary_tag.scad  (inlined for MakerWorld)
//  Kept under /* [Hidden] */ so its constants don't appear in the customizer.
// ===========================================================================
// missionary_tag.scad
// ===========================================================================
// Reusable OpenSCAD modules for building a missionary name tag for The Church
// of Jesus Christ of Latter-day Saints: a rounded-rectangle body carrying a
// centred, vertically-stacked block of text (the individual's name plus the
// church lines).
//
// The text can be RAISED or ENGRAVED as a single colour split in Z, so the tag
// prints in two colours with exactly one filament change (MMU/AMS or a manual
// swap) - see mtag_two_color_tag.
//
// These modules describe the *appearance* of the tag; they know nothing about
// how it mounts. Combine them with a mounting mechanism (e.g.
// mx_keyboard_switch.scad) in the top-level generator.
//
// Depends on BOSL2 (rect / cuboid / rounding).
// ===========================================================================


// Small overlap used to avoid coincident faces / z-fighting on colour splits.
MTAG_EPS = 0.02;

// ---------------------------------------------------------------------------
//  Body outline
// ---------------------------------------------------------------------------

// The shared rounded-rectangle name-tag outline, sitting on the bed (z = 0),
// rounded on the vertical (Z) edges. Used for both the tag and the base body.
module mtag_body(width, height, depth, corner_radius) {
    cuboid([width, height, depth], rounding = corner_radius, edges = "Z", anchor = BOTTOM);
}

// ---------------------------------------------------------------------------
//  Text layout
// ---------------------------------------------------------------------------

// One text line, centred horizontally and vertically at the given Y.
module mtag_text_line(txt, size, font, y = 0) {
    translate([0, y, 0])
        text(txt, size = size, font = font, halign = "center", valign = "center");
}

// -- internal helpers for stacking lines -----------------------------------

// Sum of a numeric vector.
function _mtag_sum(v, i = 0) = i >= len(v) ? 0 : v[i] + _mtag_sum(v, i + 1);

// Total height of the stacked block: sum of every line's size, plus the
// gap-below of every line except the last.
function _mtag_block_h(ls) =
    _mtag_sum([ for (i = [0 : len(ls) - 1]) ls[i][1] ])
  + _mtag_sum([ for (i = [0 : len(ls) - 1]) (i < len(ls) - 1 ? ls[i][4] : 0) ]);

// Y of line i's centre, measured from a block centred on y = 0. Line 0 sits at
// the top; each subsequent line drops by half the previous size, the previous
// gap-below, and half its own size.
function _mtag_line_y(ls, i, bh) =
    i == 0 ? bh / 2 - ls[0][1] / 2
           : _mtag_line_y(ls, i - 1, bh)
             - ls[i - 1][1] / 2 - ls[i - 1][4] - ls[i][1] / 2;

// A vertical stack of centred text lines, the whole block centred on y = 0.
//
// `lines` is a list of line specs, each: [text, size, font, y_adjust, gap_below]
//   text      - the string to render (blank strings are skipped, reclaiming
//               their space and gap)
//   size      - font size (also the line height used for layout)
//   font      - font family
//   y_adjust  - per-line nudge in Y (+ up / - down)
//   gap_below - space between this line and the next (ignored on the last kept
//               line)
module mtag_text_block(lines) {
    ls = [ for (l = lines) if (l[0] != "") l ];   // drop blank lines
    bh = _mtag_block_h(ls);
    for (i = [0 : len(ls) - 1]) {
        l = ls[i];
        mtag_text_line(l[0], l[1], l[2], _mtag_line_y(ls, i, bh) + l[3]);
    }
}

// ---------------------------------------------------------------------------
//  Two-colour tag rendering (single Z colour split)
// ---------------------------------------------------------------------------

// A slab spanning the whole XY footprint between z0 and z1, used to split the
// tag into an upper / lower colour region.
module _mtag_slab(width, height, z0, z1) {
    translate([-width, -height, z0])
        cube([2 * width, 2 * height, z1 - z0]);
}

// Render a solid tag body with its text as a single colour split in Z.
//
//   children(0) = the solid tag geometry (already includes any mount cutouts)
//   children(1) = the 2D text shape (e.g. mtag_text_block(...))
//
//   * text_depth > 0 -> text is RAISED above the top face, printed in
//     `text_color`; the body is `tag_color`.
//   * text_depth < 0 -> text is ENGRAVED: the top `abs(text_depth)` layers are
//     `tag_color` with the text cut out to reveal `text_color` below;
//     everything under the split is `text_color`. The two colours meet on one
//     plane => exactly one filament change for the printer.
//
// The lower (revealed) colour is drawn first and the cap last so the fast
// preview (F5) composites the physically-topmost layers over the lower colour
// instead of z-fighting.
module mtag_two_color_tag(width, height, tag_depth, text_depth,
                          tag_color = "dimgrey", text_color = "white") {
    raised = text_depth > 0;
    td_abs = abs(text_depth);
    z_top  = tag_depth;
    if (raised) {
        color(tag_color) children(0);
        color(text_color)
            translate([0, 0, z_top - MTAG_EPS])
                linear_extrude(height = text_depth + MTAG_EPS)
                    children(1);
    } else {
        z_split = z_top - td_abs;
        color(text_color)
            intersection() {
                children(0);
                _mtag_slab(width, height, -MTAG_EPS, z_split);
            }
        color(tag_color)
            difference() {
                intersection() {
                    children(0);
                    _mtag_slab(width, height, z_split, z_top + MTAG_EPS);
                }
                translate([0, 0, z_split])
                    linear_extrude(height = td_abs + MTAG_EPS)
                        children(1);
            }
    }
}

// The tag/base colour that pairs with mtag_two_color_tag: the body/cap colour
// when text is raised, and the "reveal" colour when engraved. Provided so a
// base rendered separately matches the tag's split.
function mtag_body_color(text_depth, tag_color = "dimgrey", text_color = "white") =
    text_depth > 0 ? tag_color : text_color;

// ---------------------------------------------------------------------------
//  Base border / tray
// ---------------------------------------------------------------------------

// Outer XY footprint of a bordered base, for laying parts out side by side.
function mtag_border_outer_w(width, border_tolerance, border_wall) =
    width + 2 * border_tolerance + 2 * border_wall;
function mtag_border_outer_h(height, border_tolerance, border_wall) =
    height + 2 * border_tolerance + 2 * border_wall;

// A base with a raised border/shell that rises above the base top face to
// surround the tag. Built as one solid outer block with a rounded-rectangular
// tray cavity milled into the top (no coincident faces -> a clean, slicer-safe
// mesh). The cavity clears the tag by `border_tolerance`; walls are
// `border_wall` thick and rise `border_extension` above the base.
module mtag_base_border(width, height, corner_radius, base_depth,
                        border_extension, border_wall, border_tolerance) {
    open_w = width  + 2 * border_tolerance;   // tag-clearance opening
    open_h = height + 2 * border_tolerance;
    open_r = corner_radius + border_tolerance;
    out_w  = open_w + 2 * border_wall;        // outer footprint
    out_h  = open_h + 2 * border_wall;
    out_r  = open_r + border_wall;
    difference() {
        // Full outer block, base + border height.
        linear_extrude(height = base_depth + border_extension)
            rect([out_w, out_h], rounding = out_r);
        // Tray cavity: from the top down to the base top face.
        translate([0, 0, base_depth])
            linear_extrude(height = border_extension + MTAG_EPS)
                rect([open_w, open_h], rounding = open_r);
    }
}

// Ready-to-slice layout: both parts sitting on the bed in the orientation they
// should actually be printed in.
//
// The base prints as modelled - floor down, opening up.
//
// The lid is turned over so its tag face lies on the bed. Printed the way it is
// modelled (skirt down) the top slab would have to bridge the whole cavity in
// mid-air; inverted, the slab is laid down solid first and the skirt walls rise
// from it, so there is nothing to support and the tag face comes off the smooth
// build plate. Raised text ends up against the bed too, which prints fine and
// gives especially crisp lettering.
module printing_view() {
    base_part();
    translate([0, -(outer_l + Print_Part_Gap), lid_print_h])
        rotate([180, 0, 0])
            lid_part();
}

module main() {
    if (Render_Part == "base") {
        base_part();
    } else if (Render_Part == "lid") {
        lid_part();
    } else if (Render_Part == "printing") {
        printing_view();
    } else {  // both, exploded: base on the bed, lid lifted above its seat
        base_part();
        translate([0, 0, lid_base_z + Explode_Gap]) lid_part();
    }
}

main();
