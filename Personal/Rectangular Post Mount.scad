include <lib/mounting_interfaces.scad>;

/* Rect Mount Parameters */
Mount_Width_X = 25; // [10:0.1:200]
Mount_Width_Y = 20; // [10:0.1:200]
Mount_Height = 27; // [10:1:200]

/* [Side 1 Parameters] */
Side1_Thickness = 2; // [0.5:0.5:10]
Side1_Connector_Type = "nwire"; // [none:None, nwire:N-Style Wire Clip, wwire:W-Style Wire Clip, tbscrew:Thread Board Screw Hole, slidelock:Slide Lock Slot, hook:Simple Hook, open:Opening, postclip:Post Mounting Clip, rectholder:Rectangular Holder, circularholder:Circular Holder]

/* [Side 2 Parameters] */
Side2_Thickness = 2; // [0.5:0.5:10]
Side2_Connector_Type = "none"; // [none:None, nwire:N-Style Wire Clip, wwire:W-Style Wire Clip, tbscrew:Thread Board Screw Hole, slidelock:Slide Lock Slot, hook:Simple Hook, open:Opening, postclip:Post Mounting Clip, rectholder:Rectangular Holder, circularholder:Circular Holder]
/* [Side 3 Parameters] */
Side3_Thickness = 2; // [0.5:0.5:10]
Side3_Connector_Type = "none"; // [none:None, nwire:N-Style Wire Clip, wwire:W-Style Wire Clip, tbscrew:Thread Board Screw Hole, slidelock:Slide Lock Slot, hook:Simple Hook, open:Opening, postclip:Post Mounting Clip, rectholder:Rectangular Holder, circularholder:Circular Holder]

/* [Side 4 Parameters] */
Side4_Thickness = 2; // [0.5:0.5:10]
Side4_Connector_Type = "none"; // [none:None, nwire:N-Style Wire Clip, wwire:W-Style Wire Clip, tbscrew:Thread Board Screw Hole, slidelock:Slide Lock Slot, hook:Simple Hook, open:Opening, postclip:Post Mounting Clip, rectholder:Rectangular Holder, circularholder:Circular Holder]


/* [Slot Connector] */
//Standard Large End is 20
Slot_Channel_Width_Large_End = 20; //[1:0.5:50]
//Standard Small End is 15
Slot_Channel_Width_Small_End = 15; //[1:0.5:50]
// If set to zero, will default to Mount_Height
Slot_Height = 27; //[0:1:200]
//Standard Depth is 4
Slot_Depth = 4; //[1:0.5:20]


/* [N Clip Connector] */
Clip_Arm_Width = 7; //[1:0.5:50]
Clip_Arm_Thickness = 5; //[1:0.5:50]
Clip_Opening_Width = 7; //[1:0.5:50]

/* [W Clip Connector] */
W_Clip_Width = 25; //[10:0.5:50]
W_Clip_Depth = 17; //[10:0.5:50]
W_Clip_Height = 27; //[10:0.5:50]

/* [TB Screw Hole Connector] */
Hole_Block_Width = 25; //[10:0.5:100]
Hole_Block_Height = 25; //[10:0.5:100]
Hole_Block_Thickness = 5; //[1:0.5:20]

/* [Post Clip Fastener] */
//If set to zero or negative, will default to Mount_Height
Post_Clip_Height = 27; //[0:1:200]
Clip_Wall_Thickness = 2; //[1:0.5:20]
Connector_Tolerance = 0.1; //[0:0.05:1]
Post_Clip_Mounting_Width_Per_Arm=6; //[1:0.5:20] 
Post_Clip_Mounting_Wall_Thickness=2; //[1:0.5:20] 
Post_Clip_Fastener_Height=20; //[0:1:200]
Post_Clip_Channel_Width=2; //[1:0.5:20]
Post_Clip_Channel_Depth=2; //[1:0.5:20]
Post_Clip_Channel_Stopper_Wall_Thickness=2; //[1:0.5:20]
Post_Clip_Outer_Wall_Thickness=2; //[1:0.5:20]
Post_Clip_Connecter_Tolerance=0.05; //[0:0.05:1]
Post_Clip_Connector_TB_Hole = true;

