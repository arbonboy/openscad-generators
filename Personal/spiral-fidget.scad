// spiral-fidget.scad
// Load a user-specified egg-shaped STL and generate a spiral twist fidget model.
// Designed to keep the outer skin smooth while exposing an internal spiral slider mechanism.

STL_FILE = "/Users/john.andersen/Downloads/EGG.stl";
STL_SCALE = [1, 1, 1];
STL_ROTATION = [0, 0, 0];
STL_TRANSLATION = [0, 0, 0];

PART_COUNT = 16;
SPIRAL_TURNS = 3;
SPIRAL_HEIGHT = 60;
SPIRAL_RADIUS = 18;
SPIRAL_TRACK_WIDTH = 10;
SHELL_THICKNESS = 2.8;
PART_CLEARANCE = 0.5;
SPIRAL_RESOLUTION = 180;
SHOW_SLIDERS = true;
SHOW_SHELL = true;

// Render the assembled model
if (SHOW_SHELL) color("silver") outer_shell();
if (SHOW_SLIDERS) color("gold") spiral_sliders();

//------------------------------------------------------------------------------
// Body helpers
//------------------------------------------------------------------------------

module stl_body() {
    translate(STL_TRANSLATION)
        rotate(STL_ROTATION)
            scale(STL_SCALE)
                import(file = STL_FILE, center = true, convexity = 10);
}

module inner_body() {
    // Smaller interior volume used to carve the spiral slider parts.
    translate(STL_TRANSLATION)
        rotate(STL_ROTATION)
            scale([STL_SCALE[0]*(1 - SHELL_THICKNESS/100), STL_SCALE[1]*(1 - SHELL_THICKNESS/100), STL_SCALE[2]*(1 - SHELL_THICKNESS/100)])
                import(file = STL_FILE, center = true, convexity = 10);
}

module outer_shell() {
    difference() {
        stl_body();
        if (SHELL_THICKNESS > 0)
            inner_body();
    }
}

//------------------------------------------------------------------------------
// Spiral slider mechanism
//------------------------------------------------------------------------------

module spiral_sliders() {
    union() {
        for (i = [0:PART_COUNT-1]) {
            color(i % 2 ? [1, 0.85, 0.2] : [0.95, 0.75, 0.1])
                intersection() {
                    inner_body();
                    spiral_segment(i);
                }
        }
    }
}

module spiral_segment(index) {
    angle = index * 360 / PART_COUNT;
    radial_inner = max(0, SPIRAL_RADIUS - SPIRAL_TRACK_WIDTH/2);
    radial_outer = SPIRAL_RADIUS + SPIRAL_TRACK_WIDTH/2;
    translate([0, 0, -SPIRAL_HEIGHT/2])
        rotate([0, 0, angle])
            linear_extrude(height = SPIRAL_HEIGHT, twist = 360 * SPIRAL_TURNS, $fn = SPIRAL_RESOLUTION, convexity = 10)
                polygon(points = [
                    [radial_inner, 0],
                    [radial_outer, 0],
                    [radial_outer, PART_CLEARANCE],
                    [radial_inner, PART_CLEARANCE]
                ]);
}

//------------------------------------------------------------------------------
// Utility
//------------------------------------------------------------------------------

function max(a, b) = a > b ? a : b;
