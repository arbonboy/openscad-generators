include <BOSL2/std.scad>
// 3D Printer Filament Spool Clip with Label Placeholder
// A pressure-fit clip that attaches to the inner walls of a spool
// Created for labeling spools

// ============================================
// USER CONFIGURABLE PARAMETERS
// ============================================

// Spool Dimensions
Inner_Spool_Width = 59;      //[30:0.1:70]
Spool_Wall_Thickness_Left = 3.5;   //[1:0.1:7]
Spool_Wall_Thickness_Right = 5.5;  //[1:0.1:7]
Use_Back_Size_Text = true;          // Whether to include size text on the back of the clip
Back_Text_String = "";

Filament_Clip = "internal"; // [internal:Inside the Label,under:Underneath the Label,none:None]

/* [Front Label Parameters] */
Front_Label_Type = "blank"; // [blank:Label Sticker,engraved:Engraved,none:None]
Front_Text_Depth = 0.6; // How much the text is extruded into the label face
H1 = "00A-01F8-00A";
H2 = "Sunlu";
H3 = "PLA+";
H4 = "Mint Green";
H5 = "$14.31/kg";
H6 = "TD: 3.4";

/* [Advanced Parameters] */

// Label Placeholder Dimensions  
Label_Width = 40;               // Width of label area (mm)
Label_Height = 30;              // Height of label area (mm)

// Clip Dimensions
Clip_Height = 20;               // Height of clip portions outside label area (mm)
Clip_Front_Thickness = 3;       // Thickness of front face (label and clip) (mm)

// Inner Brace (extends into spool interior)
Inner_Brace_Thickness = 2;      // Thickness of inner brace (mm)
Inner_Brace_Length = 8;         // How far into spool interior (mm)

// Outer Brace (extends along spool exterior)
Outer_Brace_Thickness = 1.5;      // Thickness of outer brace (mm) 
Outer_Brace_Length = 4;         // How far along spool exterior (mm)

// Design Parameters
Rounded_Lip_Radius = 1;         // Radius for rounded pressure lip (mm)
Tolerance = 0.2;                // Fit tolerance (mm)

Back_Text_Size = 6;             // Size of the text on the back of the clip (mm)
Back_Text_Height = 0.6;

H1Size = 6;
H2Size = 4;

Filament_Hole_Diameter = 2.5; // Diameter of the filament hole (mm)


/* [Hidden Parameters] */
H3Size = H2Size;
H4Size = H3Size;
H5Size = H4Size;
H6Size = H5Size;
Use_Front_Label = Front_Label_Type == "engraved" ? true : false;



    
// ============================================
// CALCULATED VALUES
// ============================================

// Total clip width spans the spool opening plus braces
Outer_Spool_Width = Inner_Spool_Width + Spool_Wall_Thickness_Left + Spool_Wall_Thickness_Right;
echo(str("Outer Spool Width: ", Outer_Spool_Width));
Total_Clip_Width = Outer_Spool_Width + 2*Outer_Brace_Thickness;
Total_Clip_Height = min(Label_Height, Clip_Height);

// Calculate positions
Label_X_Offset = (Total_Clip_Width - Label_Width) / 2;
Label_Y_Offset = max(Clip_Height, Label_Height)/2;

Clip_X_Offset = 0;
Clip_Y_Offset = max(Clip_Height, Label_Height)/2;

// Inner_Brace_X_Offset = -Total_Clip_Width/2 + Outer_Brace_Thickness/2 + Spool_Wall_Thickness + Inner_Brace_Thickness*3/2;
Inner_Brace_X_Offset = -Inner_Spool_Width/2+Inner_Brace_Thickness/2;
Inner_Brace_Z_Offset = Inner_Brace_Length/2+Clip_Front_Thickness/2;
Outer_Brace_X_Offset = -Total_Clip_Width/2+Outer_Brace_Thickness/2;
Outer_Brace_Z_Offset = Outer_Brace_Length/2+Clip_Front_Thickness/2;

echo(str("Calculated Inner Width: ", 2*Inner_Brace_X_Offset-Inner_Brace_Thickness));


// ============================================
// MAIN GEOMETRY
// ============================================

spool_clip();

module spool_clip() {
    union() {
        // Main clip body with label placeholder
        main_clip_body();
        
        // Inner brace with rounded lip
        // inner_brace_with_lip();
        
        // Outer brace
        // outer_brace();
    }
}

