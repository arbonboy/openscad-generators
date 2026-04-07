include <../ThreadBoards/lib/tb_screws.scad>;

module mnt_wireClipTypeN(mountingWallThickness = 2, mountWidth = 25, mountingWallHeight = 27, clipArmWidth = 5, clipOpeningWidth = 5, clipArmThickness = 5) {
  actualClipArmWidth = mountWidth - 2 * clipArmWidth - 2 * clipOpeningWidth > 0 ? clipArmWidth : (mountWidth - clipOpeningWidth) / 2;
  clipArmLength = clipArmThickness * 4;

  _mnt_backWallSimple(mountingWallThickness, mountWidth, mountingWallHeight);
  translate([0, -mountingWallThickness / 2, -mountingWallHeight / 2 + clipArmLength / 2]) {
    _mnt_wireClipArmN(clipArmWidth=actualClipArmWidth, clipOpeningWidth=clipOpeningWidth, clipArmThickness=clipArmThickness, clipArmLength=clipArmLength, openingOrientation="up");
    _mnt_wireClipArmN(clipArmWidth=actualClipArmWidth, clipOpeningWidth=clipOpeningWidth, clipArmThickness=clipArmThickness, clipArmLength=clipArmLength, openingOrientation="down");
  }
}

module mnt_wireClipTypeW(mountingWallThickness = 2, mountWidth = 25, mountingWallHeight = 27, width = 25, depth = 17, height = -1) {
  wBraceWidth = width;
  height = height == -1 ? mountingWallHeight : height;
  pointArrayEnd = [
    [0, 0],
    [depth, 0],
    [depth, height],
    [depth - 5, height],
    [depth - 5, height * 2 / 3],
    [depth - 5, height * 1 / 3],
    [5, height * 1 / 3],
    [5, height],
    [0, height],
    [0, 0],
  ];
  pointArrayMid = [
    [5, 0],
    [depth, 0],
    [depth, height],
    [depth - 10, height],
    [depth - 10, height * 2 / 3 + height * 2 / 6],
    [depth - 5, height * 2 / 3],
    [depth - 5, height * 1 / 3],
    [5, height * 1 / 3],
    [5, 0],
  ];

  _mnt_backWallSimple(mountingWallThickness, mountWidth, mountingWallHeight);

  translate([0, 0, -(mountingWallHeight-height)/2]) {
    rotate([90, 180, 0]) {
      union() {
        // cube([width+Base_Thickness, height, wallThickness], center=true);
        translate([-wBraceWidth / 3, height / 2, mountingWallThickness / 2]) rotate([0, -90, 180]) {
            linear_extrude(height=wBraceWidth / 3, center=true) {
              polygon(points=pointArrayEnd);
            }
          }

        translate([0, height / 2, mountingWallThickness / 2]) rotate([0, -90, 180]) {
            difference() {
              linear_extrude(height=wBraceWidth / 3, center=true) {
                polygon(points=pointArrayMid);
              }
              translate([depth * 2 / 3 * 6 / 10, 10, wBraceWidth / 3 * 5 / 8]) rotate([-90, -0, 0]) {
                  cylinder(r=4, h=height);
                }
              translate([depth * 2 / 3 * 6 / 10, 10, -wBraceWidth / 3 * 5 / 8]) rotate([-90, -0, 0]) {
                  cylinder(r=4, h=height);
                }
            }
          }
        translate([wBraceWidth / 3, height / 2, mountingWallThickness / 2]) rotate([0, -90, 180]) {
            linear_extrude(height=wBraceWidth / 3, center=true) {
              polygon(points=pointArrayEnd);
            }
          }
      }
    }
  }
}


module mnt_slideLockSlot(mountingWallThickness = 2, mountWidth = 25, mountingWallHeight = 27, slotWidthLarge = 20, slotWidthSmall = 15, slotDepth = 4, slotHeight = -1) {
    slotHeight = slotHeight == -1 ? mountingWallHeight : slotHeight;
    assert(slotWidthLarge > slotWidthSmall, "slotWidthLarge must be greater than slotWidthSmall");  
    assert(slotDepth > 1, "slotDepth must be greater than 1");
    assert(slotHeight > 1, "slotHeight must be greater than 1");
    assert(mountWidth > slotWidthSmall, "mountWidth must be greater than slotWidthSmall");
    

