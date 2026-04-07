include <ThreadBoards/lib/tb_screws.scad>;
include <lib/Mounts.scad>;

Inner_Diameter = 150; //[10:1:350]
Wall_Thickness = 6; //[1:0.5:20]
Height = 50; //[1:1:250]


/* [Quandrant 1] */
Quandrant_1_Component = "none"; //[none:None,tbHole:Thread Board Screw Hole,slideLockMount:Slide Lock Mount,slideLockFastener:Slide Lock Fastener,screwFastener:Screw Fastener,tbScrewFastener:Thread Board Screw Fastener,rectHolder:Rectangular Holder,circularHolder:Circular Holder]
Quandrant_2_Component = "none"; //[none:None,tbHole:Thread Board Screw Hole,slideLockMount:Slide Lock Mount,slideLockFastener:Slide Lock Fastener,screwFastener:Screw Fastener,tbScrewFastener:Thread Board Screw Fastener,rectHolder:Rectangular Holder,circularHolder:Circular Holder]
Quandrant_3_Component = "none"; //[none:None,tbHole:Thread Board Screw Hole,slideLockMount:Slide Lock Mount,slideLockFastener:Slide Lock Fastener,screwFastener:Screw Fastener,tbScrewFastener:Thread Board Screw Fastener,rectHolder:Rectangular Holder,circularHolder:Circular Holder]
Quandrant_4_Component = "none"; //[tbHole:Thread Board Screw Hole,slideLockMount:Slide Lock Mount,slideLockFastener:Slide Lock Fastener,screwFastener:Screw Fastener,tbScrewFastener:Thread Board Screw Fastener,rectHolder:Rectangular Holder,circularHolder:Circular Holder]

/* [Thread Board Screw Parameters] */
TBScrew_Wall_Thickness = 8; //[1:1:20]

/* [Slide Lock Mount Parameters] */
SlideLockMount_Width = 40; //[1:1:250]
SlideLockMount_Height = 40; //[1:1:250]
SlideLockMount_Base_Thickness = 4; //[1:0.5:20]
SlideLockMount_Wall_Thickness = 4; //[1:0.5:20]
SlideLockMount_Slot_Width_Large = 20; //[1:1:100]
SlideLockMount_Slot_Width_Small = 15; //[1:1:100]
SlideLockMount_Slot_Depth = 4; //[0.1:0.1:50]

/* [Slide Lock Fastener Parameters] */
SlideLockFastener_Width = 40;//[1:1:250]
SlideLockFastener_Height = 40;//[1:1:250]
SlideLockFastener_Base_Thickness = 4; //[1:0.5:20]
SlideLockFastener_Wall_Thickness = 4;//[1:0.5:20]
SlideLockFastener_Clip_Tolerance = 0.15; //[0:0.05:5]
SLF_Wall_Offset = 2; //[0:1:30]

/* [Screw Fastener Parameters] */
ScrewFastener_Width = 40;//[1:1:250]
ScrewFastener_Height = 40;//[1:1:250]
ScrewFastener_Base_Thickness = 4; //[1:0.5:20]
ScrewFastener_Arm_Length=40;//[1:1:250]
ScrewFastener_Arm_Thickness=4;//[1:0.5:20]
ScrewFastener_Screw_Hole_Diameter=4; //[0:0.1:20]
ScrewFastener_Screw_Head_Diameter=8; //[0:0.1:50]
ScrewFastener_Screw_Head_Depth=2; //[0:0.1:10]


/* [Thread Board Screw Fastener Parameters] */
TBScrewFastener_Width = 40;//[1:1:250]
TBScrewFastener_Height = 40;//[1:1:250]
TBScrewFastener_Base_Thickness = 4; //[1:0.5:20]
TBScrewFastener_Arm_Length=40;//[1:1:250]
TBScrewFastener_Arm_Thickness=4;//[1:0.5:20]

/* [Rectangular Holder Parameters] */
RH_Mount_Width = 40;//[1:1:250]
RH_Mount_Wall_Thickness = 8;//[1:0.5:20]
RH_Holder_Width = 30;//[1:1:250]
RH_Holder_Height = 30;//[1:1:250]
RH_Holder_Wall_Thickness = 4;//[1:0.5:20]
RH_Holder_Depth = 30;//[1:1:250]

