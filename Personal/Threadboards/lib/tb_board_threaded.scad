include <BOSL2/std.scad>
include <BOSL2/threading.scad>
use <BOSL2/shapes2d.scad>;
include <tb_screws.scad>;

/* [Hidden] */
TB_TB_Hole_Radius = 8.5;
TB_TB_Cell_Size = 24;
DEFAULT_TB_TB_Thickness = 4;

TB_TB_POS_Square = 0;
TB_TB_POS_Circle = 1;
TB_TB_POS_Octagon = 2;
TB_TB_POS_Threaded = 3;
TB_TB_POS_Complex_Threaded = 4;

TB_TB_VX_Outer_Hole_Factor = 1.2;
TB_TB_VX_Outer_Hole_Radius = TB_TB_Hole_Radius * TB_TB_VX_Outer_Hole_Factor;
TB_TB_VX_Brace_Length = (TB_TB_Cell_Size - TB_TB_VX_Outer_Hole_Radius*2)/2+0.2;
TB_TB_VX_Brace_Width = TB_TB_Cell_Size/10;
TB_TB_VX_Snap_Fit_Factor = 1.1;

module tb_tb_cell(thickness = DEFAULT_TB_NTB_Thickness, cellSize = TB_NTB_Cell_Size, holeRadius = TB_NTB_Hole_Radius){
    difference(){
        cube([cellSize, cellSize, thickness], center=false);
        translate([cellSize/2,cellSize/2,thickness/2])
            cylinder(r=holeRadius, h=thickness*2, center=true);
    }
}


module tb_tb_board(rows=2, cols=2, thickness=DEFAULT_TB_TB_Thickness, cell_size=TB_TB_Cell_Size, hole_radius=TB_TB_Hole_Radius, roundedCorners = false, cornerRadius = .5, center=false, punchout_style=0, punchout_size=12, punchout_affects_border=true, spacers=false, spacer_height=0.4){
    cornerRadius = roundedCorners ? cornerRadius : .001;
    width = cols * cell_size;
    height = rows * cell_size;
    finalX = center ? 0 : width/2;
    finalY = center ? 0 : height/2;
    finalZ = center ? 0 : thickness/2;

    punchOutCols = punchout_affects_border ? cols + 1 : cols - 1;
    punchOutRows = punchout_affects_border ? rows + 1 : rows - 1;
    punchOutComplexCols = punchout_affects_border ? cols + 1 : cols - 1;
    punchOutComplexRows = punchout_affects_border ? rows : rows;
    punchOutComplexMidCols = punchout_affects_border ? punchOutComplexCols - 1 : punchOutCols + 1;
    punchOutComplexMidRows = punchout_affects_border ? punchOutComplexRows + 1 : punchOutComplexRows - 1;
    punchOutPosX = punchout_affects_border ? -width/2 : -width/2+cell_size;
    punchOutPosY = punchout_affects_border ? -height/2 : -height/2+cell_size;
    punchOutComplexPosX = punchout_affects_border ? -width/2 : -width/2+cell_size;
    punchOutComplexPosY = punchout_affects_border ? -height/2+cell_size/2 : -height/2+cell_size/2;
    punchOutComplexMidPosX = punchout_affects_border ? -width/2 : -width/2;
    punchOutComplexMidPosY = punchout_affects_border ? -height/2+cell_size/2 : -height/2+cell_size*3/2;

