Can_Height = 125; // Height of the can
Can_Diameter = 70; // Diameter of the can
Rack_Outer_Length = 570; // Length of the rack
Side_Wall_Thickness = 5; // Thickness of the side walls
Can_Tolerance = 5;
Track_Angle = 1; // Angle of the track floor in degrees


/* [Rack Sections] */
Number_of_Sections = 3; // [1:5]
Break_into_Sections = true; // Whether to break the rack into sections for easier printing
Render_Section = 0; // [0:5]
Connector_Tolerance = 0.2; // Tolerance for the connectors between sections

/* [Can Stopper] */
Stopper_Lip_Starting_Height = 0;
Stopper_Lip_Depth = 20; 
Stopper_Lip_Width = 70;
Stopper_Angle = 50;


/* [Hidden] */
Rack_Outer_Width = Can_Height + 2 * Side_Wall_Thickness + Can_Tolerance; // Width of the rack
Section_Depth = Rack_Outer_Length / Number_of_Sections; // Depth of each section
Track_Wall_Min_Thickness = Side_Wall_Thickness; // Minimum thickness of the track walls
Side_Cutout_Rotation_Angle = 45; // Angle of the side cutouts in degrees
PaddingZ = tan(Stopper_Angle)*Stopper_Lip_Depth;
echo(str("PaddingZ: ",PaddingZ));
Rack_Outer_Height = 2*Can_Diameter + 3 * Side_Wall_Thickness + Can_Tolerance + PaddingZ*2; // Height of the rack
Font_Size = 10; // Size of the text font

// extractPart(i){
//     Rack();
// }

if(Break_into_Sections == true){
    if(Render_Section != 0){
        addFemale(Render_Section){
            addMale(Render_Section){
                getSection(Render_Section){
                    Rack();
                }
            }
        }
    } else {
        for(i = [1:1:Number_of_Sections]){
            translate([i*(50),0,0]){
                addFemale(i){
                    addMale(i){
                        getSection(i){
                            Rack();
                        }
                    }
                }
            }
            
        }
    }
    
    
} else {
    Rack();
}
// bottomLabel();




$fn = 96; // smooth arcs

// Basic tab/blank profile, centered on an edge
// dir = +1 → points outward; dir = -1 → points inward
module jigsaw_tab2d(dir=+1, depth=12, r=8) {
    translate([dir*(depth - r), 0])
    hull() {
        circle(r=r);
        translate([dir*r,  0.9*r]) circle(r=0.75*r);
        translate([dir*r, -0.9*r]) circle(r=0.75*r);
    }
}

// Puzzle piece end with configurable left & right sides
// left_side  = "flat" or "female"
// right_side = "flat" or "male"
// tol        = clearance applied to tabs/holes
module puzzle_piece_end2dTwo(w=60, h=40, depth=14, r=9, tol=0.2,
                          left_side="flat", right_side="flat") {
    echo(str("w: ", w, " h: ", h, " depth: ", depth, " r: ", r, " tol: ", tol,
             " left_side: ", left_side, " right_side: ", right_side));
    difference(){
        if(right_side == "male"){
            union(){
                square([w, h], center=false);
                translate([w, Rack_Outer_Width/4])
                    offset(delta=-tol)
                        jigsaw_tab2d(dir=+1, depth=depth, r=r);
                translate([w, -Rack_Outer_Width/4])
                    offset(delta=-tol)
                        jigsaw_tab2d(dir=+1, depth=depth, r=r);
            }
        }
        if(left_side == "female"){
            // square([w, h], center=false);
            rotate([0, 180, 0]){
                translate([0, Rack_Outer_Width/4])
                    offset(delta=+tol)
                        jigsaw_tab2d(dir=-1, depth=depth, r=r);
                translate([0, -Rack_Outer_Width/4])
                    offset(delta=+tol)
                        jigsaw_tab2d(dir=-1, depth=depth, r=r);
            }
        }
    }
    
}

// Puzzle piece end with configurable left & right sides
// left_side  = "flat" or "female"
// right_side = "flat" or "male"
// tol        = clearance applied to tabs/holes
module puzzle_piece_end2dOne(w=60, h=40, depth=14, r=9, tol=0.2,
                          left_side="flat", right_side="flat") {
    difference(){
        if(right_side == "male"){
            union(){
                square([w, h], center=false);
                translate([w, h/2])
                    offset(delta=-tol)
                        jigsaw_tab2d(dir=+1, depth=depth, r=r);
            }
        }
        if(left_side == "female"){
            // square([w, h], center=false);
            rotate([0, 180, 0]){
                translate([0, h/2])
                    offset(delta=+tol)
                        jigsaw_tab2d(dir=-1, depth=depth, r=r);
            }
        }
    }
    
}

