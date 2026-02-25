Stl = "/Users/john.andersen/Downloads/AmberPic1_Front_133x200.stl";

Show_Components = "both"; //[both:Both, sign:Sign only, slot:Slot only]


/* [Slot Parameters] */
Slot_Height = 30;
Slot_Tolerance = 1.4; //[0:0.1:5]
Slot_Entry_Height = 25;

Slot_Offset = [0,0,0];  //[0:0.1:100] 
Slot_Rotation = [0,0,0];



/* [Hidden] */
// Slot_Offset_X = 0;
// Slot_Offset_Y = 0;
// Slot_Offset_Z = 0;

Show_Slot_For_Reference = true;
Slot_Channel_Width_Large_End = 20;
Slot_Channel_Width_Small_End = 15;
Slot_Entry_Diameter = Slot_Channel_Width_Large_End + 2;
Slot_Depth = 4;


if(Show_Components == "both" || Show_Components == "sign"){
    if(Show_Components == "both"){
        difference(){
            # sign();
            color("yellow") slot();
        }
    } else {
        sign();
    }
} else if(Show_Components == "slot"){
    slot();
}


module sign(){
    translate([0, 0, 0]){
        rotate([0, 0, 0]){
            import(file=Stl, convexity=10, center=true);
        }
    }
}


module slot(){
    translate(Slot_Offset+[0,0,-Slot_Depth*2+2]){
        rotate(Slot_Rotation+[-90, 0, 0]){
            slideLockSlot();
        }
    }
}

module mainOld(){
    translate(Slot_Offset){
        rotate(Slot_Rotation){
            difference(){
                rotate([90, 0, 0])
                    import(file=Stl, convexity=10, center=true);
                if(!Show_Slot_For_Reference){
                    slideLockSlot(slotHeight=Slot_Height);
                }
            }
            if(Show_Slot_For_Reference){
                slideLockSlot(slotHeight=Slot_Height);
                translate([0,-Slot_Depth/2,-Slot_Entry_Height]){
                    rotate([90,0,0]){
                        // cylinder(r=Slot_Entry_Diameter/2 + Slot_Tolerance, h=Slot_Depth+Slot_Tolerance, center=false);
                        cube([Slot_Entry_Diameter+Slot_Tolerance, Slot_Entry_Height+Slot_Tolerance, Slot_Depth], center=true);
                    }
                }
            }
            
        }
    }

}


module slideLockSlot(slotWidthLarge=Slot_Channel_Width_Large_End, slotWidthSmall=Slot_Channel_Width_Small_End, slotDepth=Slot_Depth, slotHeight=Slot_Height){
    slotWidthLarge = slotWidthLarge + Slot_Tolerance*1.5;
    slotWidthSmall = slotWidthSmall + Slot_Tolerance;
    // slotDepth = slotDepth + Slot_Tolerance;

    pointArray=[
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
        [slotWidthLarge-1, slotDepth],
        [slotWidthLarge-1, slotDepth-1],
        [(slotWidthLarge-slotWidthSmall)/2+slotWidthSmall,0],
        [0,0]
    ];

    echo(str("Using multi-connect compatible slot profile with points: ", pointArrayMultiConnectCompatible));
    rotate([90,0,0]){
        translate([-slotWidthLarge/2, 0, 0]){
            rotate([90,0,0]){
                linear_extrude(height=slotHeight, center=true){
                    polygon(points=pointArrayMultiConnectCompatible);
                }
            } 
            linear_extrude(height=slotDepth*2, center=true){
                translate([slotWidthLarge/2, -slotHeight, slotDepth]){
                    hull(){
                        translate([-slotWidthLarge/4, slotHeight/4, 0]) circle(r=slotWidthLarge/2);  
                        translate([slotWidthLarge/4, slotHeight/4, 0]) circle(r=slotWidthLarge/2);  
                        translate([slotWidthLarge/4, -slotHeight/4, 0]) circle(r=slotWidthLarge/2);  
                        translate([-slotWidthLarge/4, -slotHeight/4, 0]) circle(r=slotWidthLarge/2);  
                    }
                }
            }
        }
    }
}