/* [Circular Holder Parameters] */
C_Mount_Width = 12;//[1:1:250]
C_Mount_Wall_Thickness = 8;//[1:0.5:20]
C_Holder_Diameter = 50;//[1:1:250]
C_Holder_Height = 30;//[1:1:250]
C_Holder_Wall_Thickness = 4;//[1:0.5:20]

/* [Hidden] */
Outer_Diameter = Inner_Diameter + 2*Wall_Thickness;


fullBaseCircularMount();


// mnts_screwFastener();

module fullBaseCircularMount(){

         
        difference(){
            cylinder(d=Outer_Diameter, h=Height, center=true);
            cylinder(d=Inner_Diameter, h=Height+2, center=true);
            // Subtraction of tbHole Components
            if(Quandrant_1_Component == "tbHole"){
                q1WallThickness = Wall_Thickness + TBScrew_Wall_Thickness;
                translate([Inner_Diameter/2+q1WallThickness/2, 0, 0]){
                    tbScrewHole(zRotation=90, qWallThickness=q1WallThickness, generateComponent=false, generateHole=true);
                }
            }
            if(Quandrant_2_Component == "tbHole"){
                q2WallThickness = Wall_Thickness + TBScrew_Wall_Thickness;
                translate([0, -Inner_Diameter/2-q2WallThickness/2, 0]){
                    tbScrewHole(zRotation=0, qWallThickness=q2WallThickness, generateComponent=false, generateHole=true);
                }
            }
            if(Quandrant_3_Component == "tbHole"){
                q3WallThickness = Wall_Thickness + TBScrew_Wall_Thickness;
                translate([-Inner_Diameter/2-q3WallThickness/2, 0, 0]){
                    tbScrewHole(zRotation=90, qWallThickness=q3WallThickness, generateComponent=false, generateHole=true);
                }
            }
            if(Quandrant_4_Component == "tbHole"){
                q4WallThickness = Wall_Thickness + TBScrew_Wall_Thickness;
                translate([0, Inner_Diameter/2+q4WallThickness/2, 0]){
                    tbScrewHole(zRotation=0, qWallThickness=q4WallThickness, generateComponent=false, generateHole=true);
                }
            }

            // Subtraction of slideLockFastener Components
            slFullThickness = Wall_Thickness + SlideLockFastener_Wall_Thickness*2 + SlideLockFastener_Clip_Tolerance;
            if(Quandrant_1_Component == "slideLockFastener"){
                translate([Inner_Diameter/2, 0, 0]){
                    rotate([0, 0, 90]){
                        mnts_slideLockFastener(mountingWallThickness=Wall_Thickness, fastenerWallThickness=SlideLockFastener_Wall_Thickness, clipWallThickness=SlideLockFastener_Wall_Thickness, generateFastener=false, generateSideClip=false, generateHole=true, width=SlideLockFastener_Width, height=Height, connectorClipTolerance=SlideLockFastener_Clip_Tolerance, wallOffset=SLF_Wall_Offset);
                    }
                }
            }
            if(Quandrant_2_Component == "slideLockFastener"){
                translate([0, -(Inner_Diameter/2), 0]){
                    rotate([0, 0, 0]){
                        mnts_slideLockFastener(mountingWallThickness=Wall_Thickness, fastenerWallThickness=SlideLockFastener_Wall_Thickness, clipWallThickness=SlideLockFastener_Wall_Thickness, generateFastener=false, generateSideClip=false, generateHole=true, width=SlideLockFastener_Width, height=Height, connectorClipTolerance=SlideLockFastener_Clip_Tolerance, wallOffset=SLF_Wall_Offset);
                    }
                }
            }
            if(Quandrant_3_Component == "slideLockFastener"){
                translate([-(Inner_Diameter/2), 0, 0]){
                    rotate([0, 0, -90]){
                        mnts_slideLockFastener(mountingWallThickness=Wall_Thickness, fastenerWallThickness=SlideLockFastener_Wall_Thickness, clipWallThickness=SlideLockFastener_Wall_Thickness, generateFastener=false, generateSideClip=false, generateHole=true, width=SlideLockFastener_Width, height=Height, connectorClipTolerance=SlideLockFastener_Clip_Tolerance, wallOffset=SLF_Wall_Offset);
                    }
                }
            }
            if(Quandrant_4_Component == "slideLockFastener"){
                translate([0,(Inner_Diameter/2), 0]){
                    rotate([0, 0, 180]){
                        mnts_slideLockFastener(mountingWallThickness=Wall_Thickness, fastenerWallThickness=SlideLockFastener_Wall_Thickness, clipWallThickness=SlideLockFastener_Wall_Thickness, generateFastener=false, generateSideClip=false, generateHole=true, width=SlideLockFastener_Width, height=Height, connectorClipTolerance=SlideLockFastener_Clip_Tolerance, wallOffset=SLF_Wall_Offset);
                    }
                }
            }


            // Subtraction of screwFastener Components
            if(Quandrant_1_Component == "screwFastener"){
                translate([Inner_Diameter/2, 0, 0]){
                    rotate([0, 0, 90]){
                        mnts_screwFastener(width=ScrewFastener_Width, height=Height, mountingWallThickness=Wall_Thickness, fastenerWallThickness=ScrewFastener_Arm_Thickness,fastenerArmLength=ScrewFastener_Arm_Length, screwHoleDiameter=ScrewFastener_Screw_Hole_Diameter, screwHoleDepth=ScrewFastener_Arm_Thickness, screwHeadDiameter=ScrewFastener_Screw_Head_Diameter, screwHeadDepth=ScrewFastener_Screw_Head_Depth, generateFastener=false, generateHole=true);
                    }
                }
            }
            if(Quandrant_2_Component == "screwFastener"){
                translate([0, -(Inner_Diameter/2), 0]){
                    rotate([0, 0, 0]){
                        mnts_screwFastener(width=ScrewFastener_Width, height=Height, mountingWallThickness=Wall_Thickness, fastenerWallThickness=ScrewFastener_Arm_Thickness,fastenerArmLength=ScrewFastener_Arm_Length, screwHoleDiameter=ScrewFastener_Screw_Hole_Diameter, screwHoleDepth=ScrewFastener_Arm_Thickness, screwHeadDiameter=ScrewFastener_Screw_Head_Diameter, screwHeadDepth=ScrewFastener_Screw_Head_Depth, generateFastener=false, generateHole=true);
                    }
                }
            }
            if(Quandrant_3_Component == "screwFastener"){
                translate([-(Inner_Diameter/2), 0, 0]){
                    rotate([0, 0, -90]){
                        mnts_screwFastener(width=ScrewFastener_Width, height=Height, mountingWallThickness=Wall_Thickness, fastenerWallThickness=ScrewFastener_Arm_Thickness,fastenerArmLength=ScrewFastener_Arm_Length, screwHoleDiameter=ScrewFastener_Screw_Hole_Diameter, screwHoleDepth=ScrewFastener_Arm_Thickness, screwHeadDiameter=ScrewFastener_Screw_Head_Diameter, screwHeadDepth=ScrewFastener_Screw_Head_Depth, generateFastener=false, generateHole=true);
                    }
                }
            }
            if(Quandrant_4_Component == "screwFastener"){
                translate([0,(Inner_Diameter/2), 0]){
                    rotate([0, 0, 180]){
                        mnts_screwFastener(width=ScrewFastener_Width, height=Height, mountingWallThickness=Wall_Thickness, fastenerWallThickness=ScrewFastener_Arm_Thickness,fastenerArmLength=ScrewFastener_Arm_Length, screwHoleDiameter=ScrewFastener_Screw_Hole_Diameter, screwHoleDepth=ScrewFastener_Arm_Thickness, screwHeadDiameter=ScrewFastener_Screw_Head_Diameter, screwHeadDepth=ScrewFastener_Screw_Head_Depth, generateFastener=false, generateHole=true);
                    }
                }
            }

            //Subtraction of TB Screw Fastener Components
            if(Quandrant_1_Component == "tbScrewFastener"){
                translate([Inner_Diameter/2, 0, 0]){
                    rotate([0, 0, 90]){
                        mnts_TBScrewFastener(width=TBScrewFastener_Width, height=Height, mountingWallThickness=Wall_Thickness, fastenerWallThickness=TBScrewFastener_Arm_Thickness,fastenerArmLength=TBScrewFastener_Arm_Length, generateFastener=false, generateTBScrew=false, generateHole=true);
                    }
                }
            }
            if(Quandrant_2_Component == "tbScrewFastener"){
                translate([0, -(Inner_Diameter/2), 0]){
                    rotate([0, 0, 0]){
                        mnts_TBScrewFastener(width=TBScrewFastener_Width, height=Height, mountingWallThickness=Wall_Thickness, fastenerWallThickness=TBScrewFastener_Arm_Thickness,fastenerArmLength=TBScrewFastener_Arm_Length, generateFastener=false, generateTBScrew=false, generateHole=true);
                    }
                }
            }
            if(Quandrant_3_Component == "tbScrewFastener"){
                translate([-(Inner_Diameter/2), 0, 0]){
                    rotate([0, 0, -90]){
                        mnts_TBScrewFastener(width=TBScrewFastener_Width, height=Height, mountingWallThickness=Wall_Thickness, fastenerWallThickness=TBScrewFastener_Arm_Thickness,fastenerArmLength=TBScrewFastener_Arm_Length, generateFastener=false, generateTBScrew=false, generateHole=true);
                    }
                }
            }
            if(Quandrant_4_Component == "tbScrewFastener"){
                translate([0,(Inner_Diameter/2), 0]){
                    rotate([0, 0, 180]){
                        mnts_TBScrewFastener(width=TBScrewFastener_Width, height=Height, mountingWallThickness=Wall_Thickness, fastenerWallThickness=TBScrewFastener_Arm_Thickness,fastenerArmLength=TBScrewFastener_Arm_Length, generateFastener=false, generateTBScrew=false, generateHole=true);
                    }
                }
            }
        }
        

