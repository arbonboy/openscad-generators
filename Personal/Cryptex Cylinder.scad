/* [Code Ring Parameters] */
Ring_Inner_Diameter = 59.1; //[10:0.5:100]       // Inner diameter of the ring (mm)
Ring_Outer_Diameter = 63; //[10:0.5:100]      // Outer diameter of the ring (mm)
Ring_Height = 15;//[5:0.5:40]              // Height of the ring (mm)
Sides = 10; //[6:1:20]
Ring_Tolerance = 0.2; //[0:0.1:1]         // Tolerance for fit (mm)
Characters = "ACEGKMORSW";          // Characters to engrave on the ring
Character_Size = 10; //[1:0.5:15]            // Size of the engraved characters (mm)
Character_Depth = 0.5; //[0:0.1:5]           // Depth of the engraved characters (mm)    
Character_Font = "Liberation Mono"; //[American Typewriter,Avenir, Chalkboard, Charter, Copperplate, Futura, Liberation Mono, Courier New, DejaVu Sans Mono, FreeMono, Inconsolata, Menlo, Monaco, Consolas]
Character_Style = "extruded"; // [engraved, extruded]

Ring_Thickness = (Ring_Outer_Diameter - Ring_Inner_Diameter) / 2; // Thickness of the ring (mm)


/* [Container Cylinder Parameters] */
Container_Outer_Diameter = 44.8; //[10:0.1:100]      // Outer diameter of the container cylinder (mm)
Container_Inner_Diameter = 40; //[10:0.1:100]      // Inner diameter of the container cylinder (mm)
Container_End_Outer_Diameter = 60; //[10:0.1:100]      // Outer diameter of the container end (mm)
Container_End_Height = 10; //[1:0.5:20]             // Height of the container end (mm)
Container_Total_Height = 90; //[5:0.5:100]             // Total height of the container (mm)
Container_Inner_Height = Container_Total_Height - Container_End_Height/2; // Inner height of the container (mm)
Container_Locking_Channel_Slot_Width = 5; //[1:0.5:20]                     // Width of the slot for the locking mechanism (mm)
Container_Support_Channel_Slot_Width = 4; //[1:0.5:20]                     // Width of the slot for the support mechanism (mm)
Container_Twist_Lock_Groove_Depth = 2; //[0:0.1:20]                     // Depth of the locking group (mm)
Container_Twist_Lock_Groove_Width = 3; //[1:0.5:20]                     // Width of the locking groove (mm)
Container_Twist_Lock_Groove_Position_From_Top = 2.2; //[0:0.1:4]                     // Position of the locking groove from the top of the container (mm)
Container_Flat_Edge_Cutout_Thickness = Container_Outer_Diameter - Container_Inner_Diameter; // Thickness of the flat edge cutout (mm)



containerCylinder();

module codeRing(){
    assert(Ring_Inner_Diameter > 0, "Ring Inner Diameter must be greater than 0");
    assert(Ring_Outer_Diameter > Ring_Inner_Diameter, "Ring Outer Diameter must be greater than Inner Diameter");
    assert(Ring_Height > 0, "Ring Height must be greater than 0");
    assert(Sides >= 3, "Sides must be at least 3");
    assert(Character_Size > 0, "Character Size must be greater than 0");
    assert(Character_Depth >= 0, "Character Depth must be non-negative");   

    Inner_Vertex_Cylinder_Height = 5.22; // Height of the inner-vertex cylinders (mm)
    Inner_Vertex_Cylinder_Radius = 1.5; // Radius of the inner-vertex cylinders (mm)
    Outer_Radius = Ring_Outer_Diameter / 2;
    Outer_Apothem = Outer_Radius * cos(180 / Sides);

    module character_solid(i, offset) {
        rotate([-90, 0, (i + 0.5) * 360 / Sides])
            translate([offset, 0, 0])
                rotate(a=120, v=[1, 1, 1])
                    color("red") 
                        linear_extrude(height=Character_Depth, center=true)
                            text(Characters[i], size=Character_Size, font=Character_Font, halign="center", valign="center");
    }

    union() {
        difference() {
            // Main ring body
            cylinder(h=Ring_Height, r=Outer_Radius, center=true, $fn=Sides);
            cylinder(h=Ring_Height+2, r=Ring_Inner_Diameter/2, center=true, $fn=Sides);

            // Engraved characters
            if (Character_Style == "engraved") {
                for (i = [0 : len(Characters)-1]) {
                    character_solid(i, Outer_Apothem - Character_Depth / 2);
                }
            }
        }

        // Extruded characters
        if (Character_Style == "extruded") {
            for (i = [0 : len(Characters)-1]) {
                character_solid(i, Outer_Apothem + Character_Depth / 2);
            }
        }

        // Inner-vertex cylinders
        for (i = [0 : Sides - 1]) {
            rotate([0, 0, i * 360 / Sides]) {
                translate([Ring_Inner_Diameter/2, 0, -Ring_Height/2+Inner_Vertex_Cylinder_Height/2]) {
                    cylinder(h=Inner_Vertex_Cylinder_Height, r=Inner_Vertex_Cylinder_Radius, center=true, $fn=Sides);
                }
            }
        }
    }
}

