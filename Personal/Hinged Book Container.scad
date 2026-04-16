include <BOSL2/std.scad>
include <BOSL2/hinges.scad>
include <Gridfinity/Gridfinity Rebuilt/src/core/gridfinity-rebuilt-holes.scad>

/* [View Parameters] */
View_Type = "open"; //[open,closed]

/* [Box Parameters] */
Inner_Box_Width = 65; //[10:1:300]
Inner_Box_Height = 90; //[10:1:350]
Box_Left_Depth = 5; //[1:1:100]
Box_Right_Depth = 20; //[1:1:200]
Box_Corner_Rounding = 3; //[0:1:10]
Box_Wall_Thickness = 3; //[1:1:20]

/* [Book Cover Parameters] */
Book_Cover_Margin = 2; //[0:1:8]
Book_Cover_Thickness = 3; //[1:1:10]
Primary_Color = "#10fefe";
// Primary_Color = 0;

/* [Book Spine] */
Spine_Text = "Playing Cards";
Spine_Text_Size = 10; //[6:1:80]
Spine_Text_Font = "Rockwell";
Spine_Text_Color = "white";

/* [Front Cover Text] */
FC_Title_Text_Ln1 = "Playing";
FC_Title_Text_Ln2 = "Cards";
FC_Title_Text_Ln3 = "";
FC_Title_Text_Size = 14; //[6:1:80]
FC_Title_Text_Font = "Rockwell";
FC_Title_Text_Color = "white";
FC_Title_Starting_Y = 0; //[-300:1:300]

/* [Front Cover Image] */
FC_SVG_Image = "default.svg";
FC_SVG_Image_Starting_Pos_Y = 50; //[-300:1:300]
FC_SVG_Image_Scale = [1, 1, 1]; //[0.01:0.01:5]

/* [Magnet Parameters] */
Magnet_Diameter = 5; //[5:0.5:20]
Magnet_Depth = 3; //[1:1:5]
Magnet_Tolerance = 0; //[0:0.1:2]
Magnet_Housing_Type = "circular"; //[circular,square,sidewall]
Magnet_Housing_Wall_Thickness = 1;//[1:0.5:6]
Magnet_Hole_Type = "normal"; //[normal:Normal,ribbed:Crushed Ribs,refined:Refined]
Number_Of_Vertical_Magnets = 2; //[2, 3]
Number_Of_Horizontal_Magnets = 1;//[1, 2]


/* [Hinge Parameters] */
Hinge_Pin_Diameter = 2.3; //[2:0.1:10]
Hinge_Knuckle_Diameter = 5; //[2:1:30]
Hinge_Section_Length = 5; //[2:1:30]

/* [Hidden] */
Spine_Text_Height = 1; 
FC_Title_Text_Height = 1;
Hinge_Fragments = 64;
Hinge_Gap = 0.35;
Hinge_Clearance = 0.15;
Hinge_Rotation_Angle = 0;

Magnet_Housing_Width = 2*Magnet_Housing_Wall_Thickness + Magnet_Diameter;
Box_Width = Magnet_Housing_Type == "sidewall" ? Inner_Box_Width + max(Box_Wall_Thickness, Magnet_Housing_Width) + Box_Wall_Thickness*2 : Inner_Box_Width+Box_Wall_Thickness*2;
Box_Height = Magnet_Housing_Type == "sidewall" ? Inner_Box_Height + 2*max(Box_Wall_Thickness, Magnet_Housing_Width) : Inner_Box_Height+Box_Wall_Thickness*2;

Book_Cover_Height = Box_Height + 2*Book_Cover_Margin;
Book_Cover_Width = Box_Width + Book_Cover_Margin;
Hinge_Leaf_Length = 1;
Hinge_Component_Width = Hinge_Knuckle_Diameter+2*Hinge_Clearance+2*Hinge_Leaf_Length;
Hinge_Offset = Hinge_Knuckle_Diameter/2+0.2;
//Middle_Section_Width = Box_Left_Depth + Box_Right_Depth + 2*Book_Cover_Thickness;
Middle_Section_Width = Box_Left_Depth + Box_Right_Depth + Book_Cover_Thickness - 2*Hinge_Knuckle_Diameter+0*Hinge_Leaf_Length;
Double_Hinge_Component_Width = 2*Hinge_Component_Width + Middle_Section_Width;