    // Components
    if($preview){
        translate([Outer_Diameter/2, Outer_Diameter/6, Height/2]) {
            rotate([90, 0, 90]) color("purple") text("1");
        }
        translate([Outer_Diameter/6, -Outer_Diameter/2, Height/2]) {
            rotate([90, 0, 0]) color("purple") text("2");
        }
        translate([-Outer_Diameter/2, -Outer_Diameter/6, Height/2]) {
            rotate([90, 0, -90]) color("purple") text("3");
        }
        translate([-Outer_Diameter/6, Outer_Diameter/2, Height/2]) {
            rotate([90, 0, 180]) color("purple") text("4");
        }
    }


    if(Quandrant_1_Component == "tbHole"){
        q1WallThickness = Wall_Thickness + TBScrew_Wall_Thickness;
        translate([Inner_Diameter/2+q1WallThickness/2, 0, 0]){
            tbScrewHole(zRotation=90, qWallThickness=q1WallThickness, generateComponent=true, generateHole=false);
        }
    }
    if(Quandrant_2_Component == "tbHole"){
        q2WallThickness = Wall_Thickness + TBScrew_Wall_Thickness;
        translate([0, -Inner_Diameter/2-q2WallThickness/2, 0]){
            tbScrewHole(zRotation=0, qWallThickness=q2WallThickness, generateComponent=true, generateHole=false);
        }
    }
    if(Quandrant_3_Component == "tbHole"){
        q3WallThickness = Wall_Thickness + TBScrew_Wall_Thickness;
        translate([-Inner_Diameter/2-q3WallThickness/2, 0, 0]){
            tbScrewHole(zRotation=90, qWallThickness=q3WallThickness, generateComponent=true, generateHole=false);
        }
    }
    if(Quandrant_4_Component == "tbHole"){
        q4WallThickness = Wall_Thickness + TBScrew_Wall_Thickness;
        translate([0, Inner_Diameter/2+q4WallThickness/2, 0]){
            tbScrewHole(zRotation=0, qWallThickness=q4WallThickness, generateComponent=true, generateHole=false);
        }
    }


    

