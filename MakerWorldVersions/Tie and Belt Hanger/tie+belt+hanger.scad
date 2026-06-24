include <BOSL2/std.scad>

// Number of columns of tie slots
Num_Slots_Wide = 1; //[1:1:3]
// Number of rows of tie slots
Num_Slots_Tall = 5; //[1:1:15]
// Space between each slot arm
Slot_Height = 15; //[5:1:30]
// Length of each slot arm
Arm_Length = 60; //[20:1:100]
// Thickness of the hanger components
Arm_Thickness = 6; //[2:1:10]
// Inner Diameter of the hanger hook
Inner_Hanger_Hook_Diameter = 40; //[10:1:60]


/* [Hidden] */
X = 0;
Y = 1;
Z = 2;
Arm_Rounding=2;
$fn = 50;
Outer_Arm_Brace_Length = Slot_Height + Arm_Thickness*2;
Hanger_Hook_Diameter = Inner_Hanger_Hook_Diameter + Arm_Thickness*2;


hanger();

// slotArm(openingSide="left", length=[Arm_Length, Arm_Thickness, Arm_Thickness], rounding=Arm_Rounding, center=false);

// Hook oriented so the opening faces straight down (-Y).
// Rotate 45° so the gap (between 270° and 360°) is centred on the -Y axis.
// rotate([0, 0, 0])
//     hangerHook();

// hangerHook: 3/4 hollow circular arc for hanging on a rod.
//   diameter  – inner diameter of the rod clearance circle
//   lineWidth – wall thickness of the arc (radial)
//   lineHeight – height of the arc cross-section (Z)
//   Open ends are capped with spheres so the Z edges are rounded.
module hangerHook(diameter=40, lineWidth=Arm_Thickness, lineHeight=Arm_Thickness, angle=255) {
    outerR = diameter / 2;
    innerR = outerR - lineWidth;
    midR   = (outerR + innerR) / 2;
    capR   = min(lineWidth, lineHeight) / 2;
    hangerStaffLength = lineWidth*3;
        

    translate([0, diameter/2+hangerStaffLength/2+lineWidth/2, lineHeight]){
        rotate([0, 180, -15]){
            union() {
                // 270-degree hollow arc swept around Z
                rotate_extrude(angle=angle, $fn=$fn)
                    translate([innerR, 0, 0])
                        square([lineWidth, lineHeight]);

                // Rounded cap at arc start (angle=0 → +X direction)
                translate([midR, 0, lineHeight / 2])
                    // sphere(r=capR, $fn=$fn);
                    cuboid([lineWidth, lineWidth, lineHeight], rounding=capR, edges="Z", $fn=$fn);

                // Rounded cap at arc end (angle=270 → -Y direction)
                // translate([0, -midR, lineHeight / 2])
                //     cuboid([lineWidth, lineWidth, lineHeight], rounding=capR, edges="Z", $fn=$fn);
            }
        }
        translate([0, -diameter/2 - lineWidth/2, -lineHeight/2]){
            cuboid([lineWidth, hangerStaffLength, lineHeight], rounding=lineWidth/3, edges="Z", $fn=$fn);
        }
    }
    
    
}

module slotArm(openingSide="left", length=[40, 8, 8], slotHeight=Slot_Height, rounding=3, center=false){
    endLipLength = length[Y]*2;
    braceLength = Outer_Arm_Brace_Length;
    transX = center ? 0 : length[X]/2;
    transY = center ? -braceLength/2 + length[Y]/2 : -braceLength+length[Y]/2;
    transZ = center ? 0 : length[Z]/2;
    translate([transX, transY, transZ]){
        rotate([0, openingSide=="right" ? 180 : 0, 0]){
            union(){
                cuboid(length, rounding=rounding, edges="Z", $fn=$fn);
                if(openingSide!="none"){
                    translate([-length[X]/2+length[Y]/2, endLipLength/2-length[Y]/2, 0]){
                        cuboid([length[Y], endLipLength, length[Z]], rounding=rounding, edges="Z", $fn=$fn);
                    }
                    
                    translate([length[X]/2-length[Y]/2, braceLength/2-length[Y]/2, 0]){
                        cuboid([length[Y], braceLength, length[Z]], rounding=rounding, edges="Z", $fn=$fn);
                    }
                }
                
            }
        }
    }
}

module hangerBrace(numSlotsWide=1, braceHeight=8, braceWidth=8, rounding=3){
    braceLength = numSlotsWide * Arm_Length - (numSlotsWide > 1 ? Arm_Thickness : 0);
    translate([0, 0, braceHeight/2]){
        cuboid([braceLength, braceWidth, braceHeight], rounding=rounding, edges="Z");
    }

}

module hanger(numSlotsWide=Num_Slots_Wide, numSlotsTall=Num_Slots_Tall){
    hangerHook(diameter=Hanger_Hook_Diameter, lineWidth=Arm_Thickness, lineHeight=Arm_Thickness, angle=255);
    hangerBrace(numSlotsWide = numSlotsWide, braceHeight = Arm_Thickness, braceWidth = Arm_Thickness, rounding=Arm_Rounding);
    slotTransX = -Arm_Length/2 * numSlotsWide - (numSlotsWide == 1 ? Arm_Thickness : 0);
    slotTransY = 0;
    translate([slotTransX, slotTransY, 0]){
        for(i=[0:numSlotsWide-1]){
            for(j=[0:numSlotsTall-1]){
                openingDirection = i == 0 ? "left" : i == numSlotsWide-1 ? "right" : "none";
                xAdj = i == 0 ? Arm_Thickness/numSlotsWide : i == numSlotsWide-1 ? -Arm_Thickness/numSlotsWide : 0;
                translate([i*Arm_Length+xAdj, -j*Outer_Arm_Brace_Length + j*Arm_Thickness, 0]){
                    slotArm(openingSide=openingDirection, length=[Arm_Length, Arm_Thickness, Arm_Thickness], rounding=Arm_Rounding, center=false);
                }
            }  
        }
    }
}