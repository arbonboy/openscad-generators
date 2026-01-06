include <BOSL2/std.scad>;
include <BOSL2/threading.scad>;



Head_Type = "Hex"; // [None, Minimal, Flat, Hex, Threaded]
Head_Height = 8; // [8, 12]
Thread_Height = 8; // thread heightHead_Height
// You can print the screw horizontally for stronger threads, but the head will be flat on the bottom
For_Horizontal_Printing = false; // [true,false]

/* [Mounting Hole Options] */
// Mounting Holes are NOT supported for Hex head screws
Include_Mounting_Hole = false; // [true, false]
Mounting_Hole_Radius = 2; // [0:.25:8]
Mounting_Hole_Type = "chamfered"; // [chamfered, phillips, hex]


/* [Hidden] */
headWidth = 23; // head width
screwThreadDiameter = 8;
minimalHeadHeight = 0.8; // height of minimal head
minimalHeadWidth = 22; // width of minimal head
TB_SCREW_Threaded_Rod_Diameter = 16;
TB_SCREW_Head_Padding = 2; //The minimum amount of solid head above the cutout portion of the screw head


hexHeadChamferMargin = 6; // chamfer margin for hex head
flatHeadChamferMargin = 8; // chamfer margin for flat head
threadedHead8ChamferMargin = 6; // chamfer margin for threaded head
threadedHead12ChamferMargin = 10; // chamfer margin for threaded head




drawScrew();

module drawScrew(){
  rotationDeg = For_Horizontal_Printing ? 90 : 0;
  zTranslate = For_Horizontal_Printing ? headWidth/4 : 0;
  headHeight = Head_Type == "None" ? 0 : (Head_Type == "Minimal" ? minimalHeadHeight : Head_Height);
  headStyle = Head_Type == "None" ? "solid" : (Head_Type == "Hex" ? "hex" : (Head_Type == "Threaded" ? "thread" : "solid"));
  translate([0,0,zTranslate])
    rotate([0,rotationDeg,0])
      difference(){
        screw(rodHeight=Thread_Height, headHeight=headHeight, headRadius=headWidth/2, headStyle=headStyle, mountingHole=Include_Mounting_Hole, mountingHoleType=Mounting_Hole_Type, mountingHoleRadius=Mounting_Hole_Radius, center=false, tolerance=0.6);
      
        if(For_Horizontal_Printing && Head_Type != "None"){
          // Create a cube to cut off the bottom half of the screw head
          translate([-headWidth/2, 0, Head_Height/2])
            rotate([90, 0, 0])
              cube([headWidth/2, headWidth*2, (Head_Height+Thread_Height)*2], center=true);
          translate([headWidth/2, 0, Head_Height/2])
            rotate([90, 0, 0])
              cube([headWidth/2, headWidth*2, (Head_Height+Thread_Height)*2], center=true);
        }
        
      }
      
}


module threadedRod(length = 20, center = false, hole_radius=TB_SCREW_Threaded_Rod_Diameter/2) {
    pitch = 4;
    depth = pitch * cos(70) * 7 / 8;
    profile = [
        [-7 / TB_SCREW_Threaded_Rod_Diameter, -depth / pitch],
        [-6 / TB_SCREW_Threaded_Rod_Diameter, -depth / pitch],
        [-1 / TB_SCREW_Threaded_Rod_Diameter, 0],
        [1 / TB_SCREW_Threaded_Rod_Diameter, 0],
        [6 / TB_SCREW_Threaded_Rod_Diameter, -depth / pitch],
        [7 / TB_SCREW_Threaded_Rod_Diameter, -depth / pitch]
    ];
    zTranslate = center ? 0 : length / 2;
    translate([0, 0, zTranslate])
    generic_threaded_rod(d = hole_radius*2, l = length, pitch = pitch, profile = profile, blunt_start = false);
}


module threadedRodForHole(length = 20, center = false, tolerance = 0.2, hole_radius=TB_SCREW_Threaded_Rod_Diameter/2) {
    scaleFactor = 4 * tolerance / TB_SCREW_Threaded_Rod_Diameter;
    scale([1 + scaleFactor, 1 + scaleFactor, 1]) {
        threadedRod(length = length, center = center, hole_radius);
    }
}