    if(Quandrant_1_Component == "slideLockMount"){
        qWallThickness = Wall_Thickness + SlideLockMount_Wall_Thickness;
        translate([Inner_Diameter/2+qWallThickness/2, 0, -Height/2+SlideLockMount_Height/2]){
            rotate([0, 0, 90]){
                mnts_slideLockSlot(wallThickness=SlideLockMount_Wall_Thickness, width=SlideLockMount_Width, height=SlideLockMount_Height, slotWidthLarge=SlideLockMount_Slot_Width_Large, slotWidthSmall=SlideLockMount_Slot_Width_Small, slotDepth=SlideLockMount_Slot_Depth, slotHeight=SlideLockMount_Height, baseThickness=Wall_Thickness);
            }
        }
    }
    if(Quandrant_2_Component == "slideLockMount"){
        qWallThickness = Wall_Thickness + SlideLockMount_Wall_Thickness;
        translate([0, -(Inner_Diameter/2+qWallThickness/2), -Height/2+SlideLockMount_Height/2]){
            rotate([0, 0, 0]){
                mnts_slideLockSlot(wallThickness=SlideLockMount_Wall_Thickness, width=SlideLockMount_Width, height=SlideLockMount_Height, slotWidthLarge=SlideLockMount_Slot_Width_Large, slotWidthSmall=SlideLockMount_Slot_Width_Small, slotDepth=SlideLockMount_Slot_Depth, slotHeight=SlideLockMount_Height, baseThickness=Wall_Thickness);
            }
        }
    }
    if(Quandrant_3_Component == "slideLockMount"){
        qWallThickness = Wall_Thickness + SlideLockMount_Wall_Thickness;
        translate([-(Inner_Diameter/2+qWallThickness/2), 0, -Height/2+SlideLockMount_Height/2]){
            rotate([0, 0, -90]){
                mnts_slideLockSlot(wallThickness=SlideLockMount_Wall_Thickness, width=SlideLockMount_Width, height=SlideLockMount_Height, slotWidthLarge=SlideLockMount_Slot_Width_Large, slotWidthSmall=SlideLockMount_Slot_Width_Small, slotDepth=SlideLockMount_Slot_Depth, slotHeight=SlideLockMount_Height, baseThickness=Wall_Thickness);
            }
        }
    }
    if(Quandrant_4_Component == "slideLockMount"){
        qWallThickness = Wall_Thickness + SlideLockMount_Wall_Thickness;
        translate([0,(Inner_Diameter/2+qWallThickness/2), -Height/2+SlideLockMount_Height/2]){
            rotate([0, 0, 180]){
                mnts_slideLockSlot(wallThickness=SlideLockMount_Wall_Thickness, width=SlideLockMount_Width, height=SlideLockMount_Height, slotWidthLarge=SlideLockMount_Slot_Width_Large, slotWidthSmall=SlideLockMount_Slot_Width_Small, slotDepth=SlideLockMount_Slot_Depth, slotHeight=SlideLockMount_Height, baseThickness=Wall_Thickness);
            }
        }
    }


