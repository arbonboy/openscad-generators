include <BOSL2/std.scad>


/* [Base Parameters] */
Base_Diameter = 245; //[10:1:800]
// Set to 0 to omit the base and just have the sign
Base_Height = 0; //[0:0.1:20]
Base_Color = "white"; //[aqua,black,blue,brown,cyan,darkgray,gray,green,lightgray,lime,magenta,orange,purple,red,silver,white,yellow,navy,violet]

/* [Mounting Tag Parameters] */
// Set to 0 to omit the mounting tag
Mounting_Hole_Diameter = 5; //[0:0.1:20]
Mounting_Hole_Wall_Thickness = 2; //[0:0.1:20]
Mounting_Tag_Length = 8; //[0:1:40]
Mounting_Tag_Thickness = 4; //[0:0.1:20]
Tag_Color = "white"; //[aqua,black,blue,brown,cyan,darkgray,gray,green,lightgray,lime,magenta,orange,purple,red,silver,white,yellow,navy,violet]

/*[Border Parameters] */
// Set to 0 to omit the border
Border_Width = 5; //[0:0.1:20]
Border_Height = 8; //[0:0.1:20]
Border_Color = "white"; //[aqua,black,blue,brown,cyan,darkgray,gray,green,lightgray,lime,magenta,orange,purple,red,silver,white,yellow,navy,violet]


/* [Top Round Text] */
// Set to "" to omit the top round text
TopRoundText = "JOHN & AMBER"; 
TopRoundText_Size = 16; //[1:1:100]
TopRoundText_Font = "Graduate"; //[Bevan,BioRhyme,Oldenburg,OrelegaOne,Aleo,Graduate,Moul,Arbutus,StintUltraCondensed,Besley,FaunaOne,MaidenOrange,RobotoSlab,SpecialElite,AlfaSlabOne,Battambang,BreeSerif,HeptaSlab,MontaguSlab,EpundaSlab,Hanuman,Arvo,KellySlab,Ultra]
TopRoundText_Height = 8; //[1:1:100]
TopRoundText_Offset_X = 0; //[-300:1:300]
TopRoundText_Offset_Y = 0; //[-300:1:300]
TopRoundText_Color = "white"; //[aqua,black,blue,brown,cyan,darkgray,gray,green,lightgray,lime,magenta,orange,purple,red,silver,white,yellow,navy,violet]

/* [Bottom Round Text] */
// Set to "" to omit the bottom round text
BottomRoundText = "EST. 1997"; 
BottomRoundText_Size = 16; //[1:1:100]
BottomRoundText_Font = "Graduate"; //[Bevan,BioRhyme,Oldenburg,OrelegaOne,Aleo,Graduate,Moul,Arbutus,StintUltraCondensed,Besley,FaunaOne,MaidenOrange,RobotoSlab,SpecialElite,AlfaSlabOne,Battambang,BreeSerif,HeptaSlab,MontaguSlab,EpundaSlab,Hanuman,Arvo,KellySlab,Ultra]
BottomRoundText_Height = 8; //[1:1:100]
BottomRoundText_Offset_X = 0; //[-300:1:300]
BottomRoundText_Offset_Y = 0; //[-300:1:300]
BottomRoundText_Color = "white"; //[aqua,black,blue,brown,cyan,darkgray,gray,green,lightgray,lime,magenta,orange,purple,red,silver,white,yellow,navy,violet]