module headHex(height = 8, center = false, radius = 10.5) {
    translate([0, 0, 0])
    difference() {
        cylinder(h = height, r = radius, center = center);
        translate([0, 0, -TB_SCREW_Head_Padding]) cylinder(h = height, r = 8.4, $fn = 6, center = center);
    }
}

module headThread(height = 8, center = false, radius = 10.5, tolerance = 0.2) {
    translate([0, 0, 0])
    difference() {
        cylinder(h = height, r = radius, center = center);
        translate([0, 0, -TB_SCREW_Head_Padding]) threadedRodForHole(length = height, center = center, tolerance = tolerance);
    }
}

module headSolid(height = 8, center = false, radius = 10.5) {
    translate([0, 0, 0])
    cylinder(h = height, r = radius, center = center);
}

module headChamfered(height = 8, center = false, radius = 10.5, innerRadius = TB_SCREW_Threaded_Rod_Diameter/2) {
    translate([0, 0, 0])
        cylinder(h = height/2, r1 = radius, r2 = radius, center = center);
    translate([0, 0, height/2])
        cylinder(h = height/2, r1 = radius, r2 = innerRadius, center = center);
    
}


module screw(rodHeight = 8, headHeight = 8, headRadius = 10.5, headStyle = "hex" /* hex, thread, solid, chamfered */ , mountingHole = false, mountingHoleType = "simple" /* simple, chamfered, phillips */ , mountingHoleRadius = 2, center = false, tolerance = 0.2) {
    zPos = center ? -(rodHeight + headHeight) / 2 : 0;
    headPadding = headStyle == "hex" ? TB_SCREW_Head_Padding : (headStyle == "thread" ? TB_SCREW_Head_Padding : (headStyle == "solid" ? headHeight : headHeight));
    translate([0, 0, zPos]) {
        difference() {
            union() {
                if (headStyle == "hex") {
                    headHex(height = headHeight, center = false, radius = headRadius);
                } else if (headStyle == "thread") {
                    headThread(height = headHeight, center = false, radius = headRadius, tolerance = tolerance);
                } else if (headStyle == "solid") {
                    headSolid(height = headHeight, center = false, radius = headRadius);
                } else {
                    headChamfered(height = headHeight, center = false, radius = headRadius);
                }
                translate([0, 0, headHeight]) threadedRod(length = rodHeight, center = false);
            }
            if (mountingHole) {
                cylinder(r = mountingHoleRadius, h = rodHeight + headHeight + 4, center = false);
                translate([0, 0, headHeight - headPadding])
                if (mountingHoleType == "chamfered") {
                    cylinder(r2 = mountingHoleRadius, r1 = mountingHoleRadius * 2, h = 2, center = false);
                } else if (mountingHoleType == "phillips") {
                    phillips_recess(depth = 3, arm_len = 3, arm_width = 1, taper = 0.3);
                } else if (mountingHoleType == "hex") {
                    cylinder(r = 3, $fn = 6, h = 3, center = false);
                }
            }
        }

    }
}


module phillips_recess(
    depth = 2.5,
    arm_len = 4.2,
    arm_width = 2.6,
    fillet = 0.5,
    taper = 0.9,
    clearance = 0.25,
    cs_dia = 0, // e.g., 8 for a small chamfer
    cs_depth = 0.6
) {
    // 2D cross profile
    module cross2d(len, wid) {
        // base cross made from two rectangles
        union() {
            square([2 * len, wid + 2 * clearance], center = true);
            rotate(90) square([2 * len, wid + 2 * clearance], center = true);
        };
        // // optional rounding of arms
        // if (fillet > 0)
        //   minkowski() { shape; circle(r=fillet, $fn=48); }
        // else
        //   shape;
    }

    // recess body (tapered)
    difference() {
        // Main tapered cruciform
        linear_extrude(height = depth, scale = taper, center = false, convexity = 10)
        cross2d(arm_len, arm_width);

        // Optional countersink/chamfer at the top
        if (cs_dia > 0 && cs_depth > 0) {
            // Subtract a shallow cone to ease starting the tip
            translate([0, 0, 0])
            cylinder(h = cs_depth, d1 = cs_dia + 2 * clearance, d2 = arm_width + 2 * clearance, $fn = 64);
        }
    }
}