    translate([finalX, finalY, finalZ])
        difference(){
            union(){
                if(spacers){
                    translate([0, 0, thickness/2])tb_tb_board_spacers(rows=rows, cols=cols, thickness=thickness, cell_size=cell_size, hole_radius=hole_radius, spacer_height=spacer_height, center=true);
                }
                translate([0,0,0]) cuboid([width, height, thickness], rounding=cornerRadius, edges="Z");
            }
            translate([-width/2+cell_size/2, -height/2+cell_size/2, -thickness/2]) tb_tb_threaded_rods_for_holes(rows=rows, cols=cols, thickness=thickness*2, cell_size=cell_size, hole_radius=hole_radius);
            if(punchout_style == TB_TB_POS_Circle || punchout_style == TB_TB_POS_Octagon || punchout_style == TB_TB_POS_Square)
                translate([punchOutPosX, punchOutPosY, -thickness/2]) tb_tb_punchouts(style = punchout_style, rows = punchOutRows, cols = punchOutCols, thickness = thickness*2, cell_size = cell_size, hole_size = punchout_size);
            if(punchout_style == TB_TB_POS_Threaded || punchout_style == TB_TB_POS_Complex_Threaded)
                translate([punchOutPosX, punchOutPosY, -thickness/2]) tb_tb_threaded_rods_for_holes(rows=punchOutRows, cols=punchOutCols, thickness=thickness*2, cell_size=cell_size, hole_radius=hole_radius);
            if(punchout_style == TB_TB_POS_Complex_Threaded){
                translate([punchOutComplexPosX, punchOutComplexPosY, -thickness/2]) tb_tb_threaded_rods_for_holes(rows=punchOutComplexRows, cols=punchOutComplexCols, thickness=thickness*2, cell_size=cell_size, hole_radius=hole_radius/3);
                translate([punchOutComplexMidPosX+cell_size/2, punchOutComplexMidPosY-cell_size/2, -thickness/2]) tb_tb_threaded_rods_for_holes(rows=punchOutComplexMidRows, cols=punchOutComplexMidCols, thickness=thickness*2, cell_size=cell_size, hole_radius=hole_radius/3);
            }
        }
}


module tb_tb_cell_vX(thickness = DEFAULT_TB_TB_Thickness, cellSize = TB_TB_Cell_Size, holeRadius = TB_TB_Hole_Radius, center=false, spacers=false, spacer_height=0.4){
    // outerHoleFactor = 1.2;
    // snapFitFactor = 1.1;
    // holeOuterRadius = holeRadius * outerHoleFactor;
    // braceLength = (cellSize - holeOuterRadius*2)/2+0.2;
    // braceWidth = cellSize/10;
    outerHoleFactor = TB_TB_VX_Outer_Hole_Factor;
    snapFitFactor = TB_TB_VX_Snap_Fit_Factor;
    holeOuterRadius = TB_TB_VX_Outer_Hole_Radius;
    braceLength = TB_TB_VX_Brace_Length;
    braceWidth = TB_TB_VX_Brace_Width;
    braceHeight = thickness;

    spacerSpacing = 2;
    spacerRadius = 0.5;
    difference(){
        union(){
            translate([0,0,0]) cylinder(r=holeOuterRadius, h=thickness, center=true);
            translate([-cellSize/2+braceLength/2, 0, 0]) rotate([0, 0, 0]) cuboid([braceLength, braceWidth, braceHeight]);
            translate([cellSize/2-braceLength/2, 0, 0]) rotate([0, 0, 0]) cuboid([braceLength, braceWidth, braceHeight]); 
            translate([0, -cellSize/2+braceLength/2, 0]) rotate([0, 0, 90]) cuboid([braceLength, braceWidth, braceHeight]);
            translate([0, cellSize/2-braceLength/2, 0]) rotate([0, 0, 90]) cuboid([braceLength, braceWidth, braceHeight]);
            
            
        }
        color("purple") union(){
            translate([-cellSize/2, -cellSize/2, -thickness/16]) cylinder(r=(cellSize-holeOuterRadius)/2*snapFitFactor, h=thickness/2, center=true);
            translate([cellSize/2, -cellSize/2, -thickness/16]) cylinder(r=(cellSize-holeOuterRadius)/2*snapFitFactor, h=thickness/2, center=true);
            translate([-cellSize/2, cellSize/2, -thickness/16]) cylinder(r=(cellSize-holeOuterRadius)/2*snapFitFactor, h=thickness/2, center=true);
            translate([cellSize/2, cellSize/2, -thickness/16]) cylinder(r=(cellSize-holeOuterRadius)/2*snapFitFactor, h=thickness/2, center=true);
        }
        
        tb_tb_threaded_rods_for_holes(rows=1, cols=1, thickness=thickness*2, cell_size=cellSize, hole_radius=holeRadius);
        translate([0, 0, -thickness*7/8]) cylinder(r1=holeRadius*2, r2=holeRadius/2, h=thickness*2, center=true);
        translate([0, 0, thickness*6/8]) rotate([180, 180, 0]) cylinder(r2=holeRadius*2, r1=holeRadius/2, h=thickness*2, center=true);
    }
    // translate([0, 0, thickness*7/8]) rotate([180, 180, 0]) cylinder(r2=holeRadius*2, r1=holeRadius/2, h=thickness*2, center=true);
    
    
}

