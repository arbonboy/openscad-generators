include <lib/tb_board_nonthreaded.scad>;
include <BOSL2/std.scad>;

Bottom_Length = 3; //[1:1:10]
Top_Length_MM = 130; //[1:1:300]
Thickness = 4; //[1:0.5:10]
Lip_Length = 10; //[0:1:200]
Num_Upper_Holes = 2; //[0:1:10]

/* [Hidden] */
Cell_Size = 24;
Bottom_Length_Adj = Bottom_Length > 1 ? Bottom_Length -1 : 1;
//Bottom_Length_Adj = Bottom_Length;
Bottom_Length_MM = Bottom_Length_Adj * Cell_Size;
//Angle_Bracket_Bottom_Length_MM = Bottom_Length > 1 ? (Bottom_Length-1)*Cell_Size : Cell_Size;
Angle_Bracket_Bottom_Length_MM = Bottom_Length_MM;
Angle_Bracket_Length = sqrt(Angle_Bracket_Bottom_Length_MM^2 + Top_Length_MM^2); //Cell_Size * Top_Length;
Angle_Bracket_Angle = atan(Top_Length_MM / Angle_Bracket_Bottom_Length_MM);   


translate([0,0,Cell_Size/2])  {
    rotate([0, 90, 0]){
        translate([-Cell_Size/2, Bottom_Length > 1 ? -Bottom_Length_MM/2-Cell_Size+Thickness/2 : -Cell_Size/2, -Thickness/2]) color("orange") tb_ntb_board(rows=Bottom_Length, cols=1, roundedCorners = true, center=false, thickness=Thickness, cornerRadius=2);
        translate([0, Bottom_Length_MM/2, Top_Length_MM/2-Thickness/2]) rotate([90,0,0]) color("aqua") cuboid([Cell_Size, Top_Length_MM, Thickness], rounding=0, edges=["Z"]);
        translate([0, 1, Top_Length_MM/2]) rotate([Angle_Bracket_Angle, 0, 0]) color("green") cuboid([Cell_Size, Angle_Bracket_Length, Thickness], rounding=Thickness/3, edges=["Z","X"]);
        translate([0, Bottom_Length_MM/2+Lip_Length/2-Thickness/2, Top_Length_MM-Thickness/2]) rotate([0, 0, 0]) color("red") cuboid([Cell_Size, Lip_Length, Thickness], rounding=Thickness/3, edges=[TOP, BOTTOM]);
        if(Num_Upper_Holes > 0){
            translate([0, Num_Upper_Holes*Cell_Size/2+Bottom_Length_MM/2+Thickness/2-0.2, 0]) rotate([0, 0, 0]) 
                color("blue") tb_ntb_board(rows=Num_Upper_Holes, cols=1, roundedCorners = true, center=true, thickness=Thickness);
        }
    }
}