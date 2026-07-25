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

include <BOSL2/std.scad>

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