/* [Simple Hook Connector] */
Hook_Arm_Width = 7; //[1:0.5:50]
Hook_Arm_Thickness = 5; //[1:0.5:50]
Hook_Opening_Width = 7; //[1:0.5:50]

/* [Rectangular Holder Connector] */
Rect_Holder_Width = 20; //[10:0.5:50]
//Height of 0 will default to Mount_Height
Rect_Holder_Height = 0; //[0:0.5:50]
Rect_Holder_Wall_Thickness = 2; //[1:0.5:20]
Rect_Holder_Depth = 40; //[10:0.5:100]
Rect_Holder_Bottom_Floor = false; //[false:true]

/* [Circular Holder Connector] */
Circular_Holder_Diameter = 20; //[10:0.5:50]
//Height of 0 will default to Mount_Height
Circular_Holder_Height = 0; //[0:0.5:50]
Circular_Holder_Wall_Thickness = 2; //[1:0.5:20]
Circular_Holder_Bottom_Floor = false; //[false:true]


drawBox();


// translate([0, -40, 0]) mnt_wireClipTypeW(
//         mountingWallThickness=Side1_Thickness, 
//         mountWidth=Mount_Width_X, 
//         width=Mount_Width_X, 
//         depth=17, 
//         height=Mount_Height
//     );


