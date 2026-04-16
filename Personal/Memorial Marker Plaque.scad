include <BOSL2/std.scad>
include <lib/qr.scad> 

Show_Components = "both"; //[both:Both, sign:Sign only, slot:Slot only, placement:Transparent object with solid slot]
Base_Shape = "rectangle"; //[circle:Circle,rectangle:Rectangle,heart:Heart]

/* [Base Parameters] */
Base_Diameter = 130;
Base_X_Size = 180;
Base_Y_Size = 90;
Base_Corner_Rounding = 3; //[0: 0.5: 15]
Base_Height = 5;
Base_Color = "white";

/*[Border Parameters] */
Border_Width = 8;
Border_Height = 9; //[0:0.1:20]
Border_Color = "black";

/* [STL 1] */
Stl1 = ""; 
Stl1_Scale_X = .05; //[0.01:0.01:4]
Stl1_Scale_Y = .05; //[0.01:0.01:4]
Stl1_Offset_X = -70; //[-300:1:300]
Stl1_Offset_Y = 30; //[-300:1:300]
Stl1_Height = 7; //[0:0.1:20]
Stl1_Color = "yellow";

/* [STL 2] */
Stl2 = ""; 
Stl2_Scale_X = 0.1; //[0.01:0.01:4]
Stl2_Scale_Y = 0.1; //[0.01:0.01:4]
Stl2_Offset_X = -40; //[-300:1:300]
Stl2_Offset_Y = 30; //[-300:1:300]
Stl2_Height = 6; //[0:0.1:20]
Stl2_Color = "brown";

/* [STL 3] */
Stl3 = ""; 
Stl3_Scale_X = 1; //[0.01:0.01:4]
Stl3_Scale_Y = 1; //[0.01:0.01:4]
Stl3_Offset_X = 0; //[-300:1:300]
Stl3_Offset_Y = 0; //[-300:1:300]
Stl3_Height = 1.5; //[0:0.1:20]
Stl3_Color = "burlywood";

/* [Text 1] */
Text1 = ""; 
Text1_Size = 14; //[1:1:100]
Text1_Font = "Charter"; 
Text1_Height = 10; //[1:1:100]
Text1_Offset_X = 0; //[-300:1:300]
Text1_Offset_Y = 75; //[-300:1:300]
Text1_Color = "chocolate";

/* [Text 2] */
Text2 = ""; 
Text2_Size = 14; //[1:1:100]
Text2_Font = "Charter"; 
Text2_Height = 10; //[1:1:100]
Text2_Offset_X = 0; //[-300:1:300]
Text2_Offset_Y = -75; //[-300:1:300]
Text2_Color = "chocolate";

/* [Text 3] */
Text3 = ""; 
Text3_Size = 12; //[1:1:100]
Text3_Font = "Charter"; 
Text3_Height = 1.5; //[1:1:100]
Text3_Offset_X = 0; //[-300:1:300]
Text3_Offset_Y = 0; //[-300:1:300]
Text3_Color = "chocolate";

/* [Text 4] */
Text4 = ""; 
Text4_Size = 12; //[1:1:100]
Text4_Font = "Charter"; 
Text4_Height = 1.5; //[1:1:100]
Text4_Offset_X = 0; //[-300:1:300]
Text4_Offset_Y = -18; //[-300:1:300]
Text4_Color = "chocolate";

/* [QR Code Parameters] */
QR_Message = ""; 
QR_Error_Correction = "M"; //[L, M, Q, H]
QR_Size = 60; //[10:1:200]
QR_Height = 18; //[0:0.1:10]
QR_Extrusion = 0; //[0:0.1:10]
QR_Center = true;
QR_Y_Offset = 0; //[-500:1:500]
QR_X_Offset = 0; //[-500:1:500]


/* [Slot Parameters] */
Slot_Height = 50; //[10:1:100]
Slot_Tolerance = 0.2; //[0:0.1:5]
Slot_Entry_Height = 35; //[10:1:100]

Slot_Offset = [0,-30,0];  //[-100:0.1:100] 
Slot_Rotation = [0,0,0];