// Solid extrusion to 3D
module puzzle_piece_end3d(w=60, h=40, thk=100, depth=14, r=9, tol=0.2,
                          left_side="flat", right_side="flat") {
    linear_extrude(height=thk){
        if( r*2 < Rack_Outer_Width/6 ) {
            puzzle_piece_end2dTwo(w=w, h=h, depth=depth, r=r, tol=tol,
                           left_side=left_side, right_side=right_side);
        } else {
            puzzle_piece_end2dOne(w=w, h=h, depth=depth, r=r, tol=tol,
                           left_side=left_side, right_side=right_side);
        }
        // puzzle_piece_end2d(w=w, h=h, depth=depth, r=r, tol=tol,
        //                    left_side=left_side, right_side=right_side);
    }
}

// Solid extrusion to 3D
module puzzle_piece_end3dOne(w=60, h=40, thk=100, depth=14, r=9, tol=0.2,
                          left_side="flat", right_side="flat") {
    linear_extrude(height=thk)
        puzzle_piece_end2d(w=w, h=h, depth=depth, r=r, tol=tol,
                           left_side=left_side, right_side=right_side);
}

module addMale(sectionNumber=0) {
    if(sectionNumber < Number_of_Sections && Number_of_Sections > 1){
        union(){
            union(){
                children();
                intersection(){
                    male(sectionNumber);
                    translate([(sectionNumber)*Section_Depth-Rack_Outer_Length/2-Side_Wall_Thickness, 0, Rack_Outer_Height/2-Side_Wall_Thickness/2])
                        cube([Rack_Outer_Length, Rack_Outer_Width, Side_Wall_Thickness], center=true);
                }
                intersection(){ 
                    male(sectionNumber);
                    translate([(sectionNumber)*Section_Depth-Rack_Outer_Length/2-Side_Wall_Thickness, 0, 0])
                        cube([Rack_Outer_Length, Rack_Outer_Width, Side_Wall_Thickness], center=true);
                }
                intersection(){ 
                    male(sectionNumber);
                    translate([(sectionNumber)*Section_Depth-Rack_Outer_Length/2-Side_Wall_Thickness, 0, -Rack_Outer_Height/2+Side_Wall_Thickness/2])
                        cube([Rack_Outer_Length, Rack_Outer_Width, Side_Wall_Thickness], center=true);
                }
            }
            
        }
    } else {
        children();
    }
}

module male(sectionNumber=0){
    translate([(sectionNumber)*Section_Depth-Rack_Outer_Length/2, 0, -Rack_Outer_Height/2])
        puzzle_piece_end3d(w=0, h=0, r=9, thk=Rack_Outer_Height, left_side="flat", right_side="male");
}

module maleOne(){
    translate([(Render_Section)*Section_Depth-Rack_Outer_Length/2, 0, -Rack_Outer_Height/2])
        puzzle_piece_end3d(w=0, h=0, r=9, thk=Rack_Outer_Height, left_side="flat", right_side="male");
}

module addFemale(sectionNumber=0) {
    echo(str("Render_Section: ", Render_Section));
    if(sectionNumber > 1 && Number_of_Sections > 1){
        difference(){
            children();
            union(){
                female(sectionNumber);
            }
        }
    } else {
        children();
    }
}

module femaleOne(){
    translate([(Render_Section-1)*Section_Depth-Rack_Outer_Length/2, 0, -Rack_Outer_Height/2])
        puzzle_piece_end3d(w=0, h=0, r=9, thk=Rack_Outer_Height, left_side="flat", right_side="male");
}

module female(sectionNumber=0){
    translate([(sectionNumber-1)*Section_Depth-Rack_Outer_Length/2, 0, -Rack_Outer_Height/2])
        puzzle_piece_end3d(w=0, h=0, r=9+Connector_Tolerance, thk=Rack_Outer_Height, left_side="flat", right_side="male");
}

module getSection(x){
    //preserveStart = Section_Depth*(x-2);
    preserveStart = -Rack_Outer_Length/2 + Section_Depth*(x-1) + Section_Depth/2;
    echo(str("preserveStart: ", preserveStart));
    echo(str("Section_Depth: ", Section_Depth));
    intersection(){
        children();
        translate([preserveStart,0,0])
            cube([Section_Depth,Rack_Outer_Width*2,Rack_Outer_Height*1.5], center=true);
    }
    
}