module drawBox(){
    ghostLabelSize = 3;
    ghostLabelX = max(Mount_Width_X, Mount_Width_Y)/2;
    ghostLabelZ = Mount_Height/2;
    ghostLabelColor = "red";
    rotate([0,0,0]){
        union(){
            // Side 1
            translate([0, -(Mount_Width_Y/2) - Side1_Thickness/2, 0]){
                // % translate([ghostLabelX, -(Side1_Thickness)/2, ghostLabelZ]) rotate([-90,0,180]) color(ghostLabelColor) text("1", size=ghostLabelSize);
                % translate([ghostLabelX, -(Side1_Thickness)/2, ghostLabelZ]) rotate([90,0,0]) color(ghostLabelColor) text("1", size=ghostLabelSize);
                if(Side1_Connector_Type == "none"){
                    boxSideFlat(mountingWallThickness=Side1_Thickness, side=1);
                } else if(Side1_Connector_Type == "nwire"){
                    boxSideWireClipNType(mountingWallThickness=Side1_Thickness, side=1);
                } else if(Side1_Connector_Type == "tbscrew"){
                    boxSideTBScrewHole(mountingWallThickness=Side1_Thickness, side=1);
                } else if(Side1_Connector_Type == "slidelock"){
                    boxSideSlideLockSlot(mountingWallThickness=Side1_Thickness, side=1);
                } else if(Side1_Connector_Type == "hook"){
                    boxSideSimpleHook(mountingWallThickness=Side1_Thickness, side=1);
                } else if(Side1_Connector_Type == "wwire"){
                    boxSideWireClipWType(mountingWallThickness=Side1_Thickness, side=1);
                } else if(Side1_Connector_Type == "open"){
                    boxSideFlat(mountingWallThickness=0, side=1);
                } else if(Side1_Connector_Type == "postclip"){
                    boxSidePostClip(mountingWallThickness=Side1_Thickness, side=1);
                } else if(Side1_Connector_Type == "rectholder"){
                    boxSideRectHolder(mountingWallThickness=Side1_Thickness, side=1);
                } else if(Side1_Connector_Type == "circularholder"){
                    boxSideCircularHolder(mountingWallThickness=Side1_Thickness, side=1);
                }
            }
            // Side 2
            translate([(Mount_Width_X/2) + Side2_Thickness/2, 0, 0]){
                rotate([0,0,90]){
                    % translate([ghostLabelX, -(Side2_Thickness)/2, ghostLabelZ]) rotate([90,0,0]) color(ghostLabelColor) text("2", size=ghostLabelSize);
                    if(Side2_Connector_Type == "none"){
                        boxSideFlat(mountingWallThickness=Side2_Thickness, side=2);
                    } else if(Side2_Connector_Type == "nwire"){
                        boxSideWireClipNType(mountingWallThickness=Side2_Thickness, side=2);
                    } else if(Side2_Connector_Type == "tbscrew"){
                        boxSideTBScrewHole(mountingWallThickness=Side2_Thickness, side=2);
                    } else if(Side2_Connector_Type == "slidelock"){
                        boxSideSlideLockSlot(mountingWallThickness=Side2_Thickness, side=2);
                    } else if(Side2_Connector_Type == "hook"){
                        boxSideSimpleHook(mountingWallThickness=Side2_Thickness, side=2);
                    } else if(Side2_Connector_Type == "wwire"){
                        boxSideWireClipWType(mountingWallThickness=Side2_Thickness, side=2);
                    } else if(Side2_Connector_Type == "postclip"){
                        boxSidePostClip(mountingWallThickness=Side2_Thickness, side=2);
                    } else if(Side2_Connector_Type == "rectholder"){
                        boxSideRectHolder(mountingWallThickness=Side2_Thickness, side=2);
                    } else if(Side2_Connector_Type == "circularholder"){
                        boxSideCircularHolder(mountingWallThickness=Side2_Thickness, side=2);
                    }

                }
            }
            // Side 3
            translate([0, Mount_Width_Y/2 + Side3_Thickness/2, 0]){
                rotate([0,0,180]){
                    % translate([ghostLabelX, -(Side3_Thickness)/2, ghostLabelZ]) rotate([90,0,0]) color(ghostLabelColor) text("3", size=ghostLabelSize);
                    if(Side3_Connector_Type == "none"){
                        boxSideFlat(mountingWallThickness=Side3_Thickness, side=3);
                    } else if(Side3_Connector_Type == "nwire"){
                        boxSideWireClipNType(mountingWallThickness=Side3_Thickness, side=3);
                    } else if(Side3_Connector_Type == "tbscrew"){
                        boxSideTBScrewHole(mountingWallThickness=Side3_Thickness, side=3);
                    } else if(Side3_Connector_Type == "slidelock"){
                        boxSideSlideLockSlot(mountingWallThickness=Side3_Thickness, side=3);
                    } else if(Side3_Connector_Type == "hook"){
                        boxSideSimpleHook(mountingWallThickness=Side3_Thickness, side=3);
                    } else if(Side3_Connector_Type == "wwire"){
                        boxSideWireClipWType(mountingWallThickness=Side3_Thickness, side=3);
                    } else if(Side3_Connector_Type == "postclip"){
                        boxSidePostClip(mountingWallThickness=Side3_Thickness, side=3);
                    } else if(Side3_Connector_Type == "rectholder"){
                        boxSideRectHolder(mountingWallThickness=Side3_Thickness, side=3);
                    } else if(Side3_Connector_Type == "circularholder"){
                        boxSideCircularHolder(mountingWallThickness=Side3_Thickness, side=3);
                    }
                }
            }
        }
        // Side 4
        translate([-(Mount_Width_X/2) - Side4_Thickness/2, 0, 0]){
            rotate([0,0,-90]){
                % translate([ghostLabelX, -(Side4_Thickness)/2, ghostLabelZ]) rotate([90,0,0]) color(ghostLabelColor) text("4", size=ghostLabelSize);
                if(Side4_Connector_Type == "none"){
                    boxSideFlat(mountingWallThickness=Side4_Thickness, side=4);
                } else if(Side4_Connector_Type == "nwire"){
                    boxSideWireClipNType(mountingWallThickness=Side4_Thickness, side=4);
                } else if(Side4_Connector_Type == "tbscrew"){
                    boxSideTBScrewHole(mountingWallThickness=Side4_Thickness, side=4);
                } else if(Side4_Connector_Type == "slidelock"){
                    boxSideSlideLockSlot(mountingWallThickness=Side4_Thickness, side=4);
                } else if(Side4_Connector_Type == "hook"){
                    boxSideSimpleHook(mountingWallThickness=Side4_Thickness, side=4);
                } else if(Side4_Connector_Type == "wwire"){
                    boxSideWireClipWType(mountingWallThickness=Side4_Thickness, side=4);
                } else if(Side4_Connector_Type == "postclip"){
                    boxSidePostClip(mountingWallThickness=Side4_Thickness, side=4);
                } else if(Side4_Connector_Type == "rectholder"){
                    boxSideRectHolder(mountingWallThickness=Side4_Thickness, side=4);
                } else if(Side4_Connector_Type == "circularholder"){
                    boxSideCircularHolder(mountingWallThickness=Side4_Thickness, side=4);
                }
            }
        }
    }
    
}



