include <lib/tb_board_nonthreaded.scad>

Inner_Width = 100; //[20:1:400]
Inner_Height = 100; //[0:1:400]
Inner_Depth = 50; //[20:1:400]
Wall_Thickness = 3; //[1:1:5]
Back_Wall_Thickness = 8; //[1:0.5:20]
Floor_Wall_Thickness = 3; //[0:1:20]
Mounting_Board_Thickness = 2; //[1:12]
Board_Cols = 4; //[1:1:20]
Board_Rows = 1; //[1:1:20]
Add_Wing_Supports = true; //[true, false]
Front_Scoop = false;
Center_Cutout_Width = 0; //[0:1:80]
Wall_System = "tb"; //[tb:Thread Boards,tskadis:Threaded Skadis]

/* [Hidden] */
Hole_Radius = 8.5;
Cell_Size = Wall_System=="tb" ? 24 : 20;
Bottom_Mount_Padding = Wall_System=="tb"? 2 : 4;

Outer_Width = Inner_Width + 2*Wall_Thickness;
Outer_Height = Inner_Height + Floor_Wall_Thickness;
Outer_Depth = Inner_Depth + Back_Wall_Thickness + Wall_Thickness + Mounting_Board_Thickness;

// Board_Cols = floor((Cell_Size + Outer_Width)/Cell_Size)-1;
// Board_Rows = floor((Cell_Size + Outer_Height)/Cell_Size)+1;

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
            if (Add_Wing_Supports) wingSupports();
        }
        centerCutout();
    }
}

// When the mounting board is wider than the box, its side "wings" cantilever past the box wall
// with nothing beneath them (an unprintable overhang). Add a triangular buttress beside each
// overhanging side: it rises from the back-bottom of the box (the bed) up to the board's outer
// edge, with a vertical inner face embedded in the box wall and a self-supporting sloped underside.
module wingSupports() {
    board_width = Board_Cols * Cell_Size;
    board_left  = (Outer_Width - board_width) / 2;   // < 0 when the board overhangs on each side
    board_right = board_left + board_width;

    z_top   = Outer_Height + 0.5;   // reach just into the board's underside (board sits at Outer_Height)
    y_back  = Outer_Depth;          // back face of the box, flush with the board's back face
    depth   = Mounting_Board_Thickness;
    overlap = 0.5;                  // dig into the box wall for a solid weld

    if (board_left < -0.01) {
        wingGusset(overlap,              board_left,  z_top, y_back, depth);  // left wing
        wingGusset(Outer_Width - overlap, board_right, z_top, y_back, depth); // right wing
    }
}

// A single triangular prism. Cross-section (x,z): a right triangle with a vertical inner leg at
// inner_x (against the box), a top leg at z_top (under the board wing) and a sloped hypotenuse
// down to (inner_x, 0). Extruded `depth` in -y, ending its back face at y_back.
module wingGusset(inner_x, outer_x, z_top, y_back, depth) {
    translate([0, y_back, 0])
        rotate([90, 0, 0])
            linear_extrude(height = depth)
                polygon([[inner_x, 0], [inner_x, z_top], [outer_x, z_top]]);
}

module innerBoxForHole(){
    translate([Wall_Thickness, Wall_Thickness, Floor_Wall_Thickness])
        cube([Inner_Width, Inner_Depth, Inner_Height], center=false);
}

module outerBox(){
    cube([Outer_Width, Outer_Depth, Outer_Height], center=false);
}

module board(){
    translate([0, Bottom_Mount_Padding, 0]){
        tb_ntb_board(rows=Board_Rows, cols=Board_Cols, thickness=Mounting_Board_Thickness, cell_size=Cell_Size, hole_radius=Hole_Radius, roundedCorners = true, cornerRadius = .5, center=false);
    }
    translate([0, 0, 0]){
        cube([Board_Cols*Cell_Size, Bottom_Mount_Padding+1, Mounting_Board_Thickness]);
    }
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



/* 
module boxWithMountingBoard(){
    union(){
        box();
        translate([Cell_Size/2-Board_Cols*Cell_Size/2,-Outer_Depth/2+Mounting_Board_Thickness/2, -Outer_Height/2+Cell_Size/2]){
            rotate([90,0,0]){
                board(Outer_Width, Outer_Height);
            }
        }
    }
    
}

module box(){
    difference(){
        cube([Outer_Width, Outer_Depth, Outer_Height], center=true);
        translate([0,Back_Wall_Thickness/2,Wall_Thickness])
            cube([Outer_Width-2*Wall_Thickness, Outer_Depth-2*Wall_Thickness-Back_Wall_Thickness, Outer_Height], center=true);
    }
}

module cell(mountingHole=true){
    difference(){
        cube([Cell_Size, Cell_Size, Mounting_Board_Thickness], center=true);
        if(mountingHole){
            translate([0,0,Mounting_Board_Thickness/2])
                cylinder(r=Hole_Radius, h=Mounting_Board_Thickness*2, center=true);
        }
        
    }
}

module board(width, height){
    echo(str("width: ", width, " height: ", height));
    rCalc = (Cell_Size + height)/Cell_Size;
    // rows = floor((Cell_Size + height)/Cell_Size);
    rows = (Cell_Size + height) % Cell_Size == 0 ? rCalc+1 : floor(rCalc);
    cols = floor((Cell_Size + width)/Cell_Size)-1;
    echo(str("rows: ", rows, " cols: ", cols));
    echo(str("Actual Dimensions - Width: ", cols*Cell_Size, " Height: ", rows*Cell_Size));
    for (row = [0:Board_Rows-1]){
        for (col = [0:Board_Cols-1]){
            translate([col*Cell_Size, row*Cell_Size, 0])
                cell(row==Board_Rows-1);
        }
    }
}
 */