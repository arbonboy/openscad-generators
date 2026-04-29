include <BOSL2/std.scad>

Show = "printing"; //["bottom","lid","both", "printing"]

Box_Width = 200; //[20:1:300]
Box_Length = 150; //[20:1:300]
Box_Height = 100; //[20:1:300]
Wall_Thickness = 3; //[1:0.5:20]
Compartment_Wall_Thickness = 2.5; //[2:0.5:20]
Rounding = 5; //[0:0.1:20]
Compartments_X = 3; //[1:1:10]
Compartments_Y = 2; //[1:1:10]
Compartment_Wall_Height_Percentage = 0.8; //[0:0.05:1]
Cutout_Diameter_X = 40; //[0:1:100]
Cutout_Diameter_Y = 40; //[0:1:100]

Lid_Height_Percentage = 0.8; //[0:0.05:2]
Lid_Outer_Tolerance = 0.4; //[0:0.1:3]
Lid_Text = "My Box";
Lid_Text_Size = 20; //[1:1:100]
Lid_Text_Font = "Herculanum:style=Bold"; //["Arial:style=Bold","Arial:style=Italic","Times:style=Bold","Times:style=Italic","Courier:style=Bold","Courier:style=Italic","Herculanum:style=Bold"]
Lid_Text_Rotation = [0, 0, 0]; 

/* [Hidden Parameters] */
Lid_Width = Box_Width + 2*Lid_Outer_Tolerance + 2*Wall_Thickness;
Lid_Length = Box_Length + 2*Lid_Outer_Tolerance + 2*Wall_Thickness;
Lid_Height = Box_Height * Lid_Height_Percentage;

if(Show == "bottom" || Show == "both" || Show == "printing"){
    color("blue") bottom();
}

if(Show == "both"){
    translate([0, 0, Box_Height/2 - Lid_Height/2 + Wall_Thickness/2]){
        color("gray") lid();
    }
} 

if(Show == "lid"){
    rotate([180, 0, 0]){
        color("gray") lid();
    }
}

if(Show == "printing"){
    translate([Box_Width + 2 * Wall_Thickness + 2 * Lid_Outer_Tolerance + 20, 0, -Box_Height/2 + Lid_Height/2 - Wall_Thickness/2]){
        rotate([180, 0, 0]){
            color("gray") lid();
        }
    }
}

module lid(){
    difference(){
        cuboid([Lid_Width, Lid_Length, Lid_Height], rounding=Rounding, edges="Z");
        translate([0, 0, -Wall_Thickness]){
            cuboid([Lid_Width-2*Wall_Thickness, Lid_Length-2*Wall_Thickness, Lid_Height], rounding=Rounding, edges="Z");
        }
        if(Cutout_Diameter_X > 0){
            translate([0, 0, -Lid_Height/2]){
                rotate([0, 90, 0]){
                    cylinder(d=Cutout_Diameter_X, h=Lid_Width + 1, center=true);
                }
            }   
        }
        if(Cutout_Diameter_Y > 0){
            translate([0, 0, -Lid_Height/2]){
                rotate([90, 0, 0]){
                    cylinder(d=Cutout_Diameter_Y, h=Lid_Length + 1, center=true);
                }
            }   
        }
        if(Lid_Text!=""){
            rotate(Lid_Text_Rotation){
                translate([0, 0, Lid_Height/2 + 0.1]){
                    linear_extrude(height=Wall_Thickness, center=true, $fn=16){
                        text(Lid_Text, size=Lid_Text_Size, font=Lid_Text_Font, halign="center", valign="center");
                    }
                }
            }
        }

    }
}


module bottom(){
    difference(){
        union(){
            cuboid([Box_Width, Box_Length, Box_Height], rounding=Rounding, edges="Z");
            translate([0, 0, -Box_Height/2]){
                cuboid([Lid_Width, Lid_Length, Wall_Thickness], rounding=Rounding, edges="Z");
            }
        }
        translate([0, 0, Wall_Thickness]){
            cuboid([Box_Width-2*Wall_Thickness, Box_Length-2*Wall_Thickness, Box_Height], rounding=Rounding, edges="Z");
        }
    }
    if(Compartments_X > 1){
        for(i = [1:Compartments_X-1]){
            translate([i*Box_Width/Compartments_X - Box_Width/2, 0, -(Box_Height - Box_Height*Compartment_Wall_Height_Percentage)/2]){
                cube([Compartment_Wall_Thickness, Box_Length, Box_Height*Compartment_Wall_Height_Percentage], center=true);
            }
        }
    }
    if(Compartments_Y > 1){
        for(j = [1:Compartments_Y-1]){
            translate([0, j*Box_Length/Compartments_Y - Box_Length/2, -(Box_Height - Box_Height*Compartment_Wall_Height_Percentage)/2]){
                cube([Box_Width, Compartment_Wall_Thickness, Box_Height*Compartment_Wall_Height_Percentage], center=true);
            }
        }
    }
    if(Box_Width > Box_Length){
        translate([Cutout_Diameter_X*2, -(Box_Length/2), Box_Height/2 - Lid_Height*2/5]){
            pressureExtrusion();
        }
        translate([-Cutout_Diameter_X*2, -(Box_Length/2), Box_Height/2 - Lid_Height*2/5]){
            pressureExtrusion();
        }
        translate([Cutout_Diameter_X*2, (Box_Length/2), Box_Height/2 - Lid_Height*2/5]){
            pressureExtrusion();
        }
        translate([-Cutout_Diameter_X*2, (Box_Length/2), Box_Height/2 - Lid_Height*2/5]){
            pressureExtrusion();
        }
    } else {
        translate([-(Box_Width/2), Cutout_Diameter_Y*2, Box_Height/2 - Lid_Height*2/5]){
            rotate([0, 0, 90]) pressureExtrusion();
        }
        translate([-(Box_Width/2), -Cutout_Diameter_Y*2, Box_Height/2 - Lid_Height*2/5]){
            rotate([0, 0, 90]) pressureExtrusion();
        }
        translate([(Box_Width/2), Cutout_Diameter_Y*2, Box_Height/2 - Lid_Height*2/5]){
            rotate([0, 0, 90]) pressureExtrusion();
        }
        translate([(Box_Width/2), -Cutout_Diameter_Y*2, Box_Height/2 - Lid_Height*2/5]){
            rotate([0, 0, 90]) pressureExtrusion();
        }
    }
}

module pressureExtrusion(width=10, height=3, depth=0.4){
    cuboid([width, depth, height], rounding=depth/2);
}