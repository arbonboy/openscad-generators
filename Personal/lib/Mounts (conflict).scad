module mnts_wireClipArmN(wallThickness=2, armWidth=7, openingWidth=7, armThickness=5){
    openWidth=openingWidth;
    thickness=armThickness;
    openWidthOuter=openWidth+thickness*5/10;
    lipHeight=7;
    totalInnerHeight=14;
    elbowHeight=lipHeight+thickness*5/10;
    topmostHeight=totalInnerHeight+thickness;

    pointArray = [
        [openWidth,0],
        [openWidthOuter,0],
        [openWidthOuter, elbowHeight],
        [0,topmostHeight],
        [0,totalInnerHeight],
        [openWidth,lipHeight],
        [openWidth,0]
    ];
    translate([0,-1*thickness*6/10,wallThickness/2]) rotate([0,-90,0]){
        linear_extrude(height=armWidth, center=true){
            polygon(points=pointArray);
        }
    }
    
}



module mnts_wireClipWType(wallThickness=2, channelWidth=15, width=25, depth=17, height=30){
    wBraceWidth = 25;
    pointArrayEnd = [
        [0,0],
        [depth,0],
        [depth, height],
        [depth-5, height],
        [depth-5, height*2/3],
        [depth-5, height*1/3],
        [5, height*1/3],
        [5,height],
        [0,height],
        [0,0]
    ];
    pointArrayMid = [
        [5, 0],
        [depth,0],
        [depth, height],
        [depth-10, height],
        [depth-10, height*2/3+height*2/6],
        [depth-5, height*2/3],
        [depth-5, height*1/3],
        [5, height*1/3],
        [5, 0],
    ];

    rotate([90,0,0]){
        union(){
            cube([width+Base_Thickness, height, wallThickness], center=true);
            translate([-wBraceWidth/3,height/2,wallThickness/2]) rotate([0,-90,180]){
                linear_extrude(height=wBraceWidth/3, center=true){
                    polygon(points=pointArrayEnd);
                }
            }
            
            translate([0,height/2,wallThickness/2]) rotate([0,-90,180]){
                difference(){
                    linear_extrude(height=wBraceWidth/3, center=true){
                        polygon(points=pointArrayMid);
                    }
                    translate([depth*2/3*6/10,10,wBraceWidth/3*5/8]) rotate([-90,-0,0]){
                        cylinder(r=4, h=height);
                    }
                    translate([depth*2/3*6/10,10,-wBraceWidth/3*5/8]) rotate([-90,-0,0]){
                        cylinder(r=4, h=height);
                    }
                }

            }
            translate([wBraceWidth/3,height/2,wallThickness/2]) rotate([0,-90,180]){
                linear_extrude(height=wBraceWidth/3, center=true){
                    polygon(points=pointArrayEnd);
                }
            }
        
        }
    }
}   



module mnts_slideLockSlot(wallThickness=2, width=20, height=20, slotWidthLarge=20, slotWidthSmall=15, slotDepth=4, slotHeight=27, baseThickness=2){
    pointArrayWorkingOriginal=[
        [slotDepth/tan(45),0],
        [0, slotDepth],
        [slotWidthLarge, slotDepth],
        [slotWidthLarge-slotDepth/tan(45),0],
        [0,0]
    ];

    pointArrayMultiConnectCompatible=[
        [(slotWidthLarge-slotWidthSmall)/2,0],
        [1, slotDepth-1],
        [1, slotDepth],
        [slotWidthLarge-0.5, slotDepth],
        [slotWidthLarge-0.5, slotDepth-1],
        [(slotWidthLarge-slotWidthSmall)/2+slotWidthSmall,0],
        [0,0]
    ];

    rotate([90,0,0]){
        cube([width+baseThickness, height, wallThickness], center=true);
        translate([-slotWidthLarge/2, 0, wallThickness/2]){
            rotate([90,0,0]){
                linear_extrude(height=slotHeight, center=true){
                    polygon(points=pointArrayMultiConnectCompatible);
                }
            }   
        }
    }

}




module mnts_postClip(wallThickness=2, generateFastener=true, generateSideClip=true, width=20, baseThickness=2, height=30){
    
    clipPortionOfWidth = 3/16;
    clipLipLength = (width+baseThickness)*clipPortionOfWidth;
    clipLipThickness = wallThickness;
    clipConnectorInnerLength = (clipLipLength/2);
    clipLipInnerHeight = wallThickness*2;
    clipBaseThickness = 2;

