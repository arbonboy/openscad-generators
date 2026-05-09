// twist-passthrough-fidget.scad
// Load a user-specified STL and cut it into a print-in-place spiral twist fidget.
// Adjust the parameters below and set STL_FILE to your own STL path.

STL_FILE = "/Users/john.andersen/Library/CloudStorage/GoogleDrive-arbonboy@gmail.com/My Drive/Personal/3D Printing/3D Printing Queue/0010 Thread Boards/Screws - Hex Head/TB HexHD9xTHR22.stl";
STL_SCALE = [1, 1, 1];
STL_ROTATION = [0, 0, 0];
STL_TRANSLATION = [0, 0, 0];

SPIRAL_TURNS = 3;           // full revolutions of the spiral cut
SPIRAL_HEIGHT = 60;         // total height of the spiral cut zone
SPIRAL_RADIUS = 20;         // approximate radius of the spiral path
SPIRAL_RADIAL_WIDTH = 12;   // radial thickness of the spiral partition
SPIRAL_CLEARANCE = 0.6;     // gap between moving parts
SPIRAL_SEGMENTS = 200;      // resolution for the helix

SHOW_HELPER = false;       // set true to visualize the cutter shape
SHOW_INNER = true;
SHOW_OUTER = true;

//------------------------------------------------------------------------------
// Scene
//------------------------------------------------------------------------------

if (SHOW_HELPER) {
    color([1, 0, 0, 0.3])
        spiral_partition(SPIRAL_RADIUS, SPIRAL_RADIAL_WIDTH, SPIRAL_HEIGHT, SPIRAL_TURNS);
}

if (SHOW_OUTER)
    color("silver") outer_shell();

if (SHOW_INNER)
    color("gold") inner_core();

//------------------------------------------------------------------------------
// Modules
//------------------------------------------------------------------------------

module stl_body() {
    translate(STL_TRANSLATION)
        rotate(STL_ROTATION)
            scale(STL_SCALE)
                import(file = STL_FILE, center = true, convexity = 10);
}

module spiral_partition(radius, width, height, turns) {
    translate([0, 0, -height / 2])
        linear_extrude(height = height, twist = 360 * turns, convexity = 10, $fn = SPIRAL_SEGMENTS)
            polygon(points = [
                [0, -width / 2],
                [radius, -width / 2],
                [radius, width / 2],
                [0, width / 2]
            ]);
}

module outer_shell() {
    difference() {
        stl_body();
        spiral_partition(SPIRAL_RADIUS, SPIRAL_RADIAL_WIDTH + 2 * SPIRAL_CLEARANCE, SPIRAL_HEIGHT + 2 * SPIRAL_CLEARANCE, SPIRAL_TURNS);
    }
}

module inner_core() {
    intersection() {
        stl_body();
        spiral_partition(SPIRAL_RADIUS, max(0.1, SPIRAL_RADIAL_WIDTH - 2 * SPIRAL_CLEARANCE), SPIRAL_HEIGHT + 2 * SPIRAL_CLEARANCE, SPIRAL_TURNS);
    }
}

//------------------------------------------------------------------------------
// Utility
//------------------------------------------------------------------------------

function max(a, b) = a > b ? a : b;
