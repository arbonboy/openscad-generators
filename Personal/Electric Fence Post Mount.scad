include <ThreadBoards/lib/tb_screws.scad>;


/* [Box Parameters] */
Box_Width_X = 25; // [10:0.1:200]
Box_Width_Y = 20; // [10:0.1:200]
Box_Height = 27; // [10:1:200]
Base_Thickness = 2; // [0.5:0.5:10]

/* [Side 1 Parameters] */
Side1_Thickness = 0; // [0.5:0.5:10]
Side1_Connector_Type = "tbscrew"; // [none:None, nwire:N-Style Wire Clip, wwire:W-Style Wire Clip, tbscrew:Thread Board Screw Hole, slidelock:Slide Lock Slot, hook:Simple Hook, open:Opening, postclip:Post Mounting Clip]

/* [Side 2 Parameters] */
Side2_Thickness = 0; // [0.5:0.5:10]
Side2_Connector_Type = "slidelock"; // [none:None, nwire:N-Style Wire Clip, wwire:W-Style Wire Clip, tbscrew:Thread Board Screw Hole, slidelock:Slide Lock Slot, hook:Simple Hook, open:Opening, postclip:Post Mounting Clip]
/* [Side 3 Parameters] */
Side3_Thickness = 0; // [0.5:0.5:10]
Side3_Connector_Type = "wwire"; // [none:None, nwire:N-Style Wire Clip, wwire:W-Style Wire Clip, tbscrew:Thread Board Screw Hole, slidelock:Slide Lock Slot, hook:Simple Hook, open:Opening, postclip:Post Mounting Clip]

/* [Side 4 Parameters] */
Side4_Thickness = 0; // [0.5:0.5:10]
Side4_Connector_Type = "postclip"; // [none:None, nwire:N-Style Wire Clip, wwire:W-Style Wire Clip, tbscrew:Thread Board Screw Hole, slidelock:Slide Lock Slot, hook:Simple Hook, open:Opening, postclip:Post Mounting Clip]

/* [Hidden] */
// Box_Depth = 32; // [10:1:100]
Slot_Channel_Width_Large_End = 20;
Slot_Channel_Width_Small_End = 15;
Slot_Depth = 4;



drawBox();
// boxSidePostClip(generateFastener = false);