    connectorTolerance = 0.1;

    coordsLeftStartX = 0-wallThickness/2;
    coordsRightStartX = width+wallThickness/2;

    fastenerCoordsLeftStartX = 0-wallThickness/2-clipLipThickness;
    fastenerCoordsRightStartX = width+wallThickness/2+clipLipThickness;


    coordsLeft=[
        [coordsLeftStartX,0],
        [coordsLeftStartX+clipLipLength, 0],
        [coordsLeftStartX+clipLipLength, clipLipInnerHeight+clipLipThickness*2],
        [coordsLeftStartX+clipLipLength-clipConnectorInnerLength-clipLipThickness, clipLipInnerHeight+clipLipThickness*2],
        [coordsLeftStartX+clipLipLength-clipConnectorInnerLength-clipLipThickness, clipLipInnerHeight+clipLipThickness],
        [coordsLeftStartX+clipLipLength-clipLipThickness, clipLipInnerHeight+clipLipThickness],
        [coordsLeftStartX+clipLipLength-clipLipThickness, clipLipThickness],
        [coordsLeftStartX, clipLipThickness],
        [coordsLeftStartX, 0]
    ];
   

   coordsRight=[
        [coordsRightStartX, 0],
        [coordsRightStartX - clipLipLength, 0],
        [coordsRightStartX-clipLipLength, clipLipInnerHeight+clipLipThickness*2],
        [coordsRightStartX-clipLipLength+clipConnectorInnerLength+clipLipThickness, clipLipInnerHeight+clipLipThickness*2],
        [coordsRightStartX-clipLipLength+clipConnectorInnerLength+clipLipThickness, clipLipInnerHeight+clipLipThickness],
        [coordsRightStartX-clipLipLength+clipLipThickness, clipLipInnerHeight+clipLipThickness],
        [coordsRightStartX-clipLipLength+clipLipThickness, clipLipThickness],
        [coordsRightStartX, clipLipThickness],
        [coordsRightStartX, 0]
    ];

    coordsConnectordelme = [
        [coordsLeftStartX, clipLipThickness+connectorTolerance], //pt1
        [coordsLeftStartX + clipLipLength - clipLipThickness - connectorTolerance, clipLipThickness+connectorTolerance], //pt2
        [coordsLeftStartX + clipLipLength - clipLipThickness - connectorTolerance, clipLipThickness+clipLipInnerHeight-connectorTolerance], //pt3
        [coordsLeftStartX + clipLipLength - clipLipThickness - connectorTolerance - clipConnectorInnerLength, clipLipThickness+clipLipInnerHeight-connectorTolerance], //pt4
        [coordsLeftStartX + clipLipLength - clipLipThickness - connectorTolerance - clipConnectorInnerLength, clipLipThickness+clipLipInnerHeight+clipLipThickness+connectorTolerance], //pt5
        [coordsRightStartX - clipLipLength+clipConnectorInnerLength+clipLipThickness+connectorTolerance, clipLipThickness+clipLipInnerHeight+clipLipThickness+connectorTolerance], //pt6
        [coordsRightStartX - clipLipLength+clipConnectorInnerLength+clipLipThickness+connectorTolerance, clipLipThickness+clipLipInnerHeight-connectorTolerance], //pt7
        [coordsRightStartX - clipLipLength + clipLipThickness + connectorTolerance, clipLipThickness+clipLipInnerHeight-connectorTolerance], //pt8
        [coordsRightStartX - clipLipLength + clipLipThickness + connectorTolerance, clipLipThickness+connectorTolerance], //pt9
        // [coordsRightStartX - clipLipLength + clipLipThickness + clipConnectorInnerLength + connectorTolerance, clipLipThickness+clipLipInnerHeight-connectorTolerance],
        [coordsRightStartX, clipLipThickness+connectorTolerance], //pt10
        [coordsRightStartX, clipLipThickness+clipLipInnerHeight+clipLipThickness+clipLipThickness], //pt11
        // [coordsRightStartX, clipLipThickness+clipLipInnerHeight+clipLipThickness+clipLipThickness],
        [coordsLeftStartX, clipLipThickness+clipLipInnerHeight+clipLipThickness+clipLipThickness], //pt12

        [coordsLeftStartX, clipLipThickness+connectorTolerance], //pt13
    ];

