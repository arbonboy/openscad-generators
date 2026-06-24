/* [Rod Parameters] */
Rod_Type = "round"; // [round:Round Rod, rectangular:Rectangular Rod]
// Diameter of the round rod (only used when Rod_Type is "round")
Rod_Diameter = 20; // [3:0.5:100]
// Width of the rectangular rod (only used when Rod_Type is "rectangular")
Rod_Width = 15; // [3:0.5:100]
// Height of the rectangular rod (only used when Rod_Type is "rectangular")
Rod_Height = 30; // [3:0.5:100]
// Extra clearance added to the rod hole for an easier fit
Rod_Tolerance = 0.2; // [0:0.05:2]

/* [Clip Parameters] */
// Z thickness of the clip (depth along the rod when installed)
Clip_Thickness = 6; // [1:0.5:30]
// Wall thickness of material surrounding the rod hole
Clip_Wall_Thickness = 5; // [1:0.5:20]
// Width of the snap-in opening at the bottom of the clip (should be less than rod size for snap fit)
Clip_Opening_Width = 20; // [1:0.5:100]
// Rounding of the outer clip corners
Clip_Rounding = 2; // [0:0.5:20]

/* [Label Parameters] */
// Length of the label plate (X direction, extending from the clip)
Label_Width = 80; // [10:1:300]
// Height of the label plate (Y direction)
Label_Height = 30; // [5:0.5:100]
// Z thickness of the label plate
Label_Thickness = 3; // [0.5:0.2:20]
// Rounding of the outer label corners
Label_Rounding = 2; // [0:0.5:20]

/* [Label Text - Top Face] */
Label_Top_Text_Line_1 = "TOPS";
Label_Top_Text_Line_2 = "";
Label_Top_Text_Line_3 = "";

/* [Label Text - Bottom Face] */
Label_Bottom_Text_Line_1 = Label_Top_Text_Line_1;
Label_Bottom_Text_Line_2 = Label_Top_Text_Line_2;
Label_Bottom_Text_Line_3 = Label_Top_Text_Line_3;

/* [Text Formatting] */
Text_Font_Size = 10; // [1:0.5:50]
Text_Font_Family = "Avenir Next Condensed"; // ["American Typewriter", "Andale Mono", "Arial", "Avenir", "Avenir Next Condensed", "Baskerville", "Copperplate", "Geneva", "Georgia", "Liberation Mono", "Menlo", "Times New Roman", "Courier New", "Comic Sans MS"]
Text_Font_Style = "Bold"; // [Regular, Bold, Italic, "Bold Italic"]
// Depth that the text sinks into (or rises above) the label surface
Text_Depth = 1.2; // [0.1:0.1:5]
// If > 0, text protrudes above the label surface by this amount; if 0, text is debossed into the label
Text_Extrusion = 0; // [0:0.1:5]
// Vertical spacing factor between lines (multiplied by font size)
Text_Line_Spacing = 1.25; // [1:0.05:3]
// Horizontal alignment of the label text within the label
Text_Alignment = "edge"; // [center:Center, edge:Edge]
// Inset from the free edge of the label when Text_Alignment is "edge"
Text_Edge_Margin = 4; // [0:0.5:50]

$fn = 64;

main();

module main(){
    rod_x_dim = (Rod_Type == "round") ? Rod_Diameter : Rod_Width;
    rod_y_dim = (Rod_Type == "round") ? Rod_Diameter : Rod_Height;
    clip_outer_x = rod_x_dim + 2 * Clip_Wall_Thickness + Rod_Tolerance;
    clip_outer_y = rod_y_dim + 2 * Clip_Wall_Thickness + Rod_Tolerance;

    color("crimson"){
        clip(clip_outer_x = clip_outer_x, clip_outer_y = clip_outer_y);
        // Tuck the label inboard by the clip's corner radius so the rounded top-right
        // corner of the clip does not leave a notch between the clip top and the label top.
        translate([clip_outer_x / 2 - Clip_Rounding, 0, 0]){
            label(top_y = clip_outer_y / 2);
        }
    }
}

module clip(clip_outer_x, clip_outer_y){
    rod_hole_x = (Rod_Type == "round") ? Rod_Diameter + Rod_Tolerance : Rod_Width + Rod_Tolerance;
    rod_hole_y = (Rod_Type == "round") ? Rod_Diameter + Rod_Tolerance : Rod_Height + Rod_Tolerance;

    difference(){
        // Outer body of the clip
        translate([0, 0, Clip_Thickness / 2]){
            roundedBlock([clip_outer_x, clip_outer_y, Clip_Thickness], Clip_Rounding);
        }

        // Rod hole (positive Z is into the part)
        translate([0, 0, -0.5]){
            linear_extrude(height = Clip_Thickness + 1){
                if(Rod_Type == "round"){
                    circle(d = Rod_Diameter + Rod_Tolerance);
                } else {
                    square([Rod_Width + Rod_Tolerance, Rod_Height + Rod_Tolerance], center = true);
                }
            }
        }

        // Snap-in opening slot at the bottom of the clip
        translate([-Clip_Opening_Width / 2, -clip_outer_y / 2 - 0.1, -0.5]){
            cube([Clip_Opening_Width, clip_outer_y / 2 + 0.2, Clip_Thickness + 1]);
        }
    }
}

