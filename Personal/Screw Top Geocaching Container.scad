include <BOSL2/std.scad>
include <BOSL2/threading.scad>
include <lib/gc_elements.scad>


/* [Object to Use for Container] */
STL_To_Import = "/Users/john.andersen/Downloads/TreeStub House 3D Model.stl";
Object_Diameter = 200; 
Object_Height = 220;
Parts_to_Generate = "Both"; //["Lid", "Container", "Both"]


/* [Internal Container Parameters] */
Container_Diameter = 70; //[5:1:500]
Container_Height = 100; //[1:1:500]

// Container_Offset_X = 0; //[-200:1:200]
// Container_Offset_Y = 0; //[-200:1:200]
// Container_Offset_Z = 0; //[-200:1:200]

// Container_Rotation_X = 0; //[-180:1:180]
// Container_Rotation_Y = 0; //[-180:1:180]
// Container_Rotation_Z = 0; //[-180:1:180]

Container_Offset_X = 0;
Container_Offset_Y = 0;
Container_Offset_Z = 0;

Container_Rotation_X = 0;
Container_Rotation_Y = 0;
Container_Rotation_Z = 0;

Container_Wall_Thickness = 2;

Rounded_Container_Bottom = true;

/* [Thread Parameters] */
Screw_Height = 10; //[3:.5:80]
Screw_Pitch = 2; //[1:.1:5]
Tolerance = 0.2; //[0:.1:1]


/* [Lid Parameters] */
Lid_Height = 15; //[5:1:100]
Lid_Overlap = 5; //[0:.5:20]
Lid_Inset_handle = true;
Lid_Handle = "Inset Bar"; //["None", "Inset Bar", "Finger Grip"]
Lid_Clearance_Height = -0.1; //[-0.1:0.1:200]
Lid_Clearance_Diameter = -0.1; //[-0.1:0.1:400]

/* [Hidden] */
Screw_Diameter = Container_Diameter-Container_Wall_Thickness;
Inner_Diameter = Container_Diameter-Container_Wall_Thickness;
pitch = Screw_Pitch;
depth = pitch * cos(30) * 5/8;
Inner_Thread_Diameter = Screw_Diameter+depth;

profile = [
    [-7/16, -depth/pitch*1.07],
    [-6/16, -depth/pitch],
    [-1/16,  0],
    [ 1/16,  0],
    [ 6/16, -depth/pitch],
    [ 7/16, -depth/pitch*1.07]
];

drawMainV2();


module drawMainV2(){
    lid_clearance_h = Lid_Clearance_Height < 0 ? Lid_Height : Lid_Clearance_Height;
    if(Parts_to_Generate == "Lid" || Parts_to_Generate == "Both") {
        rotate([0, 180, 0])
            translate([Object_Diameter, 
                    Container_Height/2, 
                    0]) 
                gc_circular_lid_external_thread(
                    outer_d = Container_Diameter+Lid_Overlap,
                    thread_d = Container_Diameter-Container_Wall_Thickness,
                    thread_h = Screw_Height,
                    nonthread_h = 0,
                    top_t = Lid_Height-Screw_Height,
                    pitch = Screw_Pitch,
                    starts = 1,
                    finger_grip = Lid_Handle == "Finger Grip" ? true : false,
                    finger_grip_r = (Container_Diameter+Lid_Overlap)/3/2,
                );
    // gc_circular_lid_internal_thread(
    //                 outer_r=Container_Diameter/2+Lid_Overlap, 
    //                 thread_r=Inner_Diameter/2+Container_Wall_Thickness, 
    //                 thread_tol=Tolerance, 
    //                 thread_h=Screw_Height, 
    //                 nonthread_h=0,
    //                 top_t=Lid_Height-Screw_Height,
    //                 pitch=Screw_Pitch, 
    //                 starts=1,
    //                 left_handed=false,
    //                 entry_chamfer_h=0.6,
    //                 $fn=128
    //             );
    }
    if(Parts_to_Generate == "Container" || Parts_to_Generate == "Both") {
        difference(){
            objectToContainerify();
            translate([Object_Diameter/2 + Container_Offset_X, 
                            Container_Height/2 + Container_Offset_Y, 
                            Container_Offset_Z]) 
                rotate([Container_Rotation_X, Container_Rotation_Y, Container_Rotation_Z])
                        // internalContainerShape(solid=true);
                        gc_container_internal_thread(
                            thread_d = Container_Diameter-Container_Wall_Thickness,
                            wall_t = Container_Wall_Thickness,
                            height = Container_Height,
                            pitch = Screw_Pitch,
                            thread_h = Screw_Height,
                            thread_tol = Tolerance,
                            lid_clearance_d = Lid_Clearance_Diameter,
                            lid_clearance_h = Lid_Clearance_Height,
                            starts = 1,
                            solid = true
                        );
                        // gc_container_external_thread(
                        //     inner_d     = Inner_Diameter,    // inner diameter of container (mm)
                        //     wall_t      = Container_Wall_Thickness,     // wall thickness (mm)
                        //     height      = Container_Height,    // height of container (mm)
                        //     bottom_angle = 35,    // angle of conical bottom (degrees)
                        //     solid = true,
                        //     pitch = Screw_Pitch,
                        //     thread_h = Screw_Height,
                        //     lid_clearance_d = Lid_Clearance_Diameter,
                        //     lid_clearance_h = lid_clearance_h,
                        //     starts      = 1,
                        //     left_handed = false,
                        //     entry_chamfer_h = 0.6,   // set 0 for none - Small entry chamfer to help engagement
                        //     $fn = 128
                        // );

        }
        translate([Object_Diameter/2 + Container_Offset_X, 
                            Container_Height/2 + Container_Offset_Y, 
                            Container_Offset_Z]) 
                rotate([Container_Rotation_X, Container_Rotation_Y, Container_Rotation_Z])
                        // internalContainerShape(solid=false);
                        gc_container_internal_thread(
                            thread_d = Container_Diameter-Container_Wall_Thickness,
                            wall_t = Container_Wall_Thickness,
                            height = Container_Height,
                            pitch = Screw_Pitch,
                            thread_h = Screw_Height,
                            thread_tol = Tolerance,
                            lid_clearance_d = Lid_Clearance_Diameter,
                            lid_clearance_h = Lid_Clearance_Height,
                            starts = 1,
                            solid = false
                        );
                        // gc_container_external_thread(
                        //     inner_d     = Inner_Diameter,    // inner diameter of container (mm)
                        //     wall_t      = Container_Wall_Thickness,     // wall thickness (mm)
                        //     height      = Container_Height,    // height of container (mm)
                        //     bottom_angle = 35,    // angle of conical bottom (degrees)
                        //     solid = false,
                        //     pitch = Screw_Pitch,
                        //     thread_h = Screw_Height,
                        //     lid_clearance_d = Lid_Clearance_Diameter,
                        //     lid_clearance_h = lid_clearance_h,
                        //     $fn = 128
                        // );
    }
}