// Width Solid is 20.9
// Expected Full Middle Section with Hinges:  LeftDepth+RightDepth+2*CoverTHickness
//.   :  31
// Middle section should be:  LeftDepth+RightDepth+2*CoverThickness-2*HingeKnucleDiameter

book();
// refinedHole();

module bookText(text="DEMO", height=2, font="Tahoma", fontSize=12, fontColor="purple", halign="center", valign="center"){
    color(fontColor){
        linear_extrude(height){
            text(text, size=fontSize, font=font, halign=halign, valign=valign);
        }
    }
}

module spineText(){
    translate([0, 0, -Book_Cover_Thickness/2+Spine_Text_Height]){
        rotate([0, 180, 90]){
            bookText(
                text=Spine_Text,
                height=Spine_Text_Height,
                font=Spine_Text_Font,
                fontSize = Spine_Text_Size,
                fontColor = Spine_Text_Color,
                halign="center",
                valign="center"
            );
        }
            
    }
}

module coverLeftText(){
    translate([0, Box_Height/2-FC_Title_Text_Size-FC_Title_Starting_Y, -Book_Cover_Thickness/2+Spine_Text_Height-0.01]){
        rotate([0, 180, 0]){
            bookText(
                text=FC_Title_Text_Ln1,
                height=Spine_Text_Height,
                font=FC_Title_Text_Font,
                fontSize = FC_Title_Text_Size,
                fontColor = FC_Title_Text_Color,
                halign="center",
                valign="center"
            );
            translate([0, -FC_Title_Text_Size-FC_Title_Text_Height, 0]){
                bookText(
                    text=FC_Title_Text_Ln2,
                    height=Spine_Text_Height,
                    font=FC_Title_Text_Font,
                    fontSize = FC_Title_Text_Size,
                    fontColor = FC_Title_Text_Color,
                    halign="center",
                    valign="center"
                );
                translate([0, -FC_Title_Text_Size-FC_Title_Text_Height, 0]){
                    bookText(
                        text=FC_Title_Text_Ln3,
                        height=Spine_Text_Height,
                        font=FC_Title_Text_Font,
                        fontSize = FC_Title_Text_Size,
                        fontColor = FC_Title_Text_Color,
                        halign="center",
                        valign="center"
                    );
                }
            }
        }
            
    }
    if(FC_SVG_Image != ""){
        translate([0, FC_SVG_Image_Starting_Pos_Y, -Book_Cover_Thickness/2+Spine_Text_Height]){
            rotate([0, 180, 0]){
                color(FC_Title_Text_Color){
                    linear_extrude(height = Spine_Text_Height+0.01)
                        scale(FC_SVG_Image_Scale){
                            import(FC_SVG_Image, center=true);
                            // surface(file=FC_SVG_Image, center=true);
                        }
                } 
            }
            
        }
    }
    
}

module coverRightText(){
    // translate([0, 0, -Book_Cover_Thickness/2+Spine_Text_Height]){
    //     rotate([0, 180, 90]){
    //         bookText(
    //             text=Spine_Text,
    //             height=Spine_Text_Height,
    //             font=Spine_Text_Font,
    //             fontSize = Spine_Text_Size,
    //             fontColor = Spine_Text_Color,
    //             halign="center",
    //             valign="center"
    //         );
    //     }
            
    // }
}

module magnetHousingForBox(side="left", housingPart="circle" /*circle, square, wall, hole*/){
    depth = side == "left" ? Box_Left_Depth : Box_Right_Depth;
    magnetHousingPadding = Magnet_Diameter+Magnet_Housing_Wall_Thickness*2;
    
