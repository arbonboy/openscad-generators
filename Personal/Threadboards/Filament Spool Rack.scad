include <lib/tb_board_nonthreaded.scad>;
include <BOSL2/std.scad>

TB_Columns = 10;
TB_Rows = 4;
TB_Backing_Thickness = 4;
TB_Hole_Type = "teardrop"; // ["circle", "teardrop"]

/* [Brace Parameters] */
Brace_Thickness = 10;
Braces = 3;
Spool_Diameter = 200; 
Spool_Margin = 10; //[0:1:40]
Brace_Cutoff_Y = 160; //[-100:1:250]

/* [Rack Bar Parameters] */
Rack_Bar_Height = 30;
Rack_Bar_Width = 10;
//Rack_Bar_Front_Y_Position = -157; //[-220:1:220]
Rack_Bar_Back_Y_Position = -70; //[-220:1:220]


/* [Hidden] */
Width = TB_Columns * TB_NTB_Cell_Size;
Height = TB_Rows * TB_NTB_Cell_Size;
Rack_Depth = Spool_Diameter + Spool_Margin;



backboard();
braces();
rackBars();

module backboard(){
    rotate([90,0,0])
        tb_ntb_board(rows=TB_Rows, cols=TB_Columns, thickness=TB_Backing_Thickness,roundedCorners = true, cornerRadius = 2, center=true, hole_mode=TB_Hole_Type);
}

module braces(){
    for (i = [0:Braces-1]){
        xTransBase = i*(Width/(Braces-1))-Width/2;
        xTrans = i == 0 ? xTransBase + Brace_Thickness/2: 
            i == Braces-1 ? xTransBase - Brace_Thickness/2 : 
            xTransBase;
        translate([xTrans, -Rack_Depth/2, 0])
            brace();
    }
}

module brace(){
    difference(){
        cuboid([Brace_Thickness, Rack_Depth, Height], rounding=2, edges="Z");
        translate([0, -Spool_Margin, Spool_Diameter/2 - Height/2 + Brace_Thickness])
            rotate([90,0,90])
                cylinder(d=Spool_Diameter, h=Brace_Thickness*2, center=true, $fn=50);
        translate([0, -Brace_Cutoff_Y, 0]){
            cube([Brace_Thickness*2, Rack_Depth, Height], center=true);
        }
    }
}

module rackBars(){
    // Lowest point of the brace (bottom of the spool cradle), in world Y.
    Cradle_Low_Y = -Spool_Margin - Rack_Depth/2;
    // Front bar: flush with the front edge of the full rack.
    Front_Bar_Y = -Rack_Depth + Rack_Bar_Width + Spool_Margin/2;
    // Back bar: mirror of the front bar across the brace's lowest point,
    // so both sit the same distance from that point.
    //Back_Bar_Y = 2*Cradle_Low_Y - Front_Bar_Y;
    Back_Bar_Y = 2*Cradle_Low_Y - Front_Bar_Y - Spool_Margin;
    // Both bars rest on the bottom of the braces.
    Bar_Z = -Height/2;

    translate([0, -Brace_Cutoff_Y, Bar_Z]) rackBar();
    translate([0, Rack_Bar_Back_Y_Position,  Bar_Z]) rackBar();
}

module rackBar(){
    // Triangular cross-section: base = Rack_Bar_Width (Y), height = Rack_Bar_Height (Z).
    // Extruded along the rack length Width (X). Corners rounded.
    triangle = [
        [-Rack_Bar_Width/2, 0],
        [ Rack_Bar_Width/2, 0],
        [0, Rack_Bar_Height]
    ];
    rounded = round_corners(triangle, radius=2, closed=true, $fn=24);
    rotate([90, 0, 90])
        linear_extrude(height=Width, center=true)
            polygon(rounded);
}