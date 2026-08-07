include <lib/tb_board_nonthreaded.scad>;
include <../ThreadedSkadis/lib/ts_board_threaded.scad>;
include <BOSL2/std.scad>;

// Which pegboard system the brace bolts onto. Threadboard is a square 24mm cell; Threaded Skadis is a staggered 40 x 20mm cell, which presents as a 20mm wide column of holes on a 20mm pitch.
Board_System = "threadboard"; // [threadboard:Threadboard, threadedskadis:Threaded Skadis]
// Width of the brace across the holes (mm). 0 uses the board system's own column width - 24mm on Threadboard, 20mm on Threaded Skadis. A larger value pads a rail down each side of the mounting plate and widens the arm, gusset and lip to match; useful on Threaded Skadis, where a 20mm column leaves only ~1.5mm of material beside a hole. Values below the column width are ignored.
Brace_Width = 0; //[0:1:60]
Bottom_Length = 3; //[1:1:10]
Top_Length_MM = 130; //[1:1:300]
Thickness = 4; //[1:0.5:10]
Lip_Length = 10; //[0:1:200]
Num_Upper_Holes = 2; //[0:1:10]

/* [Hidden] */
Is_Skadis = (Board_System == "threadedskadis");

// The two cell dimensions the brace is built from, taken from the selected system.
//   Cell_Pitch - spacing between mounting holes, measured along the brace.
//   Cell_Width - width of the brace, i.e. one column of the board.
// Threadboard's cell is square, so both are 24. Threaded Skadis stacks its rows
// every TS_Board_Cell_Size_Y (20mm) and shifts alternate rows half a cell in x,
// which makes a one-column strip TS_Board_Cell_Size_X/2 (20mm) wide with a node
// every 20mm down its length.
Cell_Pitch = Is_Skadis ? TS_Board_Cell_Size_Y     : 24;
Cell_Width = Is_Skadis ? TS_Board_Cell_Size_X / 2 : 24;

// The width everything is actually built at. The mounting plate always comes out of
// its library one column wide; anything past that is padding added down its sides.
Brace_Width_MM = max(Brace_Width, Cell_Width);
Side_Rail_Width = (Brace_Width_MM - Cell_Width) / 2;

Bottom_Length_Adj = Bottom_Length > 1 ? Bottom_Length -1 : 1;
//Bottom_Length_Adj = Bottom_Length;
Bottom_Length_MM = Bottom_Length_Adj * Cell_Pitch;
//Angle_Bracket_Bottom_Length_MM = Bottom_Length > 1 ? (Bottom_Length-1)*Cell_Pitch : Cell_Pitch;
Angle_Bracket_Bottom_Length_MM = Bottom_Length_MM;
Angle_Bracket_Length = sqrt(Angle_Bracket_Bottom_Length_MM^2 + Top_Length_MM^2); //Cell_Pitch * Top_Length;
Angle_Bracket_Angle = atan(Top_Length_MM / Angle_Bracket_Bottom_Length_MM);


translate([0,0,Brace_Width_MM/2])  {
    rotate([0, 90, 0]){
        translate([-Brace_Width_MM/2, Bottom_Length > 1 ? -Bottom_Length_MM/2-Cell_Pitch+Thickness/2 : -Cell_Pitch/2, -Thickness/2]) color("orange") brace_mounting_plate(rows=Bottom_Length, center=false, corner_radius=2);
        translate([0, Bottom_Length_MM/2, Top_Length_MM/2-Thickness/2]) rotate([90,0,0]) color("aqua") cuboid([Brace_Width_MM, Top_Length_MM, Thickness], rounding=0, edges=["Z"]);
        translate([0, 1, Top_Length_MM/2]) rotate([Angle_Bracket_Angle, 0, 0]) color("green") cuboid([Brace_Width_MM, Angle_Bracket_Length, Thickness], rounding=Thickness/3, edges=["Z","X"]);
        translate([0, Bottom_Length_MM/2+Lip_Length/2-Thickness/2, Top_Length_MM-Thickness/2]) rotate([0, 0, 0]) color("red") cuboid([Brace_Width_MM, Lip_Length, Thickness], rounding=Thickness/3, edges=[TOP, BOTTOM]);
        if(Num_Upper_Holes > 0){
            translate([0, Num_Upper_Holes*Cell_Pitch/2+Bottom_Length_MM/2+Thickness/2-0.2, 0]) rotate([0, 0, 0])
                color("blue") brace_mounting_plate(rows=Num_Upper_Holes, center=true);
        }
    }
}

// The mounting plate, widened to Brace_Width_MM if the user asked for more than the
// board system gives. The library plate is left exactly as the library builds it - it
// owns the hole spacing - and the extra width is a plain rail down each side. Those
// rails are squared off against a square-cornered library plate so the seam leaves no
// sliver of a void, then the finished outline is rounded back by intersecting it with
// a full-width rounded slab.
module brace_mounting_plate(rows, center = false, corner_radius = 0.5) {
    if (Side_Rail_Width > 0) {
        len = rows * Cell_Pitch;
        translate(center ? [-Brace_Width_MM/2, -len/2, -Thickness/2] : [0, 0, 0])
            intersection() {
                union() {
                    translate([Side_Rail_Width, 0, 0]) system_plate(rows, false, 0.001);
                    for (x = [0, Side_Rail_Width + Cell_Width])
                        translate([x, 0, 0]) cube([Side_Rail_Width, len, Thickness]);
                }
                linear_extrude(height = Thickness)
                    translate([Brace_Width_MM/2, len/2])
                        rect([Brace_Width_MM, len], rounding = corner_radius);
            }
    } else {
        system_plate(rows, center, corner_radius);
    }
}

// A one-column mounting plate for whichever board system is selected. Both libraries
// lay a plate out the same way - corner at the origin, first hole half a pitch in,
// rows stacked along +y - so the call sites above only ever need Cell_Pitch and
// Cell_Width, and the Threadboard branch is exactly what this file did before.
module system_plate(rows, center = false, corner_radius = 0.5) {
    if (Is_Skadis) {
        // Skadis boards alternate threaded-rod holes with Skadis slots down a column, so
        // every node is drilled as a plain clearance hole ("ntb"). The brace then bolts up
        // no matter which of the two interfaces the hole happens to land on.
        translate(center ? [-Cell_Width/2, -rows*Cell_Pitch/2, -Thickness/2] : [0, 0, 0])
            ts_board_threaded_board(rows=rows, cols=1, thickness=Thickness,
                                    tb_hole_type="nonthreaded", skadis_elements="ntb",
                                    board_border_type="solid", frame_type="solid",
                                    tolerance=0.1, rounding=corner_radius);
    } else {
        tb_ntb_board(rows=rows, cols=1, roundedCorners=true, center=center,
                     thickness=Thickness, cornerRadius=corner_radius);
    }
}