    //Slide Lock Fasteners
    slFullThickness = SlideLockFastener_Base_Thickness + SlideLockFastener_Wall_Thickness*2 + SlideLockFastener_Clip_Tolerance;
    if(Quandrant_1_Component == "slideLockFastener"){
        translate([Inner_Diameter/2+slFullThickness/2, 0, -Height/2+SlideLockFastener_Height/2]){
            rotate([0, 0, 90]){
                mnts_slideLockFastener(mountingWallThickness=SlideLockFastener_Base_Thickness, fastenerWallThickness=SlideLockFastener_Wall_Thickness, clipWallThickness=SlideLockFastener_Wall_Thickness, generateFastener=true, generateSideClip=true, generateHole=false, width=SlideLockFastener_Width, height=SlideLockFastener_Height, connectorClipTolerance=SlideLockFastener_Clip_Tolerance, wallOffset=SLF_Wall_Offset);
            }
        }
    }
    if(Quandrant_2_Component == "slideLockFastener"){
        translate([0, -(Inner_Diameter/2+slFullThickness/2), -Height/2+SlideLockFastener_Height/2]){
            rotate([0, 0, 0]){
                mnts_slideLockFastener(mountingWallThickness=SlideLockFastener_Base_Thickness, fastenerWallThickness=SlideLockFastener_Wall_Thickness, clipWallThickness=SlideLockFastener_Wall_Thickness, generateFastener=true, generateSideClip=true, generateHole=false, width=SlideLockFastener_Width, height=SlideLockFastener_Height, connectorClipTolerance=SlideLockFastener_Clip_Tolerance, wallOffset=SLF_Wall_Offset);
            }
        }
    }
    if(Quandrant_3_Component == "slideLockFastener"){
        translate([-(Inner_Diameter/2+slFullThickness/2), 0, -Height/2+SlideLockFastener_Height/2]){
            rotate([0, 0, -90]){
                mnts_slideLockFastener(mountingWallThickness=SlideLockFastener_Base_Thickness, fastenerWallThickness=SlideLockFastener_Wall_Thickness, clipWallThickness=SlideLockFastener_Wall_Thickness, generateFastener=true, generateSideClip=true, generateHole=false, width=SlideLockFastener_Width, height=SlideLockFastener_Height, connectorClipTolerance=SlideLockFastener_Clip_Tolerance, wallOffset=SLF_Wall_Offset);
            }
        }
    }
    if(Quandrant_4_Component == "slideLockFastener"){
        translate([0,(Inner_Diameter/2+slFullThickness/2), -Height/2+SlideLockFastener_Height/2]){
            rotate([0, 0, 180]){
                mnts_slideLockFastener(mountingWallThickness=SlideLockFastener_Base_Thickness, fastenerWallThickness=SlideLockFastener_Wall_Thickness, clipWallThickness=SlideLockFastener_Wall_Thickness, generateFastener=true, generateSideClip=true, generateHole=false, width=SlideLockFastener_Width, height=SlideLockFastener_Height, connectorClipTolerance=SlideLockFastener_Clip_Tolerance, wallOffset=SLF_Wall_Offset);
            }
        }
    }


