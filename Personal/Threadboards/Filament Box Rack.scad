// include <lib/tb_storage_box.scad>;
include <lib/tb_board_nonthreaded.scad>;

/* [General Parameters] */
Number_of_Slots = 1; //[1:1:5]
Wall_Thickness = 4;//[1:0.5:5]
Internal_Rack_Height = 70;
Internal_Rack_Width = 235;
Internal_Rack_Depth = 200;

Screw_Head_Tolerance = 8;

Side_Wall_Type = "brace"; //[solid:Solid, peg:Peg Holes, brace: Brace]
Bottom_Wall_Type = "hollow"; //[solid:Solid, peg:Peg Holes, hollow:Hollow]

/* [Side Brace Parameters] */
Side_Wall_Brace_Ratio = 0.6; //[0:0.1:1]
Side_Brace_Depth_Ratio = 0.8; //[0.4:0.05:1]

/* [Bottom Hollow Parameters] */
Bottom_Hollowing_Ratio = 0.5; //[0:0.05:1]



/* [Hidden] */
Back_Wall_Cell_Size = 48;  
Cell_Size = TB_NTB_Cell_Size;
Rack_Columns = 1;
Rounding = 1;

Total_Depth = Internal_Rack_Depth + Wall_Thickness + Screw_Head_Tolerance;
Total_Width = Internal_Rack_Width + 2*Wall_Thickness;
Total_Height = Internal_Rack_Height + Wall_Thickness;



union(){
    backWall();
    sideWall("left", Side_Wall_Type);
    sideWall("right", Side_Wall_Type);
    bottomWall(Bottom_Wall_Type);
}

module backWall(){
    cols = floor(Internal_Rack_Width / Cell_Size);
    rows = floor(Internal_Rack_Height / Cell_Size);
    difference(){
        cuboid([Total_Width, Wall_Thickness, Total_Height], rounding=Wall_Thickness/2, edges="Y");
        translate([-(cols*Cell_Size)/2+Cell_Size/2, Wall_Thickness/2, -(rows*Cell_Size)/2+Cell_Size/2]){
            rotate([90, 0, 0]){
                tb_ntb_countersinkPeg(rows = rows, cols = cols);
            }
        }
    }
}

module sideWall(side="left", wall_type="solid"){
    roundedEdge = side == "left" ? LEFT : RIGHT;
    translate([side=="left" ? -Total_Width/2+Wall_Thickness/2 : Total_Width/2-Wall_Thickness/2, -Total_Depth/2, 0]){
        rotate([0, 0, 0]){
            if( wall_type == "solid" || wall_type == "peg"){
                difference(){
                    cuboid([Wall_Thickness, Total_Depth, Total_Height], rounding=Wall_Thickness/2, edges=roundedEdge + FWD + BOT);
                    if(wall_type == "peg"){
                        translate([-Wall_Thickness/2, -Total_Depth/2+Cell_Size/2+Wall_Thickness, Total_Height/2-Cell_Size/2-Wall_Thickness])
                            rotate([0, 90, 0])
                                tb_ntb_countersinkPeg(rows = floor(Total_Depth / Cell_Size), cols = floor(Total_Height / Cell_Size));
                    }
                    if(wall_type == "brace"){
                        translate([-Wall_Thickness/2, -Total_Depth/2, -Total_Height/2])
                            rotate([0, 0, 0])
                                color("red") sideBrace();
                    }
                }
            }
            if(wall_type == "brace"){
                sideBrace();
            }
        }
    }
}

module bottomWall(wall_type="solid"){
    bottomHollowRatio = Bottom_Hollowing_Ratio;
    translate([0, -Total_Depth/2, -Total_Height/2+Wall_Thickness/2]){
        rotate([0, 0, 0]){
            difference(){
                cuboid([Total_Width, Total_Depth, Wall_Thickness], rounding=Wall_Thickness/2);
                if(wall_type == "peg"){
                    translate([-Total_Width/2+Cell_Size/2, -Total_Depth/2+Cell_Size, -Wall_Thickness])
                        rotate([0, 0, 0])
                            tb_ntb_countersinkPeg(rows = floor(Total_Depth / Cell_Size), cols = floor(Total_Width / Cell_Size));
                }
                if(wall_type == "hollow"){
                    translate([0, 0, 0])
                        rotate([0, 0, 0])
                            color("purple") cuboid([Internal_Rack_Width*bottomHollowRatio, Internal_Rack_Depth*bottomHollowRatio, 2*Wall_Thickness], rounding=Wall_Thickness/2, edges=[FRONT,BACK]);
                }
            }
        }
    }
}

module sideBrace(){
    braceFill = Side_Wall_Brace_Ratio;
    braceDepth = Total_Depth*Side_Brace_Depth_Ratio;
    CA = braceDepth;
    AB = Total_Height;
    braceWidthX = braceFill*CA;
    braceWidthY = braceFill*AB;

    pointsOutside = [
        [0, 0],
        [CA, 0],
        [CA, AB],
        [0, 0]
    ];

    FD = braceFill*CA;
    DE = braceFill*AB;

    F = [CA-braceWidthX-FD, braceWidthY];
    D = [CA-braceWidthX, braceWidthY];
    E = [CA-braceWidthX, braceWidthY+DE];
    // pointsInside = [
    //     F,
    //     D,
    //     E,
    //     F
    // ];
    pointsInside = [
        [0, 0],
        [CA*braceFill, 0],
        [CA*braceFill, AB*braceFill],
        [0, 0]
    ];
    translate([-Wall_Thickness/2, -Total_Depth/2+(Total_Depth-braceDepth), -Total_Height/2])
        rotate([90, 0, 90])
            difference(){
                linear_extrude(height = Wall_Thickness){
                    polygon(pointsOutside);
                }
                translate([(CA-FD)*3/4, (AB-DE)/4, 0])
                    linear_extrude(height = Wall_Thickness+0.1){
                        polygon(pointsInside);
                    }
            }
            
}