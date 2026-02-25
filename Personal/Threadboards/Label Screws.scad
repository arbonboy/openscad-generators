include <lib/tb_screws.scad>;

Thread_Height = 8; // thread heightHead_Height

/* [Label Plate Parameters] */
Label_Plate_Thickness = 2; // [0.5:0.5:6]
Label_Plate_Width = 40 ; // [10:1:100]
Label_Plate_Height = 30; // [10:1:100]

/* [Swivel Options] */
Create_Swivel_Style = false; // [true, false]
Swivel_Tolerance = 0.8; // [0.2:0.1:1.5]
Head_Height = 12; // [1:1:20]




/* [Testing Parameters] */
Cutout = true;



/* [Hidden] */
// headWidth = 23; // head width
headWidth = Label_Plate_Height > Label_Plate_Width ? Label_Plate_Width+2 : Label_Plate_Height+2; // head width
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


difference(){
  if(Create_Swivel_Style){
    difference(){
      union(){
        difference(){
          union(){
            translate([0,0,Label_Plate_Thickness+0.2]) drawScrew();
            drawLabelPlate();
          }
          swivelPart();
        }
        swivelPart(hole=false);
      }
      chamferThreadBottom();
    }
  } else {
    union(){
      drawScrew(headHeight = 0);
      drawLabelPlate();
    }
  }

  if(Cutout){
    translate([Label_Plate_Width/2,0,(Label_Plate_Thickness+Head_Height+Thread_Height)/2]){
      color("red") cube([Label_Plate_Width, Label_Plate_Height, Label_Plate_Thickness+Head_Height+Thread_Height+5], center=true);
    }
  }
}






module drawScrew(headHeight=Head_Height){
  rotationDeg = For_Horizontal_Printing ? 90 : 0;
  zTranslate = For_Horizontal_Printing ? headWidth/4 : 0;
  translate([0,0,zTranslate])
    rotate([0,rotationDeg,0])
      difference(){
        screw(rodHeight=Thread_Height, headHeight=headHeight, headRadius=headWidth/2, mountingHole=Include_Mounting_Hole, mountingHoleType=Mounting_Hole_Type, mountingHoleRadius=Mounting_Hole_Radius, center=false, tolerance=0.6);
      
        // if(For_Horizontal_Printing && Head_Type != "None"){
        //   // Create a cube to cut off the bottom half of the screw head
        //   translate([-headWidth/2, 0, headHeight/2])
        //     rotate([90, 0, 0])
        //       cube([headWidth/2, headWidth*2, (headHeight+Thread_Height)*2], center=true);
        //   translate([headWidth/2, 0, headHeight/2])
        //     rotate([90, 0, 0])
        //       cube([headWidth/2, headWidth*2, (headHeight+Thread_Height)*2], center=true);
        // }
        
      }
}

module swivelPart(hole=true){
  holeTolerance = Swivel_Tolerance;
  sTopRadius = hole ? screwThreadDiameter : screwThreadDiameter - holeTolerance;
  // sBottomRadius = hole ? headWidth/2-2 : (headWidth/2-2) - holeTolerance*2;
  sBottomRadius = headWidth/2 - 2;

  bottomRightX = hole ? sBottomRadius : sBottomRadius - holeTolerance;
  middleRightX = hole ? screwThreadDiameter/2 : (screwThreadDiameter/2+1) - holeTolerance;
  middleRightY = (Head_Height+Label_Plate_Thickness)*4/11;
  topY = Head_Height+Thread_Height+Label_Plate_Thickness/2-2;

  screwRadius = screwThreadDiameter;
  l0x = hole ? headWidth*3/9 : headWidth*3/9 - holeTolerance;
  l0y = 0;
  l1x = l0x;
  l1y = Head_Height*2/7;
  l2x = hole ? screwRadius*2/3 : screwRadius*2/3 - holeTolerance;
  l2y = Head_Height;
  l3x = hole ? screwRadius*1/3 : screwRadius*1/3 - holeTolerance;
  l3y = topY*3/5;
  l4x = l3x;
  l4y = topY*4/5;
  l5x = l3x;
  l5y = topY*5/5;
  l6x = hole ? screwRadius*2/3 : screwRadius*2/3 - holeTolerance;
  l6y = l5y+2;

  pointArray = [
    [0,0],
    [l0x, l0y],
    [l1x, l1y],
    [l2x, l2y],
    [l3x, l3y],
    [l4x, l4y],
    [l5x, l5y],
    [l6x, l6y],
    [0, l6y],
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

module chamferThreadBottom(){
  chamferHeight = 2;
  chamferRadiusTop = headWidth;
  chamferRadiusBottom = chamferRadiusTop + chamferHeight;
  screwRadius = screwThreadDiameter;

  pointArray = [
    [headWidth*3/9,0],
    [headWidth*6/9,0],
    [headWidth*6/9, Head_Height],
    [headWidth*3/9,0]
  ];
  translate([0,0,Label_Plate_Thickness]){
    rotate_extrude(angle=360, convexity=10, $fn=100)
      polygon(points=pointArray);
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