module label(top_y){
    // The label hangs from top_y downward; its left edge sits at x = 0 (against the clip).
    // The left edge and its corners are kept sharp so the label butts cleanly into the clip.
    label_bottom = top_y - Label_Height;
    label_center_y = top_y - Label_Height / 2;

    // Both faces share the same X anchor (near the free edge or centered).
    // Top face: edge = right-aligned.  Bottom face: mirrored, so halign="left" keeps
    // text anchored to the same physical (free) edge and reads left when viewed from back.
    text_x      = (Text_Alignment == "edge") ? Label_Width - Text_Edge_Margin : Label_Width / 2;
    top_halign  = (Text_Alignment == "edge") ? "right" : "center";
    bot_halign  = (Text_Alignment == "edge") ? "left"  : "center";

    difference(){
        translate([0, label_bottom, 0]){
            linear_extrude(height = Label_Thickness){
                labelShape(Label_Width, Label_Height, Label_Rounding);
            }
        }

        // Debossed text on top face
        if(Text_Extrusion <= 0){
            translate([text_x, label_center_y, Label_Thickness - Text_Depth + 0.01]){
                labelText(Text_Depth + 0.1, Label_Top_Text_Line_1, Label_Top_Text_Line_2, Label_Top_Text_Line_3, top_halign);
            }
        }

        // Debossed text on bottom face (mirrored in X so it reads correctly from the back)
        if(Text_Extrusion <= 0){
            translate([text_x, label_center_y, -( 0.1) + 0.01]){
                mirror([1, 0, 0]){
                    labelText(Text_Depth + 0.1, Label_Bottom_Text_Line_1, Label_Bottom_Text_Line_2, Label_Bottom_Text_Line_3, bot_halign);
                }
            }
        }
    }
    // // Debossed text on top face
    //     if(Text_Extrusion <= 0){
    //         translate([text_x, label_center_y, Label_Thickness - Text_Depth + 0.01]){
    //             labelText(Text_Depth + 0.1, Label_Top_Text_Line_1, Label_Top_Text_Line_2, Label_Top_Text_Line_3, top_halign);
    //         }
    //     }
        // if(Text_Extrusion <= 0){
        //     translate([text_x, label_center_y, -(Text_Depth/2 + 0.1) + 0.01]){
        //         mirror([1, 0, 0]){
        //             labelText(Text_Depth + 0.1, Label_Bottom_Text_Line_1, Label_Bottom_Text_Line_2, Label_Bottom_Text_Line_3, bot_halign);
        //         }
        //     }
        // }

    // Raised text on top face
    if(Text_Extrusion > 0){
        translate([text_x, label_center_y, Label_Thickness]){
            labelText(Text_Extrusion, Label_Top_Text_Line_1, Label_Top_Text_Line_2, Label_Top_Text_Line_3, top_halign);
        }
    }

    // Raised text on bottom face (protrudes below z = 0, mirrored for readability from back)
    if(Text_Extrusion > 0){
        translate([text_x, label_center_y, -Text_Extrusion]){
            mirror([1, 0, 0]){
                labelText(Text_Extrusion, Label_Bottom_Text_Line_1, Label_Bottom_Text_Line_2, Label_Bottom_Text_Line_3, bot_halign);
            }
        }
    }
}

module labelShape(w, h, r){
    // 2D footprint of the label: sharp on the left (clip side), rounded on the right.
    rr = min(r, w / 2 - 0.01, h / 2 - 0.01);
    if(rr <= 0){
        square([w, h]);
    } else {
        hull(){
            square([w - rr, h]);
            translate([w - rr, rr]) circle(r = rr);
            translate([w - rr, h - rr]) circle(r = rr);
        }
    }
}

module labelText(extrudeHeight, line1, line2, line3, halignVal){
    lines = [line1, line2, line3];
    nonEmpty = [for(l = lines) if(len(l) > 0) l];
    n = len(nonEmpty);
    if(n > 0){
        lineSpacing = Text_Font_Size * Text_Line_Spacing;
        totalBlockHeight = (n - 1) * lineSpacing;
        linear_extrude(height = extrudeHeight){
            for(i = [0 : n - 1]){
                yPos = totalBlockHeight / 2 - i * lineSpacing;
                translate([0, yPos, 0]){
                    text(
                        nonEmpty[i],
                        size = Text_Font_Size,
                        halign = halignVal,
                        valign = "center",
                        font = str(Text_Font_Family, ":style=", Text_Font_Style)
                    );
                }
            }
        }
    }
}

module roundedBlock(size, rounding){
    w = size[0];
    h = size[1];
    d = size[2];
    r = min(rounding, w / 2 - 0.01, h / 2 - 0.01);
    if(r <= 0){
        cube(size, center = true);
    } else {
        linear_extrude(height = d, center = true){
            offset(r = r) offset(r = -r) square([w, h], center = true);
        }
    }
}