// Main clip body including label placeholder
module main_clip_body() {
    union(){
        difference(){
            union(){
                if(Front_Label_Type == "blank"){
                    label_body();
                }
                
                clip_front();
                if(Use_Front_Label){
                    front_label_face();
                }
            }
            if(Filament_Clip == "internal"){
                assert(Filament_Hole_Diameter > 0, "Filament hole diameter must be greater than 0");
                assert(Filament_Hole_Diameter < Clip_Front_Thickness, "Filament hole diameter must be less than the Clip_Front_Thickness");
                rotate([90, 0, 0])
                    translate([0, 0, 0])
                        cylinder(h = Label_Height*2, d = Filament_Hole_Diameter, center=true, $fn=6);
            }
        }
        if(Filament_Clip == "under"){
            assert(Filament_Hole_Diameter > 0, "Filament hole diameter must be greater than 0");
            difference(){
                rotate([0, 0, 0])
                    translate([0, 0, Clip_Front_Thickness])
                        cuboid([Filament_Hole_Diameter*2, Clip_Height, Filament_Hole_Diameter*2], rounding=0.3, edges=TOP);
                translate([0, 0, Clip_Front_Thickness])
                    rotate([90, 0, 0])
                        cylinder(h = Label_Height*2, d = Filament_Hole_Diameter, center=true, $fn=6);
            }
            
        }
        inner_brace("left");
        inner_brace("right");
        outer_brace("left");
        outer_brace("right");
        if(Use_Back_Size_Text){
            back_text();
        }
    }
}

module label_body(){
    translate([0, 0, 0]) {
            cuboid([Label_Width, Label_Height, Clip_Front_Thickness], rounding=0.5);
    }
}

module front_label_face(){
    translate([0, 0, -Clip_Front_Thickness/2 + Front_Text_Depth/2-Front_Text_Depth]) {
        color("black") {
            difference(){
                cuboid([Total_Clip_Width, Clip_Height, Front_Text_Depth], rounding=0.1);
                Line_Height_Multiplier = 1.2;
                H1_Line_Height_Offset = -1;
                translate([0, 5*Line_Height_Multiplier,  Front_Text_Depth/2]) {
                    rotate([0, 180, 0]) 
                        linear_extrude(height = Front_Text_Depth) {
                            translate([0, 0, 0]) text(H1, size = H1Size, halign = "center", valign = "center", font="Arial");
                            translate([-Total_Clip_Width/2+2, -Line_Height_Multiplier*H2Size + H1_Line_Height_Offset, 0]) text(H2, size = H2Size, halign = "left", valign = "center", font="Arial");
                            translate([Total_Clip_Width/2-2, -Line_Height_Multiplier*H3Size + H1_Line_Height_Offset, 0]) text(H3, size = H3Size, halign = "right", valign = "center", font="Arial");
                            translate([-Total_Clip_Width/2+2, -2*Line_Height_Multiplier*H4Size + H1_Line_Height_Offset, 0]) text(H4, size = H4Size, halign = "left", valign = "center", font="Arial");
                            // translate([-Total_Clip_Width/2+2, -3*Line_Height_Multiplier*H5Size + H1_Line_Height_Offset, 0]) text(H5, size = H5Size, halign = "left", valign = "center", font="Arial");
                            // translate([Total_Clip_Width/2-2, -3*Line_Height_Multiplier*H6Size + H1_Line_Height_Offset, 0]) text(H6, size = H6Size, halign = "right", valign = "center", font="Arial");
                    }
                }
            }
        }
    }
}

module clip_front(){
    translate([0, 0, 0]) {
        cuboid([Total_Clip_Width, Clip_Height, Clip_Front_Thickness], rounding=0.5, except=TOP);
    }
}

module inner_brace(side = "left") {
    //xOffset = side=="left" ? Inner_Brace_X_Offset : -Inner_Brace_X_Offset;

    spoolWallThicknessCombined = Spool_Wall_Thickness_Left + Spool_Wall_Thickness_Right;
    spoolWallThicknessPercentLeft = Spool_Wall_Thickness_Left / spoolWallThicknessCombined;
    spoolWallThicknessPercentRight = Spool_Wall_Thickness_Right / spoolWallThicknessCombined;
    // leftXOffset = Outer_Brace_Thickness + Inner_Brace_Thickness- Spool_Wall_Thickness_Left - Inner_Spool_Width/2;
    //leftXOffset = - Inner_Spool_Width/2 - Inner_Brace_Thickness/2 + Spool_Wall_Thickness_Left/2;
    leftXOffset = -Total_Clip_Width/2 + Outer_Brace_Thickness + Spool_Wall_Thickness_Left + Inner_Brace_Thickness/2;
    //rightXOffset = Inner_Spool_Width/2 + Spool_Wall_Thickness_Right;
    // rightXOffset = Inner_Spool_Width/2 + Inner_Brace_Thickness/2 - Spool_Wall_Thickness_Right/2;
    rightXOffset = Total_Clip_Width/2 - Outer_Brace_Thickness - Spool_Wall_Thickness_Right - Inner_Brace_Thickness/2;
    xOffset = side=="left" ? leftXOffset : rightXOffset;