    _mnt_backWallSimple(mountingWallThickness, mountWidth, mountingWallHeight);
    
    pointArrayWorkingOriginal = [
        [slotDepth / tan(45), 0],
        [0, slotDepth],
        [slotWidthLarge, slotDepth],
        [slotWidthLarge - slotDepth / tan(45), 0],
        [0, 0],
    ];

    pointArrayMultiConnectCompatible = [
        [(slotWidthLarge - slotWidthSmall) / 2, 0],
        [1, slotDepth - 1],
        [1, slotDepth],
        [slotWidthLarge - 0.5, slotDepth],
        [slotWidthLarge - 0.5, slotDepth - 1],
        [(slotWidthLarge - slotWidthSmall) / 2 + slotWidthSmall, 0],
        [0, 0],
    ];

    translate([-slotWidthLarge / 2, -mountingWallThickness/2, -(mountingWallHeight - slotHeight) / 2]) {
        rotate([180, 0, 0]) {
            linear_extrude(height=slotHeight, center=true) {
                polygon(points=pointArrayMultiConnectCompatible);
            }
        }
    }

}

module mnt_postClipDELME(mountingWallThickness = 2, mountWidth = 25, mountingWallHeight = 27, generateFastener = true, generateSideClip = true, width = -1, height = -1, clipWallThickness=2, connectorTolerance = 0.1) {
    height = height == -1 ? mountingWallHeight : height;
    width = width == -1 ? mountWidth : width;

    assert(mountWidth > 0, "mountWidth must be greater than 0");
    assert(mountWidth >= width, "mountWidth must be greater than or equal to width");
    assert(width > 0, "width must be greater than 0");
    assert(mountingWallHeight > 0, "mountingWallHeight must be greater than 0");
    assert(height > 0, "height must be greater than 0");
    assert(clipWallThickness > 0, "clipWallThickness must be greater than 0");
    

    baseThickness = clipWallThickness;
    wallThickness = clipWallThickness;

    _mnt_backWallSimple(mountingWallThickness, mountWidth, mountingWallHeight);

    clipPortionOfWidth = 3 / 16;
    clipLipLength = (width + baseThickness) * clipPortionOfWidth;
    clipLipThickness = wallThickness;
    clipConnectorInnerLength = (clipLipLength / 2);
    clipLipInnerHeight = wallThickness * 2;
    clipBaseThickness = 2;

    coordsLeftStartX = 0 - wallThickness / 2 + clipLipThickness/2;
    coordsRightStartX = width + wallThickness / 2 - clipLipThickness/2;

    fastenerCoordsLeftStartX = 0 - wallThickness / 2 - clipLipThickness/2;
    fastenerCoordsRightStartX = width + wallThickness / 2 + clipLipThickness/2;

    coordsLeft = [
        [coordsLeftStartX, 0],
        [coordsLeftStartX + clipLipLength, 0],
        [coordsLeftStartX + clipLipLength, clipLipInnerHeight + clipLipThickness * 2],
        [coordsLeftStartX + clipLipLength - clipConnectorInnerLength - clipLipThickness, clipLipInnerHeight + clipLipThickness * 2],
        [coordsLeftStartX + clipLipLength - clipConnectorInnerLength - clipLipThickness, clipLipInnerHeight + clipLipThickness],
        [coordsLeftStartX + clipLipLength - clipLipThickness, clipLipInnerHeight + clipLipThickness],
        [coordsLeftStartX + clipLipLength - clipLipThickness, clipLipThickness],
        [coordsLeftStartX, clipLipThickness],
        [coordsLeftStartX, 0],
    ];

