include <BOSL2/std.scad>
include <BOSL2/threading.scad>

Height = 80; //[1:1:300]
Wall_Thickness = 1; //[1:0.1:10]
Twist_Factor = 0; //[0:1:360]
Num_Edges = 8; //[3:1:200]
Num_Sections = 4; //[1:1:10]
Section_Spacing = 3; //[2:0.5:6]

/* [Common Handle Params] */
Handle_Type = "none"; //["none":"None", "poly":"Rotated Polygon", "stl":"STL File"]
Handle_Max_Diameter = 20; //[15:1:60]
Handle_Height_Padding = 20; //[0:1:60]
Flip_Handle = false;

/* [STL Handle] */
Handle_Stl = "none"; //["none":"None", "/Users/john.andersen/Downloads/wandHiltWooden1_fixed.stl":"Wooden 1", "/Users/john.andersen/Downloads/ElegantJewelledHandle.stl":"Jewelled"]

/* [Threading] */
Add_Threading = true;
Thread_Diameter = 25; //[5:0.1:60]
Thread_Pitch = 2; //[1:0.1:5]
Thread_Length = 20; //[5:1:20]
Thread_Tolerance = 0.4; //[0:0.1:3]


/* [Rotated Polygon Handle] */
Pommel_Extend_X = 3; //[0:0.1:30]
Pommel_Outer_Height = 10; //[0:1:50]
Pommel_Total_Height = 20; //[0:1:50]

Guard_Extend_X = 8; //[0:0.1:30]
Guard_Outer_Height = 8; //[0:1:50]
Guard_Total_Height = 20; //[0:1:50]

/* [Drafting Options] */
Wand_Cutout = false;
Transparent_Shell = true; // Set to true to make the shell transparent for better visualization of internal structure during design

/* [Hidden] */
Base_Padding = 2;
Min_Outer_Diameter = 8; //[1:0.1:10]
Min_Inner_Diameter = 3; //[0.5:0.1:20]

Handle_Hollow_Diameter = sectionOuterBaseDiameter(Num_Sections) + 2*Wall_Thickness;
Extended_Wand = false;



for(i=[0:Num_Sections-1]){
    echo(str("Section ", i, ": Outer Base Diameter (", sectionOuterBaseDiameter(i), ") -> Section ", i+1, " Inner End Diameter = (", sectionInnerEndDiameter(i+1), ") => Difference of ", sectionOuterBaseDiameter(i) - sectionInnerEndDiameter(i+1)));
}


difference(){
    rotate([180, 0, 0]){
        wand();
    }
    if(Wand_Cutout){
        translate([sectionOuterBaseDiameter(Num_Sections)/2, 0, 0]){
            cube([sectionOuterBaseDiameter(Num_Sections), sectionOuterBaseDiameter(Num_Sections)*2, Height*(Num_Sections*2)], center=true);
        }
    }
}


module wand(){
    c = ["red", "blue", "cyan", "magenta", "orange", "purple", "pink", "brown", "lime", "teal", "navy", "maroon", "olive", "gray"];
    if(Handle_Type != "none"){
        handle();
    }
    
    for(i = [0:Num_Sections-1]){
        height = Height;
        extension = Extended_Wand ? (i+1)*(height*3/4) : 0;
        translate([0, 0, Extended_Wand ? extension : 0]){
            section(index=i, solid=(i==0), color=c[i]); 
        }
    }
}

function sectionOuterBaseDiameter(index) = Min_Outer_Diameter + index*Section_Spacing*Wall_Thickness;
function sectionInnerBaseDiameter(index) = sectionOuterBaseDiameter(index) - 2*Wall_Thickness;
function sectionInnerEndDiameter(index) = Min_Inner_Diameter + index*Section_Spacing*Wall_Thickness;
function sectionOuterEndDiameter(index) = sectionInnerEndDiameter(index) + 2*Wall_Thickness;


module section(index=0, solid=false, color=0){
    height = Height;
    calculatedScaleFactor = sectionOuterEndDiameter(index) / sectionOuterBaseDiameter(index); 
    echo(str("Section ", index, ": Base Diameter = ", sectionOuterBaseDiameter(index), ", End Diameter = ", sectionOuterEndDiameter(index), ", Scale Factor = ", calculatedScaleFactor));
    if(index > 0){
        assert(sectionOuterBaseDiameter(index) >= sectionInnerEndDiameter(index-1), str("Error: Section ", index, " outer base diameter (", sectionOuterBaseDiameter(index), ") must be less than or equal to previous section's base diameter (", sectionInnerEndDiameter(index-1), "). Adjust the parameters to ensure proper fitting."));
    }
    transparency = Transparent_Shell && index == Num_Sections-1 ? 0.2 : 1;
    color(color, transparency){
        difference(){
            linear_extrude(height = height, v = [0, 0, 1], center = true, convexity = 10, twist = Twist_Factor, slices = 20, scale = calculatedScaleFactor, $fn = 16) {
                    circle(d=sectionOuterBaseDiameter(index), $fn=Num_Edges);  
            }
            if(!solid){
                linear_extrude(height = height, v = [0, 0, 1], center = true, convexity = 10, twist = Twist_Factor, slices = 20, scale = calculatedScaleFactor, $fn = 16) {
                    circle(d=sectionInnerBaseDiameter(index), $fn=Num_Edges);  
                }
            }
        }
    }
}