    if(side=="left"){
        
        translate([0, 0, 0]){
            magnetHousing(depth=depth, magnetDiameter=Magnet_Diameter, magnetDepth=Magnet_Depth, tolerance=Magnet_Tolerance, housingWallThickness=Magnet_Housing_Wall_Thickness, housingPart=housingPart);
        }  
        if(Number_Of_Horizontal_Magnets == 2){
            rotate([0, 0, 0]){
                translate([Box_Width/2 - Magnet_Housing_Width/2, 0, 0]){
                    magnetHousing(depth=depth, magnetDiameter=Magnet_Diameter, magnetDepth=Magnet_Depth, tolerance=Magnet_Tolerance, housingPart=housingPart, zRotate=-90);
                }
            }
        }
        if(Number_Of_Vertical_Magnets == 3){
            translate([0, -Box_Height/2+Magnet_Housing_Width/2, 0]){
                magnetHousing(depth=depth, magnetDiameter=Magnet_Diameter, magnetDepth=Magnet_Depth, tolerance=Magnet_Tolerance, housingWallThickness=Magnet_Housing_Wall_Thickness, housingPart=housingPart);
            }    
        }
        translate([0, -(Box_Height-magnetHousingPadding-0), 0]){
            magnetHousing(depth=depth, magnetDiameter=Magnet_Diameter, magnetDepth=Magnet_Depth, tolerance=Magnet_Tolerance, housingWallThickness=Magnet_Housing_Wall_Thickness, housingPart=housingPart);
        }
        if(Number_Of_Horizontal_Magnets == 2){
            rotate([0, 0, 0]){
                translate([Box_Width/2 - Magnet_Housing_Width/2, -(Box_Height-magnetHousingPadding), 0]){
                    magnetHousing(depth=depth, magnetDiameter=Magnet_Diameter, magnetDepth=Magnet_Depth, tolerance=Magnet_Tolerance, housingWallThickness=Magnet_Housing_Wall_Thickness, housingPart=housingPart, zRotate=90);
                }
            }
        }
    }
    if(side == "right"){
        translate([Box_Width-magnetHousingPadding, 0, 0]){
            magnetHousing(depth=depth, magnetDiameter=Magnet_Diameter, magnetDepth=Magnet_Depth, tolerance=Magnet_Tolerance, housingWallThickness=Magnet_Housing_Wall_Thickness, housingPart=housingPart, zRotate=180);
        }
        if(Number_Of_Horizontal_Magnets == 2){
            rotate([0, 0, 0]){
                translate([Box_Width/2-Magnet_Housing_Width/2, 0, 0]){
                    magnetHousing(depth=depth, magnetDiameter=Magnet_Diameter, magnetDepth=Magnet_Depth, tolerance=Magnet_Tolerance, housingWallThickness=Magnet_Housing_Wall_Thickness, housingPart=housingPart, zRotate=-90);
                }
            }
        }
        if(Number_Of_Vertical_Magnets == 3){
            translate([Box_Width-magnetHousingPadding, -Box_Height/2+Magnet_Housing_Width/2, 0]){
                magnetHousing(depth=depth, magnetDiameter=Magnet_Diameter, magnetDepth=Magnet_Depth, tolerance=Magnet_Tolerance, housingWallThickness=Magnet_Housing_Wall_Thickness, housingPart=housingPart, zRotate=180);
            }    
        }
        translate([Box_Width-magnetHousingPadding, -(Box_Height-magnetHousingPadding), 0]){
            magnetHousing(depth=depth, magnetDiameter=Magnet_Diameter, magnetDepth=Magnet_Depth, tolerance=Magnet_Tolerance, housingWallThickness=Magnet_Housing_Wall_Thickness, housingPart=housingPart, zRotate=180);
        }
        if(Number_Of_Horizontal_Magnets == 2){
            rotate([0, 0, 0]){
                translate([Box_Width/2-Magnet_Housing_Width/2, -(Box_Height-magnetHousingPadding), 0]){
                    magnetHousing(depth=depth, magnetDiameter=Magnet_Diameter, magnetDepth=Magnet_Depth, tolerance=Magnet_Tolerance, housingWallThickness=Magnet_Housing_Wall_Thickness, housingPart=housingPart, zRotate=90);
                }  
            }
        }
    }
}