    coordsRight = [
        [coordsRightStartX, 0],
        [coordsRightStartX - clipLipLength, 0],
        [coordsRightStartX - clipLipLength, clipLipInnerHeight + clipLipThickness * 2],
        [coordsRightStartX - clipLipLength + clipConnectorInnerLength + clipLipThickness, clipLipInnerHeight + clipLipThickness * 2],
        [coordsRightStartX - clipLipLength + clipConnectorInnerLength + clipLipThickness, clipLipInnerHeight + clipLipThickness],
        [coordsRightStartX - clipLipLength + clipLipThickness, clipLipInnerHeight + clipLipThickness],
        [coordsRightStartX - clipLipLength + clipLipThickness, clipLipThickness],
        [coordsRightStartX, clipLipThickness],
        [coordsRightStartX, 0],
    ];

    
    coordsFastener = [
        [fastenerCoordsLeftStartX, clipLipThickness + connectorTolerance], //pt1
        [fastenerCoordsLeftStartX + clipLipLength - clipLipThickness + clipLipThickness - connectorTolerance, clipLipThickness + connectorTolerance], //pt2
        [fastenerCoordsLeftStartX + clipLipLength - clipLipThickness + clipLipThickness - connectorTolerance, clipLipThickness + clipLipInnerHeight - connectorTolerance], //pt3
        [fastenerCoordsLeftStartX + clipLipLength - clipLipThickness + clipLipThickness - connectorTolerance - clipConnectorInnerLength, clipLipThickness + clipLipInnerHeight - connectorTolerance], //pt4
        [fastenerCoordsLeftStartX + clipLipLength - clipLipThickness + clipLipThickness - connectorTolerance - clipConnectorInnerLength, clipLipThickness + clipLipInnerHeight + clipLipThickness + connectorTolerance], //pt5
        [fastenerCoordsRightStartX - clipLipLength + clipConnectorInnerLength + clipLipThickness - clipLipThickness + connectorTolerance, clipLipThickness + clipLipInnerHeight + clipLipThickness + connectorTolerance], //pt6
        [fastenerCoordsRightStartX - clipLipLength + clipConnectorInnerLength + clipLipThickness - clipLipThickness + connectorTolerance, clipLipThickness + clipLipInnerHeight - connectorTolerance], //pt7
        [fastenerCoordsRightStartX - clipLipLength + clipLipThickness - clipLipThickness + connectorTolerance, clipLipThickness + clipLipInnerHeight - connectorTolerance], //pt8
        [fastenerCoordsRightStartX - clipLipLength + clipLipThickness - clipLipThickness + connectorTolerance, clipLipThickness + connectorTolerance], //pt9
        // [fastenerCoordsRightStartX - clipLipLength + clipLipThickness + clipConnectorInnerLength + connectorTolerance, clipLipThickness+clipLipInnerHeight-connectorTolerance],
        [fastenerCoordsRightStartX, clipLipThickness + connectorTolerance], //pt10
        [fastenerCoordsRightStartX, clipLipThickness + clipLipInnerHeight + clipLipThickness + clipLipThickness + clipLipThickness], //pt11
        // [fastenerCoordsRightStartX, clipLipThickness+clipLipInnerHeight+clipLipThickness+clipLipThickness],
        [fastenerCoordsLeftStartX, clipLipThickness + clipLipInnerHeight + clipLipThickness + clipLipThickness + clipLipThickness], //pt12
        [fastenerCoordsLeftStartX, clipLipThickness + connectorTolerance], //pt13
    ];

    translate([width/2, -mountingWallThickness/2, -(mountingWallHeight - height) / 2]) {
        rotate([0, 0, 180]) {
            if (generateSideClip) {
            linear_extrude(height=height, center=true) {
                polygon(points=coordsLeft);
            }
            translate([0, 0, -height / 2 + wallThickness / 2]) {
                linear_extrude(height=clipBaseThickness, center=true) {
                    polygon(
                        points=[
                        [coordsLeftStartX, 0],
                        [coordsLeftStartX + clipLipLength, 0],
                        [coordsLeftStartX + clipLipLength, clipLipInnerHeight + clipLipThickness * 2],
                        [coordsLeftStartX, clipLipInnerHeight + clipLipThickness * 2],
                        [coordsLeftStartX, 0],
                        ]
                    );
                }
            }

            linear_extrude(height=height, center=true) {
                polygon(points=coordsRight);
            }
            translate([0, 0, -height / 2 + wallThickness / 2]) {
                linear_extrude(height=clipBaseThickness, center=true) {
                polygon(
                    points=[
                    [coordsRightStartX, 0],
                    [coordsRightStartX - clipLipLength, 0],
                    [coordsRightStartX - clipLipLength, clipLipInnerHeight + clipLipThickness * 2],
                    [coordsRightStartX, clipLipInnerHeight + clipLipThickness * 2],
                    [coordsRightStartX, 0],
                    ]
                );
                }
            }
            }
            if (generateFastener) {
                translate([0, width, -(wallThickness / 2 + connectorTolerance)]) {
                    color("yellow"){
                        difference() {
                            linear_extrude(height=height - clipBaseThickness, center=true) {
                                polygon(points=coordsFastener);
                            }
                            translate([width / 2, width/2-wallThickness/2, 0]) {
                                rotate([90, 90, 0]) {
                                    threadedRodForHole(length=wallThickness*5, center=true, tolerance=0.2, hole_radius=TB_SCREW_Threaded_Rod_Diameter / 2);
                                }
                            }
                        }
                    }
                }
            }
        }
    }

}