module drawBox(){
    ghostLabelSize = 3;
    ghostLabelX = max(Box_Width_X, Box_Width_Y)/2;
    ghostLabelZ = -8;
    ghostLabelColor = "red";
    rotate([0,180,0]){
        union(){
            // Side 1
            translate([0, -Box_Width_Y/2 - Side1_Thickness/2, 0]){
                translate([ghostLabelX, -(Base_Thickness+Side1_Thickness)/2, ghostLabelZ]) rotate([-90,0,180]) color(ghostLabelColor) text("1", size=ghostLabelSize);
                if(Side1_Connector_Type == "none"){
                    boxSideFlat(wallThickness=Base_Thickness+Side1_Thickness, side=1);
                } else if(Side1_Connector_Type == "nwire"){
                    boxSideWireClipNType(wallThickness=Base_Thickness+Side1_Thickness, side=1);
                } else if(Side1_Connector_Type == "tbscrew"){
                    boxSideTBScrewHole(wallThickness=Base_Thickness+Side1_Thickness, side=1);
                } else if(Side1_Connector_Type == "slidelock"){
                    boxSideSlideLockSlot(wallThickness=Base_Thickness+Side1_Thickness, side=1);
                } else if(Side1_Connector_Type == "hook"){
                    boxSideSimpleHook(wallThickness=Base_Thickness+Side1_Thickness, side=1);
                } else if(Side1_Connector_Type == "wwire"){
                    boxSideWireClipWType(wallThickness=Base_Thickness+Side1_Thickness, side=1);
                } else if(Side1_Connector_Type == "open"){
                    boxSideFlat(wallThickness=0, side=1);
                } else if(Side1_Connector_Type == "postclip"){
                    boxSidePostClip(wallThickness=Base_Thickness+Side1_Thickness, side=1);
                }
            }
            // Side 2
            translate([Box_Width_X/2 + Side2_Thickness/2, 0, 0]){
                rotate([0,0,90]){
                    translate([ghostLabelX, -(Base_Thickness+Side2_Thickness)/2, ghostLabelZ]) rotate([-90,0,180]) color(ghostLabelColor) text("2", size=ghostLabelSize);
                    if(Side2_Connector_Type == "none"){
                        boxSideFlat(wallThickness=Base_Thickness+Side2_Thickness, side=2);
                    } else if(Side2_Connector_Type == "nwire"){
                        boxSideWireClipNType(wallThickness=Base_Thickness+Side2_Thickness, side=2);
                    } else if(Side2_Connector_Type == "tbscrew"){
                        boxSideTBScrewHole(wallThickness=Base_Thickness+Side2_Thickness, side=2);
                    } else if(Side2_Connector_Type == "slidelock"){
                        boxSideSlideLockSlot(wallThickness=Base_Thickness+Side2_Thickness, side=2);
                    } else if(Side2_Connector_Type == "hook"){
                        boxSideSimpleHook(wallThickness=Base_Thickness+Side2_Thickness, side=2);
                    } else if(Side2_Connector_Type == "wwire"){
                        boxSideWireClipWType(wallThickness=Base_Thickness+Side2_Thickness, side=2);
                    } else if(Side2_Connector_Type == "postclip"){
                        boxSidePostClip(wallThickness=Base_Thickness+Side2_Thickness, side=2);
                    }
                }
            }
            // Side 3
            translate([0, Box_Width_Y/2 + Side3_Thickness/2, 0]){
                rotate([0,0,180]){
                    translate([ghostLabelX, -(Base_Thickness+Side3_Thickness)/2, ghostLabelZ]) rotate([-90,0,180]) color(ghostLabelColor) text("3", size=ghostLabelSize);
                    if(Side3_Connector_Type == "none"){
                        boxSideFlat(wallThickness=Base_Thickness+Side3_Thickness, side=3);
                    } else if(Side3_Connector_Type == "nwire"){
                        boxSideWireClipNType(wallThickness=Base_Thickness+Side3_Thickness, side=3);
                    } else if(Side3_Connector_Type == "tbscrew"){
                        boxSideTBScrewHole(wallThickness=Base_Thickness+Side3_Thickness, side=3);
                    } else if(Side3_Connector_Type == "slidelock"){
                        boxSideSlideLockSlot(wallThickness=Base_Thickness+Side3_Thickness, side=3);
                    } else if(Side3_Connector_Type == "hook"){
                        boxSideSimpleHook(wallThickness=Base_Thickness+Side3_Thickness, side=3);
                    } else if(Side3_Connector_Type == "wwire"){
                        boxSideWireClipWType(wallThickness=Base_Thickness+Side3_Thickness, side=3);
                    } else if(Side3_Connector_Type == "postclip"){
                    boxSidePostClip(wallThickness=Base_Thickness+Side3_Thickness, side=3);
                }
                }
            }
        }
        // Side 4
        translate([-Box_Width_X/2 - Side4_Thickness/2, 0, 0]){
            rotate([0,0,-90]){
                translate([ghostLabelX, -(Base_Thickness+Side4_Thickness)/2, ghostLabelZ]) rotate([-90,0,180]) color(ghostLabelColor) text("4", size=ghostLabelSize);
                if(Side4_Connector_Type == "none"){
                    boxSideFlat(wallThickness=Base_Thickness+Side4_Thickness, side=4);
                } else if(Side4_Connector_Type == "nwire"){
                    boxSideWireClipNType(wallThickness=Base_Thickness+Side4_Thickness, side=4);
                } else if(Side4_Connector_Type == "tbscrew"){
                    boxSideTBScrewHole(wallThickness=Base_Thickness+Side4_Thickness, side=4);
                } else if(Side4_Connector_Type == "slidelock"){
                    boxSideSlideLockSlot(wallThickness=Base_Thickness+Side4_Thickness, side=4);
                } else if(Side4_Connector_Type == "hook"){
                    boxSideSimpleHook(wallThickness=Base_Thickness+Side4_Thickness, side=4);
                } else if(Side4_Connector_Type == "wwire"){
                    boxSideWireClipWType(wallThickness=Base_Thickness+Side4_Thickness, side=4);
                } else if(Side4_Connector_Type == "postclip"){
                    boxSidePostClip(wallThickness=Base_Thickness+Side4_Thickness, side=4);
                }
            }
        }
    }
    
}




                