module drawMain(){
    if(Parts_to_Generate == "Lid" || Parts_to_Generate == "Both") {
        rotate([0, 180, 0])
            translate([Object_Diameter, 
                    Container_Height/2, 
                    0]) 
                lid();
    }
    if(Parts_to_Generate == "Container" || Parts_to_Generate == "Both") {
        difference(){
            objectToContainerify();
            translate([Object_Diameter/2 + Container_Offset_X, 
                            Container_Height/2 + Container_Offset_Y, 
                            Container_Offset_Z]) 
                rotate([Container_Rotation_X, Container_Rotation_Y, Container_Rotation_Z])
                        internalContainerShape(solid=true);
        }
        translate([Object_Diameter/2 + Container_Offset_X, 
                            Container_Height/2 + Container_Offset_Y, 
                            Container_Offset_Z]) 
                rotate([Container_Rotation_X, Container_Rotation_Y, Container_Rotation_Z])
                        internalContainerShape(solid=false);
    }
}
// internalContainerShape(solid=true);

    




module internalContainerShape(solid=false) {
    hollowedHeight = Container_Height - Container_Wall_Thickness;
    difference(){
        // Main body
        cylinder(h=Container_Height, d1=Container_Diameter, d2=Container_Diameter, center=true);
        
        if(!solid){
            // Screw top
            resize([Inner_Thread_Diameter+Tolerance, Inner_Thread_Diameter+Tolerance, Screw_Height])
                translate([0, 0, hollowedHeight/2]) //Container_Height/2-Screw_Height/2-Lid_Height
                    generic_threaded_rod(d=Inner_Thread_Diameter, l=Screw_Height, pitch=Screw_Pitch, profile=profile);

            //Spherize the inside bottom of the hollowed out container
            if(Rounded_Container_Bottom){
                // Hollow out the container
                translate([0, 0,  Container_Wall_Thickness])
                    cylinder(h=Container_Height+Inner_Diameter, d1=Inner_Diameter, d2=Inner_Diameter, center=true);
                roundedContainerBottom();
            } else {
                // Hollow out the container
                translate([0, 0,  Container_Wall_Thickness])
                    cylinder(h=hollowedHeight, d1=Inner_Diameter, d2=Inner_Diameter, center=true);
            }
        }
    }
    if(Rounded_Container_Bottom){    roundedContainerBottom(solid);
    }
    if(solid){
        translate([0, 0, hollowedHeight/2+Lid_Height/2]) 
            cylinder(h=Lid_Height, d1=Container_Diameter + Lid_Overlap, d2=Container_Diameter + Lid_Overlap, center=true);
    }
    
}



module roundedContainerBottom(solid=false){
    difference(){
        translate([0, 0, -Inner_Diameter/2-Container_Wall_Thickness]){
            sphere(d=Inner_Diameter);
        }
        if(!solid){
            translate([0, 0, 0]){
                cylinder(h=Inner_Diameter, d=Inner_Diameter, center=true);
            }
            translate([0, 0, -Inner_Diameter/2+Container_Wall_Thickness]){
                sphere(d=Inner_Diameter);
            }
        }
    }
}

module objectToContainerify() {
    resize([Object_Diameter, Object_Diameter, Object_Height]) import(STL_To_Import, center=true);
}


module lid() {
        union(){
            difference() {
            union() {
                // Lid
                cylinder(h=Lid_Height, d1=Container_Diameter+Lid_Overlap, d2=Container_Diameter+Lid_Overlap, center=false);
                
                // Screw top
                translate([0, 0, -Lid_Height/2])
                    generic_threaded_rod(d=Screw_Diameter, l=Screw_Height, pitch=Screw_Pitch, profile=profile);
                }
                if(Lid_Handle=="Inset Bar"){
                    //scale([1,1,(Screw_Height+Lid_Height)/Inner_Diameter])
                    scale([1,1,Lid_Height/(Screw_Height+Lid_Height)])
                        translate([0,0,(Screw_Height+Lid_Height)*2])
                            sphere(d=Inner_Diameter);
                }
            }
            if(Lid_Handle=="Inset Bar"){
                translate([0,0,Lid_Height/2])
                    cube([Inner_Diameter, Inner_Diameter/6, Lid_Height], center=true);
            }
        }
}