include <BOSL2/std.scad>


/* [Base Parameters] */
Base_X_Size = 180; //[160:5:300]
Base_Y_Size = 120; //[80:5:300]
Base_Height = 5; //[5:1:10]
Base_Color = "white"; //[aqua,black,blue,brown,burlywood,chocolate,cyan,darkgray,gray,green,lightgray,lime,magenta,orange,purple,red,silver,white,yellow,navy,violet]

/*[Border Parameters] */
Border_Width = 8; //[0:1:20]
Border_Height = 9; //[5:1:20]
Border_Color = "black";  //[aqua,black,blue,brown,burlywood,chocolate,cyan,darkgray,gray,green,lightgray,lime,magenta,orange,purple,red,silver,white,yellow,navy,violet]

/* [Left Image] */
Svg1 = "tractor.svg"; //["":None,"tractor.svg":Tractor,"pingpong.svg":Ping Pong, "basketball.svg":Basketball, "football.svg":Football, "soccer.svg":Soccer Ball, "star1.svg":Star 1, "tennis.svg":Tennis]
Svg1_Height = 8; //[5:1:20]
Svg1_Color = "black"; //[aqua,black,blue,brown,burlywood,chocolate,cyan,darkgray,gray,green,lightgray,lime,magenta,orange,purple,red,silver,white,yellow,navy,violet]

/* [Right Image] */
Svg2 = "pingpong.svg"; //["":None,"tractor.svg":Tractor,"pingpong.svg":Ping Pong, "basketball.svg":Basketball, "football.svg":Football, "soccer.svg":Soccer Ball, "star1.svg":Star 1, "tennis.svg":Tennis]
Svg2_Height = 8; //[5:1:20]
Svg2_Color = "black"; //[aqua,black,blue,brown,burlywood,chocolate,cyan,darkgray,gray,green,lightgray,lime,magenta,orange,purple,red,silver,white,yellow,navy,violet]


/* [Text 1] */
Text1 = "Dad"; 
Text1_Size = 24; //[10:1:50]
Text1_Font = "Charm"; //[Allura,Beau Rivage,Charm, Charter, Cookie,Ephesis,Euphoria Script,Felipa,Gwendolyn,Imperial Script,Island Moments,Italianno,Lavishly Yours,Lugrasimo,Luxurious Script,Manufacturing Consent,Meie Script,Monsieur La Doulaise,Parisienne,Pinyon Script,Romanesco,Rouge Script,Tangerine,Updock]
Text1_Height = 10; //[5:1:20]
// Text1_Offset_X = 0; //[-300:0.1:300]
// Text1_Offset_Y = -10; //[-300:0.1:300]
Text1_Color = "chocolate"; //[aqua,black,blue,brown,burlywood,chocolate,cyan,darkgray,gray,green,lightgray,lime,magenta,orange,purple,red,silver,white,yellow,navy,violet]

/* [Text 2] */
Text2 = "We love you"; 
Text2_Size = 10; //[10:1:50]
Text2_Font = "Charter"; //[Allura,Beau Rivage,Charm, Charter, Cookie,Ephesis,Euphoria Script,Felipa,Gwendolyn,Imperial Script,Island Moments,Italianno,Lavishly Yours,Lugrasimo,Luxurious Script,Manufacturing Consent,Meie Script,Monsieur La Doulaise,Parisienne,Pinyon Script,Romanesco,Rouge Script,Tangerine,Updock]
Text2_Height = 6; //[5:1:20]
// Text2_Offset_X = 0; //[-300:0.1:300]
// Text2_Offset_Y = -20; //[-300:0.1:300]
Text2_Color = "chocolate"; //[aqua,black,blue,brown,burlywood,chocolate,cyan,darkgray,gray,green,lightgray,lime,magenta,orange,purple,red,silver,white,yellow,navy,violet]