module boxSideWireClipWType(mountingWallThickness=2, depth=W_Clip_Depth, height=W_Clip_Height, width=W_Clip_Width, side=1){
    width = (side == 1 || side == 3) ? Mount_Width_X + Side2_Thickness + Side4_Thickness : Mount_Width_Y + Side1_Thickness + Side3_Thickness;
    mnt_wireClipTypeW(
        mountingWallThickness=mountingWallThickness, 
        mountWidth=width, 
        width=width, 
        depth=depth, 
        height=height
    );
    
}   


module boxSideWireClipNType(mountingWallThickness=2, side=1){
    width = (side == 1 || side == 3) ? Mount_Width_X + Side2_Thickness + Side4_Thickness : Mount_Width_Y + Side1_Thickness + Side3_Thickness;
    mnt_wireClipTypeN(
        mountingWallThickness = mountingWallThickness, 
        mountWidth = width, 
        mountingWallHeight = Mount_Height, 
        clipArmWidth = Clip_Arm_Width, 
        clipOpeningWidth = Clip_Opening_Width, 
        clipArmThickness = Clip_Arm_Thickness
    );

}

module boxSideTBScrewHole(mountingWallThickness=2, side=1){
    width = (side == 1 || side == 3) ? Mount_Width_X + Side2_Thickness + Side4_Thickness : Mount_Width_Y + Side1_Thickness + Side3_Thickness;
    //mountWidth=20, mountingWallThickness=2, mountingWallHeight=20, holeBlockWidth=-1, holeBlockHeight=-1, holeBlockThickness=0, generateComponent = true, generateHole = false
    translate([0,0,0]){
        rotate([0, 0, 0]){
            // mnts_tBScrewHole(mountingWallThickness=mountingWallThickness, width=width, height=Mount_Height, baseThickness=Base_Thickness);
            mnt_tBScrewHole(
                mountWidth=width, 
                mountingWallThickness=mountingWallThickness, 
                mountingWallHeight=Mount_Height, 
                holeBlockWidth=Hole_Block_Width, 
                holeBlockHeight=Hole_Block_Height, 
                holeBlockThickness=Hole_Block_Thickness, 
                generateComponent = true, 
                generateHole = false
            );
        }
    }
}