module handleStl(stl){

    translate([0, 0, -Wall_Thickness-Handle_Height_Padding/2]){
        resize([Handle_Max_Diameter, Handle_Max_Diameter, Height+2*Wall_Thickness+Handle_Height_Padding]){
            import(stl, center=true);   
        }
    }

}

module upper_handle(rotateX, split_z) {
    difference(){
        intersection(){
            rotate([rotateX, 0, 0]) {
                handleStl(stl=Handle_Stl);
            }
            translate([0,0, split_z + 100]) {
                cube([400,400,200], center=true);
            }
        }
        scale([0.9, 0.9, 1]) section(index=Num_Sections, solid=true, color="white");
        translate([0, 0, -(Height/2 + Base_Padding/2)]){
            cylinder(d=sectionOuterBaseDiameter(Num_Sections), h=Base_Padding, center=true, $fn=92);
        }
    }
}

module lower_handle(rotateX, split_z) {
    intersection(){
        rotate([rotateX, 0, 0]) {
            handleStl(stl=Handle_Stl);
        }
        translate([0,0, split_z - 100]) {
            cube([400,400,200], center=true);
        }
    }
}



module handleRotateExtrude(){
    pommelExtend = Pommel_Extend_X;
    pommelBaseRadius = Handle_Max_Diameter/2 + 2*Wall_Thickness;
    pommelOuterRadius = Handle_Max_Diameter/2 + pommelExtend;
    pommelOuterHeight = Pommel_Outer_Height;
    pommelTotalHeight = Pommel_Total_Height;

    guardExtend = Guard_Extend_X;
    guardBaseRadius = pommelBaseRadius;
    guardOuterRadius = Handle_Max_Diameter/2 + guardExtend;
    guardOuterHeight = Guard_Outer_Height;
    guardTotalHeight = Guard_Total_Height;
    
    gripHeight = Height-pommelTotalHeight-guardTotalHeight+Base_Padding+Wall_Thickness+Handle_Height_Padding;
    gripRadius = pommelBaseRadius;

    totalHeight = pommelTotalHeight + gripHeight + guardTotalHeight;

    difference(){
        rotate([0, 0, 0]) {
            translate([0, 0, -Height/2+(Height-totalHeight)]){
                rotate_extrude($fn=200) polygon( points=[
                    [0,0],
                    [pommelBaseRadius,0],
                    [pommelOuterRadius, (pommelTotalHeight/2-pommelOuterHeight/2)],
                    [pommelOuterRadius, (pommelTotalHeight/2+pommelOuterHeight/2)],
                    [pommelBaseRadius, pommelTotalHeight],
                    [gripRadius, pommelTotalHeight+gripHeight], 
                    [guardOuterRadius, pommelTotalHeight+gripHeight+guardTotalHeight/2-guardOuterHeight/2],
                    [guardOuterRadius, pommelTotalHeight+gripHeight+guardTotalHeight/2+guardOuterHeight/2],
                    [gripRadius, pommelTotalHeight+gripHeight+guardTotalHeight],
                    [0, pommelTotalHeight+gripHeight+guardTotalHeight]
                ]);
            }
        } 
        // translate([0, 0, 0]){
        //     // component(baseDiameter=baseDiameter(0), endDiameter=endDiameter(0), height=Height, solidBase=(true), roundedEnd=(true), solid=true);
        //     cylinder(d1=Handle_Hollow_Diameter, d2=Handle_Hollow_Diameter*Scale_Factor, h=Height+2*Base_Padding, center=true, $fn=16);
        // }
        
    }
}

module handle(){
    if(Handle_Type == "stl"){
        split_z = -Height/2 - Handle_Height_Padding/2;
        rotateX = Flip_Handle ? 180 : 0;
        union(){
            difference(){
                upper_handle(rotateX, split_z);
                translate([0, 0, split_z]){
                    cylinder(d=sectionOuterBaseDiameter(Num_Sections)-10, h=Handle_Height_Padding, center=true, $fn=92);
                }
                translate([0,0,split_z+Thread_Length/2-5]) threaded_rod(d=Thread_Diameter+Thread_Tolerance, l=Thread_Length+10, pitch=Thread_Pitch, $fn=32);
            }
            
            rotate([180, 0, 0]){
                translate([Handle_Max_Diameter*2, 0, 0]) {
                    union(){
                        lower_handle(rotateX, split_z);
                        translate([0,0,split_z + Thread_Length/2]){
                            threaded_rod(d=Thread_Diameter, l=Thread_Length, pitch=Thread_Pitch, $fn=32);    
                        } 
                    }
                    
                }
            }
            
            
        }
    } else {
        difference(){
            handleRotateExtrude();
            section(index=Num_Sections, solid=true, color="white");
            translate([0, 0, -(Height/2 + Base_Padding/2)]){
                cylinder(d=sectionOuterBaseDiameter(Num_Sections), h=Base_Padding, center=true, $fn=92);
            }
        }
    }
}


