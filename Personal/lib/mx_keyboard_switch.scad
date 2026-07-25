// mx_keyboard_switch.scad
// ===========================================================================
// Reusable OpenSCAD modules for building "clicker" fidget mechanisms around
// Cherry MX style keyboard switches. A clicker is two mating halves:
//
//   * TAG / cap  - its underside grips the cross ("+") stem on top of one or
//                  more MX switches. Built from a clearance recess, a circular
//                  housing, and the female "+" socket (see mx_tag_grip).
//   * BASE       - holds the body of each MX switch in a stepped pocket, so
//                  pressing the tag onto the base actuates the switch
//                  ("click"). See mx_base_pockets.
//
// Every module is parametric and driven by a list of X positions, so any
// outline (rounded rectangle, circle, ...) can be turned into an MX clicker by
// supplying it as the body child and calling these against it.
//
// Depends on BOSL2 (rect / rounding).
// ===========================================================================

include <BOSL2/std.scad>

// Small overlap used to avoid coincident faces on boolean cuts.
MX_EPS = 0.02;

// ---------------------------------------------------------------------------
//  Switch layout
// ---------------------------------------------------------------------------

// X positions of `n` switch mount points, evenly spaced along `width`, centred
// on X, in a single row at y = 0.
function mx_switch_xs(width, n) =
    let (pitch = width / n)
    [ for (i = [0 : n - 1]) (i + 0.5) * pitch - width / 2 ];

// ---------------------------------------------------------------------------
//  Tag (cap) side
// ---------------------------------------------------------------------------

// MX cross ("+") stem profile (2D), centred on the origin.
module mx_stem_cross_2d(len, thick) {
    square([len, thick], center = true);
    square([thick, len], center = true);
}

// Rounded-square clearance recesses cut into the tag underside (z = 0 upward),
// one per position. Each clears the top housing of an MX switch.
module mx_tag_recesses(xs, size, rounding, depth) {
    for (x = xs)
        translate([x, 0, -MX_EPS])
            linear_extrude(height = depth + MX_EPS)
                rect([size, size], rounding = rounding);
}

// Circular housings that sit inside the recesses (flush with the underside),
// giving the "+" socket its gripping walls. They join the tag body at the top
// of the recess (hence height = recess `depth`).
module mx_tag_housings(xs, diameter, depth) {
    for (x = xs)
        translate([x, 0, 0])
            cylinder(d = diameter, h = depth + MX_EPS);
}

// The female "+" stem sockets, cut up from the underside (z = 0) into the body.
// `len` / `thick` are the socket opening (nominal cross size + tolerance);
// use mx_socket_len / mx_socket_thick to add tolerance to nominal dimensions.
module mx_stem_sockets(xs, len, thick, depth) {
    for (x = xs)
        translate([x, 0, -MX_EPS])
            linear_extrude(height = depth + MX_EPS)
                mx_stem_cross_2d(len, thick);
}

// Convenience: apply the full MX gripper to a solid tag body (passed as the
// single child). Subtract the clearance recesses, add the circular stem
// housings, then cut the "+" sockets:
//
//     mx_tag_grip(xs, ...) tag_body_solid();
//
// `socket_len` / `socket_thick` are the socket opening (nominal + tolerance).
module mx_tag_grip(xs, recess_size, recess_rounding, recess_depth,
                   housing_diameter, socket_len, socket_thick, socket_depth) {
    difference() {
        union() {
            difference() {
                children(0);
                mx_tag_recesses(xs, recess_size, recess_rounding, recess_depth);
            }
            mx_tag_housings(xs, housing_diameter, recess_depth);
        }
        mx_stem_sockets(xs, socket_len, socket_thick, socket_depth);
    }
}

// Female socket opening = nominal MX cross dimension + fit tolerance.
function mx_socket_len(nominal_len, tolerance)     = nominal_len + tolerance;
function mx_socket_thick(nominal_thick, tolerance) = nominal_thick + tolerance;

// ---------------------------------------------------------------------------
//  Base side
// ---------------------------------------------------------------------------

// Total depth consumed by a stepped switch pocket (mouth + bore). Handy for
// validating that the base is deep enough to hold it.
function mx_pocket_total_depth(outer_depth, inner_depth) = outer_depth + inner_depth;

// Stepped switch pockets cut from the base top face (z = `top_z`) downward, one
// per position: a shallow wide mouth (outer_size / outer_depth) then a deeper
// narrower bore (inner_size / inner_depth) that captures the MX switch body.
module mx_base_pockets(xs, top_z, outer_size, outer_depth, inner_size, inner_depth) {
    for (x = xs) {
        // Outer mouth.
        translate([x, 0, top_z - outer_depth / 2 + MX_EPS])
            cube([outer_size, outer_size, outer_depth + 2 * MX_EPS], center = true);
        // Inner bore, continuing deeper.
        translate([x, 0, top_z - outer_depth - inner_depth / 2])
            cube([inner_size, inner_size, inner_depth + MX_EPS], center = true);
    }
}
