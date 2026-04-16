include <BOSL2/std.scad>

/* [Card Parameters] */
Card_Width = 63; //[20:1:120]
Card_Height = 88; //[20:1:120]

/* [Frame Parameters] */
Inner_Frame_Depth = 50; //[20:1:180]
Wall_Thickness = 3; //[1:0.5:10]
Number_of_Holders = 2; //[1:1:4]
Additional_Floor_Thickness = 5; //[1:1:10]

/* [Cutout Parameters] */
Cutout_Bottom_Width_Percentage = 50; //[1:1:100]
Cutout_Bottom_Height_Percentage = 50; //[1:1:100]

Cutout_Side_Upper_Width_Percentage = 70; //[1:1:100]
Cutout_Side_Lower_Width_Percentage = 40; //[1:1:100]
Cutout_Side_Depth_Percentage = 100; //[1:1:100]

Cutout_Corner_Radius = 6; //[1:1:20]

/* [Hidden] */
Rounding_Radius = 3; //[1:1:20]
Outer_Single_Frame_Width = Card_Width + 2 * Wall_Thickness;
Outer_Single_Frame_Height = Card_Height + 2 * Wall_Thickness;
Outer_Frame_Depth = Inner_Frame_Depth + Wall_Thickness;

// Calculate final object dimensions
Final_Object_Width = Number_of_Holders * (Outer_Single_Frame_Width - Wall_Thickness) + Wall_Thickness;
Final_Object_Height = Outer_Single_Frame_Height;
Final_Object_Depth = Outer_Frame_Depth;

// Output dimensions
echo("Final Object Outer Dimensions:");
echo(str("Width: ", Final_Object_Width, "mm"));
echo(str("Height: ", Final_Object_Height, "mm"));
echo(str("Depth: ", Final_Object_Depth, "mm"));

for(i = [0 : Number_of_Holders - 1]){
    translate([i * (Outer_Single_Frame_Width - Wall_Thickness), 0, 0])
        rounded_box_with_cutouts();
}

module rounded_box(size=[Outer_Single_Frame_Width, Outer_Single_Frame_Height, Outer_Frame_Depth], radius=Rounding_Radius, edges="Z", thickness=Wall_Thickness) {
    difference(){
        hull(){
            cuboid(size=size, rounding=radius, edges=edges);
            translate([0, 0, -Outer_Frame_Depth/2-Additional_Floor_Thickness]){
                cuboid(size=[size[0]-Wall_Thickness, size[1]-Wall_Thickness, Additional_Floor_Thickness], rounding=radius-2, edges=edges);
            }
        }
        translate([0, 0, thickness])
            cube([size[0]-2*thickness, size[1]-2*thickness, size[2]+thickness], center=true);
    }
    
}

module rounded_box_with_cutouts(size=[Outer_Single_Frame_Width, Outer_Single_Frame_Height, Outer_Frame_Depth], radius=Rounding_Radius, thickness=Wall_Thickness) {
    difference(){
        rounded_box(size=size, radius=radius, thickness=thickness);
        translate([0, 0, -Outer_Frame_Depth/2]){
            cuboid(size=[size[0]*Cutout_Bottom_Width_Percentage/100, size[1]*Cutout_Bottom_Height_Percentage/100, size[2]], rounding=radius);
        }
        translate([0, Wall_Thickness, -size[2]*Cutout_Side_Depth_Percentage/100+size[2]/2+Wall_Thickness/2]){
            trapezoid_3d(
                upper_width = size[0]*Cutout_Side_Upper_Width_Percentage/100,
                lower_width = size[0]*Cutout_Side_Lower_Width_Percentage/100,
                upper_height = size[1]*2,
                lower_height = size[1]*2,
                cutout_radius = Cutout_Corner_Radius,
                depth = size[2]*Cutout_Side_Depth_Percentage/100
            );
        }
        rotate([0,0,90]){
            translate([0, Wall_Thickness, -size[2]*Cutout_Side_Depth_Percentage/100+size[2]/2+Wall_Thickness/2]){
                trapezoid_3d(
                    upper_width = size[1]*Cutout_Side_Upper_Width_Percentage/100,
                    lower_width = size[1]*Cutout_Side_Lower_Width_Percentage/100,
                    upper_height = size[0]*2,
                    lower_height = size[0]*2,
                    cutout_radius = Cutout_Corner_Radius,
                    depth = size[2]*Cutout_Side_Depth_Percentage/100
                );
            }
        }
    }
       
}

module trapezoid_3d(upper_width, lower_width, upper_height, lower_height, cutout_radius, depth) {
    prismoid(
        size1=[lower_width, lower_height], 
        size2=[upper_width, upper_height], 
        h=depth,
        rounding=cutout_radius
    );
}