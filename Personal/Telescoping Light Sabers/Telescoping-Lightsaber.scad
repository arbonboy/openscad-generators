include <BOSL2/std.scad>
include <BOSL2/threading.scad>

/* [General] */
Object_To_Build = "both"; //["saber", "handle", "both"]

/* Telescoping Saber Params */
Height = 80; //[1:1:300]
Wall_Thickness = 1; //[1:0.1:10]
Twist_Factor = 0; //[0:1:360]
Num_Edges = 8; //[3:1:200]
Num_Sections = 4; //[1:1:10]
Section_Spacing = 3; //[2:0.5:6]
Saber_Z_Adjustment = 0; //[-300:1:300]

/* [Common Handle Params] */
Handle_Max_Diameter = 20; //[15:1:60]
Additional_Handle_Height = 0; //[0:1:100]
Flip_Handle = false;

/* [STL Handle] */
Handle_Stl = "/Users/john.andersen/Library/CloudStorage/GoogleDrive-arbonboy@gmail.com/My Drive/Personal/3D Printing/openscad-generators/Personal/Telescoping Light Sabers/Ascendant Light Saber/ascendant-simplified-fixed-ready-to-prodcess.stl";

/* [Threading] */
Add_Threading = true;
Handle_Cut_Z_Percentage = 10; //[1:0.1:100]
Thread_Diameter = 25; //[5:0.1:60]
Thread_Pitch = 2; //[1:0.1:5]
Thread_Length = 20; //[5:1:20]
Thread_Tolerance = 0.4; //[0:0.1:3]

/* [Drafting Options] */
Saber_Cutout = false;
Transparent_Shell = true; // Set to true to make the shell transparent for better visualization of internal structure during design
Hide_Handle = false; // Set to true to hide the handle for better visualization of the saber sections during design

/* [Hidden] */
Base_Padding = 2;
Handle_Type = "stl"; 
Min_Outer_Diameter = 10; //15; //15; //8; //[1:0.1:10]
Min_Inner_Diameter = 5; //10; //5; //3; //[0.5:0.1:20]
Total_Handle_Height = Height + Additional_Handle_Height;
Handle_Height_Padding = 0; //[0:1:120]
Threaded_Pommel_Height = Total_Handle_Height*Handle_Cut_Z_Percentage/100+Thread_Length;



Handle_Hollow_Diameter = sectionOuterBaseDiameter(Num_Sections) + 2*Wall_Thickness;
Extended_Saber = false;



for(i=[0:Num_Sections-1]){
    echo(str("Section ", i, ": Outer Base Diameter (", sectionOuterBaseDiameter(i), ") -> Section ", i+1, " Inner End Diameter = (", sectionInnerEndDiameter(i+1), ") => Difference of ", sectionOuterBaseDiameter(i) - sectionInnerEndDiameter(i+1)));
}

// outer diameter of base of outermost section - outer diameter of tip of sleeve section = between 0.8 to 1.6

// Thread_Diameter - outer diameter of base of outermost section = between 0 to 1 mm (or set it automatically)

difference(){
    rotate([180, 0, 0]){
        saber();
    }
    if(Saber_Cutout && $preview){
        translate([sectionOuterBaseDiameter(Num_Sections)/2, 0, 0]){
            cube([sectionOuterBaseDiameter(Num_Sections), sectionOuterBaseDiameter(Num_Sections)*2, Height*(Num_Sections*2)], center=true);
        }
    }
}


module saber(){
    c = ["red", "blue", "cyan", "magenta", "orange", "purple", "pink", "brown", "lime", "teal", "navy", "maroon", "olive", "gray"];
    
    if(Object_To_Build == "handle" || Object_To_Build == "both"){
        if(Handle_Type != "none" ){
            if(Hide_Handle && !$preview ){
                handle();
            } else if(!Hide_Handle){
                handle();
            }
        }
    } 
    if(Object_To_Build == "saber" || Object_To_Build == "both"){
        translate([0, 0, Saber_Z_Adjustment]){
            grounded(-Height/2) {
                sections(c);
            }
        }
    }   
    
}

module sections(c) {
    for(i = [0:Num_Sections-1]){
        height = Height;
        extension = Extended_Saber ? (i+1)*(height*3/4) : 0;
        translate([0, 0, Extended_Saber ? extension : 0]){
            section(index=i, solid=(i==0), color=c[i]); 
        }
    }
}

function sectionOuterBaseDiameter(index) = Min_Outer_Diameter + index*Section_Spacing*Wall_Thickness;
function sectionInnerBaseDiameter(index) = sectionOuterBaseDiameter(index) - 2*Wall_Thickness;
function sectionInnerEndDiameter(index) = Min_Inner_Diameter + index*Section_Spacing*Wall_Thickness;
function sectionOuterEndDiameter(index) = sectionInnerEndDiameter(index) + 2*Wall_Thickness;
// function handleSplitZ() = -Height/2 - Handle_Height_Padding/2;
function handleSplitZ() = -Height*Handle_Cut_Z_Percentage/100;


