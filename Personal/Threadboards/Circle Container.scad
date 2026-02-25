include <lib/tb_board_nonthreaded.scad>;

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


/* module cell(mountingHole=true){
    difference(){
        cube([Cell_Size, Cell_Size, Mounting_Board_Thickness], center=true);
        if(mountingHole){
            translate([0,0,Mounting_Board_Thickness/2])
                cylinder(r=Hole_Radius, h=Mounting_Board_Thickness*2, center=true);
        }
        
    }
}

module board(){
    translate([Cell_Size/2-Board_Cols*Cell_Size/2, Outer_Diameter/2+Back_Wall_Thickness-Mounting_Board_Thickness/2,Cell_Size/2+Outer_Height+Board_Margin/2]){
        rotate([-90,0,0]){
            union(){
                for (col = [0:Board_Cols-1]){
                    translate([col*Cell_Size, 0, 0])
                        cell();
                    translate([col*Cell_Size, Cell_Size/2+Board_Margin/2, 0])
                        cube([Cell_Size, Board_Margin, Mounting_Board_Thickness], center=true);
                }
            }
            // union(){
            //     for (col = [0:Board_Cols-1]){
            //         translate([col*Cell_Size, 0, 0])
            //             cell();
            //         translate([col*Cell_Size, Cell_Size-Board_Margin, 0])
            //             cube([Cell_Size, Outer_Height+Board_Margin, Mounting_Board_Thickness], center=true);
            //     }
            // }
        }
    }
    
}
 */
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