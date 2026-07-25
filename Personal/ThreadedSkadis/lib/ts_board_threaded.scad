include <BOSL2/std.scad>
include <BOSL2/threading.scad>
use <BOSL2/shapes2d.scad>;
include <ts_screws.scad>;
include <ts_constants.scad>;

/* [Hidden] */




// ts_board_threaded_rods_for_holes(rows = 5, cols = 4, tolerance = 0.1);
// ts_board_skadis_holes(rows = 5, cols = 4, tolerance = 0.1);
// ts_board_threaded_board(rows = 3, cols = 4, include_skadis=true,
//     board_border_type="cutout", frame_type="ultralite", minimum_lite_frame_border_width=2);


// ============================================================================
// Board layout helpers (rod + Skadis checkerboard, Solid / Cutout border)
// ----------------------------------------------------------------------------
// Rods and Skadis slots alternate on a REGULAR grid of pitch (cell_size_x/2, cell_size_y):
// a node is a Skadis slot when (k + r) is odd, otherwise a threaded rod.
//   Cutout Border runs the outermost nodes right to the board edges (half-open holes; abutting
//     boards share those edges when tiled).
//   Solid Border drops the far row + column and insets every node by half a pitch, so the
//     perimeter is solid and boards still tile at the standard pitch.
// ============================================================================

function ts_board_px(cx) = cx / 2;                          // horizontal node pitch
function ts_board_py(cy) = cy;                              // vertical node pitch
// function ts_board_width(cols, cx)  = (2 * cols - 1) * ts_board_px(cx);
// function ts_board_height(rows, cy) = (rows - 1)      * ts_board_py(cy);

function ts_board_width(cols, cx)  = cols * cx;
function ts_board_height(rows, cy) = rows * cy;


// All grid nodes as [x, y, is_skadis].
// `initial` fixes the interface at the TOP-LEFT node (k = 0, r = rmax): a
// threaded rod hole when "Threaded", a Skadis slot/peg when "Skadis". The rest
// of the board alternates from there.
function ts_board_nodes(rows, cols, cx, cy, solid, initial = "Threaded") =
    let(
        px   = ts_board_px(cx),
        py   = ts_board_py(cy),
        // Cutout runs nodes to both edges (cols+1 / rows+1 node lines); Solid
        // drops the far column + row and insets by half a pitch. The k loop is
        // [0 : kmax-1] (count = kmax) while the r loop is [0 : rmax], so the
        // cutout column count is cols+1 and the row count is rows+1 to match.
        kmax = solid ? cols : cols + 1,   // Solid drops the far column
        rmax = solid ? rows - 1 : rows,   // Solid drops the far row
        sx   = solid ? px / 2 : 0,                     // ...and insets by half a pitch
        sy   = solid ? py / 2 : 0,
        // Phase so the top-left node (k = 0, r = rmax) is a rod when "Threaded"
        // and a Skadis node when "Skadis"; adding rmax keeps that anchor fixed
        // regardless of how many rows the board has.
        start = (initial == "Skadis") ? 1 : 0
    )
    [ for (r = [0 : rmax]) for (k = [0 : kmax-1])
        [ k * px + sx, r * py + sy, (k + r + rmax + start) % 2 == 1 ] ];

function ts_board_skadis_nodes(rows, cols, cx, cy, solid, initial = "Threaded") =
    [ for (n = ts_board_nodes(rows, cols, cx, cy, solid, initial)) if (n[2])  [n[0], n[1]] ];
function ts_board_rod_nodes(rows, cols, cx, cy, solid, initial = "Threaded") =
    [ for (n = ts_board_nodes(rows, cols, cx, cy, solid, initial)) if (!n[2]) [n[0], n[1]] ];

// Outer radius of a drilled rod hole (matches threadedRodForHole's tolerance scaling).
function ts_rod_hole_radius(hole_radius, tolerance) =
    hole_radius * (1 + 4 * tolerance / TB_SCREW_Threaded_Rod_Diameter);

// True when two points line up horizontally or vertically (an axis-aligned strut).
function ts_is_axial(a, b) = (abs(a[0] - b[0]) < 0.01) || (abs(a[1] - b[1]) < 0.01);

// A rounded rectangle from (0,0) to (w,h).
module ts_rounded_rect_2d(w, h, r) {
    offset(r = r) offset(delta = -r) square([w, h]);
}

// 2D Skadis slot profile (stadium), grown outward by g.
module ts_slot_profile_2d(g = 0, width = TS_Board_Skadis_Slot_Width, height = TS_Board_Skadis_Slot_Height) {
    offset(r = g) hull() {
        for (dy = [-(height - width) / 2, (height - width) / 2]) {
            translate([0, dy]) circle(d = width, $fn = 24);
        }
    }
}