    c = side=="left" ? "red" : "blue";
    translate([xOffset, 0, Inner_Brace_Z_Offset]) {
        cuboid([Inner_Brace_Thickness, Clip_Height, Inner_Brace_Length], rounding=0.5, edges=[TOP,FRONT,BACK], except=BOTTOM);
    }   
    //xOffsetRoundedLip = side=="left" ? Inner_Brace_X_Offset - Inner_Brace_Thickness/2 : -Inner_Brace_X_Offset + Inner_Brace_Thickness/2;
    xOffsetRoundedLip = side=="left" ? leftXOffset - Inner_Brace_Thickness/2 : rightXOffset + Inner_Brace_Thickness/2;
    translate([xOffsetRoundedLip, 0, Inner_Brace_Length]) {
        rotate([90,90,0]){
            cylinder(h=Clip_Height, r=Rounded_Lip_Radius/2, center=true);
        }
    }
    
}

module outer_brace(side = "left") {
    xOffset = side=="left" ? Outer_Brace_X_Offset : -Outer_Brace_X_Offset;
    translate([xOffset, 0, Outer_Brace_Z_Offset]) {
        cuboid([Outer_Brace_Thickness, Clip_Height, Outer_Brace_Length], rounding=0.5, edges=[TOP,FRONT,BACK], except=BOTTOM);
    }
}


// Inner brace that extends into the spool interior with rounded pressure lip
module inner_brace_with_lip() {
    translate([0, 0, 0]) {
        union() {
            // Main inner brace body
            cuboid([Inner_Brace_Length, Total_Clip_Height, Inner_Brace_Thickness], rounding=0.5);
            
            // Rounded pressure lip at the end
            translate([Inner_Brace_Length, 0, Inner_Brace_Thickness]) {
                linear_extrude(height = Total_Clip_Height) {
                    intersection() {
                        circle(r = Rounded_Lip_Radius);
                        square([Rounded_Lip_Radius, Rounded_Lip_Radius * 2], center = false);
                    }
                }
                // Rotate the lip to face the correct direction
                rotate([90, 0, 0]) {
                    translate([0, 0, -Total_Clip_Height]) {
                        linear_extrude(height = Total_Clip_Height) {
                            intersection() {
                                circle(r = Rounded_Lip_Radius);
                                square([Rounded_Lip_Radius, Rounded_Lip_Radius], center = false);
                            }
                        }
                    }
                }
            }
        }
    }
}

// Enhanced inner brace with proper rounded lip for pressure fitting
module inner_brace_with_lip_enhanced() {
    translate([0, 0, 0]) {
        union() {
            // Main inner brace body
            cuboid([Inner_Brace_Length, Total_Clip_Height, Inner_Brace_Thickness], rounding=0.5);
            
            // Rounded pressure lip - creates inward pressure on spool wall
            translate([Inner_Brace_Length, 0, 0]) {
                rotate([0, 0, 0]) {
                    linear_extrude(height = Total_Clip_Height) {
                        hull() {
                            // Base of the lip
                            translate([0, 0]) square([0.1, Inner_Brace_Thickness]);
                            // Rounded end extending inward
                            translate([Rounded_Lip_Radius - 0.5, Inner_Brace_Thickness/2]) 
                                circle(r = Rounded_Lip_Radius/2);
                        }
                    }
                }
            }
        }
    }
}
module back_text(){
    textSize = Back_Text_Size;
    textHeight = Back_Text_Height;
    wallThickText = Spool_Wall_Thickness_Left == Spool_Wall_Thickness_Right ? Spool_Wall_Thickness_Left : str(Spool_Wall_Thickness_Left, "+", Spool_Wall_Thickness_Right);

    if(Back_Text_String){
        translate([0, +textSize/2+1, Clip_Front_Thickness/2]) {
            linear_extrude(height = textHeight) {
                text(Back_Text_String, size = textSize, halign = "center", valign = "center", font="Arial:style=Bold");
            }
        }
        translate([0, -textSize/2-1, Clip_Front_Thickness/2]) {
            linear_extrude(height = textHeight) {
                text(str(Inner_Spool_Width, " x ", wallThickText), size = textSize, halign = "center", valign = "center", font="Arial:style=Bold");
            }
        }
    } else {
        translate([0, +textSize/2+1, Clip_Front_Thickness/2]) {
            linear_extrude(height = textHeight) {
                text(str(Inner_Spool_Width," mm"), size = textSize, halign = "center", valign = "center", font="Arial:style=Bold");
            }
        }
        translate([0, -textSize/2-1, Clip_Front_Thickness/2]) {
            linear_extrude(height = textHeight) {
                text(str(wallThickText), size = textSize, halign = "center", valign = "center");
            }
        }
    }
    
}
