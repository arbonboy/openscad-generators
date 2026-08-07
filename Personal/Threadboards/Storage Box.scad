include <lib/tb_storage_box.scad>;
include <../ThreadedSkadis/lib/ts_constants.scad>;


/* [General Parameters] */
// Which pegboard system the rack hangs on. It sets the cell the drawers are sized in and the pitch of the back wall's mounting holes: 48mm on Threadboard, 40mm on Threaded Skadis.
Board_System = "threadboard"; // [threadboard:Threadboard, threadedskadis:Threaded Skadis]
Item_to_Render = "Rack"; // [Rack, Bin, Both]
Wall_Thickness = 1.5;//[1:0.5:5]


/* [Bin Drawer Parameters] */
// Height of each bin slot
Drawer_Height = 1; //[1:Small,2:Medium,3:Large,4:Extra Large]
// Width of each bin slot
Drawer_Width = 2; //[1:Small,2:Medium,3:Large,4:Extra Large,5:XXL]
// Depth of each bin slot
Drawer_Depth = 3; //[1:Small,2:Medium,3:Large,4:Extra Large]
//Space between the bin and the frame to allow for easy insertion/removal
Drawer_Tolerance = 1; //[0:0.1:3]
// Shape of the finger opening in the front of the bin. Rounded is a U shaped scoop; Rectangular is the original square cornered slot.
Drawer_Cutout_Style = "Rounded"; // [Rounded, Rectangular, None]
// Drawer cutout height
Drawer_Cutout_Height = 10; //[0:1:40]
// Drawer cutout width
Drawer_Cutout_Width = 30; //[0:1:130]
// Rounded style only: how much the two lips left on the top edge are broken back
Drawer_Cutout_Corner_Radius = 2; //[0:0.5:20]

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
// Rounding on the four upright (Z) edges of a bin.
Bin_Corner_Rounding = 2;        // [0:0.5:20]
// The same for the rack. The back board is tiled one piece per slot, so this rounds the
// outside corners of the finished rack rather than every slot's share of the board.
Rack_Corner_Rounding = 2;       // [0:0.5:20]

Is_Skadis = (Board_System == "threadedskadis");

// The back wall is drilled one hole per cell, and a drawer slot is a whole number of
// cells, so this is both the mounting pitch and the granularity the Small/Medium/Large
// drawer sizes step in. Threadboard spans two of its 24mm cells; Threaded Skadis spans
// two of its 20mm nodes, which is exactly TS_Board_Cell_Size_X. Doubling matters on the
// Skadis lattice: its rod holes and Skadis slots alternate node by node, so a 40mm pitch
// stays on one of the two and a 20mm pitch would land on both by turns.
Back_Wall_Cell_Size = Is_Skadis ? TS_Board_Cell_Size_X : 48;
// Skadis boards drill their rod holes a touch over nominal; match that here so the box
// hangs on the same hardware with the same clearance.
Back_Wall_Hole_Radius = Is_Skadis ? TS_Board_Hole_Radius + 0.1 : TB_NTB_Hole_Radius;


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
    backWallCellSize = Back_Wall_Cell_Size,
    backWallHoleRadius = Back_Wall_Hole_Radius,
    cornerRounding = Rack_Corner_Rounding
  );
}

if (Item_to_Render == "Bin"|| Item_to_Render == "Both") {
  widthMM = Back_Wall_Cell_Size * Drawer_Width - Drawer_Tolerance - Wall_Thickness*2;
  heightMM = Back_Wall_Cell_Size * Drawer_Height - Drawer_Tolerance - Wall_Thickness*2;
  depthMM = Back_Wall_Cell_Size * Drawer_Depth - Drawer_Tolerance - Back_Wall_Thickness*2;

  translate([-widthMM, depthMM/2, 0]) rotate([0,0,0]) tbSb_StorageBoxDrawer(
    drawerCutoutHeight = Drawer_Cutout_Height,
    drawerCutoutWidth = Drawer_Cutout_Width,
    drawerCutoutStyle = Drawer_Cutout_Style,
    drawerCutoutCornerRadius = Drawer_Cutout_Corner_Radius,
    wallThickness = Wall_Thickness,
    drawerHeight = heightMM,
    drawerWidth = widthMM,
    drawerDepth = depthMM, 
    drawerSectionThickness = Drawer_Section_Thickness,
    drawerSectionHeight = Drawer_Section_Height,
    drawerSectionsY = Drawer_Sections_Y,
    drawerSectionsX = Drawer_Sections_X,
    cornerRounding = Bin_Corner_Rounding
  );
}