module mnt_slideLockFastenerMount(mountWidth=25, mountingWallWidthPerArm=6, mountingWallThickness=2, fastenerMountHeight=20, channelWidth=2, channelDepth=2, channelStopperWallThickness=2, outerWallThickness=2) {
    assert(mountWidth > 2*mountingWallWidthPerArm, "mountWidth needs to be wider than the sum of the two mounting arm widths");
    translate([-mountWidth/2+mountingWallWidthPerArm/2-channelDepth, 0, 0]) {
        _mnt_slideLockFastenerMountArm(mountingWallWidth=mountingWallWidthPerArm, mountingWallThickness=mountingWallThickness, fastenerMountHeight=fastenerMountHeight, channelWidth=channelWidth, channelDepth=channelDepth, channelStopperWallThickness=channelStopperWallThickness, outerWallThickness=outerWallThickness, side="left");
    }
    translate([mountWidth/2-mountingWallWidthPerArm/2+channelDepth, 0, 0]) {
        _mnt_slideLockFastenerMountArm(mountingWallWidth=mountingWallWidthPerArm, mountingWallThickness=mountingWallThickness, fastenerMountHeight=fastenerMountHeight, channelWidth=channelWidth, channelDepth=channelDepth, channelStopperWallThickness=channelStopperWallThickness, outerWallThickness=outerWallThickness, side="right");
    }
}
module mnt_slideLockFastenerClip(mountWidth=25, mountingWallWidthPerArm=6, mountingWallThickness=2, fastenerMountHeight=20, channelWidth=2, channelDepth=2, channelStopperWallThickness=2, outerWallThickness=2, distanceFromFastener=20,connectorClipTolerance=0.15, includeThreadBoardHole=true) {
    assert(mountWidth > 2*mountingWallWidthPerArm, "mountWidth needs to be wider than the sum of the two mounting arm widths");
    clipDepthForMountOuterWall = outerWallThickness + connectorClipTolerance;
    clipDepthForMountChannel = channelWidth-connectorClipTolerance*2;
    fullClipDepth = clipDepthForMountOuterWall + clipDepthForMountChannel + outerWallThickness;
    channelWallThickness = mountingWallWidthPerArm - channelDepth;
    clipArmInnerLength = channelDepth-connectorClipTolerance;
    clipArmOuterLength = clipArmInnerLength + channelWallThickness;
    clipOpeningWidth = mountWidth + connectorClipTolerance*2;
    fullClipWidth = clipOpeningWidth+clipArmOuterLength*2;
    clipCenterOpeningWidth = fullClipWidth-channelWallThickness*2+connectorClipTolerance*2;
    fullClipHeight = fastenerMountHeight - channelStopperWallThickness;
    