module boxSideFlat(mountingWallThickness=2, side=1){
    width = (side == 1 || side == 3) ? Mount_Width_X + Side2_Thickness + Side4_Thickness : Mount_Width_Y + Side1_Thickness + Side3_Thickness;
    //xTranslation = (side == 1 || side == 3) ? -width/2 : Side1_Thickness/2-Side4_Thickness/2;
    xTranslation = side == 4 ? (Side1_Thickness/2-Side3_Thickness/2) :
        side == 3 ? -(Side2_Thickness/2-Side4_Thickness/2) :
        side == 2 ? -(Side1_Thickness/2-Side3_Thickness/2) : 
        -(Side4_Thickness/2-Side2_Thickness/2);
    yTranslation = side == 4 ? 0 :
        side == 3 ? (Side2_Thickness/2-Side4_Thickness/2) :
        side == 2 ? (Side2_Thickness/2-Side4_Thickness/2) : 
        -(Side2_Thickness/2-Side4_Thickness/2);
    // yTranslation = (side == 1 || side == 3) ? -width/2 : 0;
    // height = side == 2 ? Mount_Height+10 : Mount_Height;
    height = Mount_Height;
    translate([xTranslation, 0, 0]){
        rotate([90,0,0]){
            cube([width, height, mountingWallThickness], center=true);
        }
    }
}

    
module boxSideSlideLockSlot(mountingWallThickness=2, slotWidthLarge=Slot_Channel_Width_Large_End, slotWidthSmall=Slot_Channel_Width_Small_End, slotDepth=Slot_Depth, slotHeight=Slot_Height, side=1){
    width = (side == 1 || side == 3) ? Mount_Width_X + Side2_Thickness + Side4_Thickness : Mount_Width_Y + Side1_Thickness + Side3_Thickness;
    height = (slotHeight > 0) ? slotHeight : Mount_Height;
    mnt_slideLockSlot(mountingWallThickness = mountingWallThickness, mountWidth = width, mountingWallHeight = Mount_Height, slotWidthLarge = slotWidthLarge, slotWidthSmall = slotWidthSmall, slotDepth = slotDepth, slotHeight = height);
}
    
    
module boxSidePostClip(mountingWallThickness=2, generateFastener=true, generateSideClip=true, side=1){
    width = (side == 1 || side == 3) ? Mount_Width_X + Side2_Thickness + Side4_Thickness : Mount_Width_Y + Side1_Thickness + Side3_Thickness;
    height = (Post_Clip_Height > 0) ? Post_Clip_Height : Mount_Height;
    // mnt_postClip(mountingWallThickness = mountingWallThickness, mountWidth = width, mountingWallHeight = Mount_Height, generateFastener = generateFastener, generateSideClip = generateSideClip, height = height, clipWallThickness=Clip_Wall_Thickness, connectorTolerance = Connector_Tolerance);
    mnt_slideLockFastener(
        mountWidth=width, 
        mountingWallWidthPerArm=Post_Clip_Mounting_Width_Per_Arm, 
        mountingWallThickness=mountingWallThickness, 
        mountingWallHeight=Mount_Height,
        fastenerMountHeight=height, 
        channelWidth=Post_Clip_Channel_Width, 
        channelDepth=Post_Clip_Channel_Depth, 
        channelStopperWallThickness=Post_Clip_Channel_Stopper_Wall_Thickness, 
        outerWallThickness=Post_Clip_Outer_Wall_Thickness, 
        generateFastener = true, 
        generateFastenerClip = true, 
        generateHole = false, 
        connectorClipTolerance = Post_Clip_Connecter_Tolerance, 
        connectorClipThreadboardHole=true
    );
    // mnts_postClip(wallThickness=wallThickness, width=width, height=Mount_Height, baseThickness=Base_Thickness, generateFastener=generateFastener, generateSideClip=generateSideClip);
    
}

module boxSideSimpleHook(mountingWallThickness=2, armWidth=Hook_Arm_Width, openingWidth=Hook_Opening_Width, armThickness=Hook_Arm_Thickness, side=1){
    width = (side == 1 || side == 3) ? Mount_Width_X + Side2_Thickness + Side4_Thickness : Mount_Width_Y + Side1_Thickness + Side3_Thickness;
    mnt_simpleHook(mountingWallThickness = mountingWallThickness, mountWidth = width, mountingWallHeight = Mount_Height, clipArmWidth = armWidth, clipOpeningWidth=openingWidth, clipArmThickness = armThickness);
}

module boxSideRectHolder(mountingWallThickness=2, holderWidth=Rect_Holder_Width, holderHeight=Rect_Holder_Height, holderWallThickness=Rect_Holder_Wall_Thickness, holderDepth=Rect_Holder_Depth, bottomFloor=Rect_Holder_Bottom_Floor, side=1){
    width = (side == 1 || side == 3) ? Mount_Width_X + Side2_Thickness + Side4_Thickness : Mount_Width_Y + Side1_Thickness + Side3_Thickness;
    holderHeight = (holderHeight > 0) ? holderHeight : Mount_Height;
    mnt_rectHolder(
        mountWidth=width, 
        mountingWallThickness=mountingWallThickness, 
        mountingWallHeight=Mount_Height, 
        holderWidth = holderWidth, 
        holderHeight = holderHeight, 
        holderWallThickness = holderWallThickness, 
        holderDepth = holderDepth,
        bottomFloor = bottomFloor
    );
}   