    //Screw Fasteners
    slFullLength = ScrewFastener_Base_Thickness + ScrewFastener_Arm_Length;
    if(Quandrant_1_Component == "screwFastener"){
        translate([Inner_Diameter/2+slFullLength-ScrewFastener_Base_Thickness, 0, -Height/2+ScrewFastener_Height/2]){
            rotate([0, 0, 90]){
                mnts_screwFastener(width=ScrewFastener_Width, height=ScrewFastener_Height, mountingWallThickness=ScrewFastener_Base_Thickness, fastenerWallThickness=ScrewFastener_Arm_Thickness,fastenerArmLength=ScrewFastener_Arm_Length, screwHoleDiameter=ScrewFastener_Screw_Hole_Diameter, screwHoleDepth=ScrewFastener_Arm_Thickness-ScrewFastener_Screw_Head_Depth, screwHeadDiameter=ScrewFastener_Screw_Head_Diameter, screwHeadDepth=ScrewFastener_Screw_Head_Depth, generateFastener=true, generateHole=false);
            }
        }
    }
    if(Quandrant_2_Component == "screwFastener"){
        translate([0, -(Inner_Diameter/2+slFullLength-ScrewFastener_Base_Thickness), -Height/2+ScrewFastener_Height/2]){
            rotate([0, 0, 0]){
                mnts_screwFastener(width=ScrewFastener_Width, height=ScrewFastener_Height, mountingWallThickness=ScrewFastener_Base_Thickness, fastenerWallThickness=ScrewFastener_Arm_Thickness,fastenerArmLength=ScrewFastener_Arm_Length, screwHoleDiameter=ScrewFastener_Screw_Hole_Diameter, screwHoleDepth=ScrewFastener_Arm_Thickness-ScrewFastener_Screw_Head_Depth, screwHeadDiameter=ScrewFastener_Screw_Head_Diameter, screwHeadDepth=ScrewFastener_Screw_Head_Depth, generateFastener=true, generateHole=false);
            }
        }
    }
    if(Quandrant_3_Component == "screwFastener"){
        translate([-(Inner_Diameter/2+slFullLength-ScrewFastener_Base_Thickness), 0, -Height/2+ScrewFastener_Height/2]){
            rotate([0, 0, -90]){
                mnts_screwFastener(width=ScrewFastener_Width, height=ScrewFastener_Height, mountingWallThickness=ScrewFastener_Base_Thickness, fastenerWallThickness=ScrewFastener_Arm_Thickness,fastenerArmLength=ScrewFastener_Arm_Length, screwHoleDiameter=ScrewFastener_Screw_Hole_Diameter, screwHoleDepth=ScrewFastener_Arm_Thickness-ScrewFastener_Screw_Head_Depth, screwHeadDiameter=ScrewFastener_Screw_Head_Diameter, screwHeadDepth=ScrewFastener_Screw_Head_Depth, generateFastener=true, generateHole=false);
            }
        }
    }
    if(Quandrant_4_Component == "screwFastener"){
        translate([0,(Inner_Diameter/2+slFullLength-ScrewFastener_Base_Thickness), -Height/2+ScrewFastener_Height/2]){
            rotate([0, 0, 180]){
                mnts_screwFastener(width=ScrewFastener_Width, height=ScrewFastener_Height, mountingWallThickness=ScrewFastener_Base_Thickness, fastenerWallThickness=ScrewFastener_Arm_Thickness,fastenerArmLength=ScrewFastener_Arm_Length, screwHoleDiameter=ScrewFastener_Screw_Hole_Diameter, screwHoleDepth=ScrewFastener_Arm_Thickness-ScrewFastener_Screw_Head_Depth, screwHeadDiameter=ScrewFastener_Screw_Head_Diameter, screwHeadDepth=ScrewFastener_Screw_Head_Depth, generateFastener=true, generateHole=false);
            }
        }
    }