    echo(str("channelWidth: ", channelWidth, " clipDepthForMountChannel: ", clipDepthForMountChannel, " clipDepthForMountOuterWall: ", clipDepthForMountOuterWall, " fullClipDepth: ", fullClipDepth, " channelWallThickness: ", channelWallThickness, " clipArmInnerLength: ", clipArmInnerLength, " clipArmOuterLength: ", clipArmOuterLength, " clipOpeningWidth: ", clipOpeningWidth, " fullClipWidth: ", fullClipWidth, " clipCenterOpeningWidth: ", clipCenterOpeningWidth));
    translate([0, -distanceFromFastener, -channelStopperWallThickness/2]) {
      difference(){
          cube([fullClipWidth, fullClipDepth, fullClipHeight], center=true);
          translate([0, -fullClipDepth/2+clipDepthForMountOuterWall/2+outerWallThickness, 0]){
            cube([clipCenterOpeningWidth, clipDepthForMountOuterWall, fullClipHeight+0.1], center=true);
          }
          translate([0, fullClipDepth/2-clipDepthForMountChannel/2 , 0]) {
              cube([clipOpeningWidth, clipDepthForMountChannel, fullClipHeight+0.1], center=true);
          }
          if(includeThreadBoardHole){
            translate([0, -fullClipDepth/2, 0]) {
                rotate([90, 90, 0]) {
                    threadedRodForHole(length=outerWallThickness+channelWidth+channelStopperWallThickness+connectorClipTolerance*2, center=true, tolerance=0.2, hole_radius=TB_SCREW_Threaded_Rod_Diameter / 2);
                }
            }
          }
      }
    }
    
}
module mnt_slideLockFastener(mountWidth=20, mountingWallWidthPerArm=4, mountingWallThickness=2, mountingWallHeight = 27, fastenerMountHeight=20, channelWidth=2, channelDepth=2, channelStopperWallThickness=2, outerWallThickness=2, generateFastener = true, generateFastenerClip = true, generateHole = false, connectorClipTolerance = 0.15, wallOffset = 0, connectorClipThreadboardHole=true) {
    assert(mountingWallWidthPerArm > channelDepth, "mountingWallWidthPerArm needs to be larger than channelDepth for the fastener to fit");
    standardWallOffset = (channelWidth+outerWallThickness)/2;
    wallOffset = wallOffset == 0 ? standardWallOffset : standardWallOffset + wallOffset;
    fastenerMountHeight = fastenerMountHeight == 0 ? mountingWallHeight : fastenerMountHeight;
    translate([0, -wallOffset, -(mountingWallHeight - fastenerMountHeight) / 2]) {
      if(generateFastener){
        mnt_slideLockFastenerMount(mountWidth=mountWidth, mountingWallWidthPerArm=mountingWallWidthPerArm, mountingWallThickness=mountingWallThickness, fastenerMountHeight=fastenerMountHeight, channelWidth=channelWidth, channelDepth=channelDepth, channelStopperWallThickness=channelStopperWallThickness, outerWallThickness=outerWallThickness);
      }
      if(generateHole){
        cube([mountWidth, mountingWallThickness+channelWidth+channelStopperWallThickness, fastenerMountHeight], center=true);
      }
      if(generateFastenerClip){
        mnt_slideLockFastenerClip(mountWidth=mountWidth, mountingWallWidthPerArm=mountingWallWidthPerArm, mountingWallThickness=mountingWallThickness, fastenerMountHeight=fastenerMountHeight, channelWidth=channelWidth, channelDepth=channelDepth, channelStopperWallThickness=channelStopperWallThickness, outerWallThickness=outerWallThickness, distanceFromFastener=mountingWallThickness+channelWidth+outerWallThickness+2, connectorClipTolerance=connectorClipTolerance, includeThreadBoardHole=connectorClipThreadboardHole);
      }
    }
}

module mnt_screwFastener(mountWidth=20, mountingWallThickness=2, fastenerWallThickness=2, fastenerMountHeight=20, fastenerArmLength = 20, screwHoleDiameter = 10, screwHoleDepth = 1, screwHeadDiameter = 10, screwHeadDepth = 2, generateFastener = true, generateHole = false) {
    fullFastenerLength = mountingWallThickness + fastenerArmLength;
    fullScrewHoleLength = screwHoleDepth + screwHeadDepth;
    translate([0, -fullFastenerLength/2, 0]) {
        if (generateFastener) {
          difference() {
            union() {
              translate([mountWidth / 2 + fastenerWallThickness / 2, (fullFastenerLength) / 2, 0]) {
                cube([fastenerWallThickness, fullFastenerLength, fastenerMountHeight], center=true);
              }
            }
            translate([mountWidth / 2 - screwHeadDepth / 2 + fastenerWallThickness, fastenerArmLength / 2, 0]) {
              rotate([90, 0, -90]) {
                cylinder(d=screwHeadDiameter, h=screwHeadDepth, center=true);
                translate([0, 0, screwHeadDepth / 2 + screwHoleDepth / 2]) {
                  cylinder(d=screwHoleDiameter, h=screwHoleDepth, center=true);
                }
              }
            }
          }

          difference() {
            translate([-(mountWidth / 2 + fastenerWallThickness / 2), (fullFastenerLength) / 2, 0]) {
              cube([fastenerWallThickness, fullFastenerLength, fastenerMountHeight], center=true);
            }
            translate([-mountWidth / 2 - fastenerWallThickness + screwHeadDepth / 2, fastenerArmLength / 2, 0]) {
              rotate([-90, 0, -90]) {
                cylinder(d=screwHeadDiameter, h=screwHeadDepth, center=true);
                translate([0, 0, screwHeadDepth / 2 + screwHoleDepth / 2]) {
                  cylinder(d=screwHoleDiameter, h=screwHoleDepth, center=true);
                }
              }
            }
          }
        }
        
    }
    if(generateHole){
      cube([mountWidth, fullFastenerLength, fastenerMountHeight], center=true);
    }
    
}

