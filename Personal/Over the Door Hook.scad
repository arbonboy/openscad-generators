include <BOSL2/std.scad>


/* [Hook Settings ] */
Hook_Inner_Depth = 30;
Hook_Wall_Thickness = 5;
Hook_Lip_Height = 10;
Number_Of_Hooks = 2;

/* [ Door Hanger Settings ] */
Door_Hanger_Thickness = 3;
Door_Hanger_Depth = 46;
Door_Hanger_Back_Length = 30;
Width = 20;
Total_Height = 85;

/* [ Hidden ] */
Rounding = 1;
Brace_Angle = 30;




doorHanger();
for(i = [0 : Number_Of_Hooks - 1])
    translate([-Door_Hanger_Depth/2-Hook_Wall_Thickness, -Total_Height/Number_Of_Hooks*i-tan(Brace_Angle)*Hook_Inner_Depth, 0])
        hook(1-(i/Number_Of_Hooks));




module doorHanger() {
    translate([0, 0, 0]) rotate([0, 0, 0])
        union(){
            cuboid([Door_Hanger_Depth+Door_Hanger_Thickness*2, Door_Hanger_Thickness, Width], rounding=Rounding);
            translate([Door_Hanger_Depth/2+Door_Hanger_Thickness/2, -Door_Hanger_Back_Length/2+Door_Hanger_Thickness/2, 0]) rotate([0, 0, 0])
                cuboid([Door_Hanger_Thickness, Door_Hanger_Back_Length, Width], rounding=Rounding);
            translate([-Door_Hanger_Depth/2-Door_Hanger_Thickness/2, -Total_Height/2+Door_Hanger_Thickness/2, 0]) rotate([0, 0, 0])
                cuboid([Hook_Wall_Thickness, Total_Height, Width], rounding=Rounding);
        }
}

module hook(scaleFactor=1) {
    hookFloorLength = Hook_Inner_Depth*scaleFactor+Hook_Wall_Thickness*2;
    braceAngle = Brace_Angle;
    translate([-hookFloorLength/2+Hook_Wall_Thickness/2, -Hook_Wall_Thickness/2, 0]) rotate([0, 0, 0])
        union(){
            translate([0, 0, 0]){
                cuboid([hookFloorLength, Hook_Wall_Thickness, Width], rounding=Rounding);
            }
            translate([-hookFloorLength/2+Hook_Wall_Thickness/2, Hook_Lip_Height/2, 0]){
                cuboid([Hook_Wall_Thickness, Hook_Lip_Height, Width], rounding=Rounding);
            }
            braceLength = hookFloorLength/cos(braceAngle);
            braceHeight = sin(braceAngle)*braceLength;
            translate([Hook_Wall_Thickness/4, -braceHeight/2, 0]){
                rotate([0, 0, -braceAngle]){
                    cuboid([braceLength, Hook_Wall_Thickness, Width], rounding=Rounding);
                }
            }
            
                
        }
}