include <lib/tb_storage_box.scad>;


/* [General Parameters] */
Item_to_Render = "Rack"; // [Rack, Bin, Both]
Wall_Thickness = 1.5;//[1:0.5:5]


/* [Bin Drawer Parameters] */
// Height of each bin slot
Drawer_Height = 1; //[1:Small,2:Medium,3:Large,4:Extra Large]
// Width of each bin slot
Drawer_Width = 2; //[1:Small,2:Medium,3:Large,4:Extra Large]
// Depth of each bin slot
Drawer_Depth = 3; //[1:Small,2:Medium,3:Large,4:Extra Large]
//Space between the bin and the frame to allow for easy insertion/removal
Drawer_Tolerance = 1; //[0:0.1:3]
// Drawer cutout height
Drawer_Cutout_Height = 10; //[0:1:40]
// Drawer cutout width
Drawer_Cutout_Width = 30; //[0:1:130]

/* [Bin Drawer Sections] */
Drawer_Section_Thickness = 2; //[1:0.5:5]
Drawer_Section_Height = 40; //[10:1:200]
Drawer_Sections_Y = 2; //[1:1:10]
Drawer_Sections_X = 1; //[1:1:10]

/* [Rack Parameters] */
// Number of Bin columns in the rack
Rack_Columns = 2; // [1:20]
// Number of Bin rows in the rack
Rack_Rows = 4; // [1:20]
// Add Drawer blockers to the sides of the rack to allow for screw head clearance
Add_Drawer_Blockers = true; // [true,false]
//Thickness of the back wall of the rack
Back_Wall_Thickness = 1; //[1:0.5:5]


/* [Rack Cut-out Parameters] */
// Style of Cut-out on each wall
Cutout_Style = "Trapezoidal"; // [Trapezoidal, None]
// [% of bin size]
Cutout_Top_Width_Percentage = 80; //[0:100]
// [% of bin size]
Cutout_Bottom_Width_Percentage = 50; //[0:100]
// [% of bin depth]
Cutout_Height_Percentage = 80; //[0:100]
Ignore_Cutout_For_Top_Wall = false; // [true,false]
Ignore_Cutout_For_Right_Wall = false; // [true,false]
Ignore_Cutout_For_Bottom_Wall = false; // [true,false]
Ignore_Cutout_For_Left_Wall = false; // [true,false]

/* [Hidden] */
Back_Wall_Cell_Size = 48;  


if (Item_to_Render == "Rack" || Item_to_Render == "Both") {
  tbSb_StorageBoxRack(
    cols = Rack_Columns,
    rows = Rack_Rows,
    wallThickness = Wall_Thickness,
    drawerHeight = Drawer_Height,
    drawerWidth = Drawer_Width,
    drawerDepth = Drawer_Depth,
    addDrawerBlockers = Add_Drawer_Blockers,
    backWallThickness = Back_Wall_Thickness,
    cutoutTopWidthPercentage = Cutout_Top_Width_Percentage,
    cutoutBottomWidthPercentage = Cutout_Bottom_Width_Percentage,
    cutoutHeightPercentage = Cutout_Height_Percentage,
    ignoreCutoutForTopWall = Ignore_Cutout_For_Top_Wall,
    ignoreCutoutForRightWall = Ignore_Cutout_For_Right_Wall,
    ignoreCutoutForBottomWall = Ignore_Cutout_For_Bottom_Wall,
    ignoreCutoutForLeftWall = Ignore_Cutout_For_Left_Wall,
    backWallCellSize = Back_Wall_Cell_Size
  );
}

if (Item_to_Render == "Bin"|| Item_to_Render == "Both") {
  widthMM = Back_Wall_Cell_Size * Drawer_Width - Drawer_Tolerance - Wall_Thickness*2;
  heightMM = Back_Wall_Cell_Size * Drawer_Height - Drawer_Tolerance - Wall_Thickness*2;
  depthMM = Back_Wall_Cell_Size * Drawer_Depth - Drawer_Tolerance - Back_Wall_Thickness*2;

  translate([-widthMM, depthMM/2, 0]) rotate([0,0,0]) tbSb_StorageBoxDrawer(
    drawerCutoutHeight = Drawer_Cutout_Height,
    drawerCutoutWidth = Drawer_Cutout_Width,
    wallThickness = Wall_Thickness,
    drawerHeight = heightMM,
    drawerWidth = widthMM,
    drawerDepth = depthMM, 
    drawerSectionThickness = Drawer_Section_Thickness,
    drawerSectionHeight = Drawer_Section_Height,
    drawerSectionsY = Drawer_Sections_Y,
    drawerSectionsX = Drawer_Sections_X
  );
}