    //TB Screw Fasteners
    tbslFullLength = ScrewFastener_Base_Thickness + ScrewFastener_Arm_Length;
    if(Quandrant_1_Component == "tbScrewFastener"){
        translate([Inner_Diameter/2+tbslFullLength-ScrewFastener_Base_Thickness, 0, -Height/2+TBScrewFastener_Height/2]){
            rotate([0, 0, 90]){
                mnts_TBScrewFastener(width=TBScrewFastener_Width, height=TBScrewFastener_Height, mountingWallThickness=TBScrewFastener_Base_Thickness, fastenerWallThickness=TBScrewFastener_Arm_Thickness,fastenerArmLength=TBScrewFastener_Arm_Length, generateFastener=true, generateTBScrew=true, generateHole=false);
            }
        }
    }
    if(Quandrant_2_Component == "tbScrewFastener"){
        translate([0, -(Inner_Diameter/2+tbslFullLength-ScrewFastener_Base_Thickness), -Height/2+TBScrewFastener_Height/2]){
            rotate([0, 0, 0]){
                mnts_TBScrewFastener(width=TBScrewFastener_Width, height=TBScrewFastener_Height, mountingWallThickness=TBScrewFastener_Base_Thickness, fastenerWallThickness=TBScrewFastener_Arm_Thickness,fastenerArmLength=TBScrewFastener_Arm_Length, generateFastener=true, generateTBScrew=true, generateHole=false);
            }
        }
    }
    if(Quandrant_3_Component == "tbScrewFastener"){
        translate([-(Inner_Diameter/2+tbslFullLength-ScrewFastener_Base_Thickness), 0, -Height/2+TBScrewFastener_Height/2]){
            rotate([0, 0, -90]){
                mnts_TBScrewFastener(width=TBScrewFastener_Width, height=TBScrewFastener_Height, mountingWallThickness=TBScrewFastener_Base_Thickness, fastenerWallThickness=TBScrewFastener_Arm_Thickness,fastenerArmLength=TBScrewFastener_Arm_Length, generateFastener=true, generateTBScrew=true, generateHole=false);
            }
        }
    }
    if(Quandrant_4_Component == "tbScrewFastener"){
        translate([0,(Inner_Diameter/2+tbslFullLength-ScrewFastener_Base_Thickness), -Height/2+TBScrewFastener_Height/2]){
            rotate([0, 0, 180]){
                mnts_TBScrewFastener(width=TBScrewFastener_Width, height=TBScrewFastener_Height, mountingWallThickness=TBScrewFastener_Base_Thickness, fastenerWallThickness=TBScrewFastener_Arm_Thickness,fastenerArmLength=TBScrewFastener_Arm_Length, generateFastener=true, generateTBScrew=true, generateHole=false);
            }
        }
    }



