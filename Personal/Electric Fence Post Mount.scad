include <ThreadBoards/lib/tb_screws.scad>;
include <lib/Mounts.scad>;


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
    ghostLabelZ = -Box_Height/2;
    ghostLabelColor = "red";
    rotate([0,180,0]){
        union(){
            // Side 1
            translate([0, -(Box_Width_Y/2+Base_Thickness/2) - Side1_Thickness/2, 0]){
                % translate([ghostLabelX, -(Base_Thickness+Side1_Thickness)/2, ghostLabelZ]) rotate([-90,0,180]) color(ghostLabelColor) text("1", size=ghostLabelSize);
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
            translate([(Box_Width_X/2+Base_Thickness/2) + Side2_Thickness/2, 0, 0]){
                rotate([0,0,90]){
                    % translate([ghostLabelX, -(Base_Thickness+Side2_Thickness)/2, ghostLabelZ]) rotate([-90,0,180]) color(ghostLabelColor) text("2", size=ghostLabelSize);
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
            translate([0, Box_Width_Y/2+Base_Thickness/2 + Side3_Thickness/2, 0]){
                rotate([0,0,180]){
                    % translate([ghostLabelX, -(Base_Thickness+Side3_Thickness)/2, ghostLabelZ]) rotate([-90,0,180]) color(ghostLabelColor) text("3", size=ghostLabelSize);
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
        translate([-(Box_Width_X/2+Base_Thickness/2) - Side4_Thickness/2, 0, 0]){
            rotate([0,0,-90]){
                % translate([ghostLabelX, -(Base_Thickness+Side4_Thickness)/2, ghostLabelZ]) rotate([-90,0,180]) color(ghostLabelColor) text("4", size=ghostLabelSize);
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
    mnts_tBScrewHole(wallThickness=wallThickness, width=width, height=Box_Height, baseThickness=Base_Thickness);
    // rotate([90,0,0]){
    //     difference(){
    //         cube([width+Base_Thickness, Box_Height, wallThickness], center=true);
    //         threadedRodForHole(length = wallThickness*2, center = true, tolerance = 0.2, hole_radius=TB_SCREW_Threaded_Rod_Diameter/2);
    //     }
    // }
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
                mnts_wireClipArmN(wallThickness);
            }
        }
        translate([-width*1/5, Box_Height/2, 0]){
            rotate([0,0,180]){
                mnts_wireClipArmN(wallThickness);
            }
        }
    }

}

// module wireClipArmN(wallThickness=2, armWidth=7, openingWidth=7, armThickness=5){
//     openWidth=openingWidth;
//     thickness=armThickness;
//     openWidthOuter=openWidth+thickness*5/10;
//     lipHeight=7;
//     totalInnerHeight=14;
//     elbowHeight=lipHeight+thickness*5/10;
//     topmostHeight=totalInnerHeight+thickness;

//     pointArray = [
//         [openWidth,0],
//         [openWidthOuter,0],
//         [openWidthOuter, elbowHeight],
//         [0,topmostHeight],
//         [0,totalInnerHeight],
//         [openWidth,lipHeight],
//         [openWidth,0]
//     ];
//     translate([0,-1*thickness*6/10,wallThickness/2]) rotate([0,-90,0]){
//         linear_extrude(height=armWidth, center=true){
//             polygon(points=pointArray);
//         }
//     }
    
// }

module boxSideSimpleHook(wallThickness=2, armWidth=7, openingWidth=7, armThickness=5, side=1){
    width = (side == 1 || side == 3) ? Box_Width_X : Box_Width_Y;
    rotate([90,0,0]){
        cube([width+Base_Thickness, Box_Height, wallThickness], center=true);
        translate([0, 0, 0]){
            rotate([0,0,0]){
                mnts_wireClipArmN(wallThickness);
            }
        }
    }

}


module boxSideWireClipWType(wallThickness=2, channelWidth=15, width=25, depth=17, height=Box_Height, side=1){
    width = (side == 1 || side == 3) ? Box_Width_X : Box_Width_Y;
    mnts_wireClipWType(wallThickness, channelWidth, width, depth, height);    
}   
    
module boxSideSlideLockSlot(wallThickness=2, slotWidthLarge=Slot_Channel_Width_Large_End, slotWidthSmall=Slot_Channel_Width_Small_End, slotDepth=Slot_Depth, slotHeight=Box_Height, side=1){
    width = (side == 1 || side == 3) ? Box_Width_X : Box_Width_Y;
    mnts_slideLockSlot(wallThickness=wallThickness, width=width, height=Box_Height, slotWidthLarge=slotWidthLarge, slotWidthSmall=slotWidthSmall, slotDepth=slotDepth, slotHeight=slotHeight, baseThickness=Base_Thickness);

}
    
    
module boxSidePostClip(wallThickness=2, generateFastener=true, generateSideClip=true, side=1){
    width = (side == 1 || side == 3) ? Box_Width_X : Box_Width_Y;
    mnts_postClip(wallThickness=wallThickness, width=width, height=Box_Height, baseThickness=Base_Thickness, generateFastener=generateFastener, generateSideClip=generateSideClip);
    
}