/* [Hidden] */
$fn = 80;



// Slot_Offset_X = 0;
// Slot_Offset_Y = 0;
// Slot_Offset_Z = 0;
echo(string_split("Hello World I am John", " "));
Show_Slot_For_Reference = true;
Slot_Channel_Width_Large_End = 20;
Slot_Channel_Width_Small_End = 15;
Slot_Entry_Diameter = Slot_Channel_Width_Large_End + 0;
Slot_Depth = 4;

plaque();

module delme(){
    if(Show_Components == "both" || Show_Components == "sign" || Show_Components == "placement"){
        if(Show_Components == "both"){
            difference(){
                plaque();
                slot();
            }
        } else if(Show_Components == "placement"){
            difference(){
                # plaque();
                color("yellow") slot();
            }
        }
    }
    if(Show_Components == "slot"){
        slot();
    } else if(Show_Components == "placement"){
        % color("red") slot();
    }
}

module sign(){
    if(Stl1 != ""){
        color(Stl1_Color){
            translate([Stl1_Offset_X, Stl1_Offset_Y, 0]){
                rotate([0, 0, 0]){
                    scale([Stl1_Scale_X, Stl1_Scale_Y, 1]){
                        linear_extrude(height = Stl1_Height){
                            import(file=Stl1, convexity=10, center=true);
                        } 
                    }
                }
            }
        }
    } 
    if(Stl2 != ""){
        color(Stl2_Color){
            translate([Stl2_Offset_X, Stl2_Offset_Y, 0]){
                rotate([0, 0, 0]){
                    scale([Stl2_Scale_X, Stl2_Scale_Y, 1]){
                        linear_extrude(height = Stl2_Height){
                            import(file=Stl2, convexity=10, center=true);
                        } 
                    }
                }
            }
        }
    } 
    if(Stl3 != ""){
        color(Stl1_Color){
            translate([Stl3_Offset_X, Stl3_Offset_Y, 0]){
                rotate([0, 0, 0]){
                    scale([Stl3_Scale_X, Stl3_Scale_Y, 1]){
                        linear_extrude(height = Stl3_Height){
                            import(file=Stl3, convexity=10, center=true);
                        } 
                    }
                }
            }
        }
    }
    if(Text1 != ""){
        color(Text1_Color){
            translate([Text1_Offset_X, Text1_Offset_Y, 0]){
                rotate([0, 0, 0]){
                    linear_extrude(height = Text1_Height){
                        multiline_text(text_value=Text1, font=Text1_Font, size=Text1_Size, halign="center");
                    }
                }
            }
        }
    }
    if(Text2 != ""){
        color(Text2_Color){
            translate([Text2_Offset_X, Text2_Offset_Y, 0]){
                rotate([0, 0, 0]){
                    linear_extrude(height = Text2_Height){
                        multiline_text(text_value=Text2, font=Text2_Font, size=Text2_Size, halign="center");
                    }
                }
            }
        }
    }
    if(Text3 != ""){
        color(Text3_Color){
            translate([Text3_Offset_X, Text3_Offset_Y, 0]){
                rotate([0, 0, 0]){
                    linear_extrude(height = Text3_Height){
                        multiline_text(text_value=Text3, font=Text3_Font, size=Text3_Size, halign="center");
                    }
                }
            }
        }
    }
    if(Text4 != ""){
        color(Text4_Color){
            translate([Text4_Offset_X, Text4_Offset_Y, 0]){
                rotate([0, 0, 0]){
                    linear_extrude(height = Text4_Height){
                        multiline_text(text_value=Text4, font=Text4_Font, size=Text4_Size, halign="center");
                    }
                }
            }
        }
    }
    if(QR_Message != ""){
        echo("Generating QR code with message: ", QR_Message);
        color("black"){
            translate([QR_X_Offset, QR_Y_Offset, QR_Extrusion]){
                rotate([0, 0, 0]){
                    qr(QR_Message, error_correction=QR_Error_Correction, width=QR_Size, height=QR_Size, thickness=QR_Height, center=QR_Center);
                }
            }
        }
    }   
    
}


