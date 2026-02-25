/* [Container Parameters] */
Inner_Width = 150;  // Width of the container in millimeters
Inner_Depth = 100;  // Depth of the container in millimeters
Outer_Height = 200  ;  // Height of the container in millimeters
Wall_Thickness = 3;  // Thickness of the container walls in millimeters
Opening_Height = 50;  // Height of the opening at the top in millimeters
Add_Inset_Bottom = true; 

/* [Ramp Parameters] */
// Ratio of the ramp height to the inner height
Ramp_Height_Ratio = 0.3; //[0 : 0.01 : 0.99]
// Ratio of the ramp depth to the inner depth 
Ramp_Depth_Ratio = 0.8;  //[0 : 0.01 : 0.99]

/* [Landing and Stopper Parameters] */
Landing_Length = 40; // Length of the landing in millimeters
Stopper_Length = 20; // Length of the stopper ramp in millimeters
Stopper_Height = 40; // Height of the stopper ramp in millimeters
Stopper_Bar_Width = 30; // Width of the stopper bars in millimeters


/* [Front Cutout Parameters] */
// If true, the container has a front top cutout
Add_Top_Cutout = false; 
// If true, you customize the front vertical cutout
Customize_Front_Cutout = true;
// Width of the front vertical cutout in millimeters
Front_VC_Width = 80; // [0 : 1 : 500]
// Height of the front vertical cutout in millimeters
Front_VC_Height = 200; // [0 : 1 : 500]
// Height of the lower triangular cutout in millimeters
Front_LTC_Height = 30;// [0 : 1 : 500]
// Height of the front top cutout in millimeters
Top_Cutout_Height = 20; // [0 : 1 : 500]

/* [Side Cutout Parameters] */
Add_Side_Cutouts = true;
// Width of the side cutouts in millimeters
Side_Cutout_Width = 50; // [0 : 1 : 400]
// Height of the side cutouts in millimeters
Side_Cutout_Height = 50; // [0 : 1 : 400]
// Side_Cutout_Angle = 0; // [-90 : 1 : 90]


/* [Back Cutout Parameters] */
Add_Back_Cutouts = true;
// Width of the back cutouts in millimeters
Back_Cutout_Width = 50; // [0 : 1 : 400]
// Height of the back cutouts in millimeters
Back_Cutout_Height = 50; // [0 : 1 : 400]
// Back_Cutout_Angle = 0; // [-90 : 1 : 90]

/* [Bottom Floor Cutout Parameters] */
Add_Bottom_Cutouts = false;
Bottom_Cutout_Width = 50; // [0 : 1 : 400]
Bottom_Cutout_Depth = 20; // [0 : 1 : 400

/* [Other Cutout Parameters] */
// If true, the bottom of the container is solid; if false, it has a cutout
Solid_Bottom = false;



/* [Hidden] */
Outer_Width = Inner_Width + 2 * Wall_Thickness;
Outer_Depth = Inner_Depth + 2 * Wall_Thickness;
Inner_Height = Outer_Height - Wall_Thickness;


main();
// internalRamp();
// stopper();
// landing();
// color("blue") backCutouts();
// color("red") bottomCutouts();

module main(){
    difference() {
        union(){
            difference() {
                // Outer container
                cube([Outer_Width, Outer_Depth, Outer_Height]);
                // Inner hollow space
                translate([Wall_Thickness, Wall_Thickness, Wall_Thickness])
                    cube([Inner_Width, Inner_Depth, Inner_Height]);
                translate([Wall_Thickness, 0, Wall_Thickness])
                    cube([Inner_Width, Wall_Thickness*2, Opening_Height], center=false);
                frontCutout();   
                if(Add_Side_Cutouts){
                    sideCutouts();
                }
                if(Add_Back_Cutouts){
                    backCutouts();
                }
                
            }
            internalRamp();
            landing();
            translate([0, -Landing_Length+Stopper_Length, 0]) stopper();
            if(Add_Inset_Bottom){
                color("red") insetBottom();
            }
            
        }
        if(!Solid_Bottom){
            translate([0, Wall_Thickness*2, -Wall_Thickness]) internalRamp();
        }
        if(Add_Bottom_Cutouts){
            bottomCutouts();
        }
    }
}