module extractPart(x){
    preserveStart = Section_Depth*(x-1);
    preserveEnd = preserveStart + Section_Depth;
    children();
    // difference(){
    //     children();
    //     intersection(){
    //         children();
    //         translate([x,0,0])
    //             cube([0.2,Rack_Outer_Width*2,Rack_Outer_Height*1.5], center=true);
    //     }
    // }
}



module sliceIt(x){
    difference(){
        children();
        intersection(){
            children();
            translate([x,0,0])
                cube([0.2,Rack_Outer_Width*2,Rack_Outer_Height*1.5], center=true);
        }
    }
}




module Rack() {
    difference() {
            
        union(){
            translate([-Rack_Outer_Length/2, -Rack_Outer_Width/2, -Rack_Outer_Height/2])
                sloped_top_block(len=Rack_Outer_Length, wid=Rack_Outer_Width, thk=Side_Wall_Thickness, ang=Track_Angle, pivot="right");
            rotate([180, 180, 0]) 
                translate([-Rack_Outer_Length/2, -Rack_Outer_Width/2, -Side_Wall_Thickness]){
                    difference(){
                        sloped_top_block(len=Rack_Outer_Length, wid=Rack_Outer_Width, thk=Side_Wall_Thickness, ang=Track_Angle, pivot="right");
                        
                        middleLeftCutout();
                            
                    }
                    
                // color("brown") middleLeftCutout();
                }

            difference() {
                outerShell();
                sideCutouts();
                
            }
        }

        topAndBottomCutouts();
        
        backCutouts();

        topRightCutout();    
        bottomRightSideCanAccessCutout();
        

    }
    // bottomRightSideCanAccessCutout();
}

module sideCutouts(){
    // Side cutouts
    sideCutoutX = Rack_Outer_Height*3/16;
    sideCutoutY = Section_Depth*4/7; 
    sideCutoutZ = Rack_Outer_Width;
    tanAng = Rack_Outer_Height / Section_Depth;
    // ang = 90-atan(tanAng);
    ang = 90;
    // echo(str("ang: ", ang));

    for(i = [1:1:Number_of_Sections]){
        //Top
        translate([(i-1)*Section_Depth-Rack_Outer_Length/2+Section_Depth/2, 0, Rack_Outer_Height/3])
             rotate([90, ang, 0]) Cutout(sideCutoutX, sideCutoutY, sideCutoutZ);

        //Middle
        translate([(i-1)*Section_Depth-Rack_Outer_Length/2+Section_Depth/2, 0, 0])
            rotate([90, ang, 0]) Cutout(sideCutoutX, sideCutoutY, sideCutoutZ);
        
        //Bottom
        translate([(i-1)*Section_Depth-Rack_Outer_Length/2+Section_Depth/2, 0, -Rack_Outer_Height*1/4])
             rotate([90, ang, 0]) Cutout(sideCutoutX, sideCutoutY, sideCutoutZ);
        
    }
}

module sideCutoutsSlanted(){
    // Side cutouts
    sideCutoutX = Section_Depth*2/5;
    sideCutoutY = Rack_Outer_Height*5/7;
    sideCutoutZ = Rack_Outer_Width;
    tanAng = Rack_Outer_Height / Section_Depth;
    ang = 90-atan(tanAng);
    // echo(str("ang: ", ang));

    for(i = [1:1:Number_of_Sections]){
        translate([(i-1)*Section_Depth-Rack_Outer_Length/2+Section_Depth/2, 0, 0])
            rotate([90, ang, 0]) Cutout(sideCutoutX, sideCutoutY, sideCutoutZ);
        // translate([(i-1)*Section_Depth-Rack_Outer_Length/2+Section_Depth/3, 0, Rack_Outer_Height/8])
        //     rotate([90, ang, 0]) Cutout(sideCutoutX/4, sideCutoutY, sideCutoutZ);
        // translate([(i-1)*Section_Depth-Rack_Outer_Length/2+Section_Depth*2/3, 0, -Rack_Outer_Height/8])
        //     rotate([90, ang, 0]) Cutout(sideCutoutX/4, sideCutoutY, sideCutoutZ);
        translate([(i-1)*Section_Depth-Rack_Outer_Length/2+Section_Depth/4, 0, Rack_Outer_Height/3])
             rotate([90, ang, 0]) Cutout(sideCutoutX/4, sideCutoutY/4, sideCutoutZ);
        translate([(i-1)*Section_Depth-Rack_Outer_Length/2+Section_Depth*3/4, 0, -Rack_Outer_Height/3])
             rotate([90, ang, 0]) Cutout(sideCutoutX/4, sideCutoutY/4, sideCutoutZ);
        
    }
}