// A strut (rounded capsule) of width w between two 2D points.
module ts_strut(p, q, w) {
    hull() {
        translate(p) circle(d = w, $fn = 16);
        translate(q) circle(d = w, $fn = 16);
    }
}

// 2D lite-frame region: a border around every Skadis slot, a disk around every rod, and struts
// tying neighbouring nodes together, all clipped to the board outline. "ultralite" keeps only the
// horizontal/vertical struts; "lite" also adds the diagonals. The holes are drilled later, turning
// each filled patch into a ring/wall. On the regular grid every node reaches its axis neighbours,
// so even ultralite stays fully connected.
module ts_lite_frame_2d(rows, cols, cx, cy, solid, lite_border, frame_type, hole_radius, tolerance, rounding, skadis_elements = "hole", initial = "Threaded") {
    px       = ts_board_px(cx);
    py       = ts_board_py(cy);
    W        = ts_board_width(cols, cx);
    H        = ts_board_height(rows, cy);
    skadis   = ts_board_skadis_nodes(rows, cols, cx, cy, solid, initial);
    rods     = ts_board_rod_nodes(rows, cols, cx, cy, solid, initial);
    nodes    = concat(skadis, rods);
    rod_disk = ts_rod_hole_radius(hole_radius, tolerance) + lite_border;   // >= lite_border wall
    conn_w   = 2 * lite_border;
    thresh   = (frame_type == "lite") ? norm([px, py]) + 0.5 : max(px, py) + 0.5;
    // "tb"/"ntb" turn the Skadis nodes into rod-style holes, so they need a rod-sized disk of wall
    // material (not the narrow slot patch) and no border brace (the disk already reaches the border).
    skadis_as_rod = (skadis_elements == "tb") || (skadis_elements == "ntb");
    intersection() {
        ts_rounded_rect_2d(W, H, rounding);
        union() {
            for (p = skadis) translate(p)
                if (skadis_as_rod) circle(r = rod_disk, $fn = 32);
                else               ts_slot_profile_2d(lite_border);
            for (p = rods)   translate(p) circle(r = rod_disk, $fn = 32);
            for (a = [0 : len(nodes) - 1]) {
                for (b = [a + 1 : len(nodes) - 1]) {
                    if (norm(nodes[a] - nodes[b]) <= thresh
                        && (frame_type == "lite" || ts_is_axial(nodes[a], nodes[b]))) {
                        ts_strut(nodes[a], nodes[b], conn_w);
                    }
                }
            }

            // Brace the outer Skadis holes to a solid border. Only meaningful when the perimeter
            // is solid (solid == true) and the interior is a lite frame (this module only runs for
            // lite/ultralite). The outer rod holes already overlap the border via their large disks;
            // the narrow Skadis slots do not, so tie every perimeter Skadis node out to the board
            // edge(s) it borders, reusing the same strut as the interior connectors.
            if (solid && !skadis_as_rod && len(nodes) > 0) {
                xs = [for (n = nodes) n[0]];
                ys = [for (n = nodes) n[1]];
                min_x = min(xs); max_x = max(xs);
                min_y = min(ys); max_y = max(ys);
                bW  = max_x + px / 2;   // true board width  (matches the solid-border slab)
                bH  = max_y + py / 2;   // true board height (ditto)
                eps = 0.01;
                // Clip to the true board rectangle so right/top braces don't overshoot the oversized
                // outer clip rect. Interior nodes never satisfy these edge tests, so they're untouched.
                intersection() {
                    ts_rounded_rect_2d(bW, bH, rounding);
                    union() {
                        for (p = skadis) {
                            if (p[0] <= min_x + eps) ts_strut(p, [0,    p[1]], conn_w);  // left border
                            if (p[0] >= max_x - eps) ts_strut(p, [bW,   p[1]], conn_w);  // right border
                            if (p[1] <= min_y + eps) ts_strut(p, [p[0], 0   ], conn_w);  // bottom border
                            if (p[1] >= max_y - eps) ts_strut(p, [p[0], bH  ], conn_w);  // top border
                        }
                    }
                }
            }
        }
    }
}

