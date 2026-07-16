include <BOSL2/std.scad>
use <BOSL2/shapes2d.scad>;
include <ts_constants.scad>;
include <ikea_skadis.scad>;

/* [Hidden] */

// ts_board_rods_for_holes(rows = 5, cols = 4, tolerance = 0.1);
// ts_board_skadis_holes(rows = 5, cols = 4, tolerance = 0.1);

// ts_board_nonthreaded_board(rows = 2, cols = 2, include_skadis="none");

// module ts_board_nonthreaded_board(rows=1, cols=2, thickness=DEFAULT_TS_Board_NonThreaded_Thickness, cell_size_x=TS_Board_Cell_Size_X, cell_size_y=TS_Board_Cell_Size_Y, hole_radius=TS_Board_Hole_Radius, include_skadis=false,tolerance=0.1, rounding=2) {
//     // translate([cell_size_x/2, cell_size_y/2, 0]) {
//         difference(){
//             // The board itself.
//             translate([cols*cell_size_x/2 - cell_size_x/4, rows*cell_size_y/2, thickness/2]){
//                 cuboid([cols * cell_size_x - cell_size_x/2, rows * cell_size_y, thickness], rounding=rounding, edges="Z");
//             }
//             translate([cell_size_x/4, cell_size_y/2, 0]){
//                 // The holes for the rods.
//                 # ts_board_rods_for_holes(rows=rows, cols=cols, thickness=thickness, cell_size_x=cell_size_x, cell_size_y=cell_size_y, hole_radius=hole_radius, tolerance=tolerance);

//                 if(include_skadis){
//                     // The Skadis slots.
//                     # ts_board_skadis_holes(rows=rows, cols=cols, thickness=thickness, cell_size_x=cell_size_x, cell_size_y=cell_size_y);
//                 }
//             }
//         }
        
//     // }
// }

module ts_board_nonthreaded_board(rows=1, cols=2, thickness=DEFAULT_TS_Board_NonThreaded_Thickness, cell_size_x=TS_Board_Cell_Size_X, cell_size_y=TS_Board_Cell_Size_Y, hole_radius=TS_Board_Hole_Radius, include_skadis="none" /* none,hole,peg */, tolerance=0.1, rounding=2) {
    // translate([cell_size_x/2, cell_size_y/2, 0]) {
        difference(){
            // The board itself.
            translate([cols*cell_size_x/4, rows*cell_size_y/2, thickness/2]){
                // cuboid([cols * cell_size_x - cell_size_x/2, rows * cell_size_y, thickness], rounding=rounding, edges="Z");
                cuboid([cols * cell_size_x/2, rows * cell_size_y, thickness], rounding=rounding, edges="Z");
            }
            translate([cell_size_x/4, cell_size_y/2, 0]){
                // The holes for the rods.
                # ts_board_rods_for_holes(rows=rows, cols=cols, thickness=thickness, cell_size_x=cell_size_x, cell_size_y=cell_size_y, hole_radius=hole_radius, tolerance=tolerance);

                if(include_skadis=="hole"){
                    // The Skadis slots.
                    # ts_board_skadis_holes(rows=rows, cols=cols, thickness=thickness, cell_size_x=cell_size_x, cell_size_y=cell_size_y);
                }
            }
        }
        translate([cell_size_x/4, cell_size_y/2, 0]){
            if(include_skadis=="peg"){
                ts_board_skadis_pegs(rows=rows, cols=cols, thickness=thickness, cell_size_x=cell_size_x, cell_size_y=cell_size_y);
                // skadis_pegs_position(length = , all_pegs = true){
                //     skadis_peg(true, true);
                // }
            }
        }
        
    // }
}

module ts_board_rods_for_holes(rows = 1, cols = 1, thickness = DEFAULT_TS_Board_NonThreaded_Thickness, cell_size_x = TS_Board_Cell_Size_X, cell_size_y = TS_Board_Cell_Size_Y, hole_radius = TS_Board_Hole_Radius, tolerance = 0.1) {
    for (row = [0 : rows - 1]) {
        // Even rows start at x = 0; odd rows are shifted right by half a cell. Every row is
        // cell_size_y above the previous one, so the pattern alternates back and forth.
        let (x_offset = (row % 2 == 0) ? 0 : cell_size_x / 2) {
            for (col = [0 : cols - 1]) {
                translate([col * cell_size_x + x_offset, row * cell_size_y, thickness / 2]) {
                    // Placeholder for non-threaded rods
                    cylinder(h = thickness+1, r = hole_radius + tolerance, center = true);
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

// Skadis slot placeholders interleaved with the threaded-rod grid (for use in a difference()).
// Each slot sits in the gap between rods: cell_size_x/2 to the right of a threaded hole and
// cell_size_y/2 above it (i.e. equidistant left/right of the rods and midway between the rows).
module ts_board_skadis_holes(rows = 1, cols = 1, thickness = DEFAULT_TS_Board_NonThreaded_Thickness, cell_size_x = TS_Board_Cell_Size_X, cell_size_y = TS_Board_Cell_Size_Y, hole_radius = TS_Board_Hole_Radius, tolerance = 0.1) {
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

// Skadis pegs interleaved with the threaded-rod grid (for use in a difference()).
// Each slot sits in the gap between rods: cell_size_x/2 to the right of a threaded hole and
// cell_size_y/2 above it (i.e. equidistant left/right of the rods and midway between the rows).
module ts_board_skadis_pegs(rows = 1, cols = 1, thickness = DEFAULT_TS_Board_NonThreaded_Thickness, cell_size_x = TS_Board_Cell_Size_X, cell_size_y = TS_Board_Cell_Size_Y, hole_radius = TS_Board_Hole_Radius, tolerance = 0.1) {
    for (row = [0 : rows - 1]) {
        // Mirror the threaded-rod staggering so the slots land squarely between the rods.
        let (x_offset = (row % 2 == 0) ? 0 : -cell_size_x / 2) {
            for (col = [0 : cols - 1]) {
                translate([col * cell_size_x + x_offset + cell_size_x / 2, row * cell_size_y , thickness / 2]) {
                    ts_board_skadis_connection_peg();
                }
            }
        }
    }
}

// ts_board_skadis_connection_peg();
module ts_board_skadis_connection_peg(depth = DEFAULT_TS_Board_Thickness) {
    height = TS_Board_Skadis_Slot_Width;
    templateOrig = [
        [0,3], [0,6], [3,6], [3,1], [7,1], [7,3], [8,3],
        [8,1], [7,0], [3,0], [2,1], [2,5], [1,5], [1,4],
        [0,3]
    ];
    template = [
        [0,0],
            [depth * 2, 0],
            [depth * 2, depth + 2.5],
            [depth + 1, depth+2.5],
            [depth, depth],
            [0, depth],
        [0,0]
    ];
    
    $fn=36; // remove for dev

    linear_extrude(height) {
        polygon(template);
    };

}