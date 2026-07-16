include <../Threadboards/lib/tb_board_threaded.scad>;
include <BOSL2/std.scad>

/* [Board Settings] */
// Cutout Border leaves half-slots/holes open along the edges; Solid Border keeps all holes and adds a tiling border so the perimeter is solid and multiple boards tile with standard hole spacing.
Board_Frame_Type = "solid";    // [cutout:Cutout Border, solid:Solid Border]
// Horizontal.
Number_Of_Columns = 2;
// Vertical - Ideally an odd number.
Number_Of_Rows = 3;       
// (mm)
Board_Thickness = 5; 
// (mm)
Board_Corner_Radius = 5;  

/* [Corner Mount Settings] */
Corner_Screw_Holes = false;
Corner_Screw_Holes_Chamfer = true;
// (mm)
Corner_Screw_Holes_Diameter = 3;
// (mm)
Corner_Screw_Holes_Inset = 10;
// (mm)
Corner_Screw_Holes_Chamfer_Diameter = 8;


/* [Lite Frame Settings] */
// Remove material between holes to save filament, keeping only a connected border frame around each hole.
Enable_Lite_Frame = false;
// Ultra Lite keeps only horizontal and vertical connectors; Lite also adds diagonal connectors for extra rigidity.
Lite_Frame_Type = "ultralite";    // [ultralite:Ultra Lite, lite:Lite]
// (mm) Width of the border kept around each hole and of the struts that connect the holes together.
Minimum_Lite_Frame_Border_Width = 2;    // [0.5:0.5:15]

/* [Hidden] */
// (mm)
Skadis_Slot_Width = 5;    
// (mm)
Skadis_Slot_Height = 15;    
Chamfer_Skadis_Slots = true;

hole_radius = Skadis_Slot_Width / 2 - 0.01;  // Rounded corners of the holes

hole_spacing_x = 35 + Skadis_Slot_Width; // Horizontal distance between holes (mm)
hole_spacing_y = 25 - Skadis_Slot_Width; // Vertical distance between rows (every two rows)

solid_border = (Board_Frame_Type == "solid");

edge_margin_x = 17.5 + ( Skadis_Slot_Width / 2 ); // Horizontal edge margin
edge_margin_y = 12.5 + ( Skadis_Slot_Height / 2 ); // Vertical edge margin

// Base (Cutout Border) board dimensions - holes reach right to the edges.
cutout_board_width  = 2 * edge_margin_x + (Number_Of_Columns - 1) * hole_spacing_x;
cutout_board_height = 2 * edge_margin_y + (Number_Of_Rows - 1) * hole_spacing_y;

// Solid Border drops the shared-edge (far) row and column that Cutout Border relies on for
// tiling, so every row keeps exactly Number_Of_Columns holes and the board stays the same size.
// The remaining holes shift inward by half the pitch at which they actually repeat in each
// direction, giving a solid perimeter and letting boards tile with the standard staggered pitch.
// Rows are staggered, so holes repeat every hole_spacing_x/2 across the columns (not
// hole_spacing_x, the same-row spacing) and every hole_spacing_y down the rows - hence /4 vs /2.
solid_border_x = hole_spacing_x / 4;
solid_border_y = hole_spacing_y / 2;
hole_shift_x   = solid_border ? solid_border_x : 0;
hole_shift_y   = solid_border ? solid_border_y : 0;

board_width  = cutout_board_width;
board_height = cutout_board_height;

// --- Lite frame derived values ---
lite_border = Minimum_Lite_Frame_Border_Width;
// Struts are two borders wide so they meet the ring wall on either side of the centre line.
lite_connector_width = 2 * lite_border;

// Neighbour distances in the staggered Skadis pattern:
//   horizontal (same row)          = hole_spacing_x
//   vertical   (same column)       = 2 * hole_spacing_y   (holes repeat every other row)
//   diagonal   (adjacent rows)     = norm([hole_spacing_x/2, hole_spacing_y])
// The diagonal links bridge the two offset row-parities so nothing is left free-floating.
lite_diag_dist = norm([hole_spacing_x / 2, hole_spacing_y]);
lite_connect_threshold = max(hole_spacing_x, 2 * hole_spacing_y, lite_diag_dist) + 0.5;

// Feature-keep test for Solid Border. The hole loops over-generate past the edges; we keep the
// near edge (>= 0) but drop the FAR row and column (strict < far edge) - those are the shared-edge
// holes Cutout Border tiles by, redundant on a self-contained Solid board. This leaves each row
// with exactly Number_Of_Columns holes. (In Cutout mode this test is unused - holes are clipped.)
function on_cutout_board(p) =
    p[0] >= -0.01 && p[0] < cutout_board_width  - 0.01 &&
    p[1] >= -0.01 && p[1] < cutout_board_height - 0.01;