    coordsFastener = [
        [fastenerCoordsLeftStartX, clipLipThickness+connectorTolerance], //pt1
        [fastenerCoordsLeftStartX + clipLipLength - clipLipThickness + clipLipThickness - connectorTolerance, clipLipThickness+connectorTolerance], //pt2
        [fastenerCoordsLeftStartX + clipLipLength - clipLipThickness + clipLipThickness - connectorTolerance, clipLipThickness+clipLipInnerHeight-connectorTolerance], //pt3
        [fastenerCoordsLeftStartX + clipLipLength - clipLipThickness  + clipLipThickness - connectorTolerance - clipConnectorInnerLength, clipLipThickness+clipLipInnerHeight-connectorTolerance], //pt4
        [fastenerCoordsLeftStartX + clipLipLength - clipLipThickness  + clipLipThickness- connectorTolerance - clipConnectorInnerLength, clipLipThickness+clipLipInnerHeight+clipLipThickness+connectorTolerance], //pt5
        [fastenerCoordsRightStartX - clipLipLength+clipConnectorInnerLength+clipLipThickness - clipLipThickness+connectorTolerance, clipLipThickness+clipLipInnerHeight+clipLipThickness+connectorTolerance], //pt6
        [fastenerCoordsRightStartX - clipLipLength+clipConnectorInnerLength+clipLipThickness -clipLipThickness +connectorTolerance, clipLipThickness+clipLipInnerHeight-connectorTolerance], //pt7
        [fastenerCoordsRightStartX - clipLipLength + clipLipThickness - clipLipThickness + connectorTolerance, clipLipThickness+clipLipInnerHeight-connectorTolerance], //pt8
        [fastenerCoordsRightStartX - clipLipLength + clipLipThickness - clipLipThickness + connectorTolerance, clipLipThickness+connectorTolerance], //pt9
        // [fastenerCoordsRightStartX - clipLipLength + clipLipThickness + clipConnectorInnerLength + connectorTolerance, clipLipThickness+clipLipInnerHeight-connectorTolerance],
        [fastenerCoordsRightStartX, clipLipThickness+connectorTolerance], //pt10
        [fastenerCoordsRightStartX, clipLipThickness+clipLipInnerHeight+clipLipThickness+clipLipThickness+clipLipThickness], //pt11
        // [fastenerCoordsRightStartX, clipLipThickness+clipLipInnerHeight+clipLipThickness+clipLipThickness],
        [fastenerCoordsLeftStartX, clipLipThickness+clipLipInnerHeight+clipLipThickness+clipLipThickness+clipLipThickness], //pt12
        [fastenerCoordsLeftStartX, clipLipThickness+connectorTolerance], //pt13
    ];

    translate([-width/2, 0, 0]){
        rotate([180, 0, 0]){
            if(generateSideClip){
                linear_extrude(height=height, center=true){
                    polygon(points=coordsLeft);
                }
                translate([0, 0, -height/2+wallThickness/2]){
                    linear_extrude(height=clipBaseThickness, center=true){
                        polygon(points=[
                            [coordsLeftStartX, 0],
                            [coordsLeftStartX+clipLipLength, 0],
                            [coordsLeftStartX+clipLipLength, clipLipInnerHeight+clipLipThickness*2],
                            [coordsLeftStartX, clipLipInnerHeight+clipLipThickness*2],
                            [coordsLeftStartX, 0]
                        ]);
                    }
                }
                
                
                linear_extrude(height=height, center=true){
                    polygon(points=coordsRight);
                }
                translate([0, 0, -height/2+wallThickness/2]){
                    linear_extrude(height=clipBaseThickness, center=true){
                        polygon(points=[
                            [coordsRightStartX, 0],
                            [coordsRightStartX-clipLipLength, 0],
                            [coordsRightStartX-clipLipLength, clipLipInnerHeight+clipLipThickness*2],
                            [coordsRightStartX, clipLipInnerHeight+clipLipThickness*2],
                            [coordsRightStartX, 0]
                        ]);
                    }
                }
            }
            if(generateFastener){
                translate([0, width, wallThickness/2+connectorTolerance]){
                    color("yellow") 
                    difference(){
                        linear_extrude(height=height-clipBaseThickness, center=true){
                            polygon(points=coordsFastener);
                        }
                        translate([width/2, 0, 0]) {
                            rotate([90, 90, 0]){
                                threadedRodForHole(length = wallThickness*20, center = true, tolerance = 0.2, hole_radius=TB_SCREW_Threaded_Rod_Diameter/2);
                            }
                        }
                    }
                        
                }
            }
            
        }
    }

