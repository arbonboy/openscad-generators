include <lib/tb_screws.scad>;

Peg_Length = 20; //[5:1:150]
Peg_Radius = 4; //[0.5:0.5:20]
Peg_Terminator_Radius = 5; //[0:0.5:20]
Peg_Terminator_Height = 2;

/* [Hidden] */
Thread_Height = 8;
Base_Bevel_Height = 1;




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