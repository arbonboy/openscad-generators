
include <lib/tb_screws.scad>;

Stem_Radius = 3; //[1:0.5:4]
Hook_Radius = 4; //[1:0.5:8]
Thread_Height = 10; // height of the threaded portion
Head_Height = 8; // height of the head
Tolerance = 0.2; // tolerance for swivel fitting


//translate([16,0,Thread_Height+Head_Height]) rotate([180,0,0]) screw(rodHeight=Thread_Height, headHeight=Head_Height, headStyle="solid", center=false);
union(){
    difference(){
        translate([0,0,Thread_Height+Head_Height]) rotate([180, 0, 0]) screw(rodHeight=Thread_Height, headHeight=Head_Height, headStyle="chamfered", center=false, tolerance=Tolerance);
        translate([0,0,-Tolerance]) swivel_component(type="outer");
    }
    translate([0, 0, 0]) rotate([0,0,0]) swivel_component(type="inner");
    hook();
}

// Type == "inner" or "outer"
module swivel_component(type="inner"){
    stemRadius = type == "inner" ? Stem_Radius : Stem_Radius + Tolerance;
    t = type == "inner" ? 0 : Tolerance*2;

        union(){
            translate([0,0,0]) rotate([0, 0, 0]) cylinder(r=stemRadius, h=Thread_Height+t, center=false);
            translate([0,0,Thread_Height + 0*Head_Height/4]) rotate([0, 0, 0]) cylinder(r1=stemRadius, r2=stemRadius*1.5, h=Head_Height/4+t, center=false);
            translate([0,0,Thread_Height + 1*Head_Height/4]) rotate([0, 0, 0]) cylinder(r1=stemRadius*1.5, r2=stemRadius*1.5, h=Head_Height/4+t, center=false);
            translate([0,0,Thread_Height + 2*Head_Height/4]) rotate([0, 0, 0]) cylinder(r1=stemRadius*1.5, r2=stemRadius, h=Head_Height/4+t, center=false);
            translate([0,0,Thread_Height + 3*Head_Height/4]) rotate([0, 0, 0]) cylinder(r1=stemRadius, r2=stemRadius, h=Head_Height/4+t, center=false);
        }
}

module hook(){
    hookStartZ = Thread_Height + Head_Height;
    hookBend1Z = Thread_Height+1.25*Head_Height+Hook_Radius/2;
    hookBend2Z = hookBend1Z + Hook_Radius*3;
    hookBend3Z = hookBend2Z + Hook_Radius*2;
    hookEndZ = hookBend3Z + sin(45)*Hook_Radius*6;

    union(){
        translate([0,0,hookStartZ]) rotate([0, 0, 0]) cylinder(r1=Stem_Radius, r2=Hook_Radius, h=Head_Height/4+1, center=false);
        translate([0,0,hookBend1Z]) rotate([0, 45, 0]) cylinder(r=Hook_Radius, h=Hook_Radius*4, center=false);
        translate([0,0,hookBend1Z-0]) rotate([0, 0, 0]) sphere(r=Hook_Radius*1.1); //spheroid(d=Hook_Radius*2, style="icosa", circum=true, $fn=10);
        translate([cos(45)*Hook_Radius*4,0,hookBend2Z]) rotate([0, 0, 0]) cylinder(r=Hook_Radius, h=Hook_Radius*2, center=false);
        translate([cos(45)*Hook_Radius*4,0,hookBend2Z-0]) rotate([0, 0, 0]) sphere(r=Hook_Radius*1.1);
        translate([cos(45)*Hook_Radius*4,0,hookBend3Z]) rotate([0, -45, 0]) cylinder(r=Hook_Radius, h=Hook_Radius*6, center=false);
        translate([cos(45)*Hook_Radius*4,0,hookBend3Z]) rotate([0, -45, 0]) sphere(r=Hook_Radius*1.1);
        translate([cos(45)*Hook_Radius*4-cos(45)*Hook_Radius*6,0,hookEndZ]) rotate([0, -45, 0]) sphere(r=Hook_Radius*1.1);
        // translate([0,0,Thread_Height+1.25*Head_Height]) rotate([0, 0, 0]) torus(R=Hook_Radius, r=Stem_Radius, angle_start=0, angle_end=270, $fn=100);
    }
}