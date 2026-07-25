// Missionary Name Tag Box
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
// skirt down) so the two-color split reads correctly. For a clean top surface
// most people slice the lid flipped (text face on the bed); the base prints
// as-modelled (floor down, opening up).

include <BOSL2/std.scad>
include <lib/missionary_tag.scad>

/* [Box Size] */
// Interior width (X)
Inner_Width = 100;       // [20:1:250]
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
Retention_Protrusion = 0.3;   // [0.2:0.05:2]
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
Render_Part = "both";    // [both, base, lid]
// Vertical gap between the parts in the "both" (exploded) view
Explode_Gap = 40;        // [0:1:120]

/* [Hidden] */
$fn = 64;
eps = 0.02;

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

// A horizontal (X-axis) half-pipe scallop centred on the front (min-Y) wall at
// z = z0, penetrating `r` inward. `front_l` is the outer length used to reach
// the wall.
module finger_notch(front_l, z0, r) {
    if (Add_Finger_Cutout)
        translate([0, -front_l / 2, z0])
            rotate([0, 90, 0])
                cylinder(h = Finger_Cutout_Width, r = r, center = true, $fn = 64);
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
            finger_notch(outer_l, lid_base_z, base_finger_depth);
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
module main() {
    if (Render_Part == "base") {
        base_part();
    } else if (Render_Part == "lid") {
        lid_part();
    } else {  // both, exploded: base on the bed, lid lifted above its seat
        base_part();
        translate([0, 0, lid_base_z + Explode_Gap]) lid_part();
    }
}

main();