    //Rectangular Holder Fasteners
    if(Quandrant_1_Component == "rectHolder"){
        translate([Outer_Diameter/2-Wall_Thickness/2, 0, -Height/2]){
            rotate([0, 0, 90]){
                mnts_rectHolder(mountWidth=RH_Mount_Width, mountHeight=Height, mountingWallThickness=RH_Mount_Wall_Thickness, holderWidth=RH_Holder_Width, holderHeight=RH_Holder_Height, holderWallThickness=RH_Holder_Wall_Thickness, holderDepth=RH_Holder_Depth);
            }
        }
    }
    if(Quandrant_2_Component == "rectHolder"){
        translate([0, -(Inner_Diameter/2+Wall_Thickness/2), -Height/2]){
            rotate([0, 0, 0]){
                mnts_rectHolder(mountWidth=RH_Mount_Width, mountHeight=Height, mountingWallThickness=RH_Mount_Wall_Thickness, holderWidth=RH_Holder_Width, holderHeight=RH_Holder_Height, holderWallThickness=RH_Holder_Wall_Thickness, holderDepth=RH_Holder_Depth);
            }
        }
    }
    if(Quandrant_3_Component == "rectHolder"){
        translate([-(Inner_Diameter/2+Wall_Thickness/2), 0, -Height/2]){
            rotate([0, 0, -90]){
                mnts_rectHolder(mountWidth=RH_Mount_Width, mountHeight=Height, mountingWallThickness=RH_Mount_Wall_Thickness, holderWidth=RH_Holder_Width, holderHeight=RH_Holder_Height, holderWallThickness=RH_Holder_Wall_Thickness, holderDepth=RH_Holder_Depth);
            }
        }
    }
    if(Quandrant_4_Component == "rectHolder"){
        translate([0,(Inner_Diameter/2+Wall_Thickness/2), -Height/2]){
            rotate([0, 0, 180]){
                mnts_rectHolder(mountWidth=RH_Mount_Width, mountHeight=Height, mountingWallThickness=RH_Mount_Wall_Thickness, holderWidth=RH_Holder_Width, holderHeight=RH_Holder_Height, holderWallThickness=RH_Holder_Wall_Thickness, holderDepth=RH_Holder_Depth);
            }
        }
    }



    //Circular Holder Fasteners
    if(Quandrant_1_Component == "circularHolder"){
        translate([Outer_Diameter/2-Wall_Thickness/2, 0, -Height/2]){
            rotate([0, 0, 90]){
                mnts_circularHolder(mountWidth=C_Mount_Width, mountHeight=Height, mountingWallThickness=C_Mount_Wall_Thickness, holderDiameter=C_Holder_Diameter, holderHeight=C_Holder_Height, holderWallThickness=C_Holder_Wall_Thickness);
            }
        }
    }
    if(Quandrant_2_Component == "circularHolder"){
        translate([0, -(Inner_Diameter/2+Wall_Thickness/2), -Height/2]){
            rotate([0, 0, 0]){
                mnts_circularHolder(mountWidth=C_Mount_Width, mountHeight=Height, mountingWallThickness=C_Mount_Wall_Thickness, holderDiameter=C_Holder_Diameter, holderHeight=C_Holder_Height, holderWallThickness=C_Holder_Wall_Thickness);
            }
        }
    }
    if(Quandrant_3_Component == "circularHolder"){
        translate([-(Inner_Diameter/2+Wall_Thickness/2), 0, -Height/2]){
            rotate([0, 0, -90]){
                mnts_circularHolder(mountWidth=C_Mount_Width, mountHeight=Height, mountingWallThickness=C_Mount_Wall_Thickness, holderDiameter=C_Holder_Diameter, holderHeight=C_Holder_Height, holderWallThickness=C_Holder_Wall_Thickness);
            }
        }
    }
    if(Quandrant_4_Component == "circularHolder"){
        translate([0,(Inner_Diameter/2+Wall_Thickness/2), -Height/2]){
            rotate([0, 0, 180]){
                mnts_circularHolder(mountWidth=C_Mount_Width, mountHeight=Height, mountingWallThickness=C_Mount_Wall_Thickness, holderDiameter=C_Holder_Diameter, holderHeight=C_Holder_Height, holderWallThickness=C_Holder_Wall_Thickness);
            }
        }
    }


}


module tbScrewHole(zRotation=0, qWallThickness=2, generateComponent=true, generateHole=false){
    headPadding = 8;
    width = TB_SCREW_Head_Hex_Radius*2+headPadding;
    height = min((width + Height)/2+headPadding/2, Height);
    echo("Height: ", height);
    rotate([90, 0, zRotation]){
        //threadedRodForHole(length = qWallThickness+Wall_Thickness, center = true, tolerance = 0.2, hole_radius=TB_SCREW_Threaded_Rod_Diameter/2);
        mnts_tBScrewHole(wallThickness=0, width=width, baseThickness=qWallThickness, height=height, wallHeight=Height, zRotation=0, holeLength=qWallThickness+1, generateComponent=generateComponent, generateHole=generateHole);
    }
}