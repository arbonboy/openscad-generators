include <lib/tb_board_nonthreaded.scad>;
include <../ThreadedSkadis/lib/ts_board_threaded.scad>;
include <BOSL2/std.scad>

// Which pegboard system the rack hangs on. Threadboard is a square 24mm cell; Threaded Skadis is a 40 x 20mm cell, which puts a node every 20mm across and every 20mm down.
Board_System = "threadboard"; // [threadboard:Threadboard, threadedskadis:Threaded Skadis]
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
Is_Skadis = (Board_System == "threadedskadis");

// Column and row pitch of the selected system. Threadboard's cell is square, so both
// are TB_NTB_Cell_Size (24). Threaded Skadis' cell is 40 x 20, but half of that width
// is the stagger: a board carries a node every TS_Board_Cell_Size_X/2 (20mm) across
// and every TS_Board_Cell_Size_Y (20mm) down, with the threaded-rod holes and the
// Skadis slots alternating between them like a checkerboard.
Cell_Size_X = Is_Skadis ? TS_Board_Cell_Size_X / 2 : TB_NTB_Cell_Size;
Cell_Size_Y = Is_Skadis ? TS_Board_Cell_Size_Y     : TB_NTB_Cell_Size;
// Clearance added to the Skadis hole radius, matching ts_board_threaded_board's default.
TS_Hole_Tolerance = 0.1;

Width = TB_Columns * Cell_Size_X;
Height = TB_Rows * Cell_Size_Y;
Rack_Depth = Spool_Diameter + Spool_Margin;



backboard();
braces();
rackBars();

module backboard(){
    rotate([90,0,0]){
        if (Is_Skadis)
            ts_backboard();
        else
            tb_ntb_board(rows=TB_Rows, cols=TB_Columns, thickness=TB_Backing_Thickness,roundedCorners = true, cornerRadius = 2, center=true, hole_mode=TB_Hole_Type);
    }
}

// The Threaded Skadis backboard: the same slab-with-holes the Threadboard library builds,
// but on the Skadis lattice. The node positions come from the Skadis library itself, so it
// keeps owning the hole grid. Every node is drilled, not just the threaded-rod ones - a
// Skadis board alternates rod holes with Skadis slots, and drilling both means the rack
// bolts up wherever on the board it lands. The holes reuse the Threadboard library's
// teardrop profile so TB_Hole_Type still works: the backboard prints standing on edge,
// which leaves the hole axes horizontal and a plain round hole unsupported at its top.
module ts_backboard(){
    hole_r = TS_Board_Hole_Radius + TS_Hole_Tolerance;
    nodes  = ts_board_nodes(TB_Rows, TB_Columns, TS_Board_Cell_Size_X, TS_Board_Cell_Size_Y, true);

    translate([-Width/2, -Height/2, -TB_Backing_Thickness/2])
        difference(){
            linear_extrude(height=TB_Backing_Thickness) ts_rounded_rect_2d(Width, Height, 2);
            for (p = nodes)
                translate([p[0], p[1], -1])
                    linear_extrude(height=TB_Backing_Thickness+2){
                        if (TB_Hole_Type == "teardrop") tb_ntb_teardrop2d(r=hole_r);
                        else                            circle(r=hole_r);
                    }
        }
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