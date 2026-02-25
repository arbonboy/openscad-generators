include <BOSL2/std.scad>
include <BOSL2/threading.scad>


Container_Diameter = 70;
Container_Height = 100;
Wall_Thickness = 3;
Lid_Height = 15;
Lid_Overlap = 5;
Screw_Height = 10;
Screw_Diameter = Container_Diameter + Wall_Thickness;
Screw_Pitch = 2; //[1:.1:5]
Tolerance = 0.2; //[0:.1:1]

/* [Parts to Generate] */
Lid = true;
Container = true;

/* [Hidden] */
Inner_Diameter = Container_Diameter - Lid_Overlap - Wall_Thickness;
Outer_Diameter = Container_Diameter + Lid_Overlap + Wall_Thickness;

if(Lid) translate([0, 0, Container_Height+Lid_Height]) lid();

if(Container) container();  

Screw_Depth = Screw_Pitch * cos(30) * 5/8;
Screw_Profile = [
    [-Screw_Diameter/2, -Screw_Depth/Screw_Pitch*1.07],
    [-Screw_Diameter/2 + Screw_Pitch/8, -Screw_Depth/Screw_Pitch],
    [-Screw_Pitch/32,  0],
    [ Screw_Pitch/32,  0],
    [ Screw_Diameter/2 - Screw_Pitch/8, -Screw_Depth/Screw_Pitch],
    [ Screw_Diameter/2, -Screw_Depth/Screw_Pitch*1.07]
];  


pitch = Screw_Pitch;
depth = pitch * cos(30) * 5/8;
profile = [
    [-7/16, -depth/pitch*1.07],
    [-6/16, -depth/pitch],
    [-1/16,  0],
    [ 1/16,  0],
    [ 6/16, -depth/pitch],
    [ 7/16, -depth/pitch*1.07]
];



module container() {
    difference() {
        union() {
            // Main body
            cylinder(h=Container_Height, d1=Outer_Diameter, d2=Outer_Diameter, center=false);
            
            // Screw top
            translate([0, 0, (Container_Height+Screw_Height/2)])
                color("red") generic_threaded_rod(d=Screw_Diameter, l=Screw_Height, pitch=Screw_Pitch, profile=profile);
        }
        
        // Hollow out the container
        translate([0, 0, Wall_Thickness])
            cylinder(h=Container_Height + Screw_Height, d1=Inner_Diameter, d2=Inner_Diameter, center=false);
    }
}


module lid() {
    scale([1+Tolerance, 1+Tolerance, 1]){
        difference() {
        union() {
            // Lid
            cylinder(h=Lid_Height, d1=Outer_Diameter, d2=Outer_Diameter, center=false);
            
            // Screw top
            // translate([0, 0, Lid_Height - Screw_Height/2])
                
        }
        // Hollow out the lid
        translate([0, 0, Wall_Thickness])
            // cylinder(h=Lid_Height, d1=Container_Diameter + Wall_Thickness - 2*Wall_Thickness + Lid_Overlap, d2=Container_Diameter + Wall_Thickness - 2*Wall_Thickness + Lid_Overlap, center=false);
            generic_threaded_rod(d=Screw_Diameter, l=Screw_Height, pitch=Screw_Pitch, profile=profile);
        }
    }
    
}