/* [Middle Horizontal Text] */
// Set to "" to omit the middle horizontal text
MiddleHorizontalText = "ANDERSEN"; 
MiddleHorizontalText_Size = 15; //[1:1:100]
MiddleHorizontalText_Font = "Graduate"; //[Bevan,BioRhyme,Oldenburg,OrelegaOne,Aleo,Graduate,Moul,Arbutus,StintUltraCondensed,Besley,FaunaOne,MaidenOrange,RobotoSlab,SpecialElite,AlfaSlabOne,Battambang,BreeSerif,HeptaSlab,MontaguSlab,EpundaSlab,Hanuman,Arvo,KellySlab,Ultra]
MiddleHorizontalText_Height = 8; //[1:1:100]
MiddleHorizontalText_Offset_X = 0; //[-300:1:300]
MiddleHorizontalText_Offset_Y = -40; //[-300:1:300]
MiddleHorizontalText_Color = "white"; //[aqua,black,blue,brown,cyan,darkgray,gray,green,lightgray,lime,magenta,orange,purple,red,silver,white,yellow,navy,violet]

/* [Center Monogram] */
// Set to "" to omit the center monogram
CenterMonogram = "A"; 
CenterMonogram_Size = 120; //[1:1:300]
CenterMonogram_Font = "Allura"; //[Allura,Beau Rivage,Charm,Cookie,Ephesis,Euphoria Script,Felipa,Gwendolyn,Imperial Script,Island Moments,Italianno,Lavishly Yours,Lugrasimo,Luxurious Script,Manufacturing Consent,Meie Script,Monsieur La Doulaise,Parisienne,Pinyon Script,Romanesco,Rouge Script,Tangerine,Updock]
CenterMonogram_Height = 8; //[1:1:100]
CenterMonogram_Offset_X = -10; //[-300:1:300]
CenterMonogram_Offset_Y = 20; //[-300:1:300]
CenterMonogram_Color = "white"; //[aqua,black,blue,brown,cyan,darkgray,gray,green,lightgray,lime,magenta,orange,purple,red,silver,white,yellow,navy,violet]



/* [Hidden] */
$fn = 80;
Inner_Border_Diameter = Base_Diameter - max(TopRoundText_Size, BottomRoundText_Size)*2-Border_Width*2-1;
Base_Shape = "circle"; //[circle:Circle,rectangle:Rectangle,heart:Heart]

plaque();



module sign(){
    topRoundText();
    bottomRoundText();
    difference(){
        centerMonogram();
        middleHorizontalText(cutting=true);
    }
    middleHorizontalText();
    
    
}