module mnt_TBScrewFastener(mountWidth=20, mountingWallThickness=2, fastenerWallThickness=2, fastenerMountHeight=20, fastenerArmLength = 20,  generateFastener = true, generateHole = false) {
  
  fullFastenerLength = mountingWallThickness + fastenerArmLength;

  if (generateFastener) {
    difference(){
      cube([mountWidth, fullFastenerLength, fastenerMountHeight], center=true);
      translate([0, -mountingWallThickness/2, 0]) {
        rotate([0, 90, 0]) {
          threadedRodForHole(length=mountWidth, center=true, tolerance=0.2, hole_radius=TB_SCREW_Threaded_Rod_Diameter / 2);
        }
      }
      cube([mountWidth-fastenerWallThickness*2, fullFastenerLength, fastenerMountHeight], center=true); 
    }
  }

  if (generateHole) {
    cube([mountWidth-fastenerWallThickness*2, fullFastenerLength, fastenerMountHeight], center=true); 
  }
}

module mnt_tBScrewHole(mountWidth=20, mountingWallThickness=2, mountingWallHeight=20, holeBlockWidth=-1, holeBlockHeight=-1, holeBlockThickness=0, generateComponent = true, generateHole = false) {
  holeBlockWidth = holeBlockWidth == -1 ? mountWidth : holeBlockWidth;
  holeBlockHeight = holeBlockHeight == -1 ? mountingWallHeight : holeBlockHeight;
  fullDepth = mountingWallThickness + holeBlockThickness;


  if (generateComponent) {
    difference(){
      union(){
        translate([0, 0, 0]) {
          cube([mountWidth, mountingWallThickness, mountingWallHeight], center=true);
        }
        translate([0, -fullDepth/2-mountingWallThickness/2, -(mountingWallHeight - holeBlockHeight)/2]) {
          cube([holeBlockWidth, fullDepth, holeBlockHeight], center=true);
        }
      }
      translate([0, -fullDepth/2, -(mountingWallHeight - holeBlockHeight)/2]) {
        rotate([90, 90, 0]) {
          threadedRodForHole(length=fullDepth+2, center=true, tolerance=0.2, hole_radius=TB_SCREW_Threaded_Rod_Diameter / 2);
        }
      }
      
    }
  }

  if (generateHole) {
    translate([0, 0, -(mountingWallHeight - holeBlockHeight)/2]) {
      cube([holeBlockWidth, fullDepth, holeBlockHeight], center=true);
    }
  }
}



module mnt_rectHolder(mountWidth=20, mountingWallThickness=2, mountingWallHeight=20, holderWidth = 50, holderHeight = 20, holderWallThickness = 3, holderDepth = 20, bottomFloor=false) {
  fullRectHolderLength = mountingWallThickness + holderDepth;
  translate([0, 0, 0]) {
    //Mount
    cube([mountWidth, mountingWallThickness, mountingWallHeight], center=true);

    //Holder
    holeHeight = bottomFloor ? holderWallThickness : 0;
    translate([0, -fullRectHolderLength / 2, -(mountingWallHeight - holderHeight) / 2]) {
      difference() {
        cube([holderWidth, holderDepth, holderHeight], center=true);
        translate([0, 0, holeHeight]) {
          cube([holderWidth - 2 * holderWallThickness, holderDepth - 2 * holderWallThickness, holderHeight], center=true);
        }
      }
    }
  }
}

