include <lib/tb_screws.scad>;

Head_Type = "Hex"; // [None, Minimal, Flat, Hex, Threaded]
Head_Height = 8; // [8, 12]
Thread_Height = 8; // thread heightHead_Height
// You can print the screw horizontally for stronger threads, but the head will be flat on the bottom
For_Horizontal_Printing = false; // [true,false]

/* [Mounting Hole Options] */
// Mounting Holes are NOT supported for Hex head screws
Include_Mounting_Hole = false; // [true, false]
Mounting_Hole_Radius = 2; // [0:.25:8]
Mounting_Hole_Type = "chamfered"; // [chamfered, phillips, hex]


/* [Hidden] */
headWidth = 23; // head width
screwThreadDiameter = 8;
minimalHeadHeight = 0.8; // height of minimal head
minimalHeadWidth = 22; // width of minimal head

hexHeadChamferMargin = 6; // chamfer margin for hex head
flatHeadChamferMargin = 8; // chamfer margin for flat head
threadedHead8ChamferMargin = 6; // chamfer margin for threaded head
threadedHead12ChamferMargin = 10; // chamfer margin for threaded head




drawScrew();

module drawScrew(){
  rotationDeg = For_Horizontal_Printing ? 90 : 0;
  zTranslate = For_Horizontal_Printing ? headWidth/4 : 0;
  headHeight = Head_Type == "None" ? 0 : (Head_Type == "Minimal" ? minimalHeadHeight : Head_Height);
  headStyle = Head_Type == "None" ? "solid" : (Head_Type == "Hex" ? "hex" : (Head_Type == "Threaded" ? "thread" : "solid"));
  translate([0,0,zTranslate])
    rotate([0,rotationDeg,0])
      difference(){
        screw(rodHeight=Thread_Height, headHeight=headHeight, headRadius=headWidth/2, headStyle=headStyle, mountingHole=Include_Mounting_Hole, mountingHoleType=Mounting_Hole_Type, mountingHoleRadius=Mounting_Hole_Radius, center=false, tolerance=0.6);
      
        if(For_Horizontal_Printing && Head_Type != "None"){
          // Create a cube to cut off the bottom half of the screw head
          translate([-headWidth/2, 0, Head_Height/2])
            rotate([90, 0, 0])
              cube([headWidth/2, headWidth*2, (Head_Height+Thread_Height)*2], center=true);
          translate([headWidth/2, 0, Head_Height/2])
            rotate([90, 0, 0])
              cube([headWidth/2, headWidth*2, (Head_Height+Thread_Height)*2], center=true);
        }
        
      }
      
}