module plaque(){
    union(){
        base();
        sign();
        border();
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
    translate([0, Base_Diameter/2+Mounting_Tag_Length/2, Mounting_Tag_Thickness/2]){
        mountingTag();
    }
}

module border(cutting=false){
    if(Border_Width > 0){
                
        if(cutting){
            translate([0, 0, -Border_Height*100]){
                difference(){
                    cylinder(d=Base_Diameter, h=Border_Height*200, center=false);
                    cylinder(d=Inner_Border_Diameter-Border_Width*2, h=Border_Height*200, center=false);
                }
            }
        } else {
            color(Border_Color){
                translate([0, 0, 0]){
                    difference(){
                        cylinder(d=Base_Diameter, h=Border_Height, center=false);
                        # cylinder(d=Base_Diameter-Border_Width*2, h=Border_Height, center=false);
                    }
                    difference(){
                        cylinder(d=Inner_Border_Diameter, h=Border_Height, center=false);
                        # cylinder(d=Inner_Border_Diameter-Border_Width*2, h=Border_Height, center=false);
                    }
                }
            }
        }
        
    }
    
}

module topRoundText(){
    if(TopRoundText != ""){
        initialTopRoundTextYOffset = Border_Width + TopRoundText_Size;
        color(TopRoundText_Color){
            translate([TopRoundText_Offset_X, -0, 0]){
                rotate([0, 0, 0]){
                    linear_extrude(height = TopRoundText_Height){
                        arc_copies(r=Inner_Border_Diameter/2, n=len(TopRoundText), sa=25, ea=155)
                            text(select(TopRoundText,-1-$idx), size=TopRoundText_Size, font=TopRoundText_Font, anchor=str("baseline",CENTER), spin=-90);
                    }
                }
            }
        }
    }
}

module bottomRoundText(){
    if(BottomRoundText != ""){
        color(BottomRoundText_Color){
            translate([BottomRoundText_Offset_X, BottomRoundText_Offset_Y, 0]){
                rotate([0, 0, 0]){
                    linear_extrude(height = BottomRoundText_Height){
                        arc_copies(r=Base_Diameter/2-Border_Width, n=len(BottomRoundText), sa=230, ea=310)
                            text(select(BottomRoundText,$idx), size=BottomRoundText_Size, font=BottomRoundText_Font, anchor=str("baseline",CENTER), spin=90);
                    }
                }
            }
        }
    }
}

module middleHorizontalText(cutting=false){
    if(MiddleHorizontalText != ""){
        translate([0, MiddleHorizontalText_Offset_Y, 0]){
            
            if(cutting){
                translate([0, 0, Border_Height/2]){
                    color("red"){
                        cube([Inner_Border_Diameter, MiddleHorizontalText_Size+2*Border_Width, 20*Border_Height], center=true);
                    }
                }
            } else {
                translate([0, 0, MiddleHorizontalText_Height/2]){
                    difference(){
                        union(){
                            //translate([0, MiddleHorizontalText_Size-Border_Width, 0]){
                            translate([0, MiddleHorizontalText_Size/2+Border_Width/2, 0]){
                                color(Border_Color){
                                    cube([Inner_Border_Diameter-Border_Width/2, Border_Width, Border_Height], center=true);
                                }
                            }
                            color(MiddleHorizontalText_Color){
                                //translate([MiddleHorizontalText_Offset_X, -initialMiddleHorizontalTextYOffset, -MiddleHorizontalText_Height/2]){
                                translate([MiddleHorizontalText_Offset_X, -MiddleHorizontalText_Size/2, -MiddleHorizontalText_Height/2]){
                                    rotate([0, 0, 0]){
                                        linear_extrude(height = MiddleHorizontalText_Height){
                                            text(text=MiddleHorizontalText, font=MiddleHorizontalText_Font, size=MiddleHorizontalText_Size, halign="center");
                                        }
                                    }
                                }
                            }
                            
                            translate([0, -MiddleHorizontalText_Size/2-Border_Width/2, 0]){
                                color(Border_Color){
                                    cube([Inner_Border_Diameter-Border_Width/2, Border_Width, Border_Height], center=true);
                                }
                            }
                        }
                        translate([0, -MiddleHorizontalText_Offset_Y, 0]){
                            border(cutting=true);
                        }
                    }
                }
            }
        }
    }
}

module centerMonogram(){
    if(CenterMonogram != ""){;
        color(CenterMonogram_Color){
            translate([CenterMonogram_Offset_X, CenterMonogram_Offset_Y-CenterMonogram_Size/2, 0]){
                rotate([0, 0, 0]){
                    linear_extrude(height = CenterMonogram_Height){
                        text(text=CenterMonogram, font=CenterMonogram_Font, size=CenterMonogram_Size, halign="center");
                    }
                }
            }
        }
    }
}

module mountingTag(){
    if(Mounting_Hole_Diameter > 0){
        mountingTagWidth = Mounting_Hole_Diameter+Mounting_Hole_Wall_Thickness*2;
        color(Tag_Color){
            difference(){
                cylinder(d=mountingTagWidth, h=Mounting_Tag_Thickness, center=true);
                cylinder(d=Mounting_Hole_Diameter, h=Mounting_Tag_Thickness, center=true);
            }
            translate([0, -mountingTagWidth/2, 0]){
                difference(){
                    cube([mountingTagWidth, Mounting_Tag_Length, Mounting_Tag_Thickness], center=true);
                    translate([0, Mounting_Tag_Length/2, 0]){
                        cylinder(d=Mounting_Hole_Diameter, h=Mounting_Tag_Thickness, center=true);
                    }
                }
            }
        }
       
    
        
    }
}