module insetBottom(){
    translate([Wall_Thickness*0, Wall_Thickness*0, 0]){
        hull(){
            cube([Outer_Width, Outer_Depth, 0.1], center=false);
            translate([Wall_Thickness+1, Wall_Thickness+1, -4]) cube([Outer_Width-Wall_Thickness*2-2, Outer_Depth-Wall_Thickness*2-2, 0.1], center=false);
        }
    }
    
    

}

module frontCutout() { 
    lowerTriangleHeight = Customize_Front_Cutout ? Front_LTC_Height : (Inner_Height - Opening_Height)/5;
    lowerTriangleBase = Inner_Width;
    higherTriangleBase = Customize_Front_Cutout ? lowerTriangleBase/2 : lowerTriangleBase/2;
    cylRadius = Customize_Front_Cutout ? Front_VC_Width/2 : higherTriangleBase/3;
    higherTriangleHeight = Customize_Front_Cutout ? Front_VC_Height-Opening_Height : lowerTriangleHeight*4;
    
    // if(Customize_Front_Cutout){
    //     lowerTriangleHeight = (Inner_Height - Opening_Height)/5;
    //     lowerTriangleBase = Inner_Width;
    //     higherTriangleHeight = lowerTriangleHeight*4;
    //     higherTriangleBase = lowerTriangleBase/2;
    //     cylRadius = Front_VC_Width/2;
    // } else {
    //     lowerTriangleHeight = (Inner_Height - Opening_Height)/5;
    //     lowerTriangleBase = Inner_Width;
    //     higherTriangleHeight = lowerTriangleHeight*4;
    //     higherTriangleBase = lowerTriangleBase/2;
    //     cylRadius = higherTriangleBase/3;
    // }
    

    translate([Wall_Thickness, 0, Wall_Thickness])
        cube([Inner_Width, Wall_Thickness*2, Opening_Height], center=false);
    translate([Wall_Thickness + Inner_Width/2, Wall_Thickness, Wall_Thickness+Opening_Height]) 
        rotate([90,0,0]) 
            iso_tri_prism(base_w=lowerTriangleBase, tri_h=lowerTriangleHeight, depth=Wall_Thickness*2);
    // translate([Wall_Thickness + Inner_Width/2, Wall_Thickness*2, Wall_Thickness+Opening_Height+lowerTriangleHeight/4]) 
    //     rotate([90,0,0]) 
    //         iso_tri_prism(base_w=higherTriangleBase, tri_h=higherTriangleHeight, depth=Wall_Thickness*2);

    translate([Wall_Thickness + Inner_Width/2, Wall_Thickness*2, Wall_Thickness+Opening_Height+lowerTriangleHeight+higherTriangleHeight-cylRadius*2]) 
        rotate([90,0,0]) 
            cylinder(h=Wall_Thickness*2, r=cylRadius, center=false, $fn=50);

    translate([Outer_Width/2-cylRadius, -Wall_Thickness, Wall_Thickness+Opening_Height]) 
        rotate([0,0,0]) 
            cube([cylRadius*2, Wall_Thickness*2, higherTriangleHeight+lowerTriangleHeight-cylRadius*2], center=false);

    if(Add_Top_Cutout){
        tcHeight = Customize_Front_Cutout ? Top_Cutout_Height : Opening_Height;
        translate([Wall_Thickness, -Wall_Thickness, Outer_Height-tcHeight]) 
            rotate([0,0,0]) 
                cube([Inner_Width, Wall_Thickness*2, tcHeight], center=false);
    }


}