module section(index=0, solid=false, color=0){
    height = index == Num_Sections && Handle_Type == "section" ? Height + 2*Wall_Thickness : Height;
    // height = Height;
    // translateZ = index == Num_Sections && Handle_Type == "section" ? -Base_Padding/2 : 0;
    translateZ = Base_Padding/2;
    calculatedScaleFactor = sectionOuterEndDiameter(index) / sectionOuterBaseDiameter(index); 
    echo(str("Section ", index, ": Base Diameter = ", sectionOuterBaseDiameter(index), ", End Diameter = ", sectionOuterEndDiameter(index), ", Scale Factor = ", calculatedScaleFactor));
    if(index > 0){
        assert(sectionOuterBaseDiameter(index) >= sectionInnerEndDiameter(index-1), str("Error: Section ", index, " outer base diameter (", sectionOuterBaseDiameter(index), ") must be less than or equal to previous section's base diameter (", sectionInnerEndDiameter(index-1), "). Adjust the parameters to ensure proper fitting."));
    }
    transparency = Transparent_Shell && index == Num_Sections-1 ? 0.2 : 1;
    translate([0, 0, translateZ]){
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
}




module handleStl(stl){
    sizeX = Handle_Max_Diameter;
    sizeY = Handle_Max_Diameter;
    // sizeZ = Height+2*Wall_Thickness+Handle_Height_Padding+Additional_Handle_Height+(Add_Threading ? Thread_Length : 0);
    // sizeZ = Height+2*Wall_Thickness+Handle_Height_Padding;
    sizeZ = Total_Handle_Height;
    echo(str("Handle STL: ", stl, " -> Scaled to fit within ", sizeX, "x", sizeY, "x", sizeZ, "mm box"));
    echo(str("Handle Split Z: ", -handleSplitZ()));
    translate([0, 0, -handleSplitZ()]){
        resize([sizeX, sizeY, sizeZ]){
            import(stl, center=true);   
        }
    }

}




module handle(){
    if(Handle_Type == "stl"){
        if(Add_Threading){
            split_z = handleSplitZ();
            rotateX = Flip_Handle ? 180 : 0;
            grounded(0) {
                upperHandle(rotateX, split_z);
            }

            //function handleSplitZ() = -Height/2 - Handle_Height_Padding/2;
            rotate([180, 0, 0]){    
                grounded(-handleSplitZ()){
                        lowerHandle(rotateX, split_z);
                }
            }
        } else {
            grounded(-Height/2){
                difference(){
                    handleStl(stl=Handle_Stl);
                    section(index=Num_Sections, solid=true, color="white");
                    translate([0, 0, -(Height/2 + Base_Padding/2)]){
                        cylinder(d=sectionOuterBaseDiameter(Num_Sections), h=Base_Padding, center=true, $fn=92);
                    }
                }
            }
        }
            
    } 
}



module lowerHandle(rotateX, split_z){
    echo("lowerHandle::\nTotal_Handle_Height: ",Total_Handle_Height,"\nAdditional_Handle_Height: ",Additional_Handle_Height,"\nHandle Cut Z Percentage: ",Handle_Cut_Z_Percentage,"\nThread Length: ",Thread_Length);
    translate([Handle_Max_Diameter*2, Handle_Max_Diameter*2, 0]) {
        union(){
            translate([0, 0, Total_Handle_Height/2 + 3*split_z]) lower_handle(rotateX, split_z);
            translate([0,0,split_z + Thread_Length/2]){
                threaded_rod(d=Thread_Diameter, l=Thread_Length, pitch=Thread_Pitch, $fn=32);    
            } 
        }
        
    }
}

module upperHandle(rotateX, split_z){
    difference(){
        upper_handle(rotateX, split_z);
        // translate([0, 0, -Total_Handle_Height/2+Thread_Length*2]){
        //     cylinder(d=sectionOuterBaseDiameter(Num_Sections), h=Additional_Handle_Height-Thread_Length/2, center=true, $fn=92);
        // }
        # translate([0,0,-Total_Handle_Height/2-split_z]) threaded_rod(d=Thread_Diameter+Thread_Tolerance, l=Thread_Length+Additional_Handle_Height, pitch=Thread_Pitch, $fn=32);
    }
}

module upper_handle(rotateX, split_z) {
    difference(){
        translate([0, 0, -Additional_Handle_Height/2]){
            intersection(){
                rotate([rotateX, 0, 0]) {
                    handleStl(stl=Handle_Stl);
                }
                translate([0,0, -split_z*2]) {
                    cube([Handle_Max_Diameter,Handle_Max_Diameter,Total_Handle_Height], center=true);
                }
            }
        }
        # translate([0, 0, -handleSplitZ()-Base_Padding/2+1]) scale([0.9, 0.9, 1]) section(index=Num_Sections, solid=true, color="white");
        // translate([0, 0, -(Height/2 + Base_Padding/2)]){
        //     # cylinder(d=sectionOuterBaseDiameter(Num_Sections), h=Base_Padding, center=true, $fn=92);
        // }
    }
}

module lower_handle(rotateX, split_z) {
    intersection(){
        rotate([rotateX, 0, 0]) {
            handleStl(stl=Handle_Stl);
        }
        translate([0,0,-Total_Handle_Height-split_z*2]) {
            cube([Handle_Max_Diameter,Handle_Max_Diameter,Total_Handle_Height], center=true);
        }
    }
}


module grounded(shift = handleSplitZ()) {
    translate([0, 0, shift]) {
        children();
    }
}