module mnt_circularHolder(mountWidth = 40, mountingWallHeight=20, mountingWallThickness = 8, holderDiameter = 80, holderHeight = 40, holderWallThickness = 4, bottomFloor=false) {
  fullCircularHolderLength = mountingWallThickness + holderDiameter;
  translate([0, 0, 0]) {
    //Mount
    cube([mountWidth, mountingWallThickness, mountingWallHeight], center=true);
    //Holder
    holeHeight = bottomFloor ? holderWallThickness : 0;
    translate([0, -fullCircularHolderLength / 2 + 1, -(mountingWallHeight - holderHeight) / 2]) {
      difference() {
        cylinder(d=holderDiameter, h=holderHeight, center=true);
        translate([0, 0, holeHeight]) {
          cylinder(d=holderDiameter - 2 * holderWallThickness, h=holderHeight, center=true);
        }
      }
    }
  }
}

module mnt_simpleHook(mountingWallThickness = 2, mountWidth = 25, mountingWallHeight = 27, clipArmWidth = 2, clipOpeningWidth=7, clipArmThickness = 2) {
  // actualClipArmWidth = mountWidth - 2 * clipArmWidth - 2 * clipOpeningWidth > 0 ? clipArmWidth : (mountWidth - clipOpeningWidth) / 2;
  clipArmLength = clipArmThickness * 4;

  _mnt_backWallSimple(mountingWallThickness, mountWidth, mountingWallHeight);
  translate([0, -mountingWallThickness / 2, -mountingWallHeight / 2 + clipArmLength / 2]) {
    _mnt_wireClipArmN(clipArmWidth=clipArmWidth, clipOpeningWidth=clipOpeningWidth, clipArmThickness=clipArmThickness, clipArmLength=clipArmLength, openingOrientation="up", centerXPosition=true);
  }
}

module _mnt_backWallSimple(mountingWallThickness = 2, mountWidth = 20, mountingWallHeight = 30) {
  translate([0, 0, 0]) {
    cube([mountWidth, mountingWallThickness, mountingWallHeight], center=true);
  }
}

module _mnt_wireClipArmN(clipArmWidth = 7, clipArmLength = -1, clipOpeningWidth = 7, clipArmThickness = 5, openingOrientation = "up", centerXPosition=false) {
  clipArmLength = clipArmLength == -1 ? clipArmThickness * 4 : clipArmLength;
  rotation = openingOrientation == "down" ? [90, 0, -90] : [-90, 0, -90];
  translation = openingOrientation == "down" ? [centerXPosition ? 0 : 1 * (clipArmWidth + clipOpeningWidth) / 2, 0, -clipArmLength / 2] : [centerXPosition ? 0 : -1 * (clipArmWidth + clipOpeningWidth) / 2, 0, clipArmLength / 2];

  ptA = [0, clipArmLength - clipArmThickness * 2];
  ptB = [clipOpeningWidth / 2, clipArmLength - clipArmThickness];
  ptC = [clipOpeningWidth, clipArmLength - clipArmThickness * 2];
  ptD = [clipOpeningWidth, 0];
  ptE = [clipOpeningWidth + clipArmThickness, 0];
  ptF = [clipOpeningWidth + clipArmThickness, clipArmLength];
  ptG = [0, clipArmLength];

  pointArray = [
    ptA,
    ptB,
    ptC,
    ptD,
    ptE,
    ptF,
    ptG,
    ptA,
  ];
  translate(translation) {
    rotate(rotation) {
      linear_extrude(height=clipArmWidth, center=true) {
        polygon(points=pointArray);
      }
    }
  }
}

module _mnt_slideLockFastenerMountArm(mountingWallWidth=6, mountingWallThickness=2, fastenerMountHeight=20, channelWidth=2, channelDepth=2, channelStopperWallThickness=2, outerWallThickness=2,side="left"){
    fastenerFullDepth = mountingWallThickness + channelWidth + outerWallThickness;
    channelTranslationX = side == "left" ? -mountingWallWidth/2 + channelDepth/2 : mountingWallWidth/2 - channelDepth/2;
    echo(str("mountingWallThickness: ", mountingWallThickness, " channelWidth: ", channelWidth, " outerWallThickness: ", outerWallThickness, " fastenerFullDepth: ", fastenerFullDepth));
    difference(){
        cube([mountingWallWidth, fastenerFullDepth, fastenerMountHeight], center=true);
        translate([channelTranslationX, (fastenerFullDepth/2-channelWidth/2-mountingWallThickness), channelStopperWallThickness]) {
            cube([channelDepth, channelWidth, fastenerMountHeight], center=true);
        }
    }
}