module slot(){
    translate(Slot_Offset+[0,0,0]){
        rotate(Slot_Rotation+[-90, 0, 0]){
            slideLockSlot();
        }
    }
}



module slideLockSlot(slotWidthLarge=Slot_Channel_Width_Large_End, slotWidthSmall=Slot_Channel_Width_Small_End, slotDepth=Slot_Depth, slotHeight=Slot_Height, entryHeight=Slot_Entry_Height){
    slotWidthLarge = slotWidthLarge + Slot_Tolerance*1.5;
    slotWidthSmall = slotWidthSmall + Slot_Tolerance;
    // slotDepth = slotDepth + Slot_Tolerance;

    // pointArray=[
    //     [slotDepth/tan(45),0],
    //     [0, slotDepth],
    //     [slotWidthLarge, slotDepth],
    //     [slotWidthLarge-slotDepth/tan(45),0],
    //     [0,0]
    // ];

    pointArrayMultiConnectCompatible=[
        [(slotWidthLarge-slotWidthSmall)/2,0],
        [1, slotDepth-1],
        [1, slotDepth],
        [slotWidthLarge-1, slotDepth],
        [slotWidthLarge-1, slotDepth-1],
        [(slotWidthLarge-slotWidthSmall)/2+slotWidthSmall,0],
        [0,0]
    ];
    echo ("slotWidthLarge: ", slotWidthLarge);

    rotate([90,0,0]){
        translate([-slotWidthLarge/2, 0, 0]){
            rotate([90,0,0]){
                linear_extrude(height=slotHeight, center=true){
                    polygon(points=pointArrayMultiConnectCompatible);
                }
            } 
            linear_extrude(height=slotDepth*2, center=true){
                translate([slotWidthLarge/2, -slotHeight/2-entryHeight/2-slotWidthLarge/2+1, slotDepth]){
                    hull(){
                        translate([-slotWidthLarge/4, entryHeight/2, 0]) circle(r=slotWidthLarge/2);  
                        translate([slotWidthLarge/4, entryHeight/2, 0]) circle(r=slotWidthLarge/2);  
                        translate([slotWidthLarge/4, -entryHeight/2, 0]) circle(r=slotWidthLarge/2);  
                        translate([-slotWidthLarge/4, -entryHeight/2, 0]) circle(r=slotWidthLarge/2);  
                    }
                }
            }
        }
    }
}

module plaque(){
    difference(){
        if(Show_Components == "both" || Show_Components == "sign"){ 
            union(){
                base();
                sign();
                border();
            }
        }
        if(Show_Components == "placement"){ 
            # union(){
                base();
                sign();
                border();
            }
        }
        if(Show_Components == "both" || Show_Components == "slot"){
            slot();
        }
    }
}

module base(){
    color(Base_Color) {
        if(Base_Shape == "circle"){
            cylinder(d=Base_Diameter, h=Base_Height, center=false);
        } else if(Base_Shape == "rectangle"){
            translate([0, 0, Base_Height/2]){
                cuboid([Base_X_Size, Base_Y_Size, Base_Height], rounding=Base_Corner_Rounding, edges=["Z"]);
            }
        } else if(Base_Shape == "heart"){
            translate([0, 0, Base_Height/2]){
                linear_extrude(height = Base_Height) {
                    heart(width=Base_X_Size, height=Base_Y_Size);
                }
            }
        }
    }
}

