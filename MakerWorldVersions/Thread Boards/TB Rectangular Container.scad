include <BOSL2/std.scad>;

Inner_Width = 100; //[20:1:400]
Inner_Height = 100; //[0:1:400]
Inner_Depth = 50; //[20:1:400]
Wall_Thickness = 3; //[1:1:5]
Back_Wall_Thickness = 8; //[1:0.5:20]
Floor_Wall_Thickness = 3; //[0:1:20]
Mounting_Board_Thickness = 2; //[1:12]
Board_Cols = 4; //[1:1:20]
Board_Rows = 1; //[1:1:20]
Front_Scoop = false;
Center_Cutout_Width = 0; //[0:1:80]

/* [Hidden] */
Hole_Radius = 8.5;
Cell_Size = 24;
DEFAULT_TB_NTB_Thickness = 2;
TB_NTB_Hole_Radius = Hole_Radius;
TB_NTB_Cell_Size = Cell_Size;



Outer_Width = Inner_Width + 2*Wall_Thickness;
Outer_Height = Inner_Height + Floor_Wall_Thickness;
Outer_Depth = Inner_Depth + Back_Wall_Thickness + Wall_Thickness + Mounting_Board_Thickness;

generateContainer();

module generateContainer(){
    difference(){
        union(){
            difference(){
                outerBox();
                innerBoxForHole();
                if(Front_Scoop){
                    scoop();
                }
            }
            translate([(Outer_Width-Board_Cols*Cell_Size)/2,Outer_Depth,Outer_Height]) 
                rotate([90, 0, 0])
                    board();
        }
        centerCutout();
    }
}

module innerBoxForHole(){
    translate([Wall_Thickness, Wall_Thickness, Floor_Wall_Thickness])
        cube([Inner_Width, Inner_Depth, Inner_Height], center=false);
}

module outerBox(){
    cube([Outer_Width, Outer_Depth, Outer_Height], center=false);
}

module board(){
    tb_ntb_board(rows=Board_Rows, cols=Board_Cols, thickness=Mounting_Board_Thickness, cell_size=Cell_Size, hole_radius=Hole_Radius, roundedCorners = true, cornerRadius = .5, center=false);
}


module scoop(){
    translate([Outer_Width/2,Wall_Thickness/2,Outer_Height])
        rotate([90, 0, 0])
            cylinder(h=Wall_Thickness, r=Inner_Width/4, center=true);
}

module centerCutout(){
    translate([Outer_Width/2, Outer_Depth/2, Outer_Height/2+Board_Rows*Cell_Size/2])
        cube([Center_Cutout_Width, Outer_Depth, Outer_Height+Board_Rows*Cell_Size], center=true);
}


// Module: tb_ntb_board()
// Synopsis: Creates a grid of threadboards cells
// Usage:
//   tb_ntb_board(rows, cols, cell_size);
// Description:
//   Creates a grid of threadboards cells.
// Arguments:
//   rows = Number of rows of cells.
//   cols = Number of columns of cells
//   cell_size = (optional) Size of each cell to deviate from the standard size of 24mm
// Example:
//   tb_ntb_board(); // Standard 2x2 board
// Example with more cells:
//   tb_ntb_board(rows=4, cols=3);
// Example with larger cells (non-standard):
//   tb_ntb_board(cell_size=30);
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