module ts_board_threaded_board(
    rows = 3, 
    cols = 2, 
    thickness=DEFAULT_TS_Board_Thickness, 
    cell_size_x=TS_Board_Cell_Size_X, 
    cell_size_y=TS_Board_Cell_Size_Y, 
    hole_radius=TS_Board_Hole_Radius, 
    tb_hole_type="threaded",
    skadis_elements="hole", //hole, peg, tb, ntb, none
    peg_height = DEFAULT_TS_Board_Thickness,
    tolerance=0.1, 
    rounding=2,
    board_border_type="solid",
    frame_type="ultralite",
    minimum_lite_frame_border_width=2,
    initial_interface="Threaded"   // [Threaded, Skadis] - interface in the top-left corner

    ) {




    // Both border types share the SAME (inset) node grid - same columns and
    // rows. "cutout" is simply the "solid" board with the perimeter frame
    // border removed, so the hole positions line up between the two.
    grid_solid = true;                                             // always the inset grid
    add_border = (board_border_type == "solid");                   // "solid" | "cutout"
    lite   = (frame_type == "lite") || (frame_type == "ultralite"); // else "solid" = full board
    W      = ts_board_width(cols, cell_size_x/2);
    H      = ts_board_height(rows, cell_size_y);
    skadis = ts_board_skadis_nodes(rows, cols, cell_size_x, cell_size_y, grid_solid, initial_interface);
    rods   = ts_board_rod_nodes(rows, cols, cell_size_x, cell_size_y, grid_solid, initial_interface);


    difference(){
        union(){
            if(add_border) {
                difference(){
                    translate([W/2, H/2, thickness/2]) {
                        cuboid([W, H, thickness], rounding=rounding, edges="Z");
                    }
                    translate([W/2+minimum_lite_frame_border_width/4, H/2+minimum_lite_frame_border_width/4, thickness/2]) {
                        cuboid([W-minimum_lite_frame_border_width*2, H-minimum_lite_frame_border_width*2, thickness+2], rounding=rounding, edges="Z");
                    }
                }
            }
        
        
            difference() {
                // Base board: full rounded slab, or the material-saving lite frame.
                if (lite) {
                    linear_extrude(height = thickness)
                        ts_lite_frame_2d(rows, cols, cell_size_x, cell_size_y, grid_solid,
                                        minimum_lite_frame_border_width, frame_type, hole_radius, tolerance, rounding,
                                        skadis_elements = skadis_elements, initial = initial_interface);
                } else {
                    linear_extrude(height = thickness) ts_rounded_rect_2d(W, H, rounding);
                }
            }
        }
        // Drill the threaded-rod holes.
        for (p = rods) {
            translate([p[0], p[1], thickness / 2])
                if(tb_hole_type=="threaded"){
                    threadedRodForHole(length = thickness + 1, center = true, tolerance = tolerance, hole_radius = hole_radius);
                } else if(tb_hole_type=="nonthreaded"){
                    cylinder(h = thickness + 1, r = hole_radius + tolerance, center = true);
                }
                
        }

        // Drill the Skadis nodes. "hole" cuts a Skadis slot; "tb"/"ntb" repurpose the node as a
        // threaded / non-threaded rod hole, matching the rod-hole cuts above.
        if (skadis_elements != "none") {
            for (p = skadis) {
                translate([p[0], p[1], thickness / 2]) {
                    if(skadis_elements == "hole"){
                        ts_skadis_slot(thickness);
                    } else if(skadis_elements == "tb"){
                        threadedRodForHole(length = thickness + 1, center = true, tolerance = tolerance, hole_radius = hole_radius);
                    } else if(skadis_elements == "ntb"){
                        cylinder(h = thickness + 1, r = hole_radius + tolerance, center = true);
                    }
                }
            }
        }
    }
        

        if( skadis_elements == "peg" ){
            for (p = skadis) {
                translate([p[0], p[1], peg_height/2+thickness]) ts_skadis_peg(peg_height, tolerance=tolerance);
            }
        }
}



module ts_board_threaded_board_simple(
    rows = 3, 
    cols = 2, 
    thickness=DEFAULT_TS_Board_Thickness, 
    cell_size_x=TS_Board_Cell_Size_X, 
    cell_size_y=TS_Board_Cell_Size_Y, 
    hole_radius=TS_Board_Hole_Radius, 
    include_skadis=false,
    tolerance=0.1, 
    rounding=2
    ) {
        difference(){
            // The board itself.
            translate([cols*cell_size_x/2 - cell_size_x/4, rows*cell_size_y/2, thickness/2]){
                cuboid([cols * cell_size_x - cell_size_x/2, rows * cell_size_y, thickness], rounding=rounding, edges="Z");
            }
            translate([cell_size_x/4, cell_size_y/2, 0]){
                // The holes for the rods.
                # ts_board_threaded_rods_for_holes(rows=rows, cols=cols, thickness=thickness, cell_size_x=cell_size_x, cell_size_y=cell_size_y, hole_radius=hole_radius, tolerance=tolerance);

                if(include_skadis){
                    // The Skadis slots.
                    # ts_board_skadis_holes(rows=rows, cols=cols, thickness=thickness, cell_size_x=cell_size_x, cell_size_y=cell_size_y);
                }
            }
        }
}