module boxSideTBScrewHole(wallThickness=2, side=1){
    width = (side == 1 || side == 3) ? Box_Width_X : Box_Width_Y;
    rotate([90,0,0]){
        difference(){
            cube([width+Base_Thickness, Box_Height, wallThickness], center=true);
            threadedRodForHole(length = wallThickness*2, center = true, tolerance = 0.2, hole_radius=TB_SCREW_Threaded_Rod_Diameter/2);
        }
    }
}

module boxSideFlat(wallThickness=2, side=1){
    width = (side == 1 || side == 3) ? Box_Width_X : Box_Width_Y;
    rotate([90,0,0]){
        cube([width+Base_Thickness, Box_Height, wallThickness], center=true);
    }
}

module boxSideWireClipNType(wallThickness=2, side=1){
    width = (side == 1 || side == 3) ? Box_Width_X : Box_Width_Y;
    rotate([90,0,0]){
        cube([width+Base_Thickness, Box_Height, wallThickness], center=true);
        translate([width*1/5, 0, 0]){
            rotate([0,0,0]){
                wireClipArmN(wallThickness);
            }
        }
        translate([-width*1/5, Box_Height/2, 0]){
            rotate([0,0,180]){
                wireClipArmN(wallThickness);
            }
        }
    }

}

module wireClipArmN(wallThickness=2, armWidth=7, openingWidth=7, armThickness=5){
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

module boxSideSimpleHook(wallThickness=2, armWidth=7, openingWidth=7, armThickness=5, side=1){
    width = (side == 1 || side == 3) ? Box_Width_X : Box_Width_Y;
    rotate([90,0,0]){
        cube([width+Base_Thickness, Box_Height, wallThickness], center=true);
        translate([0, 0, 0]){
            rotate([0,0,0]){
                wireClipArmN(wallThickness);
            }
        }
    }

}


module boxSideWireClipWType(wallThickness=2, channelWidth=15, width=25, depth=17, height=Box_Height, side=1){
    width = (side == 1 || side == 3) ? Box_Width_X : Box_Width_Y;
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
            cube([width+Base_Thickness, Box_Height, wallThickness], center=true);
            translate([-wBraceWidth/3,Box_Height/2,wallThickness/2]) rotate([0,-90,180]){
                linear_extrude(height=wBraceWidth/3, center=true){
                    polygon(points=pointArrayEnd);
                }
            }
            
            translate([0,Box_Height/2,wallThickness/2]) rotate([0,-90,180]){
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
            translate([wBraceWidth/3,Box_Height/2,wallThickness/2]) rotate([0,-90,180]){
                linear_extrude(height=wBraceWidth/3, center=true){
                    polygon(points=pointArrayEnd);
                }
            }
        
        }
    }
}   
    
module boxSideSlideLockSlot(wallThickness=2, slotWidthLarge=Slot_Channel_Width_Large_End, slotWidthSmall=Slot_Channel_Width_Small_End, slotDepth=Slot_Depth, slotHeight=Box_Height, side=1){
    width = (side == 1 || side == 3) ? Box_Width_X : Box_Width_Y;
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
        cube([width+Base_Thickness, Box_Height, wallThickness], center=true);
        translate([-slotWidthLarge/2, 0, wallThickness/2]){
            rotate([90,0,0]){
                linear_extrude(height=slotHeight, center=true){
                    polygon(points=pointArrayMultiConnectCompatible);
                }
            }   
        }
    }

}
    
    
module boxSidePostClip(wallThickness=2, generateFastener=true, generateSideClip=true, side=1){
    width = (side == 1 || side == 3) ? Box_Width_X : Box_Width_Y;
    
    clipPortionOfWidth = 3/16;
    clipLipLength = (width+Base_Thickness)*clipPortionOfWidth;
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
                linear_extrude(height=Box_Height, center=true){
                    polygon(points=coordsLeft);
                }
                translate([0, 0, -Box_Height/2+wallThickness/2]){
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
                
                
                linear_extrude(height=Box_Height, center=true){
                    polygon(points=coordsRight);
                }
                translate([0, 0, -Box_Height/2+wallThickness/2]){
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
                        linear_extrude(height=Box_Height-clipBaseThickness, center=true){
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
        // translate([(width+Base_Thickness)/2 - (width+Base_Thickness)*clipPortionOfWidth/2, 0, 0]){
        //     color("purple") cube([clipLipLength, Box_Height, wallThickness], center=true);
        // }
        
        
        
    }

}