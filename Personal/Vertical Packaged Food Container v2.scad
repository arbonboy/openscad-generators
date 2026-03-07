/* [Container Parameters] */
Part = "main"; //[main:Main, extension:Extension]
Inner_Depth = 100;  // Depth of the container in millimeters
Outer_Height = 200  ;  // Height of the container in millimeters
Wall_Thickness = 3;  // Thickness of the container walls in millimeters
Opening_Height = 50;  // Height of the opening at the top in millimeters

/* [Dispenser Opening] */
Dispenser_Opening_Top_Height = 100;

/* [Item Parameters] */
Item_Width = 120; // Width of the item to be stored in millimeters
Item_Depth = 50;  // Depth of the item to be stored in millimeters
Item_Height = 20; // Height of the item to be stored in millimeters
Item_Tolerance = 5; // [0 : 0.5 : 10] Additional space added to the item dimensions to ensure it fits inside the container



/* [Ramp Parameters] */
// Ratio of the ramp height to the inner height
Ramp_Height_Ratio = 0.3; //[0 : 0.01 : 0.99]
// Ratio of the ramp depth to the inner depth 
Ramp_Depth_Ratio = 0.8;  //[0 : 0.01 : 0.99]

/* [Landing and Stopper Parameters] */
Landing_Length = 40; //[0:1:200]
Stopper_Length = 20; //[0:1:60]
Stopper_Height = 40; //[0:1:60]
Stopper_Bar_Width = 30; //[0:1:200]


/* [Bottom Parameters] */
// If true, the bottom of the container is solid; if false, it has a cutout
Solid_Bottom = false;
Add_Inset_Bottom = true;

/* [Wall Pattern] */
Pattern = "hexagon"; //[none:None, hexagon:Hexagon, circle:Circle, square:Square, quartz:Quartz]
Pattern_Wall_Thickness = 1;
Pattern_Size = 10;


/* [Hidden] */
Inner_Width = Item_Width + Item_Tolerance; 
Outer_Width = Inner_Width + 2 * Wall_Thickness;
Outer_Depth = Inner_Depth + 2 * Wall_Thickness;
Inner_Height = Outer_Height - Wall_Thickness;


if(Part=="main") {
    main();
} else {
    extension();
}
// extension();


module main(){
    difference() {
        union(){
            translate([Outer_Width/2, Outer_Depth/2, 0]){
                color("red") sideWall("left");
                color("green") sideWall("right");
                color("blue") sideWall("front");
                color("pink") sideWall("back");
            }
            floorWall();
            internalRamp();
            landing();
            translate([0, -Landing_Length+Stopper_Length, 0]) stopper();
            if(Add_Inset_Bottom){
                color("red") insetBottom();
                translate([0, -Landing_Length, 0]){
                    color("purple") insetBottom(depth = Landing_Length-Wall_Thickness*2);
                }
            }
            
        }
        if(!Solid_Bottom){
            translate([0, Wall_Thickness*2, -Wall_Thickness]) internalRamp();
        }
        // if(Add_Bottom_Cutouts){
        //     bottomCutouts();
        // }
    }
}


module extension(){
    // translate([0, 0, Outer_Height/2]) {
    //     difference(){
    //         cube([Outer_Width, Outer_Depth, Outer_Height], center=true);
    //         cube([Outer_Width-2*Wall_Thickness, Outer_Depth-2*Wall_Thickness, Outer_Height+2], center=true);
    //     }
    // }
    
    translate([Outer_Width/2, Outer_Depth/2, 0]){
        color("red") sideWall("left");
        color("green") sideWall("right");
        color("blue") sideWall("front");
        color("pink") sideWall("back");
    }
        
    difference(){
        union() {
            floorWall();
            translate([0, 0, 0]) {
                color("red") insetBottom();            
            }
        }
        cutoutWidth = Outer_Width-Wall_Thickness*4;
        cutoutDepth = Outer_Depth-Wall_Thickness*4;
        translate([Outer_Width/2, Outer_Depth/2, -Wall_Thickness]){
            cube([cutoutWidth, cutoutDepth, 20], center=true);    
        }
        
    }    
    
    


    
    // insetBraceWidth = Outer_Width - 2*Wall_Thickness;
    // insetBraceDepth = Outer_Depth - 2*Wall_Thickness;
    // insetBraceHeight = Wall_Thickness*8;

    // translate([Outer_Width/2, Outer_Depth/2, 0]) {
    //     difference(){
    //         cube([insetBraceWidth, insetBraceDepth, insetBraceHeight], center=true);
    //         cube([insetBraceWidth-2*Wall_Thickness, insetBraceDepth-2*Wall_Thickness, insetBraceHeight+2], center=true);
    //     }
    // }
}