module sideCutoutsFixed(){
    // Side cutouts
                sideCutoutX = Rack_Outer_Height*Number_of_Sections/5;
                sideCutoutY = Section_Depth*Number_of_Sections/4;
                sideCutoutZ = Rack_Outer_Width;
                translate([Rack_Outer_Length/2/Number_of_Sections + Section_Depth/2, 0, 0])
                    rotate([90, 20, 0]) Cutout(sideCutoutX, sideCutoutY, sideCutoutZ);
                translate([0, 0, 0])
                    rotate([90, 20, 0]) Cutout(sideCutoutX, sideCutoutY, sideCutoutZ);
                translate([-1 * (Rack_Outer_Length/2/Number_of_Sections + Section_Depth/2), 0, 0])
                    rotate([90, 20, 0]) Cutout(sideCutoutX, sideCutoutY, sideCutoutZ);
}

module backCutouts(){
    // Back cutouts
    backCutoutX = Rack_Outer_Width*3/5;
    backCutoutY = Rack_Outer_Height*3/5;
    backCutoutZ = Rack_Outer_Height*3/5;
    translate([-Rack_Outer_Length/2, 0, 0])
        rotate([90, 0, 90]) Cutout(backCutoutX, backCutoutY, backCutoutZ);
}

module topAndBottomCutouts() {
    //Top & Bottom cutouts
    tbCutOutX = Rack_Outer_Width*4/8;
    tbCutOutY = Section_Depth/2;
    tbCutOutZ = Rack_Outer_Height;

   ang = Rack_Outer_Width < Section_Depth ? 90 : 0;
   x = ang != 0 ? tbCutOutX : tbCutOutY;
   y = ang != 0 ? tbCutOutY : tbCutOutX;

    for(i = [1:1:Number_of_Sections]){
        translate([(i-1)*Section_Depth-Rack_Outer_Length/2+Section_Depth/2, 0, 0])
            rotate([0, 0, ang]) Cutout(x, y, tbCutOutZ);
        
    }
}

module topAndBottomCutoutsFixed() {
    //Top & Bottom cutouts
    tbCutOutX = Rack_Outer_Width/2;
    tbCutOutY = Section_Depth*2/3;
    tbCutOutZ = Rack_Outer_Height;
    translate([Rack_Outer_Length/2/3 + Section_Depth/2, 0, 0])
        rotate([0, 0, 90]) Cutout(tbCutOutX, tbCutOutY, tbCutOutZ);
    translate([0, 0, 0])
        rotate([0, 0, 90]) Cutout(tbCutOutX, tbCutOutY, tbCutOutZ);
    translate([-1 * (Rack_Outer_Length/2/3 + Section_Depth/2), 0, 0])
        rotate([0, 0, 90]) Cutout(tbCutOutX, tbCutOutY, tbCutOutZ);
}

module topRightCutout() {
    trCutOutX = Section_Depth*2/3;
    trCutOutY = Rack_Outer_Width-Side_Wall_Thickness*2-Can_Tolerance;
    trCutOutZ = Side_Wall_Thickness*2;
    translate([Rack_Outer_Length/2-trCutOutX/2, 0, Rack_Outer_Height/2-trCutOutZ/2])
        cube([trCutOutX, trCutOutY, trCutOutZ], center = true);
}

module middleLeftCutout() {
    //Middle Left Ramp Cutout
    mlCutOutX = Can_Diameter + Can_Tolerance*2;
    // mlCutOutX = Can_Diameter + Can_Tolerance*4 - Side_Wall_Thickness*2;
    // mlCutOutY = Rack_Outer_Width-2*Side_Wall_Thickness-Can_Tolerance;
    mlCutOutY = Rack_Outer_Width-2*Side_Wall_Thickness;
    mlCutOutZ = Rack_Outer_Height/2;
    mlCutOutCylRad = -(Can_Height + Can_Tolerance)/4;
    //translate([Rack_Outer_Length/2+Section_Depth/2+mlCutOutX, Rack_Outer_Width/2,0])
    //posX = Rack_Outer_Length-mlCutOutX/2;
    posX = Rack_Outer_Length-mlCutOutX/2-Side_Wall_Thickness;
    echo(str("posX: ", posX));
    echo(str("mlCutOutX: ", mlCutOutX));
    translate([posX, Rack_Outer_Width/2,0]){
        cube([mlCutOutX, mlCutOutY, mlCutOutZ], center = true);
        // translate([mlCutOutCylRad, 0,0])
        //     cylinder(h=Side_Wall_Thickness*4, d1=mlCutOutY, d2=mlCutOutY, center = true);
    }
}