module magnetHousing(depth=10, magnetDiameter=6, magnetDepth=3, tolerance=0.24, housingWallThickness=3, numberOfRibs=8, housingPart="circle" /*circle, square, wall, hole*/, zRotate=0){
    $fn=48;
    translate([0, 0, depth/2]){
        rotate([0, 0, 0]){
            difference(){
                if(housingPart == "circular"){
                    translate([0, 0, -depth/2]){
                        cylinder(h=depth, d=Magnet_Housing_Width, center=true);
                    }
                } else if(housingPart == "square"){
                    translate([0, 0, -depth/2]){
                        cuboid([Magnet_Housing_Width, Magnet_Housing_Width, depth], rounding=1, edges=[FWD+LEFT, FWD+RIGHT, BACK+LEFT, BACK+RIGHT]);
                    }
                } else if(housingPart == "hole"){
                    if(Magnet_Hole_Type == "normal"){
                        translate([0, 0, -(magnetDepth)/2]) {
                            cylinder(
                                d=magnetDiameter+tolerance, 
                                h=magnetDepth,
                                $fn = 48,
                                center=true
                            );
                        }
                    } else if(Magnet_Hole_Type == "ribbed"){
                        ribbed_cylinder(
                            outer_radius=magnetDiameter/2+tolerance/2, 
                            inner_radius = magnetDiameter/2, 
                            height=magnetDepth, 
                            ribs=numberOfRibs
                        );
                    } else if(Magnet_Hole_Type == "refined"){
                        refinedHole(holeHeight=magnetDepth, holeRadius=magnetDiameter/2, zRotate=zRotate);
                    }
                }
                
            }
        }
    }
}

module book(){
    leftCoverColor = View_Type == "closed" ? Primary_Color : Primary_Color;
    leftTranslateLeftCover = View_Type == "closed" ? [0, 0, Box_Right_Depth+Box_Left_Depth+Book_Cover_Thickness] : [0, 0, 0];
    leftRotateLeftCover = View_Type == "closed" ? [0, 180, 0] : [0, 0, 0];
    translate(leftTranslateLeftCover){
        rotate(leftRotateLeftCover){
            translate([-Book_Cover_Width/2 - Double_Hinge_Component_Width/2, 0, 0]){
                color(leftCoverColor) bookPart(side="left");
                coverLeftText();
            }
        }
    }
    
    translate([Book_Cover_Width/2 + Double_Hinge_Component_Width/2, 0, 0]){
        bookPart(side="right");
        coverRightText();
    }
    
    leftTranslateMiddle = View_Type == "closed" ? [Middle_Section_Width/2+Book_Cover_Thickness, 0, Middle_Section_Width/2+Hinge_Knuckle_Diameter] : [0, 0, 0];
    leftRotateMiddle = View_Type == "closed" ? [0, 90, 0] : [0, 0, 0];
    translate(leftTranslateMiddle){
        rotate(leftRotateMiddle){
            doubleHinge();
        }
    }
    
    if(false){
        translate([-Book_Cover_Width/2 - Double_Hinge_Component_Width/2, 0, 0]){
            color(Primary_Color) bookPart(side="left");
            coverLeftText();
        }
        translate([Book_Cover_Width/2 + Double_Hinge_Component_Width/2, 0, 0]){
            bookPart(side="right");
            coverRightText();
        }
        doubleHinge();
    }

    
}