module sideWall(side = "left"){
    xoffset = side == "left" ? -Outer_Width/2  - Wall_Thickness/2 : 
        side == "right" ? Outer_Width/2 - Wall_Thickness*3/2 : 0;
    yoffset = side == "front" ? -Outer_Depth/2 +Wall_Thickness*3/2 : 
        side == "back" ? Outer_Depth/2 + Wall_Thickness*1/2 : 0;
    zoffset = side == "left" || side == "right" ? Outer_Height/2 : Outer_Height/2;
    // xrotation = side == "front" || side == "back" ? 0 : 0;
    // yrotation = side == "left" || side == "right" ? 90 : 90;
    zrotation = side == "front" || side == "back" ? 0 : 90;

    width = side == "front" || side == "back" ? Outer_Width : Outer_Depth;  

    translate([xoffset, yoffset, zoffset]) {
        rotate([90, 0, zrotation]) {
            patterned_wall(Wall_Thickness, width, Outer_Height) {
                difference(){
                    square([width, Outer_Height], center=true);
                    if(side == "front" && Part != "extension"){
                        a = [Wall_Thickness, 0];
                        b = [Wall_Thickness, Item_Height];
                        c = [Item_Width/4, Item_Height*2];
                        d = [Outer_Width/2, Dispenser_Opening_Top_Height];
                        e = [Outer_Width-Item_Width/4, Item_Height*2];
                        f = [Outer_Width-Wall_Thickness, Item_Height];
                        g = [Outer_Width-Wall_Thickness, 0];
                        points = [a, b, c, d, e, f, g];
                        
                        translate([-Outer_Width/2, -Outer_Height/2]) 
                            polygon(points = points);
                    }
                }
                if(Pattern == "hexagon"){
                    xstep = sin(30) * (Pattern_Wall_Thickness + sqrt(3) * Pattern_Size / 2);
                    ystep = cos(30) * (Pattern_Wall_Thickness + sqrt(3) * Pattern_Size / 2);
                    xmove = [ 2 * xstep, 0];
                    ymove = [ xstep, ystep ];
                    spray_pattern([[-20,-20], [width, Outer_Height]], [ xmove, ymove])
                        rotate([0, 0, 90])cylinder(d = Pattern_Size, h = Wall_Thickness, center = true, $fn = 6);
                } else if(Pattern == "circle"){
                    xstep = Pattern_Size+Pattern_Wall_Thickness;
                    ystep = Pattern_Size+Pattern_Wall_Thickness;
                    xmove = [ xstep, 0];
                    ymove = [ xstep/2, ystep ];
                    spray_pattern([[-20,-20], [width, Outer_Height]], [ xmove, ymove])
                        cylinder(d = Pattern_Size, h = Wall_Thickness, center = true, $fn = 92);
                } else if(Pattern == "square"){
                    xstep = Pattern_Size+Pattern_Wall_Thickness;
                    ystep = Pattern_Size/2+Pattern_Wall_Thickness;
                    xmove = [ xstep, 0];
                    ymove = [ xstep/2, ystep ];
                    spray_pattern([[-20,-20], [width, Outer_Height]], [ xmove, ymove])
                        translate([0, 0, -Wall_Thickness/2])
                            linear_extrude(height = Wall_Thickness){
                                polygon([[0,Pattern_Size/2], [Pattern_Size/2, Pattern_Size], [Pattern_Size, Pattern_Size/2], [Pattern_Size/2, 0], [0, Pattern_Size/2]]);
                            } 
                } else if(Pattern == "quartz"){
                    xstep = Pattern_Size+Pattern_Wall_Thickness;
                    ystep = Pattern_Size*3/2+Pattern_Wall_Thickness;
                    xmove = [ xstep, 0];
                    ymove = [ xstep/2, ystep ];
                    spray_pattern([[-20,-20], [width, Outer_Height]], [ xmove, ymove])
                        translate([0, 0, -Wall_Thickness/2])
                            linear_extrude(height = Wall_Thickness){
                                polygon([[0,Pattern_Size/2], [0, Pattern_Size*3/2], [Pattern_Size/2, Pattern_Size*2], [Pattern_Size, Pattern_Size*3/2],[Pattern_Size, Pattern_Size/2], [Pattern_Size/2, 0], [0, Pattern_Size/2]]);
                            } 
                }
            }
        }
    }
        
    
}