module tb_tb_cell_snapbase_vX(thickness = DEFAULT_TB_TB_Thickness, cellSize = TB_TB_Cell_Size, holeRadius = TB_TB_Hole_Radius, center=false, scale=0.97, noSnap=false){
    snapCellSize = TB_TB_Cell_Size - TB_TB_VX_Brace_Width;
    snapRadius1 = snapCellSize/3-1;
    snapRadius2 = snapCellSize/3+0.2;

    finalX = center ? 0 : (cellSize/2-TB_TB_VX_Brace_Width/2)*(scale);
    finalY = center ? 0 : (cellSize/2-TB_TB_VX_Brace_Width/2)*(scale);
    finalZ = center ? 0 : thickness/2;
    translate([finalX, finalY, finalZ]){
        scale([scale, scale, 1]){
            union(){
                difference(){
                    cuboid([snapCellSize, snapCellSize, thickness]);
                    translate([cellSize/2,cellSize/2,thickness/2])
                        cylinder(r=TB_TB_VX_Outer_Hole_Radius, h=thickness*2, center=true);
                    translate([-cellSize/2,cellSize/2,thickness/2])
                        cylinder(r=TB_TB_VX_Outer_Hole_Radius, h=thickness*2, center=true);
                    translate([cellSize/2,-cellSize/2,thickness/2])
                        cylinder(r=TB_TB_VX_Outer_Hole_Radius, h=thickness*2, center=true);
                    translate([-cellSize/2,-cellSize/2,thickness/2])
                        cylinder(r=TB_TB_VX_Outer_Hole_Radius, h=thickness*2, center=true);
                }
                if(!noSnap){
                    translate([0, 0, thickness/4])
                        cylinder(r1=snapRadius2, r2=snapRadius1, h=thickness/4, center=true);
                    translate([0, 0, 0])
                        cylinder(r1=snapRadius2, r2=snapRadius2, h=thickness/4, center=true);
                    translate([0, 0, -thickness/4])
                        cylinder(r1=snapRadius1, r2=snapRadius2, h=thickness/4, center=true);
                }
            }
        }
    }
}

module tb_tb_board_vX(rows=2, cols=2, thickness=DEFAULT_TB_TB_Thickness, cell_size=TB_TB_Cell_Size, hole_radius=TB_TB_Hole_Radius, center=false, spacers=false, spacer_height=0.4){
    width = cols * cell_size;
    height = rows * cell_size;
    finalX = center ? 0 : width/2;
    finalY = center ? 0 : height/2;
    finalZ = center ? 0 : thickness/2;

    
    translate([finalX, finalY, finalZ])
        difference(){
            union(){
                // if(spacers){
                //     translate([0, 0, thickness/2])tb_tb_board_spacers(rows=rows, cols=cols, thickness=thickness, cell_size=cell_size, hole_radius=hole_radius, spacer_height=spacer_height, center=true);
                // }
                for(row = [0:rows-1]){
                    for(col = [0:cols-1]){
                        translate([ -width/2 + col*cell_size + cell_size/2, -height/2 + row*cell_size + cell_size/2, 0]){
                            tb_tb_cell_vX(thickness=thickness, cellSize=cell_size, holeRadius=hole_radius, center=true, spacers=spacers, spacer_height=spacer_height);
                        }
                    }
                }
                
            }
            translate([-width/2+cell_size/2, -height/2+cell_size/2, -thickness/2]) tb_tb_threaded_rods_for_holes(rows=rows, cols=cols, thickness=thickness*2, cell_size=cell_size, hole_radius=hole_radius, tolerance=0);
            
        }
}

module tb_tb_board_vX_stacked(rows=2, cols=2, boards=2, thickness=DEFAULT_TB_TB_Thickness, cell_size=TB_TB_Cell_Size, hole_radius=TB_TB_Hole_Radius, center=false, spaceMM=0.4){
    for(boardNum = [0:boards-1]){
        translate([0,0,boardNum*(thickness+spaceMM)]) 
            tb_tb_board_vX(rows=rows, cols=cols, thickness=thickness, cell_size=cell_size, hole_radius=hole_radius, center=center);
    }   
    
    
}

module tb_tb_board_spacers(rows = 2, cols = 2, thickness = DEFAULT_TB_TB_Thickness, cell_size = TB_TB_Cell_Size, hole_radius = TB_TB_Hole_Radius, spacer_height = 4, center = false) { 
    width = cols * cell_size;
    height = rows * cell_size;
    finalX = center ? 0 : width / 2;
    finalY = center ? 0 : height / 2;
    finalZ = center ? 0 : thickness / 2;