module box(side="left"){
    box_depth = (side == "right") ? Box_Right_Depth : Box_Left_Depth;
    magnetFullDiameter = Magnet_Diameter+Magnet_Housing_Wall_Thickness*2;
    xTranslate = Magnet_Housing_Type == "sidewall" ? side=="left" ? max(Box_Wall_Thickness, Magnet_Housing_Width)/2 - Box_Wall_Thickness*0  : -max(Box_Wall_Thickness, Magnet_Housing_Width)/2 + Box_Wall_Thickness*0 : 0;
    difference(){
        union(){
            difference(){
                color(Primary_Color) cuboid([Box_Width, Box_Height, box_depth], rounding=Box_Corner_Rounding, edges=[FRONT+LEFT, FRONT+RIGHT, BACK+LEFT, BACK+RIGHT]);
                translate([xTranslate, 0, 0]){
                    //color(Primary_Color) cuboid([Box_Width-2*Box_Wall_Thickness, Box_Height-2*Box_Wall_Thickness, box_depth], rounding=Box_Corner_Rounding, edges=[FRONT+LEFT, FRONT+RIGHT, BACK+LEFT, BACK+RIGHT]);
                    color(Primary_Color) cuboid([Inner_Box_Width, Inner_Box_Height, box_depth], rounding=Box_Corner_Rounding, edges=[FRONT+LEFT, FRONT+RIGHT, BACK+LEFT, BACK+RIGHT]);
                }
                
            }
            translate([-Box_Width/2+magnetFullDiameter/2, Box_Height/2-magnetFullDiameter/2, 0]){
                color(Primary_Color) magnetHousingForBox(side=side, housingPart=Magnet_Housing_Type);
            }
        }
        translate([-Box_Width/2+magnetFullDiameter/2, Box_Height/2-magnetFullDiameter/2, 0]){
                color(Primary_Color) magnetHousingForBox(side=side, housingPart="hole");
            }
    }
}

module bookCover(side="left"){
    cover_width = Book_Cover_Width;
    cover_height = Book_Cover_Height;
    edges = side=="left" ? [FRONT+LEFT, BACK+LEFT] : [FRONT+RIGHT, BACK+RIGHT];

    color(Primary_Color) cuboid([cover_width, cover_height, Book_Cover_Thickness], rounding=Box_Corner_Rounding, edges=edges);
}

module bookPart(side="left"){
    box_depth = (side == "right") ? Box_Right_Depth : Box_Left_Depth;
    xTranslate = (side == "right") ? -Book_Cover_Margin/2 : Book_Cover_Margin/2;
    color(Primary_Color) bookCover(side=side);
    translate([xTranslate, 0, box_depth/2+Book_Cover_Thickness/2]){
        color(Primary_Color) box(side=side);
    }
}

module doubleHinge(){
    middleSectionWidth = Middle_Section_Width;
    translate([0, 0, Hinge_Knuckle_Diameter/4]){
        color(Primary_Color) cube([middleSectionWidth, Book_Cover_Height, Book_Cover_Thickness+Hinge_Knuckle_Diameter/2], center=true);
    }
    spineText();
    leftHingeRotation = View_Type == "closed" ? [180, 180, 0] : [0, 0, 0];
    leftHingeTranslation = View_Type == "closed" ? [-Middle_Section_Width-Hinge_Knuckle_Diameter*1-Hinge_Leaf_Length*2, 0, 0] : [0, 0,0 ];
    translate(leftHingeTranslation) {
        rotate(leftHingeRotation) {
            translate([-(Hinge_Component_Width+middleSectionWidth)/2, 0, 0]){
               color(Primary_Color)  hinge();
            }
        }

    }   
    translate([(Hinge_Component_Width+middleSectionWidth)/2, 0, 0]){
       color(Primary_Color) hinge();
    }   
    // translate([Hinge_Component_Width/2-Double_Hinge_Component_Width/2, 0, 0]){
    //     hinge();
    //     translate([middleSectionWidth/2+Hinge_Knuckle_Diameter/2+Hinge_Clearance, 0, 0]){
    //         cube([middleSectionWidth, Book_Cover_Height, Book_Cover_Thickness], center=true);
    //         translate([middleSectionWidth/2+Hinge_Knuckle_Diameter/2+Hinge_Clearance, 0, 0]){
    //             hinge();
    //         }
    //     }
    // }
}



module hinge(side="left"){
    $fn = Hinge_Fragments;
    hingeKnuckleDiameter = Hinge_Knuckle_Diameter;       // Hinge knuckle diameter
    gapBetweenHingeSegments = Hinge_Gap; // Gap between hinge segments
    hingeClearance = Hinge_Clearance;   // Clearance so hinge will close all the way
    // hingeRotationAngle=Hinge_Rotation_Angle;          // Hinge rotation angle
    hingeRotationAngle = View_Type == "closed" ? side == "left" ? 90 : -90 : 0;