    rotate([90,0,0]){
        // translate([(width+baseThickness)/2 - (width+baseThickness)*clipPortionOfWidth/2, 0, 0]){
        //     color("purple") cube([clipLipLength, height, wallThickness], center=true);
        // }
    }
}




module mnts_slideLockFastener(mountingWallThickness=4, fastenerWallThickness=2, clipWallThickness=2, generateFastener=true, generateSideClip=true, generateHole=false, width=20, height=30, connectorClipTolerance=0.15){
    fullFastenerThickness = mountingWallThickness+fastenerWallThickness+clipWallThickness+connectorClipTolerance;
    fullClipWidth = width + fastenerWallThickness*2+connectorClipTolerance*2;
    fullClipThickness = clipWallThickness+fastenerWallThickness*2;
    if(generateFastener){
        difference(){
            cube([width, fullFastenerThickness, height], center=true);
            translate([0, 0, fastenerWallThickness]){
                cube([width-fastenerWallThickness*4, fullFastenerThickness, height], center=true);
                translate([-width/2+fastenerWallThickness/2, fullFastenerThickness/2-fastenerWallThickness/2-mountingWallThickness-connectorClipTolerance/2, 0]){
                    cube([fastenerWallThickness, fastenerWallThickness+connectorClipTolerance, height], center=true);
                }
                translate([width/2-fastenerWallThickness/2, fullFastenerThickness/2-fastenerWallThickness/2-mountingWallThickness-connectorClipTolerance/2, 0]){
                    cube([fastenerWallThickness, fastenerWallThickness+connectorClipTolerance, height], center=true);
                }
                translate([0, 0, -height/2]){
                    cube([width-fastenerWallThickness*4, fullFastenerThickness, height], center=true);
                }
            }
        }
        
    }

    if(generateHole){
        cube([width-fastenerWallThickness*4, fullFastenerThickness, height], center=true);
    }
    
    if(generateSideClip){
        translate([0, -fullFastenerThickness*2, 0]){
            difference(){
                cube([fullClipWidth, fullClipThickness, height-fastenerWallThickness], center=true);
                translate([0, 0, 0]){
                    cube([fullClipWidth-fastenerWallThickness*2, clipWallThickness+connectorClipTolerance, height-fastenerWallThickness], center=true);
                }
                translate([0, fastenerWallThickness, 0]){
                    cube([fullClipWidth-fastenerWallThickness*4, clipWallThickness+connectorClipTolerance, height-fastenerWallThickness], center=true);
                }
            }
            
        }
    }
}


module mnts_screwFastener(width=20, height=30, mountingWallThickness=4, fastenerWallThickness=2,fastenerArmLength=20, screwHoleDiameter=10, screwHoleDepth=1, screwHeadDiameter=10, screwHeadDepth=2, generateFastener=true, generateHole=false){
    fullFastenerLength = mountingWallThickness+fastenerArmLength;
    if(generateFastener){
        difference(){
            translate([width/2+fastenerWallThickness/2, (fullFastenerLength)/2, 0])
                cube([fastenerWallThickness, fullFastenerLength, height], center=true);
            translate([0, 0, 0])
                rotate([0, 0, 0])
                    cylinder(d=screwHoleDiameter, h=screwHoleDepth, center=true);
        }
        translate([-(width/2+fastenerWallThickness/2), (fullFastenerLength)/2, 0])
            cube([fastenerWallThickness, fullFastenerLength, height], center=true);
        
        translate([0, 0, 0])
                rotate([90, 0, 0])
                    cylinder(d=screwHeadDiameter, h=screwHeadDepth, center=true);
                    translate([0, 0, screwHeadDepth/2+screwHoleDepth/2])
                        cylinder(d=screwHoleDiameter, h=screwHoleDepth, center=true);
    }

    if(generateHole){
        cube([width, fullFastenerLength, height], center=true);
    }
    
    
}

module mnts_tBScrewHole(wallThickness=2, width=2, baseThickness=2, height=10, zRotation=0, holeLength=-1){
    officialHoleLength = holeLength==-1 ? wallThickness*2 : holeLength;

    echo(str("holeLength: ", holeLength));
    rotate([90,0,zRotation]){
        difference(){
            cube([width+baseThickness, height, wallThickness], center=true);
        threadedRodForHole(length = officialHoleLength, center = true, tolerance = 0.2, hole_radius=TB_SCREW_Threaded_Rod_Diameter/2);
        }
    }
}