module border(){
    if(Border_Width > 0){
        color(Border_Color){
            translate([0, 0, 0]){
                if(Base_Shape == "circle"){
                    difference(){
                        cylinder(d=Base_Diameter, h=Border_Height, center=false);
                        cylinder(d=Base_Diameter-Border_Width, h=Border_Height, center=false);
                    }
                } else if(Base_Shape == "rectangle"){
                    translate([0, 0, Border_Height/2]){
                        difference(){
                            cuboid([Base_X_Size, Base_Y_Size, Border_Height], rounding=Base_Corner_Rounding, edges=["Z"]);
                            cuboid([Base_X_Size-Border_Width, Base_Y_Size-Border_Width, Border_Height], rounding=Base_Corner_Rounding, edges=["Z"]);
                        }
                    }
                } else if(Base_Shape == "heart"){
                    translate([0, 0, Border_Height/2]){
                        linear_extrude(height = Base_Height) {
                            difference(){
                                heart(width=Base_X_Size, height=Base_Y_Size);
                                scale([(Base_X_Size-Border_Width)/Base_X_Size, (Base_Y_Size-Border_Width)/Base_Y_Size]){
                                    heart(width=Base_X_Size, height=Base_Y_Size);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
}

string_split = function(s, sep=" ")
    sep == "" ? [for(i = [0:1:len(s) - 1]) s[i]]
    : let(
        slen = len(s),
        seplen = len(sep),
        // Concatenate a character array into a string using divide-and-conquer (O(log n) depth)
        _concat_chars = function(chars, b, e)
            let(n = e - b)
                n <= 0 ? ""
                : n == 1 ? chars[b]
                : let(m = b + floor(n / 2))
                    str(_concat_chars(chars, b, m), _concat_chars(chars, m, e)),
        // Build a substring from index start to end (exclusive)
        _sub = function(start, end)
            start >= end ? ""
            : let(chars = [for(i = [start:1:end - 1]) s[i]])
                _concat_chars(chars, 0, len(chars)),
        // Find the next occurrence of sep starting at pos; returns -1 if not found
        _find = function(pos)
            pos + seplen > slen ? -1
            : let(all_match = len([for(i = [0:1:seplen - 1]) if(s[pos + i] != sep[i]) false]) == 0)
                all_match ? pos
                : _find(pos + 1),
        // Walk through the string, splitting on each sep occurrence
        _split = function(start, result)
            let(found = _find(start))
                found < 0 ? concat(result, [_sub(start, slen)])
                : _split(found + seplen, concat(result, [_sub(start, found)]))
    )
    _split(0, []);

module multiline_text(text_value, font, size, halign="left", valign="baseline", delimiter="|", line_height=undef) {
    text_lines = string_split(text_value, delimiter);
    resolved_line_height = is_undef(line_height) ? size+2 : line_height;

    for(line_index = [0:1:len(text_lines) - 1]) {
        translate([0, -line_index * resolved_line_height, 0]) {
            text(text=text_lines[line_index], size=size, font=font, halign=halign, valign=valign);
        }
    }
}


module heart(width, height = 0) { // 0 = auto height
    w = width; h = height;
    r = 2 * w/7; // top circle radius
    i = r/4.0; // top circle intersect-part width
    rc = 2.0 * r; // center circle raidus
    rb = 3.0 * rc; // bottom circel radius
    j = rb/3; // bottom circle join-part width

    // center y offset
    yc = sqrt((rc -r) * (rc -r) - (r -i) * (r -i));
    wh = [2.0* rc * (r - i) / (rc - r), rc - yc];

    // bottom y offset
    yb = 2 * rb / sqrt(3) - yc;
    
    // bottom rectangle offset, width, height
    yt = rc * (yc + yb) / (rc + rb) - yc;
    wb = 2.0 * rc * (rb -j) /(rb +rc);
    hb = yb - sqrt(rb * rb - (rb -j) * (rb -j));
  
    // height of the heart
    h0 = r +yb - sqrt(rb *rb - (rb -j) * (rb -j));

    scale([1, h > 0 && h != h0 ? h/h0 : 1]) union() {
        translate([-r +i, 0, 0]) circle(r);
        translate([r -i, 0, 0]) circle(r);
        intersection() {
            translate([0, yc, 0]) circle(rc);
            translate([-wh[0]/2.0, yc -rc, 0]) square(wh);
        } 
        difference() {
           translate([-wb/2.0, -yt -hb]) square([wb, hb]);
           union() {
                translate([-rb +j, -yb, 0]) circle(rb);
                translate([rb -j, -yb, 0]) circle(rb);
            }
        }
    }
}