/* [Text 3] */
Text3 = "and miss you!"; 
Text3_Size = 10; //[10:1:50]
Text3_Font = "Charter"; //[Allura,Beau Rivage,Charm, Charter, Cookie,Ephesis,Euphoria Script,Felipa,Gwendolyn,Imperial Script,Island Moments,Italianno,Lavishly Yours,Lugrasimo,Luxurious Script,Manufacturing Consent,Meie Script,Monsieur La Doulaise,Parisienne,Pinyon Script,Romanesco,Rouge Script,Tangerine,Updock]
Text3_Height = 6; //[5:1:20]
// Text3_Offset_X = 0; //[-300:0.1:300]
// Text3_Offset_Y = -35; //[-300:0.1:300]
Text3_Color = "chocolate"; //[aqua,black,blue,brown,burlywood,chocolate,cyan,darkgray,gray,green,lightgray,lime,magenta,orange,purple,red,silver,white,yellow,navy,violet]

/* [Text 4] */
Text4 = "test"; 
Text4_Size = 10; //[10:1:50]
Text4_Font = "Charter"; //[Allura,Beau Rivage,Charm, Charter, Cookie,Ephesis,Euphoria Script,Felipa,Gwendolyn,Imperial Script,Island Moments,Italianno,Lavishly Yours,Lugrasimo,Luxurious Script,Manufacturing Consent,Meie Script,Monsieur La Doulaise,Parisienne,Pinyon Script,Romanesco,Rouge Script,Tangerine,Updock]
Text4_Height = 6; //[5:1:20]
// Text4_Offset_X = 0; //[-300:0.1:300]
// Text4_Offset_Y = -18; //[-300:0.1:300]
Text4_Color = "chocolate"; //[aqua,black,blue,brown,burlywood,chocolate,cyan,darkgray,gray,green,lightgray,lime,magenta,orange,purple,red,silver,white,yellow,navy,violet]








/* [Hidden] */
$fn = 80;
svgBasePath = "svg/";
Show_Components = "both"; //[both:Both, sign:Sign only, slot:Slot only, placement:Transparent object with solid slot]
Base_Shape = "heart"; //[circle:Circle,rectangle:Rectangle,heart:Heart]
Base_Diameter = 130; 
Base_Corner_Rounding = 3; //[0: 0.5: 15]
QR_Message = ""; 
QR_Error_Correction = "M"; //[L, M, Q, H]
QR_Size = 60; //[10:1:200]
QR_Height = 18; //[0:0.1:10]
QR_Extrusion = 0; //[0:0.1:10]
QR_Center = true;
QR_Y_Offset = 0; //[-500:1:500]
QR_X_Offset = 0; //[-500:1:500]
Text1_Offset_X = 0; //[-300:0.1:300]
Text1_Offset_Y = -Text1_Size/2; //[-300:0.1:300]
Text2_Offset_X = 0; //[-300:0.1:300]
Text2_Offset_Y = Text1_Offset_Y-Text2_Size*2; //[-300:0.1:300]
Text3_Offset_X = 0; //[-300:0.1:300]
Text3_Offset_Y = Text2_Offset_Y-Text3_Size*3/2; //[-300:0.1:300]
Text4_Offset_X = 0; //[-300:0.1:300]
Text4_Offset_Y = Text3_Offset_Y-Text4_Size*3/2; //[-300:0.1:300]
Svg1_Scale_X = 1; //[0.01:0.01:4]
Svg1_Scale_Y = 1; //[0.01:0.01:4]
Svg1_Size_X = Base_X_Size/4; //[10:1:300]
Svg1_Size_Y = Base_Y_Size/4; //[10:1:300]
Svg1_Offset_X = -Base_X_Size/2+Svg1_Size_X*2/3; //[-300:0.1:300]
Svg1_Offset_Y = Base_Y_Size/2-Svg1_Size_Y*3/2; //[-300:0.1:300]
Svg2_Scale_X = 1; //[0.01:0.01:4]
Svg2_Scale_Y = 1; //[0.01:0.01:4]
Svg2_Size_X = Base_X_Size/4; //[10:1:300]
Svg2_Size_Y = Base_Y_Size/4; //[10:1:300]
Svg2_Offset_X = Base_X_Size/2-Svg2_Size_X*2/3; //[-300:0.1:300]
Svg2_Offset_Y = Base_Y_Size/2-Svg2_Size_Y*3/2; //[-300:0.1:300]
Svg3 = ""; 
Svg3_Scale_X = 1; //[0.01:0.01:4]
Svg3_Scale_Y = 1; //[0.01:0.01:4]
Svg3_Offset_X = 0; //[-300:0.1:300]
Svg3_Offset_Y = 0; //[-300:0.1:300]
Svg3_Height = 1.5; //[5:1:20]
Svg3_Color = "burlywood"; //[aqua,black,blue,brown,burlywood,chocolate,cyan,darkgray,gray,green,lightgray,lime,magenta,orange,purple,red,silver,white,yellow,navy,violet]