    module myhinge(inner){
        knuckle_hinge(
            length=Book_Cover_Height, 
            segs=max(5,ceil(Book_Cover_Height/Hinge_Section_Length)),
            offset=Hinge_Offset, 
            inner=inner, 
            clearance=hingeClearance, 
            knuckle_diam=hingeKnuckleDiameter,
            pin_diam=Hinge_Pin_Diameter, 
            arm_angle=28, 
            gap=gapBetweenHingeSegments, 
            in_place=false, 
            anchor=CTR,
            teardrop=true,
            //clip=2+hingeClearance
            clip=Book_Cover_Thickness+hingeClearance
        ){
            children();
        }
        //knuckle_hinge(length=25, segs=11,offset=3.2, inner=inner, clearance=clear, knuckle_diam=diam,
                        // pin_diam=diam-0.2, arm_angle=40, gap=seg_gap, in_place=false, anchor=CTR,clip=2+clear)
    }

    
    module leaf(){
        cuboid(
            [Book_Cover_Height,Book_Cover_Thickness,Hinge_Leaf_Length],
            anchor=TOP+BACK,
            rounding=0,
            edges=[BOT+LEFT,BOT+RIGHT]
        );
    } 
    hingeRightComponentColor = View_Type == "closed" ? "lightblue" : 0;
    translate([0, 0, Book_Cover_Thickness/2]){
        rotate([90, 0, 90]){    // Rotate to printing orientation
            myhinge(true) position(BOT) leaf();
            color(hingeRightComponentColor){
                xrot(180-hingeRotationAngle,cp=[0,hingeClearance,0])
                zrot(180,cp=[0,hingeClearance,0])
                myhinge(false) position(BOT) leaf();
            }
        }
    }
}


module hingeOrigDelme(){
    $fn = Hinge_Fragments;
    hingeKnuckleDiameter = Hinge_Knuckle_Diameter;       // Hinge knuckle diameter
    gapBetweenHingeSegments = Hinge_Gap; // Gap between hinge segments
    hingeClearance = Hinge_Clearance;   // Clearance so hinge will close all the way
    hingeRotationAngle=Hinge_Rotation_Angle;          // Hinge rotation angle

    module myhinge(inner){
        knuckle_hinge(
            length=Book_Cover_Height, 
            segs=Book_Cover_Height/10,
            offset=1.2, 
            inner=inner, 
            clearance=hingeClearance, 
            knuckle_diam=hingeKnuckleDiameter,
            pin_diam=hingeKnuckleDiameter-0.2, 
            arm_angle=28, 
            gap=gapBetweenHingeSegments, 
            in_place=true, 
            anchor=CTR,
            //clip=2+hingeClearance
            clip=Book_Cover_Thickness+hingeClearance
        ){
            children();
        }
    }

    

    
    module leaf(){
        cuboid(
            [Book_Cover_Height,Book_Cover_Thickness,Hinge_Leaf_Length],
            anchor=TOP+BACK,
            rounding=0,
            edges=[BOT+LEFT,BOT+RIGHT]
        );
    } 

    translate([0, 0, Book_Cover_Thickness/2]){
        rotate([90, 0, 90]){    // Rotate to printing orientation
            myhinge(true) position(BOT) leaf();
            color("lightblue"){
                xrot(180-hingeRotationAngle,cp=[0,hingeClearance,0])
                zrot(180,cp=[0,hingeClearance,0])
                myhinge(false) position(BOT) leaf();
            }
        }
    }
}



module test(){
    $fn = 64;
    diam = 2;       // Hinge knuckle diameter
    seg_gap = 0.15; // Gap between hinge segments
    clear = 0.15;   // Clearance so hinge will close all the way
    ang=0;          // Hinge rotation angle
    module myhinge(inner)
    knuckle_hinge(length=25, segs=11,offset=1.2, inner=inner, clearance=clear, knuckle_diam=diam,
                    pin_diam=diam-0.2, arm_angle=40, gap=seg_gap, in_place=true, anchor=CTR,clip=2+clear)
        children();
    module leaf() cuboid([25,2,12],anchor=TOP+BACK,rounding=7,edges=[BOT+LEFT,BOT+RIGHT]);
    xrot(90){    // Rotate to printing orientation
    myhinge(true) position(BOT) leaf();
    color("lightblue")
        xrot(180-ang,cp=[0,clear,0])
        zrot(180,cp=[0,clear,0])
        myhinge(false) position(BOT) leaf();
    }
}

