include <BOSL2/std.scad>;
include <BOSL2/threading.scad>;

Peg_Length = 20; //[5:1:150]
Peg_Radius = 4; //[0.5:0.5:20]
Peg_Terminator_Radius = 5; //[0:0.5:20]
Peg_Terminator_Height = 2;

/* [Hidden] */
Thread_Height = 8;
Base_Bevel_Height = 1;
TB_SCREW_Threaded_Rod_Diameter = 16;
TB_SCREW_Head_Padding = 2; //The minimum amount of solid head above the cutout portion of the screw head



peg();

module threadedBase() {
    union(){
        translate([0,0,Thread_Height]) cylinder(h=Base_Bevel_Height, r1=TB_SCREW_Threaded_Rod_Diameter/2-1, r2=TB_SCREW_Threaded_Rod_Diameter/2+1, center=false);
        screw(rodHeight=Thread_Height, headStyle="solid", headHeight=0);
    }
}

module pegStaff(startingHeight) {
    translate([0,0,startingHeight]){
        cylinder(h=Peg_Length, r=Peg_Radius, center=false);
    }
}

module pegTerminator(startingHeight) {
    translate([0,0,startingHeight])
        cylinder(h=Peg_Terminator_Height, r1=Peg_Radius, r2=Peg_Terminator_Radius, center=false);
}

module peg() {
    union() {
        threadedBase();
        pegStaff(Thread_Height+Base_Bevel_Height);
        pegTerminator(Thread_Height + Base_Bevel_Height + Peg_Length);
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