Show_Slot_For_Reference = true;
Slot_Channel_Width_Large_End = 20;
Slot_Channel_Width_Small_End = 15;
Slot_Entry_Diameter = Slot_Channel_Width_Large_End + 0;
Slot_Depth = 4;
Slot_Height = 50; //[10:1:100]
Slot_Tolerance = 0.2; //[0:0.1:5]
Slot_Entry_Height = 35; //[10:1:100]
Slot_Offset = [0,-Base_Y_Size/2+Slot_Height/2,Slot_Depth/2];  //[-100:0.1:100] 
Slot_Rotation = [0,0,0];


plaque();


module sign(){
    if(Svg1 != ""){
        color(Svg1_Color){
            translate([Svg1_Offset_X, Svg1_Offset_Y, Svg1_Height/2]){
                rotate([0, 0, 0]){
                    scale([Svg1_Scale_X, Svg1_Scale_Y, 1]){
                        resize([30, 30, 0]){
                            linear_extrude(height = Svg1_Height){
                                import(file=str(svgBasePath,Svg1), convexity=10, center=true);
                            }
                        }
                    }
                }
            }
        }
    } 
    if(Svg2 != ""){
        color(Svg2_Color){
            translate([Svg2_Offset_X, Svg2_Offset_Y, Svg2_Height/2]){
                rotate([0, 0, 0]){
                    scale([Svg2_Scale_X, Svg2_Scale_Y, 1]){
                        resize([30, 30, 0]){
                            linear_extrude(height = Svg2_Height){
                                import(file=str(svgBasePath,Svg2), convexity=10, center=true);
                            }
                        }
                         
                    }
                }
            }
        }
    } 
    if(Svg3 != ""){
        color(Svg1_Color){
            translate([Svg3_Offset_X, Svg3_Offset_Y, 0]){
                rotate([0, 0, 0]){
                    scale([Svg3_Scale_X, Svg3_Scale_Y, 1]){
                        linear_extrude(height = Svg3_Height){
                            import(file=str(svgBasePath,Svg3), convexity=10, center=true);
                        } 
                    }
                }
            }
        }
    }
    if(Text1 != ""){
        color(Text1_Color){
            translate([Text1_Offset_X, Text1_Offset_Y, Text1_Height/2]){
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
            translate([Text2_Offset_X, Text2_Offset_Y, Text2_Height/2]){
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
            translate([Text3_Offset_X, Text3_Offset_Y, Text3_Height/2]){
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
            translate([Text4_Offset_X, Text4_Offset_Y, Text4_Height/2]){
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
    
    pointArrayMultiConnectCompatible=[
        [(slotWidthLarge-slotWidthSmall)/2,0],
        [1, slotDepth-1],
        [1, slotDepth],
        [slotWidthLarge-1, slotDepth],
        [slotWidthLarge-1, slotDepth-1],
        [(slotWidthLarge-slotWidthSmall)/2+slotWidthSmall,0],
        [0,0]
    ];
    
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
            color(Base_Color){
                slot();
            }
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
        scale([0.999, 0.999, 1]){
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