module capsule3d(w=40, total_h=80, depth=5, $fn=96) {
    r = w/2;
    rect_h = max(0, total_h - 2*r);
    union() {
        translate([0, r, 0]) cube([w, rect_h, depth], center=false);          // rectangle centered at origin
        translate([r, total_h-r, 0]) cylinder(h=depth, r=r, $fn=$fn); // top circle, center on top edge
        translate([r, r, 0]) cylinder(h=depth, r=r, $fn=$fn); // bottom circle, center on bottom edge
    }
}


module sideCutouts() {
    sideCutoutWidth = Side_Cutout_Width;
    sideCutoutHeight = Side_Cutout_Height;
    // angle = Side_Cutout_Angle;
    translate([0, Outer_Depth/2-sideCutoutWidth/2, Outer_Height/2-sideCutoutHeight/2]) rotate([90, 0, 90]) capsule3d(w=sideCutoutWidth, total_h=sideCutoutHeight, depth=Wall_Thickness, $fn=96);
    translate([Outer_Width-Wall_Thickness, Outer_Depth/2-sideCutoutWidth/2, Outer_Height/2-sideCutoutHeight/2]) rotate([90, 0, 90]) capsule3d(w=sideCutoutWidth, total_h=sideCutoutHeight, depth=Wall_Thickness, $fn=96);
}

module backCutouts() {
    backCutoutWidth = Back_Cutout_Width;
    backCutoutHeight = Back_Cutout_Height;
    // angle = Back_Cutout_Angle;
    translate([Outer_Width/2-backCutoutWidth/2, Outer_Depth, Outer_Height/2-backCutoutHeight/2+Inner_Height*Ramp_Height_Ratio/2]) rotate([90, 0, 0]) capsule3d(w=backCutoutWidth, total_h=backCutoutHeight, depth=Wall_Thickness, $fn=96);
}

module bottomCutouts() {
    bottomCutoutWidth = Bottom_Cutout_Width;
    bottomCutoutDepth = Bottom_Cutout_Depth;
    bottomCutoutHeight = Wall_Thickness;
    translate([Outer_Width/2-bottomCutoutWidth/2, Outer_Depth/2-bottomCutoutDepth/2-Wall_Thickness, 0]) rotate([0, 0, 0]) cube([bottomCutoutWidth, bottomCutoutDepth, bottomCutoutHeight], center=false);
}

// lowerTriangleHeight = (Inner_Height - Opening_Height)/5;
// higherTriangleHeight = lowerTriangleHeight*4;
// lowerTriangleBase = Inner_Width;
// higherTriangleBase = lowerTriangleBase/2;
// cylRadius = higherTriangleBase/4;
    

// translate([Outer_Width/2-higherTriangleBase/4, -Wall_Thickness, Wall_Thickness+Opening_Height]) 
//         rotate([0,0,0]) 
//             color("blue") cube([higherTriangleBase/2, Wall_Thickness*2, higherTriangleHeight+lowerTriangleHeight-cylRadius*2], center=false);

module internalRamp() {
    // rampHeight = Inner_Height/10;
    // rampDepth = Inner_Depth/2;
    
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

// Isosceles Triangular Prism
// base_w  = width of the triangle's base (mm)
// tri_h   = height of the triangle from base to apex (mm)
// depth   = extrusion depth (mm) along Z
// center_xy = center the triangle in XY (apex up); if false, base starts at x=0
// center_z  = center the prism along Z during extrusion

module iso_tri_prism(base_w=40, tri_h=30, depth=20, center_xy=true, center_z=false) {
    b = base_w;
    h = tri_h;

    // Define triangle points in the XY plane
    pts = center_xy
        ? [ [-b/2, 0], [ b/2, 0], [0, h] ]              // centered base, apex at +Y
        : [ [0, 0], [ b, 0], [ b/2, h ] ];              // base from x=0..b, apex centered

    linear_extrude(height=depth, center=center_z)
        polygon(points = pts);
}

// ---------- Examples ----------
// Centered triangle, 40×30, extruded 20 mm:
