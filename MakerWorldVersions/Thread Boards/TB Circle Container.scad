include <BOSL2/std.scad>;


Inner_Diameter = 72; //[20:1:200]
Outer_Height = 25; //[10:1:100]
Wall_Thickness = 1.5; //[1:0.5:5]
Back_Wall_Thickness = 10; //[1:0.5:20]
Mounting_Board_Thickness = 2; //[1:12]
Bottom_Thickness = 2; //[0:0.5:5]
Board_Cols = 3; //[1:10]
Board_Margin = 2; //[0:0.5:10]

/* [Hidden] */
Outer_Diameter = Inner_Diameter + 2*Wall_Thickness;
Hole_Radius = 8.5;
Cell_Size = 24;
Board_Rows = 1;
DEFAULT_TB_NTB_Thickness = 2;
TB_NTB_Hole_Radius = Hole_Radius;
TB_NTB_Cell_Size = Cell_Size;

completeObject();

module completeObject(){
    union(){
        base();
        translate([0, Outer_Diameter/2+Back_Wall_Thickness-Mounting_Board_Thickness/2, Outer_Height+Board_Margin/2])
            cube([Outer_Diameter, Mounting_Board_Thickness, Board_Margin], center=true);
        translate([0, Outer_Diameter/2+Back_Wall_Thickness-Mounting_Board_Thickness/2, Outer_Height+Cell_Size/2+Board_Margin])
            rotate([90, 0, 0])
                tb_ntb_board(cols=Board_Cols, rows=Board_Rows, thickness=Mounting_Board_Thickness, cell_size=Cell_Size, hole_radius=Hole_Radius, roundedCorners=true, cornerRadius=.5, center=true);
    }
    
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

module tb_ntb_board(rows=2, cols=2, thickness=DEFAULT_TB_NTB_Thickness, cell_size=TB_NTB_Cell_Size, hole_radius=TB_NTB_Hole_Radius, roundedCorners = false, cornerRadius = .5, center=false){
    cornerRadius = roundedCorners ? cornerRadius : .001;
    width = cols * cell_size;
    height = rows * cell_size;
    finalX = center ? 0 : width/2;
    finalY = center ? 0 : height/2;
    finalZ = center ? 0 : thickness/2;
    translate([finalX, finalY, finalZ])
        difference(){
            cuboid([width, height, thickness], rounding=cornerRadius, edges="Z");
            translate([-width/2+cell_size/2, -height/2+cell_size/2, -(thickness+2)/2]) tb_ntb_countersinkPeg(rows=rows, cols=cols, headRadius=hole_radius, headHeight=0, cellSize=cell_size, stemRadius=hole_radius, stemHeight=thickness+2);
        }
}


module tb_ntb_countersinkPeg(rows = 1, cols = 1, headRadius=11, headHeight=8, cellSize=TB_NTB_Cell_Size, stemRadius=TB_NTB_Hole_Radius, stemHeight=20){
    for (row = [0:rows-1]){
        for (col = [0:cols-1]){
            translate([col*cellSize, row*cellSize, 0]){
                translate([0,0,stemHeight]){
                    union(){
                        translate([0,0,-stemHeight])
                            cylinder(r=stemRadius, h=stemHeight+headHeight, center=false);
                        translate([0,0,headHeight])
                cylinder(r=headRadius, h=headHeight, center=false);
                    }
                }
            }   
        }
    }
}   