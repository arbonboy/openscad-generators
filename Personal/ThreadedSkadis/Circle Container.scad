include <lib/ts_board_threaded.scad>;

Inner_Diameter = 72; //[20:1:200]
Outer_Height = 25; //[10:1:100]
Wall_Thickness = 1.5; //[1:0.5:5]
Back_Wall_Thickness = 10; //[1:0.5:20]
Mounting_Board_Thickness = 2; //[1:12]
Bottom_Thickness = 2; //[0:0.5:5]
Board_Cols = 3; //[1:10]
Board_Margin = 2; //[0:0.5:10]
Add_Wing_Supports = true; // [true, false]

/* [Hidden] */
Outer_Diameter = Inner_Diameter + 2*Wall_Thickness;
Board_Rows = 1;

completeObject();

module completeObject(){
    union(){
        base();
        translate([0, Outer_Diameter/2+Back_Wall_Thickness-Mounting_Board_Thickness/2, Outer_Height+Board_Margin/2])
            cube([Outer_Diameter, Mounting_Board_Thickness, Board_Margin], center=true);
        //translate([-TS_Board_Cell_Size_X*Board_Cols/2 + TS_Board_Cell_Size_X/4, Outer_Diameter/2+Back_Wall_Thickness-Mounting_Board_Thickness/2*0, Outer_Height+Board_Margin])
        translate([-Board_Cols*TS_Board_Cell_Size_X/4, Outer_Diameter/2+Back_Wall_Thickness-Mounting_Board_Thickness/2*0, Outer_Height+Board_Margin])
            rotate([90, 0, 0])
                // tb_ntb_board(cols=Board_Cols, rows=Board_Rows, thickness=Mounting_Board_Thickness, cell_size=Cell_Size, hole_radius=Hole_Radius, roundedCorners=true, cornerRadius=.5, center=true);
                // ts_board_nonthreaded_board(cols=Board_Cols, rows=Board_Rows, thickness=Mounting_Board_Thickness,  tolerance=0.1, rounding=0);
                ts_board_threaded_board(cols=Board_Cols, rows=Board_Rows, tb_hole_type="nonthreaded", thickness=Mounting_Board_Thickness, skadis_elements="ntb", board_border_type="solid", frame_type="solid", tolerance=0.1, rounding=0);
        if (Add_Wing_Supports) wingSupports();
    }
}

// If the mounting board is wider than the neck, its side "wings" cantilever past the neck
// with nothing beneath them (an unprintable overhang). Add a triangular buttress beside each
// side of the neck: it rises from the back-bottom of the neck (the bed) up to the board's outer
// edge, with a vertical inner face bonded to the neck side and a self-supporting sloped underside.
module wingSupports() {
    board_half = (TS_Board_Cell_Size_X*Board_Cols/2) / 2; // board spans +/- this in x
    neck_half  = Outer_Diameter / 2;                                             // neck spans +/- this in x

    if (board_half > neck_half) {
        neck_back = Back_Wall_Thickness + Outer_Diameter/2;   // back face of the neck (max y)
        z_top     = Outer_Height + Board_Margin + 0.5;        // reach just into the board's underside
        depth     = Mounting_Board_Thickness;           // spans the board plate back to the neck face
        overlap   = 0.5;                                      // dig into the neck side for a solid weld

        wingGusset(neck_half - overlap, board_half, z_top, neck_back, depth);              // +x wing
        mirror([1, 0, 0]) wingGusset(neck_half - overlap, board_half, z_top, neck_back, depth); // -x wing
    }
}

// A single triangular prism. Cross-section (x,z): a right triangle with a vertical inner leg at
// inner_x (against the neck), a top leg at z_top (under the board wing) and a sloped hypotenuse
// down to (inner_x, 0). Extruded `depth` in -y, ending its back face at y_back.
module wingGusset(inner_x, outer_x, z_top, y_back, depth) {
    translate([0, y_back, 0])
        rotate([90, 0, 0])
            linear_extrude(height = depth)
                polygon([[inner_x, 0], [inner_x, z_top], [outer_x, z_top]]);
}

module base(){
    difference(){
        union(){
            cupOuterFrame(Outer_Diameter, Wall_Thickness, Outer_Height, Bottom_Thickness);
            translate([0,(Back_Wall_Thickness+Outer_Diameter/2)/2,Outer_Height/2]){
                neck(Outer_Diameter, Outer_Height, Back_Wall_Thickness+Outer_Diameter/2);
            }
        }
        cupHole(Outer_Diameter, Wall_Thickness, Outer_Height, Bottom_Thickness);
    }
}


module neck(width, height, depth){
    difference(){
        translate([0,0,0])
            cube([width, depth, height], center=true);
        translate([0,Outer_Diameter/2+Back_Wall_Thickness,0])
            cube([width+2, depth, height+2], center=true);
    }
}

module cupOuterFrame(od, wall, h, bottom) {
    // Cylindrical cup with a solid bottom of thickness `bottom`
    // Z axis is vertical; base sits on Z=0
    difference() {
        // Outer shell
        cylinder(d = od, h = h, $fn = 128);

        // Hollow interior — starts above the bottom to leave a solid base
        translate([0,0,bottom])
            cylinder(d = od - 2*wall, h = h - bottom + 0.01, $fn = 128);
    }
}
module cupHole(od, wall, h, bottom) {
    // Cylindrical cup with a solid bottom of thickness `bottom`
    // Z axis is vertical; base sits on Z=0
    // difference() {
    //     // Outer shell
    //     cylinder(d = od, h = h, $fn = 128);

    //     // Hollow interior — starts above the bottom to leave a solid base
    //     translate([0,0,bottom])
    //         cylinder(d = od - 2*wall, h = h - bottom + 0.01, $fn = 128);
    // }

    
    translate([0,0,bottom])
        cylinder(d = od - 2*wall, h = h - bottom + 0.01, $fn = 128);
}