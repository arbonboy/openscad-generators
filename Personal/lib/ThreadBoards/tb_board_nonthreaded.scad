include <tb_misc.scad>;
include <BOSL2/std.scad>;

/* [Hidden] */
TB_NTB_Hole_Radius = 8.5;
TB_NTB_Cell_Size = 24;
DEFAULT_TB_NTB_Thickness = 2;



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




/* Old Stuff Below - To be deleted
module tb_ntb_boardOrig(rows=2, cols=2, thickness=DEFAULT_TB_NTB_Thickness, cell_size=TB_NTB_Cell_Size, hole_radius=TB_NTB_Hole_Radius, roundedCorners = false, cornerRadius = 0.5){
    for (row = [0:rows-1]){
        for (col = [0:cols-1]){
            translate([col*cell_size, row*cell_size, 0])
                tb_ntb_cell(thickness=thickness, cellSize=cell_size, holeRadius=hole_radius, roundedCorners = roundedCorners, cornerRadius = cornerRadius);
        }
    }
}

function _tb_ntb_board_2d(rows=2, cols=2, cell_size=TB_NTB_Cell_Size, hole_radius=TB_NTB_Hole_Radius) = tb_ntb_board_2d(rows=rows, cols=cols, cell_size=cell_size, hole_radius=hole_radius);


module tb_ntb_board_2d(rows=2, cols=2, cell_size=TB_NTB_Cell_Size, hole_radius=TB_NTB_Hole_Radius){
    difference() {
        square([cols*cell_size, rows*cell_size], center=false);
        translate([cell_size/2, cell_size/2,-1])tb_ntb_countersinkPeg(rows=rows, cols=cols, headRadius=hole_radius, headHeight=0, stemRadius=hole_radius, stemHeight=5);
    }
}


// Module: tb_ntb_cell()
// Synopsis: Creates a single threadboards cell
// Usage:
//   tb_ntb_cell(cellSize, holeRadius, thickness);
// Description:
//   Creates a single threadboards cell with a central hole.
// Arguments:
//   thickness = (optional) Thickness of the cell. - Default is 2mm.
//   cellSize = (optional) A cell size that deviates from the standard size of 24mm
//   holeRadius = (optional) A radius of the central hole that deviates from the standard size of 8.5mm
// Example:
//   tb_ntb_cell(); // Standard cell
// Example with thicker board:
//   tb_ntb_cell(thickness=5);
// Example with larger hole than what is standard:
//   tb_ntb_cell(holeRadius=10);
module tb_ntb_cell(thickness = DEFAULT_TB_NTB_Thickness, cellSize = TB_NTB_Cell_Size, holeRadius = TB_NTB_Hole_Radius, roundedCorners = false, cornerRadius = 0.5){
    crad = roundedCorners ? cornerRadius : .001;
    difference(){
        roundedcube([cellSize, cellSize, thickness], center=false, radius=crad, apply_to="z");
        translate([cellSize/2,cellSize/2,thickness/2])
            cylinder(r=holeRadius, h=thickness*2, center=true);
    }
}


*/