module bottomRightSideCanAccessCutout() {
    //Bottom Right Side Can Access Cutout
    brCutOutX = Rack_Outer_Width + Can_Tolerance;
    brCutOutY = Can_Diameter + Can_Tolerance;
    brCutOutZ = Rack_Outer_Height/2;
    translate([Rack_Outer_Length/2, 0, -Rack_Outer_Height/6])
        rotate([90, 90, 0])
            cylinder(h=brCutOutX, d1=brCutOutY, d2=brCutOutY, center = true);
}



module outerShell() {
    union(){
        difference(){
            // Outer box
            cube([Rack_Outer_Length, Rack_Outer_Width, Rack_Outer_Height], center = true);
            
            // Inner cutout
            translate([Side_Wall_Thickness, 0, -(Side_Wall_Thickness)/2])
                //cube([Rack_Outer_Length -2 * Side_Wall_Thickness - Can_Tolerance, Rack_Outer_Width - 2 * Side_Wall_Thickness - Can_Tolerance, Rack_Outer_Height - 2 * Track_Wall_Min_Thickness-Can_Tolerance], center = true);
                cube([Rack_Outer_Length, Can_Height + Can_Tolerance, Rack_Outer_Height - 2 * Track_Wall_Min_Thickness+Can_Tolerance], center = true);
        }
        translate([Rack_Outer_Length/2-Stopper_Lip_Depth, -Stopper_Lip_Width/2, -Rack_Outer_Height/2])
            sloped_top_block(len=Stopper_Lip_Depth, wid=Stopper_Lip_Width, thk=Stopper_Lip_Starting_Height, ang=Stopper_Angle, pivot="left");
        bottomLabels();
    }
}

module Cutout(x, y, z) {
    lengthOfCutoutX = x;
    lengthOfCutoutY = y-x;   
    lengthOfCutoutZ = z;         
    translate([0, -lengthOfCutoutY/2, -lengthOfCutoutZ/2]){
        union() {
            linear_extrude(lengthOfCutoutZ){
                circle(r = lengthOfCutoutX/2, $fn=100);
                translate([0, lengthOfCutoutY]){
                    circle(r = lengthOfCutoutX/2, $fn=100);
                }
                translate([0, lengthOfCutoutY/2]){
                    square([lengthOfCutoutX, lengthOfCutoutY], center = true);
                }
            }
        }
    }
}

module bottomLabels(){
    for(i = [1:1:Number_of_Sections]){
        translate([(i-1)*Section_Depth-Rack_Outer_Length/2+Section_Depth/2, -Rack_Outer_Width/2, -Rack_Outer_Height/2+Font_Size]) 
            bottomLabel(str("bottom ", i));
    }
}
module bottomLabel(st){
    rotate([-90, 180, 180])
            linear_extrude(height=1, v=[0,0,1], center=true)
                text(text=st, size=Font_Size, halign="center", valign="center", font="Arial:style=Bold");
}

// Block with flat bottom (z=0) and a top face tilted by `ang`.
// `pivot` decides which end's top stays at `thk` (unchanged).
// - pivot="right": right end top = thk, left end top = thk + rise
// - pivot="left" : left  end top = thk, right end top = thk + rise
module sloped_top_block(len=500, wid=100, thk=10, ang=2, pivot="right") {
    // ang_rad = ang * PI / 180;
    ang_rad = ang;
    rise = len * tan(ang_rad);

    zL_top = (pivot == "right") ? thk + rise : thk;
    zR_top = (pivot == "right") ? thk         : thk + rise;

    // vertices: 0..3 bottom, 4..7 top
    pts = [
        [0,    0, 0], [0,  wid, 0], [len,  0, 0], [len, wid, 0],
        [0,    0, zL_top], [0,  wid, zL_top], [len,  0, zR_top], [len, wid, zR_top]
    ];

    faces = [
        [0,1,3,2],   // bottom (flat)
        [4,5,7,6],   // top (tilted plane)
        [0,2,6,4],   // front (y=0)
        [1,3,7,5],   // back  (y=wid)
        [0,4,5,1],   // left  (x=0)
        [2,3,7,6]    // right (x=len)
    ];

    polyhedron(points=pts, faces=faces);
}