module floorWall(){
    translate([Outer_Width/2, Outer_Depth/2, Wall_Thickness/2])
        cube([Outer_Width, Outer_Depth, Wall_Thickness], center=true);
}


module insetBottom(thickness = Wall_Thickness, width = Outer_Width, depth = Outer_Depth) {
    translate([thickness*0, thickness*0, 0]){
        hull(){
            cube([width, depth, 0.1], center=false);
            translate([thickness*2, thickness*2, -4]) cube([width-thickness*4, depth-thickness*4, 0.1], center=false);
        }
    }
}

module internalRamp() {
    rampHeight = Inner_Height*Ramp_Height_Ratio;
    rampWidth = Inner_Width;
    rampMinBottom = 0;
    rampDepth = Inner_Depth*Ramp_Depth_Ratio;
    difference(){
        translate([Inner_Width+Wall_Thickness, Inner_Depth+Wall_Thickness, Wall_Thickness])
            rotate([90,0,270])
                linear_extrude(height=rampWidth)
                    polygon(points=[[0,0], [rampDepth,0], [rampDepth,rampMinBottom], [0,rampMinBottom + rampHeight]]);
    }
    
}

module stopper() {
    rampThickness = Stopper_Bar_Width;
    rampWidthOuter = Outer_Width;
    rampWidthInner = rampWidthOuter - rampThickness*2;
    rampMinBottom = Wall_Thickness;
    rampDepth = Stopper_Length;
    rampDepthInner = rampDepth + Wall_Thickness;
    rampMinBottomInner = rampMinBottom + Wall_Thickness;
    rampHeight = rampMinBottom+Stopper_Height;

    difference(){
        translate([0, -rampDepth, 0])
            rotate([90,0,90])
                linear_extrude(height=rampWidthOuter)
                    polygon(points=[[0,0], [rampDepth,0], [rampDepth,rampMinBottom],[Wall_Thickness,rampHeight], [0, rampHeight]]);

        translate([rampThickness, -rampDepth, Wall_Thickness])
            rotate([90,0,90])
                linear_extrude(height=rampWidthInner)
                    polygon(points=[[0,0], [rampDepthInner,0], [rampDepthInner,rampMinBottomInner], [Wall_Thickness,rampHeight], [0, rampHeight - Wall_Thickness]]);
    }
    
}

module landing() {
    landingWidth = Outer_Width;
    landingWidthInner = landingWidth - Wall_Thickness*2;
    landingHeight = Wall_Thickness + Stopper_Height/2;
    landingHeightInner = landingHeight - Wall_Thickness;
    landingDepth = Landing_Length;
    // translate([rampThickness, -rampDepth, Wall_Thickness])
        rotate([90,0,0])
            linear_extrude(height=landingDepth)
                polygon(points=[[0,0], [landingWidth,0], [landingWidth, landingHeight], [landingWidth-Wall_Thickness, landingHeight], [landingWidth-Wall_Thickness, Wall_Thickness], [Wall_Thickness, Wall_Thickness],[Wall_Thickness, landingHeight], [0, landingHeight]]);

}




module patterned_wall(thickness, height, width) {
  // Reinforce the bottom
  difference() {
    translate([0, 0, thickness/2]){
        linear_extrude(height = thickness)
            children(0);
    }
    translate([-height/2+Pattern_Size, -width/2+Pattern_Size, thickness]) {
        children(1);
    }
      
  }

  // Build the walls
  translate([0, 0, thickness/2]){
    linear_extrude(height = thickness) {
        difference() {
        children(0);
        offset(-thickness)
            children(0);
        }
    }
  }
}

/* 
* https://github.com/nmasse-itix/OpenSCAD-Pattern-Filling/tree/master
* OPENSCAD-PATTERN-FILLING library
*/
module spray_pattern(bounding_box, move_patterns) {
  size = bounding_box[1] - bounding_box[0];
  xn = floor(size.x / move_patterns[0].x);
  yn = floor(size.y / move_patterns[1].y);
  origin = bounding_box[0];

  for (y = [0:1:yn]) {
    for (x = [0:1:xn]) {
      move = [x, y] * move_patterns;
      complement = [
        move.x >= 0 && move.x <= size.x ? 0 : -(xn + 1) * floor(move.x / ((xn + 1) * move_patterns[0].x)),
        move.y >= 0 && move.y <= size.y ? 0 : -(xn + 1) * floor(move.y / ((xn + 1) * move_patterns[0].y))
      ];
      adjusted_move = origin + ([x, y] + complement) * move_patterns;
      translate(adjusted_move)
        children();
    }
  }
}
