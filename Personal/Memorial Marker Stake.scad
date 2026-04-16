include <BOSL2/std.scad>

Stake_Arm_Length = 180;




/* [Hidden] */
Stake_Arm_Width = 12;
Stake_Arm_Thickness = 4;

Stake_Inset_Thickness = 4;
Stake_Inset_Depth = 30;
Stake_Inset_Scale = 1.01;

Slot_Channel_Width_Large_End = 20;
Slot_Channel_Width_Small_End = 15;
Slot_Entry_Diameter = Slot_Channel_Width_Large_End + 0;
Slot_Depth = 4;




stakeArms();
head();


// tent(baseWidth=Stake_Arm_Width, height=Stake_Arm_Width, depth=20, center=true);


module stakeArm(){
    translate([-Stake_Arm_Width, 0, -Stake_Arm_Thickness/2]){
        points = [
            [0, 0],
            [Stake_Arm_Width, 0],
            [Stake_Arm_Width, Stake_Arm_Length],
            [Stake_Arm_Width-2, Stake_Arm_Length],
            [0, Stake_Arm_Length-20],
            [0, 0]
        ];
        linear_extrude(height = Stake_Arm_Thickness) {
            polygon(points);    
        } 
    }
}

module stakeArms(){
    stakeArm();
    translate([0, 0, 0]){
        rotate([0, 180, 0]){
            stakeArm();
        }
    }
    translate([0, 0, 0]){
        rotate([0, 90, 0]){
            stakeArm();
        }
    }
}

module head(){
    headLength = Stake_Inset_Depth+Stake_Inset_Thickness*2;
    headWidth = Stake_Arm_Width*2+Stake_Inset_Thickness*2;
    headDepth = Stake_Arm_Width+Stake_Inset_Thickness*2;
    union(){
        translate([0, -(Stake_Inset_Depth+Stake_Inset_Thickness*2)/2, headDepth/2-Stake_Inset_Thickness/2]){
            rotate([0, 0, 0]){
                difference(){
                    cuboid([headWidth, headLength, headDepth], rounding=1, edges=[TOP+LEFT,TOP+RIGHT,TOP+BACK,TOP+FRONT,RIGHT+FRONT,RIGHT+LEFT,LEFT+FRONT,LEFT+BACK,RIGHT+BACK]);
                    scale([Stake_Inset_Scale, Stake_Inset_Scale, Stake_Inset_Scale]){
                        translate([0, -Stake_Arm_Length+headLength/2-Stake_Inset_Thickness, -Stake_Inset_Thickness-1]){
                            rotate([0, 0, 0]){
                                stakeArms();
                            }
                        }
                    }
                    // scale([Stake_Inset_Scale, Stake_Inset_Scale, Stake_Inset_Scale]){
                    //     translate([-4, -17, -1]){
                    //        # color("purple") tetrahedron(tetrahedron_height=10, edge_length=22, baseWidth=30, center=true);
                    //     }
                    // }
                    // scale([Stake_Inset_Scale, Stake_Inset_Scale, Stake_Inset_Scale]){
                        translate([0, -Stake_Inset_Thickness/2-3, -(Stake_Arm_Width-Stake_Inset_Thickness*3/2)/2-0.5]){
                           # color("purple") tent(baseWidth=Stake_Arm_Width*2+2, height=Stake_Arm_Width-Stake_Inset_Thickness, depth=Stake_Inset_Depth-Stake_Inset_Thickness/2, center=true);
                        }
                    // }
                    
                }

            }
        }
        translate([0, -headLength/2, headDepth-Slot_Depth/2]){
            rotate([0, 0, 0]){
                slideLockSlot(slotHeight=headLength-2);
            }
        }
    }
}



module slideLockSlot(slotWidthLarge=Slot_Channel_Width_Large_End, slotWidthSmall=Slot_Channel_Width_Small_End, slotDepth=Slot_Depth, slotHeight=Slot_Height){
    
    pointArrayMultiConnectCompatible=[
        [(slotWidthLarge-slotWidthSmall)/2,0],
        [1, slotDepth-1],
        [1, slotDepth],
        [slotWidthLarge-1, slotDepth],
        [slotWidthLarge-1, slotDepth-1],
        [(slotWidthLarge-slotWidthSmall)/2+slotWidthSmall,0],
        [0,0]
    ];
    
    rotate([0,0,0]){
        translate([-slotWidthLarge/2, 0, 0]){
            rotate([90,0,0]){
                linear_extrude(height=slotHeight, center=true){
                    polygon(points=pointArrayMultiConnectCompatible);
                }
            } 
            // linear_extrude(height=slotDepth*2, center=true){
            //     translate([slotWidthLarge/2, -slotHeight/2-entryHeight/2-slotWidthLarge/2+1, slotDepth]){
            //         hull(){
            //             translate([-slotWidthLarge/4, entryHeight/2, 0]) circle(r=slotWidthLarge/2);  
            //             translate([slotWidthLarge/4, entryHeight/2, 0]) circle(r=slotWidthLarge/2);  
            //             translate([slotWidthLarge/4, -entryHeight/2, 0]) circle(r=slotWidthLarge/2);  
            //             translate([-slotWidthLarge/4, -entryHeight/2, 0]) circle(r=slotWidthLarge/2);  
            //         }
            //     }
            // }
        }
    }
}

module triangularPrism(base_edge=20, prism_length=20, center=false){
    triangle_height = base_edge * sqrt(3) / 2;
    triangle_points = [
        [0, 0],
        [base_edge, 0],
        [base_edge / 2, triangle_height]
    ];

    linear_extrude(height=prism_length, center=center){
        polygon(points=triangle_points);
    }
}

module tetrahedron(tetrahedron_height=20, edge_length=0, center=false, baseWidth=0){
    // edge_length = tetrahedron_height/sqrt(2/3);
    edge_length = edge_length > 0 ? edge_length : tetrahedron_height/sqrt(2/3);
    baseWidth = baseWidth > 0 ? baseWidth : edge_length;
    triangle_height = edge_length * sqrt(3) / 2;
    // tetrahedron_height = edge_length * sqrt(2 / 3);
    

    vertices = [
        [0, 0, 0],
        [baseWidth, 0, 0],
        [(baseWidth) / 2, triangle_height*2, 0],
        [(baseWidth) / 2, triangle_height / 3, tetrahedron_height]
    ];

    faces = [
        [0, 1, 2],
        [0, 1, 3],
        [1, 2, 3],
        [2, 0, 3]
    ];

    if(center){
        translate([-edge_length / 2, -triangle_height / 3, -tetrahedron_height / 4]){
            polyhedron(points=vertices, faces=faces);
        }
    } else {
        polyhedron(points=vertices, faces=faces);
    }
}

module tent(baseWidth=20, height=20, depth=20, center=true){      
    
    points = [
        [-baseWidth/2, 0],
        [baseWidth/2, 0],
        [0, height],
        [-baseWidth/2, 0]
    ];
    rotate([90,0,0]){
        linear_extrude(height = depth, center=center) {
            polygon(points);
        }
    }

}