    for (row = [0:rows - 1]) {
        for (col = [0:cols - 1]) {
            translate([finalX - width / 2 + col * cell_size + cell_size / 2, finalY - height / 2 + row * cell_size + cell_size / 2, finalZ]) {
                // threadedRod(length = spacer_height, center = true, tolerance = 0.2, hole_radius = hole_radius);
                color("pink") translate([0.5, 0, 0])tb_tb_board_spacer_circular(r=hole_radius+0.6, dash_len=1, gap_len=3, width=0.7, height=spacer_height);
            }
            translate([finalX - width / 2 + col * cell_size, finalY - height / 2 + row * cell_size, finalZ])
                tb_tb_board_spacer_cell(cell_size = TB_TB_Cell_Size, width=0.7, gap=3, height=spacer_height);
        }
    }
}

module tb_tb_board_spacer_circular(r=TB_NTB_Hole_Radius, dash_len=2, gap_len=4, width=0.7, height=0.4) {
    circ     = 2 * PI * r;
    dash_deg = 360 * (dash_len / circ);
    gap_deg  = 360 * (gap_len  / circ);
    step     = dash_deg + gap_deg;

    linear_extrude(height=height)
        difference(){
            for (a = [0 : step : 360 - 0.01]){
                arc(r=r, start=a, angle=dash_deg, wedge=true);
            }
            arc(r=r-width, start=0, angle=360, wedge=true);    
        }
}

module tb_tb_board_spacer_cell(cell_size = TB_TB_Cell_Size, width=2, gap=4, height=0.4) {
    // for(c = [0:gap_len:cell_size-1e-6]){
    //     for(r = [0:gap_len:cell_size-1e-6]){
    //         translate([c,r,0])
    //             cube([dash_len, dash_len, height], center=false);
    //     }
    // }  
    step = (gap+width);
    for(c = [0:step:cell_size-width]){
        for(r = [0:step:cell_size-width]){
            translate([c,r,0])
                color("red") cube([width, width, height], center=false);
        }
    }  
    color("blue")
        union(){
            translate([0, 0, 0])
                cube([width, width, height], center=false);
            translate([cell_size-width, 0, 0])
                cube([width, width, height], center=false);
            translate([(cell_size-width)/2, 0, 0])
                cube([width, width, height], center=false);
            translate([(cell_size-width)/2, cell_size-width, 0])
                cube([width, width, height], center=false);
            translate([0, cell_size-width, 0])
                cube([width, width, height], center=false);
            translate([cell_size-width, cell_size-width, 0])
                cube([width, width, height], center=false);
            translate([0, (cell_size-width)/2, 0])
                cube([width, width, height], center=false);
            translate([cell_size-width, (cell_size-width)/2, 0])
                cube([width, width, height], center=false);
        }
    
}

module tb_tb_threaded_rods_for_holes(rows = 1, cols = 1, thickness = DEFAULT_TB_TB_Thickness, cell_size = TB_TB_Cell_Size, hole_radius = TB_TB_Hole_Radius, tolerance = 0.1) {
    for (row = [0:rows - 1]) {
        for (col = [0:cols - 1]) {
            translate([col * cell_size, row * cell_size, 0]) {
                translate([0, 0, thickness / 2]) {
                    threadedRodForHole(length = thickness, center = true, tolerance = tolerance, hole_radius = hole_radius);
                }
            }
        }
    }
}   

module tb_tb_punchouts(style=TB_TB_POS_Square, rows = 1, cols = 1, thickness = DEFAULT_TB_TB_Thickness, cell_size = TB_TB_Cell_Size, hole_size = TB_TB_Hole_Radius*2) {
    for (row = [0:rows - 1]) {
        for (col = [0:cols - 1]) {
            translate([col * cell_size, row * cell_size, 0]) {
                translate([0, 0, thickness / 2]) {
                    if(style == TB_TB_POS_Octagon)
                        rotate([0, 0, 22.5]) cylinder(r=hole_size/2, h=thickness, $fn=8, center=true);
                    if(style == TB_TB_POS_Square)
                        rotate([0, 0, 45]) cube([hole_size, hole_size, thickness], center = true);
                    if(style == TB_TB_POS_Circle)
                        cylinder(r=hole_size/2, h=thickness, $fn=32, center=true);
                }
            }
        }
    }
} 