include <lib/tb_screws.scad>;

Head_Height = 8; // [1:1:20]
Thread_Height = 8; // thread heightHead_Height

/* Label Plate Parameters */
Label_Plate_Thickness = 2; // [0.5:0.5:6]
Label_Plate_Width = 40 ; // [10:1:100]
Label_Plate_Height = 30; // [10:1:100]

/* Testing Parameters */
Cutout = true;



/* [Hidden] */
headWidth = 23; // head width
screwThreadDiameter = 8;
minimalHeadHeight = 0.8; // height of minimal head
minimalHeadWidth = 22; // width of minimal head

hexHeadChamferMargin = 6; // chamfer margin for hex head
flatHeadChamferMargin = 8; // chamfer margin for flat head
threadedHead8ChamferMargin = 6; // chamfer margin for threaded head
threadedHead12ChamferMargin = 10; // chamfer margin for threaded head

Include_Mounting_Hole = false; // [true, false]
Mounting_Hole_Radius = 2; // [0:.25:8]
Mounting_Hole_Type = "chamfered"; // [chamfered, phillips, hex]
For_Horizontal_Printing = false; // [true,false]
Head_Type = "Flat"; // [None, Minimal, Flat, Hex, Threaded]


// translate([30,0,0]){
//     color("red") cube([Label_Plate_Width, Label_Plate_Height, Label_Plate_Thickness+Head_Height+Thread_Height], center=true);
//     // color("red") cube([50, 100, 0], center=true);
// }
difference(){
  union(){
    difference(){
      union(){
        drawScrew();
        drawLabelPlate();
      }
      swivelPart();
    }
    swivelPart(hole=false);
  }
  if(Cutout){
    translate([Label_Plate_Width/2,0,(Label_Plate_Thickness+Head_Height+Thread_Height)/2]){
      color("red") cube([Label_Plate_Width, Label_Plate_Height, Label_Plate_Thickness+Head_Height+Thread_Height], center=true);
    }
  }
  // translate([Label_Plate_Width/2,0,(Label_Plate_Thickness+Head_Height+Thread_Height)/2]){
  //   color("red") cube([Label_Plate_Width, Label_Plate_Height, Label_Plate_Thickness+Head_Height+Thread_Height], center=true);
  // }
}




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

module swivelPart(hole=true){
  holeTolerance = 0.5;
  sTopRadius = hole ? screwThreadDiameter : screwThreadDiameter - holeTolerance;
  // sBottomRadius = hole ? headWidth/2-2 : (headWidth/2-2) - holeTolerance*2;
  sBottomRadius = headWidth/2 - 2;

  bottomRightX = hole ? sBottomRadius : sBottomRadius - holeTolerance;
  middleRightX = hole ? screwThreadDiameter : (screwThreadDiameter/2+1) - holeTolerance;
  middleRightY = (Head_Height+Label_Plate_Thickness)*4/11;
  topY = Head_Height+Label_Plate_Thickness+Thread_Height;
  echo(str("bottomRightX: ", bottomRightX));
  echo(str("middleRightX: ", middleRightX));
  echo(str("middleRightY: ", middleRightY));
  echo(str("topY: ", topY));

  pointArray = [
    [0,0],
    [bottomRightX, 0],
    [middleRightX, middleRightY],
    [middleRightX, topY],
    [0, topY],
    [0,0]
  ];
  echo(str("pointArray: ", pointArray));
  translate([0,0,Label_Plate_Thickness]){
    color("green") rotate_extrude(angle=360, convexity=10, $fn=100){
      polygon(points=pointArray);
      // polygon(points=[[0,0],[0,40], [middleRightX, middleRightY], [middleRightX, topY], [0, topY],[0,0]]);
    }
  }
}

module swivelPartOld(hole=true){
  holeTolerance = 0.5;
  sTopRadius = hole ? screwThreadDiameter : screwThreadDiameter - holeTolerance;
  sBottomRadius = hole ? headWidth/2 : headWidth/2 - holeTolerance*2;

  translate([0,0,Label_Plate_Thickness]){
    rotate_extrude(angle=360, convexity=10, $fn=100)
      polygon(points=[[0,0],[0,Head_Height-Label_Plate_Thickness],[sTopRadius,Head_Height-Label_Plate_Thickness],[0,0]]);
  }
  translate([0,0,Label_Plate_Thickness]){
    rotate_extrude(angle=360, convexity=10, $fn=100)
      polygon(points=[[0,0],[sBottomRadius,0],[0,Head_Height-Label_Plate_Thickness],[0,0]]);
  }
}

module drawLabelPlate(){
  translate([0,0,Label_Plate_Thickness/2])
    cuboid([Label_Plate_Width, Label_Plate_Height, Label_Plate_Thickness], rounding=2, edges="Z");
}