module lockNut(){

}

module lockingCylinder(){

}


translate([20, 80,40]) {
   rotate([0, 0, 50]) {
        import("/Users/john.andersen/Downloads/OuterShell_V2-jja.stl", center=true);
    }
}


module containerCylinder() {
    Container_Outer_Radius = Container_Outer_Diameter / 2;
    Container_Inner_Radius = Container_Inner_Diameter / 2;
    Container_End_Outer_Radius = Container_End_Outer_Diameter / 2;
    Container_Chamfer_Size = 1.5;
    
    difference() {
        union() {
            // Top chamfer of bottom lip
            hull() {
                translate([0, 0, Container_End_Height/2]) 
                    cylinder(h=0.01, r=Container_End_Outer_Radius - Container_Chamfer_Size, $fn=60);
                translate([0, 0, Container_End_Height/2 - Container_Chamfer_Size/2]) 
                    cylinder(h=0.01, r=Container_End_Outer_Radius, $fn=60);
                
            }

            //Main body of bottom lip
            translate([0, 0, -Container_End_Height/2 + Container_Chamfer_Size/2])
                cylinder(h=Container_End_Height-Container_Chamfer_Size, r=Container_End_Outer_Radius, $fn=60);
            

            // Bottom lip with chamfered edges
            hull() {
                // Bottom chamfer
                translate([0, 0, -Container_End_Height/2]) 
                    cylinder(h=0.01, r=Container_End_Outer_Radius - Container_Chamfer_Size, $fn=60);
                translate([0, 0, -Container_End_Height/2 + Container_Chamfer_Size/2]) 
                    cylinder(h=0.01, r=Container_End_Outer_Radius, $fn=60);
            }
            
            
        }
        
        // Cut the inner hole from the bottom lip
        translate([0, 0, Container_End_Height/2-2])
            cylinder(h=Container_End_Height + 4, r=Container_Inner_Radius + 1, $fn=60);
    }
    
    // Main hollow cylinder
    difference() {
        union() {
            // Outer cylinder
            translate([0, 0, Container_End_Height/2 - Container_End_Height/2])
                cylinder(h=Container_Inner_Height, r=Container_Outer_Radius, $fn=60);
        }
        
        // Inner hollow
        translate([0, 0, (Container_End_Height/2 - Container_End_Height/2) - 2])
            cylinder(h=Container_Inner_Height + 4, r=Container_Inner_Radius, $fn=60);
        
        // Locking channel slot (wider one) - positioned at 0 degrees
        translate([Container_Outer_Radius - Container_Locking_Channel_Slot_Width/2, -Container_Locking_Channel_Slot_Width/2, Container_End_Height/2 - Container_End_Height/2])
            cube([Container_Locking_Channel_Slot_Width, Container_Locking_Channel_Slot_Width, Container_Inner_Height + 2]);
        
        // Support channel slot (narrower one) - positioned at 180 degrees
        translate([-(Container_Outer_Radius - Container_Support_Channel_Slot_Width/2), -Container_Support_Channel_Slot_Width/2, Container_End_Height/2 - Container_End_Height/2])
            cube([Container_Support_Channel_Slot_Width, Container_Support_Channel_Slot_Width, Container_Inner_Height + 2]);
        
        // Locking channel depth cut - extends into the end
        translate([Container_Outer_Radius + 1, -Container_Locking_Channel_Slot_Width/2, Container_End_Height/2 - Container_End_Height/2])
            cube([4, Container_Locking_Channel_Slot_Width, Container_End_Height/2 + 2]);
        
        // Flat cut on support channel side - vertical slice
        translate([0, -(Container_Outer_Radius + 2), Container_End_Height/2 - Container_End_Height/2 - 2])
            cube([Container_Outer_Radius + 4, 4, Container_Inner_Height + 4]);
    }
    
    // Grooves near the top
    // Locking channel groove - 45 degrees from locking slot
    translate([Container_Outer_Radius * cos(22.5), Container_Outer_Radius * sin(22.5), Container_Inner_Height/2 + Container_End_Height/2 - Container_Twist_Lock_Groove_Position_From_Top - Container_Twist_Lock_Groove_Width/2])
        rotate([0, 0, 22.5])
            cube([Container_Twist_Lock_Groove_Width, Container_Twist_Lock_Groove_Depth, Container_Twist_Lock_Groove_Width], center=true);
    
    // Support channel groove - 45 degrees from support slot
    translate([-(Container_Outer_Radius * cos(22.5)), Container_Outer_Radius * sin(22.5), Container_Inner_Height/2 + Container_End_Height/2 - Container_Twist_Lock_Groove_Position_From_Top - Container_Twist_Lock_Groove_Width/2])
        rotate([0, 0, 180 - 22.5])
            cube([Container_Twist_Lock_Groove_Width, Container_Twist_Lock_Groove_Depth, Container_Twist_Lock_Groove_Width], center=true);
}