module ts_board_threaded_rods_for_holes(rows = 1, cols = 1, thickness = DEFAULT_TS_Board_Thickness, cell_size_x = TS_Board_Cell_Size_X, cell_size_y = TS_Board_Cell_Size_Y, hole_radius = TS_Board_Hole_Radius, tolerance = 0.1) {
    for (row = [0 : rows - 1]) {
        // Even rows start at x = 0; odd rows are shifted right by half a cell. Every row is
        // cell_size_y above the previous one, so the pattern alternates back and forth.
        let (x_offset = (row % 2 == 0) ? 0 : cell_size_x / 2) {
            for (col = [0 : cols - 1]) {
                translate([col * cell_size_x + x_offset, row * cell_size_y, thickness / 2]) {
                    threadedRodForHole(length = thickness+1, center = true, tolerance = tolerance, hole_radius = hole_radius);
                }
            }
        }
    }
}

// A single vertical rounded Skadis slot placeholder, extruded to cut cleanly through the board.
// The opening is chamfered at the front and back faces (a 45 deg lead-in) so the drilled hole
// flares out at both surfaces. Placed centred on the board, so the faces sit at +/- thickness/2.
module ts_skadis_slot(thickness, width = TS_Board_Skadis_Slot_Width, height = TS_Board_Skadis_Slot_Height, chamfer = TS_Board_Skadis_Slot_Chamfer) {
    half = thickness / 2;
    eps  = 0.02;

    // 2D rounded-slot profile, optionally grown outward by g (keeps the stadium shape).
    module profile(g = 0) {
        offset(r = g) hull() {
            for (dy = [-(height - width) / 2, (height - width) / 2]) {
                translate([0, dy]) circle(d = width, $fn = 24);
            }
        }
    }

    union() {
        // Straight slot, overshooting both faces so it always cuts through.
        linear_extrude(height = thickness + 2, center = true) profile();

        // Front-face chamfer: base size chamfer-deep, flaring out to the face.
        hull() {
            translate([0, 0, half - chamfer]) linear_extrude(eps) profile(0);
            translate([0, 0, half])           linear_extrude(eps) profile(chamfer);
        }

        // Back-face chamfer (mirror of the front).
        hull() {
            translate([0, 0, -half + chamfer]) linear_extrude(eps) profile(0);
            translate([0, 0, -half - eps])     linear_extrude(eps) profile(chamfer);
        }
    }
}

// A single vertical rounded Skadis peg placeholder, extruded from the board.
// Placed centred on the board, so the faces sit at +/- thickness/2.
module ts_skadis_peg(thickness, width = TS_Board_Skadis_Slot_Width, height = TS_Board_Skadis_Slot_Height, tolerance=0.1) {
    half = thickness / 2;
    eps  = 0.02;

    // 2D rounded-slot profile, optionally grown outward by g (keeps the stadium shape).
    module profile(g = 0) {
        offset(r = g) hull() {
            for (dy = [-(height - width) / 2, (height - width) / 2]) {
                translate([0, dy]) circle(d = width-tolerance, $fn = 24);
            }
        }
    }

    union() {
        // Straight slot, overshooting both faces so it always cuts through.
        linear_extrude(height = thickness, center = true) profile();

        // Front-face chamfer: base size chamfer-deep, flaring out to the face.
        // (Removed for peg)

        // Back-face chamfer (mirror of the front).
        // (Removed for peg)
    }
}


// Skadis slot placeholders interleaved with the threaded-rod grid (for use in a difference()).
// Each slot sits in the gap between rods: cell_size_x/2 to the right of a threaded hole and
// cell_size_y/2 above it (i.e. equidistant left/right of the rods and midway between the rows).
module ts_board_skadis_holes(rows = 1, cols = 1, thickness = DEFAULT_TS_Board_Thickness, cell_size_x = TS_Board_Cell_Size_X, cell_size_y = TS_Board_Cell_Size_Y, hole_radius = TS_Board_Hole_Radius, tolerance = 0.1) {
    for (row = [0 : rows - 1]) {
        // Mirror the threaded-rod staggering so the slots land squarely between the rods.
        let (x_offset = (row % 2 == 0) ? 0 : -cell_size_x / 2) {
            for (col = [0 : cols - 1]) {
                translate([col * cell_size_x + x_offset + cell_size_x / 2, row * cell_size_y , thickness / 2]) {
                    ts_skadis_slot(thickness);
                }
            }
        }
    }
}