module boxSideCircularHolder(mountingWallThickness=2, holderWidth=Circular_Holder_Diameter, holderHeight=Circular_Holder_Height, holderWallThickness=Circular_Holder_Wall_Thickness, bottomFloor=Circular_Holder_Bottom_Floor, side=1){
    width = (side == 1 || side == 3) ? Mount_Width_X : Mount_Width_Y;
    holderHeight = (holderHeight > 0) ? holderHeight : Mount_Height;
    mnt_circularHolder(
        mountWidth=width, 
        mountingWallThickness=mountingWallThickness, 
        mountingWallHeight=Mount_Height, 
        holderDiameter = holderWidth, 
        holderHeight = holderHeight, 
        holderWallThickness = holderWallThickness, 
        bottomFloor = bottomFloor
    );
}   

testing=false;
if(testing){
    // mnt_slideLockSlot(
    //     mountingWallThickness = 20, 
    //     mountWidth = 40, 
    //     mountingWallHeight = 27, 
    //     slotWidthLarge = 30, 
    //     slotWidthSmall = 5, 
    //     slotDepth = 10, 
    //     slotHeight = 20);


    // mnt_postClip(
    //     mountingWallThickness = 15, 
    //     mountWidth = 30, 
    //     mountingWallHeight = 27, 
    //     generateFastener = true, 
    //     generateSideClip = true, 
    //     width = 25, 
    //     height = 20, 
    //     clipWallThickness=2, 
    //     connectorTolerance = 0.1
    // );

    // mnt_slideLockFastener(
    //     mountWidth=30, 
    //     mountingWallWidthPerArm=4, 
    //     mountingWallThickness=2, 
    //     fastenerMountHeight=30, 
    //     channelWidth=4, 
    //     channelDepth=3, 
    //     channelStopperWallThickness=2, 
    //     outerWallThickness=2,
    //     connectorClipTolerance = 0.15,
    //     generateFastener=true,
    //     generateHole=false,
    //     generateFastenerClip=true
    // );

    // mnt_screwFastener(
    //     mountWidth=20, 
    //     mountingWallThickness=10, 
    //     fastenerWallThickness=2,
    //     fastenerMountHeight=30, 
    //     screwHeadDiameter=6, 
    //     screwHeadDepth=3, 
    //     screwHoleDepth=10, 
    //     generateFastener=true, 
    //     generateHole=false
    // );

    // mnt_TBScrewFastener(
    //     mountWidth=20, 
    //     mountingWallThickness=20, 
    //     fastenerWallThickness=2, 
    //     fastenerMountHeight=20, 
    //     fastenerArmLength = 20, 
    //     generateFastener = true, 
    //     generateHole = false
    // );

    // mnt_tBScrewHole(
    //     mountWidth=30, 
    //     mountingWallThickness=2, 
    //     mountingWallHeight=40, 
    //     holeBlockWidth=25, 
    //     holeBlockHeight=25, 
    //     holeBlockThickness=5, 
    //     generateComponent = Generate_Component, 
    //     generateHole = Generate_Hole
    // );

    // mnt_rectHolder(
    //     mountWidth=30, 
    //     mountingWallThickness=10, 
    //     mountingWallHeight=30, 
    //     holderWidth = 20, 
    //     holderHeight = 20, 
    //     holderWallThickness = 2, 
    //     holderDepth = 40,
    //     bottomFloor = false
    // );


    // mnt_circularHolder(
    //     mountWidth = 20, 
    //     mountingWallHeight=40, 
    //     mountingWallThickness = 10, 
    //     holderDiameter = 40, 
    //     holderHeight = 20, 
    //     holderWallThickness = 1, 
    //     bottomFloor=false
    // );


}