// Every hole centre in the base (unshifted) staggered layout.
lite_hole_positions_cutout = [
    for (j = [0 : Number_Of_Rows + 2])
        let(
            x_offset      = (j % 2 == 0) ? hole_spacing_x / 2 : 0,
            col_reduction = (j % 2 == 0) ? 2 : 1
        )
        for (i = [0 : Number_Of_Columns - col_reduction + 2])
            [ edge_margin_x - x_offset + i * hole_spacing_x,
              edge_margin_y + j * hole_spacing_y - hole_spacing_y * 2 ]
];
// Keep every on-board hole (Solid Border also drops the over-generated extras) and shift inward.
lite_hole_positions = [
    for (p = lite_hole_positions_cutout)
        if (!solid_border || on_cutout_board(p))
            [ p[0] + hole_shift_x, p[1] + hole_shift_y ]
];

// Threaded-rod boss support for the lite frame.
// Outer radius of the drilled rod hole (matches threadedGrid()'s tolerance = 0.1), so the
// preserved disk leaves at least lite_border of solid wall around every threaded rod.
lite_rod_hole_radius = TB_TB_Hole_Radius * (1 + 4 * 0.1 / TB_SCREW_Threaded_Rod_Diameter);
lite_rod_radius = lite_rod_hole_radius + lite_border;
// Distance out to which a rod is tied to neighbouring skadis holes (its 4 nearest at ~hole_spacing_y).
lite_rod_anchor_threshold = max(hole_spacing_x / 2, hole_spacing_y) + 1;

// Every threaded-rod centre in the base (unshifted) layout - two staggered 40 mm sets.
lite_rod_positions_cutout = [
    for (c = [0 : Number_Of_Columns])
        for (r = [0 : Number_Of_Rows - 1])
            each [
                [ c * 40,      r * 40 ],
                [ c * 40 + 20, r * 40 - 20 ]
            ]
];
// Keep every on-board rod (Solid Border also drops the over-generated extras) and shift inward.
lite_rod_positions = [
    for (p = lite_rod_positions_cutout)
        if (!solid_border || on_cutout_board(p))
            [ p[0] + hole_shift_x, p[1] + hole_shift_y ]
];

// Function to create a rounded rectangle.
module rounded_rectangle(width, height, radius, c = true) {
    offset(r=radius) 
        offset(delta=-radius)
            square([width, height], center=c);
}

// Module to create an extruded board with rounded corners
module rounded_board() {
    $fn = 50; // Improve corner resolution.
    linear_extrude(height = Board_Thickness) {
        rounded_rectangle(board_width, board_height, Board_Corner_Radius, false);
    }
}

// Module to create a properly extruded hole
module hole(x, y, z) {
    $fn = 30; // Reduce corner resolution for optimisation.
    
    // Extrude the hole through the board.
    translate([ x, y, z ]) {
        linear_extrude(height = Board_Thickness + 2, center=true) {
            rounded_rectangle(Skadis_Slot_Width, Skadis_Slot_Height, hole_radius);
        }
    }
    
    if( Chamfer_Skadis_Slots ) {
        hull() {
            translate([ x, y - (Skadis_Slot_Height / 2) + (Skadis_Slot_Width / 2), Board_Thickness ]) {
                cylinder(h=Board_Thickness / 5, r1=Skadis_Slot_Width / 2, r2=Skadis_Slot_Width / 1.25, center=true);
            }
            translate([ x, y + (Skadis_Slot_Height / 2) - (Skadis_Slot_Width / 2), Board_Thickness ]) {
                cylinder(h=Board_Thickness / 5, r1=Skadis_Slot_Width / 2, r2=Skadis_Slot_Width / 1.25, center=true);
            }
        }
    }
}

// Module for circular corner holes
module corner_hole(x, y, z) {
    $fn = 30; // Smooth circular hole
    
    // Create the hole.
    translate([ x, y, z ]) {
        linear_extrude(height = Board_Thickness + 2, center=true) {
            circle(d=Corner_Screw_Holes_Diameter);
        }
    }
    
    // Make a bevel for a screw head.
    if( Corner_Screw_Holes_Chamfer ) {
        translate([ x, y, Board_Thickness ]) {
            cylinder(h=Board_Thickness / 2, r1=Corner_Screw_Holes_Diameter / 2, r2=Corner_Screw_Holes_Chamfer_Diameter, center=true);
        }
    }
}

