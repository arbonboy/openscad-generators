Base_Diameter = 18; //[1:0.1:100]
Height = 120; //[1:1:300]
Wall_Thickness = 1; //[1:0.1:10]
Twist_Factor = -50; //[-360:1:360]
Scale_Factor = 0.8; //[0.1:0.05:1]
Num_Edges = 8; //[3:1:20]
components = 4;

/* [Handle] */
Handle_Type = "none"; //["none":"None", "poly":"Rotated Polygon", "stl":"STL File"]
Handle_Stl = "none"; //["none":"None", "/Users/john.andersen/Downloads/wandHiltWooden1_fixed.stl":"Wooden 1", "/Users/john.andersen/Downloads/ElegantJewelledHandle.stl":"Jewelled"]
Handle_Max_Diameter = 50; //[15:1:60]
Handle_Height_Padding = 20; //[0:1:60]
Flip_Handle = false;

Pommel_Extend_X = 3; //[0:0.1:30]
Pommel_Outer_Height = 10; //[0:1:50]
Pommel_Total_Height = 20; //[0:1:50]

Guard_Extend_X = 8; //[0:0.1:30]
Guard_Outer_Height = 8; //[0:1:50]
Guard_Total_Height = 20; //[0:1:50]

/* [Hidden] */
Base_Padding = 2;

Handle_Hollow_Diameter = Base_Diameter + 2*Wall_Thickness;
Cutout = false;
Extended_Wand = false;

difference(){
    rotate([180, 0, 0]){
        wand();
    }
    if(Cutout){
        translate([Base_Diameter/2, 0, 0]){
            color("white", 0) cube([Base_Diameter, Base_Diameter*2, Height*(components*2)], center=true);
        }
    }
}


module wand(){
    c = ["red", "blue", "cyan", "magenta", "orange", "purple", "pink", "brown", "lime", "teal", "navy", "maroon", "olive", "gray"];
    basePadding = Base_Padding;
    if(Handle_Type != "none"){
        handle();
    }
    
    for(i = [0:components-1]){
        // height = i==0 ? Height + basePadding : Height;
        height = Height;
        extension = Extended_Wand ? (i+1)*(Height*3/4) : 0;
        translate([0, 0, Extended_Wand ? extension : 0]){
            // component(baseDiameter=Base_Diameter - 4*i*Wall_Thickness, height=height, solidBase=(i==0), roundedEnd=(i==components-1));
            previousBaseDiameter = i==0 ? Base_Diameter : baseDiameter(i-1);
            if(i > 0){
                assert(baseDiameter(i) < previousBaseDiameter - 2*Wall_Thickness, "Wall thickness is too large for the given scale factor and number of components. Adjust the parameters to ensure proper fitting.");
            } else {
                assert(baseDiameter(i) < Base_Diameter + 2*Wall_Thickness, "Base diameter must be greater than the first component's base diameter. Adjust the parameters to ensure proper fitting.");
            }
            if(Extended_Wand){
                color(c[i]) component(baseDiameter=baseDiameter(i), endDiameter=endDiameter(i), height=height, solidBase=(i==0), roundedEnd=(i==components-1), color=c[i], solid=(i==components-1));
            } else {
                component(baseDiameter=baseDiameter(i), endDiameter=endDiameter(i), height=height, solidBase=(i==0), roundedEnd=(i==components-1), color=c[i], solid=(i==components-1));
            }
            
        }
    }
}


function baseDiameter(index) = index == 0 ? Base_Diameter : index == -1 ? Base_Diameter + 2*Wall_Thickness : endDiameter(index-1) - Wall_Thickness;
function endDiameter(index) = baseDiameter(index) * Scale_Factor;
 
module component(baseDiameter=Base_Diameter, endDiameter=Base_Diameter * Scale_Factor, height=Height, solidBase=false, roundedEnd=false, solid=false, color=0){

    echo(str("Creating component with base diameter: ", baseDiameter, " and end Diameter: ", endDiameter));
    calculatedScaleFactor = endDiameter / baseDiameter;
    echo(str("Calculated scale factor for this component: ", calculatedScaleFactor));
    color(color){
        difference(){
            linear_extrude(height = height, v = [0, 0, 1], center = true, convexity = 10, twist = Twist_Factor, slices = 20, scale = calculatedScaleFactor, $fn = 16) {
                circle(d=baseDiameter, $fn=Num_Edges);  
            }
            if(!solid){
                linear_extrude(height = height, v = [0, 0, 1], center = true, convexity = 10, twist = Twist_Factor, slices = 20, scale = calculatedScaleFactor, $fn = 16) {
                    circle(d=baseDiameter - 2 * Wall_Thickness, $fn=Num_Edges);  
                }
            }
        }
    }
    // if(solidBase && !solid){
    //     translate([0, 0, -height/2]){
    //         cylinder(d=baseDiameter+1, h=Wall_Thickness*2, center=true, $fn=16);
    //     }
    // }
    if(roundedEnd && !solid){
        endFillerHeight = 4;
        translate([0, 0, height/2-endFillerHeight/2]){
            // sphere(d=baseDiameter*Scale_Factor, $fn=Num_Edges);
             linear_extrude(height = endFillerHeight, v = [0, 0, 1], center = true, $fn = 16) {
                circle(d=baseDiameter*Scale_Factor, $fn=Num_Edges);  
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



module handleRotateExtrude(){
    pommelExtend = Pommel_Extend_X;
    pommelBaseRadius = Base_Diameter/2 + 2*Wall_Thickness;
    pommelOuterRadius = Base_Diameter/2 + pommelExtend;
    pommelOuterHeight = Pommel_Outer_Height;
    pommelTotalHeight = Pommel_Total_Height;

    guardExtend = Guard_Extend_X;
    guardBaseRadius = pommelBaseRadius;
    guardOuterRadius = Base_Diameter/2 + guardExtend;
    guardOuterHeight = Guard_Outer_Height;
    guardTotalHeight = Guard_Total_Height;
    
    gripHeight = Height-pommelTotalHeight-guardTotalHeight+Base_Padding+Wall_Thickness;
    gripRadius = pommelBaseRadius;

    totalHeight = pommelTotalHeight + gripHeight + guardTotalHeight;

    difference(){
        rotate([0, 0, 0]) {
            translate([0, 0, -Height/2-(totalHeight-Height)]){
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
    difference(){
        if(Handle_Type == "stl"){
            rotateX = Flip_Handle ? 180 : 0;
            rotate([rotateX, 0, 0]) {
                handleStl(stl=Handle_Stl);
            }
        } else {
            handleRotateExtrude();
        }
        component(baseDiameter=baseDiameter(-1), endDiameter=endDiameter(-1), height=Height+2*Base_Padding, solidBase=true, roundedEnd=true, solid=true);
        // cylinder(d1=Handle_Hollow_Diameter, d2=Handle_Hollow_Diameter*Scale_Factor, h=Height+2*Base_Padding, center=true, $fn=16);
    }
    
    

}