module test2(){
    $fn=64;
    thickness=6;
    seg_gap = 0.2;
    end_space = 0.6;
    ang=0;
    module myhinge(inner)
    knuckle_hinge(length=25, segs=13,offset=thickness/2+end_space, inner=inner, clearance=-thickness/2, knuckle_diam=thickness,
                    arm_angle=45, gap=seg_gap, in_place=true, clip=thickness/2)
                    children();
    module leaf() cuboid([25,thickness,25],anchor=TOP+BACK, rounding=7, edges=[BOT+LEFT,BOT+RIGHT]);
    xrot(90)
    myhinge(true){
        position(BOT) leaf();
        color("lightblue")
        up(end_space) attach(BOT,TOP,inside=true)
        tag("")  // cancel default "remove" tag
        xrot(-ang,cp=[0,-thickness/2,thickness/2]) myhinge(false)
            position(BOT) leaf();
    }
}

module test3(){
    $fn=32;
    // cuboid([20,40,2])
    // position(TOP+RIGHT) orient(anchor=RIGHT)
    //     knuckle_hinge(length=35, segs=9, offset=3, arm_height=0,
    //         arm_angle=90, pin_fn=8, clear_top=true);


    cuboid([20,40,2]){
        position(TOP+RIGHT) orient(anchor=RIGHT)
            knuckle_hinge(length=35, segs=9, offset=3, arm_height=0, arm_angle=90, pin_fn=8, clear_top=true,
                seg_ratio=1/3);
        attach(TOP,TOP) color("green")
            cuboid([20,40,2],anchor=TOP)
            position(TOP+LEFT) orient(anchor=LEFT)
                knuckle_hinge(length=35, segs=9, offset=3, arm_height=0, arm_angle=90, pin_fn=8, clear_top=true,
                    seg_ratio=1/3, inner=true);
    }
}

module test4(){
        $fn = 64;
        diam = 3;       // Hinge knuckle diameter
        seg_gap = 0.15; // Gap between hinge segments
        clear = 0.15;   // Clearance so hinge will close all the way
        ang=0;          // Hinge rotation angle
        module myhinge(inner)
        knuckle_hinge(length=25, segs=11,offset=3.2, inner=inner, clearance=clear, knuckle_diam=diam,
                        pin_diam=diam-0.2, arm_angle=40, gap=seg_gap, in_place=false, anchor=CTR,clip=2+clear)
            children();
        module leaf() cuboid([25,2,12],anchor=TOP+BACK,rounding=7,edges=[BOT+LEFT,BOT+RIGHT]);
        xrot(90){    // Rotate to printing orientation
        myhinge(true) position(BOT) leaf();
        color("lightblue")
            xrot(180-ang,cp=[0,clear,0])
            zrot(180,cp=[0,clear,0])
            myhinge(false) position(BOT) leaf();
        }

}

module refinedHole(holeHeight = 3, holeRadius = 6, zRotate=0) {
    refined_offset = LAYER_HEIGHT * REFINED_HOLE_BOTTOM_LAYERS;

    // Poke through - For removing a magnet using a toothpick
    ptl = refined_offset + LAYER_HEIGHT; // Additional layer just in case
    poke_through_height = holeHeight + ptl;
    poke_hole_radius = 2.5;
    magic_constant = 5.60;
    poke_hole_center = [-12.53 + magic_constant, 0, -ptl];

    rotate([0, 180, zRotate]){
        translate([0, 0, refined_offset]){
            union() {
                // Magnet hole
                translate([0, -holeRadius, 0])
                cube([11, holeRadius*2, holeHeight]);
                cylinder(holeHeight, r=holeRadius);

                // Poke hole
                translate([poke_hole_center.x, -poke_hole_radius/2, poke_hole_center.z])
                cube([10 - magic_constant, poke_hole_radius, poke_through_height]);
                translate(poke_hole_center)
                cylinder(poke_through_height, d=poke_hole_radius);
            }
        }
    }
}