// True when two points line up horizontally or vertically (i.e. an axis-aligned strut).
function lite_is_axial(a, b) = (abs(a[0] - b[0]) < 0.01) || (abs(a[1] - b[1]) < 0.01);

// A straight strut of the given width between two 2D points (a rounded capsule).
module lite_strut(p, q, w) {
    hull() {
        translate(p) circle(d = w, $fn = 16);
        translate(q) circle(d = w, $fn = 16);
    }
}

// 2D lite-frame region: a border ring around every hole plus struts connecting
// neighbouring holes, all clipped to the board outline. The hole itself is drilled
// later (in pegboard()), which turns each filled patch into a border ring.
module lite_frame_2d() {
    intersection() {
        rounded_rectangle(board_width, board_height, Board_Corner_Radius, false);
        union() {
            // Border kept around every hole.
            for (p = lite_hole_positions) {
                translate(p)
                    offset(r = lite_border)
                        rounded_rectangle(Skadis_Slot_Width, Skadis_Slot_Height, hole_radius);
            }
            // Connect neighbouring holes. "Ultra Lite" keeps only horizontal/vertical struts;
            // "Lite" also keeps the diagonal ones. (Cross-parity linking still happens via the
            // axis-aligned rod anchors below, so Ultra Lite stays fully connected.)
            for (a = [0 : len(lite_hole_positions) - 1]) {
                for (b = [a + 1 : len(lite_hole_positions) - 1]) {
                    if (norm(lite_hole_positions[a] - lite_hole_positions[b]) <= lite_connect_threshold
                        && (Lite_Frame_Type == "lite"
                            || lite_is_axial(lite_hole_positions[a], lite_hole_positions[b]))) {
                        lite_strut(lite_hole_positions[a], lite_hole_positions[b], lite_connector_width);
                    }
                }
            }
            // Preserve a solid disk around every threaded-rod location (rod is drilled later,
            // leaving a >= lite_border wall), and tie each one to its neighbouring skadis holes.
            for (rp = lite_rod_positions) {
                translate(rp) circle(r = lite_rod_radius, $fn = 40);
                for (hp = lite_hole_positions) {
                    if (norm(rp - hp) <= lite_rod_anchor_threshold) {
                        lite_strut(rp, hp, lite_connector_width);
                    }
                }
            }
        }
    }
}

// The board reduced to just the lite frame.
module lite_frame_board() {
    $fn = 50;
    linear_extrude(height = Board_Thickness) {
        lite_frame_2d();
    }
}

// Main pegboard module
module pegboard() {
    difference() {
        // Base Board (solid, or the material-saving lite frame).
        if (Enable_Lite_Frame) {
            lite_frame_board();
        } else {
            rounded_board();
        }

        // Drill the staggered skadis holes (positions built in lite_hole_positions,
        // which already applies the Solid Border shift + edge filtering).
        for (p = lite_hole_positions) {
            hole(p[0], p[1], Board_Thickness / 2);
        }
        
        // Conditionally render corner holes.
        if (Corner_Screw_Holes) {
            // Origin hole.
            corner_hole(
                Corner_Screw_Holes_Inset,
                Corner_Screw_Holes_Inset,
                Board_Thickness / 2
            );
            
            // Origin X hole.
            corner_hole(
                board_width - Corner_Screw_Holes_Inset,
                Corner_Screw_Holes_Inset,
                Board_Thickness / 2
            );
            
            // Origin Y hole.
            corner_hole(
                Corner_Screw_Holes_Inset,
                board_height - Corner_Screw_Holes_Inset,
                Board_Thickness / 2
            );
            
            // XY limit hole.
            corner_hole(
                board_width - Corner_Screw_Holes_Inset,
                board_height - Corner_Screw_Holes_Inset,
                Board_Thickness / 2
            );
        }
    }
}

module threadedGrid(){
    // Drill a threaded rod at every rod centre (lite_rod_positions already applies the
    // Solid Border shift + edge filtering, and matches the lite-frame rod bosses).
    for (p = lite_rod_positions) {
        translate([p[0], p[1], 0])
            tb_tb_threaded_rods_for_holes(rows = 1, cols = 1, thickness = Board_Thickness, cell_size = TB_TB_Cell_Size, hole_radius = TB_TB_Hole_Radius, tolerance = 0.1);
    }
}

// Render the pegboard. Change arg to false to create a 2d projection instead.
if ( true ) {
    difference(){
        pegboard();
        threadedGrid();
    }
    // pegboard();
    echo(board_width);
    echo(board_height);
} else {
    projection(cut=true) {
        Corner_Screw_Holes_Chamfer = false;
        Chamfer_Skadis_Slots = false;
        pegboard();
    }
}
