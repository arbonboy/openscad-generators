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
    drawerDepth = depthMM 
  );
}

// module singleCellBackWall() {
//   cellCenter = (cellSize + 2 * Wall_Thickness) / 2;
//   difference() {
//     cube([cellSize + 2 * Wall_Thickness, cellSize + 2 * Wall_Thickness, Back_Wall_Thickness]);
//     translate([cellCenter, cellCenter, -1])
//       cylinder(Wall_Thickness * 10, holeRadius, holeRadius, center=true);
//   }
// }

// module binSlotBackWall() {

//   union() {
//     for (w = [0:Drawer_Width - 1], h = [0:Drawer_Height - 1]) {
//       //   echo(str("w: ", w, " h: ", h));
//       translate([w * (cellSize + 2 * Wall_Thickness), h * (cellSize + 2 * Wall_Thickness), 0])
//         singleCellBackWall();
//     }
//   }
// }

// // function that creates an isosceles trapezoid
// // with a given top width, bottom width, height, and depth.
// // The trapezoid is centered at the origin in the XY plane,
// // and extends in the positive Z direction.
// module trapezoid(topWidth, bottomWidth, height, depth) {
//   polyhedron(
//     // pt      0        1        2        3        4        5        6        7
//     points=[
//       [-bottomWidth / 2, -height / 2, 0],   // 0
//       [bottomWidth / 2, -height / 2, 0],    // 1
//       [bottomWidth / 2, height / 2, 0],     // 2
//       [-bottomWidth / 2, height / 2, 0],    // 3
//       [-topWidth / 2, -height / 2, depth], // 4
//       [topWidth / 2, -height / 2, depth],    // 5
//       [topWidth / 2, height / 2, depth],     // 6
//       [-topWidth / 2, height / 2, depth]     // 7
//     ],
//     // faces
//     faces=[
//       [0, 1, 2, 3], // bottom face
//       [4, 5, 6, 7], // top face
//       [0, 1, 5, 4], // front face
//       [1, 2, 6, 5], // right face
//       [2, 3, 7, 6], // back face
//       [3, 0, 4, 7]  // left face
//     ]
//   );    
// }


// module binSlot(binSlotOuterWidth, binSlotOuterHeight, binSlotInnerWidth, binSlotInnerHeight, binSlotDepth, colIndex, rowIndex) {
//   union() {
//     translate([binSlotOuterWidth / 2, binSlotOuterHeight / 2, binSlotDepth / 2]) {
//       if (Add_Drawer_Blockers) {
//           // Left Blocker
//           translate([-binSlotInnerWidth / 2 + wallBlockerLengthX / 2, 0, -binSlotDepth / 2 + headPadding / 2]) {
//             cube([wallBlockerLengthX, wallBlockerHeightY, headPadding], center=true);
//           }
//           // Right Blocker
//           translate([binSlotInnerWidth / 2 - wallBlockerLengthX / 2, 0, -binSlotDepth / 2 + headPadding / 2]) {
//             cube([wallBlockerLengthX, wallBlockerHeightY, headPadding], center=true);
//           }
        
//       }

//       difference() {
//         cube([binSlotOuterWidth, binSlotOuterHeight, binSlotDepth], center=true);
//         cube([binSlotInnerWidth, binSlotInnerHeight, binSlotDepth], center=true);
//         if (Cutout_Style == "Trapezoidal") {
//           trapezoidalCutoutWidthHorizontal = Cutout_Top_Width_Percentage / 100 * binSlotOuterWidth;
//           trapezoidalCutoutWidthHorizontalBottom = Cutout_Bottom_Width_Percentage / 100 * binSlotOuterWidth;
//           trapezoidalCutoutWidthVertical = Cutout_Top_Width_Percentage / 100 * binSlotOuterHeight;
//           trapezoidalCutoutWidthVerticalBottom = Cutout_Bottom_Width_Percentage / 100 * binSlotOuterHeight;
//           trapezoidalCutoutDepth = Cutout_Height_Percentage / 100 * binSlotDepth;
//           cutoutThickness = Wall_Thickness*2;
          

//           topCutoutPositionX = 0;
//           topCutoutPositionY = binSlotOuterHeight/2;
//           topCutoutPositionZ =  binSlotDepth/2 - trapezoidalCutoutDepth + 1;
//           translate([topCutoutPositionX, topCutoutPositionY, topCutoutPositionZ]) {
//             rotate([0, 0, 0]){
//                 if(Ignore_Cutout_For_Top_Wall && rowIndex == Rack_Rows-1) {
//                   // Do nothing
//                 } else {
//                   color("red") 
//                     trapezoid(trapezoidalCutoutWidthHorizontal, trapezoidalCutoutWidthHorizontalBottom, cutoutThickness, trapezoidalCutoutDepth);
//                 }
//             }
//           }

//           bottomCutoutPositionX = 0;
//           bottomCutoutPositionY = -binSlotOuterHeight/2;
//           bottomCutoutPositionZ =  binSlotDepth/2 - trapezoidalCutoutDepth + 1;
//           translate([bottomCutoutPositionX, bottomCutoutPositionY, bottomCutoutPositionZ]) {
//             rotate([0, 0, 0]){
//                 if(Ignore_Cutout_For_Bottom_Wall && rowIndex == 0) {
//                   // Do nothing
//                 } else {
//                   color("red") 
//                     trapezoid(trapezoidalCutoutWidthHorizontal, trapezoidalCutoutWidthHorizontalBottom, cutoutThickness, trapezoidalCutoutDepth);
//                 }
//             }
//           }
          
//           rightCutoutPositionX = binSlotOuterWidth/2;
//           rightCutoutPositionY = 0;
//           rightCutoutPositionZ =  binSlotDepth/2 - trapezoidalCutoutDepth + 1;
//           translate([rightCutoutPositionX, rightCutoutPositionY, rightCutoutPositionZ]) {
//             rotate([0, 0, 90]){
//                 if(Ignore_Cutout_For_Right_Wall && colIndex == Rack_Columns-1) {
//                   // Do nothing
//                 } else {
//                   color("green")
//                     trapezoid(trapezoidalCutoutWidthVertical, trapezoidalCutoutWidthVerticalBottom, cutoutThickness, trapezoidalCutoutDepth);
//                 }
//             }
            
//           }

//           leftCutoutPositionX = -binSlotOuterWidth/2;
//           leftCutoutPositionY = 0;
//           leftCutoutPositionZ =  binSlotDepth/2 - trapezoidalCutoutDepth + 1;
//           translate([leftCutoutPositionX, leftCutoutPositionY, leftCutoutPositionZ]) {
//             rotate([0, 0, 90]){
//                 if(Ignore_Cutout_For_Left_Wall && colIndex == 0) {
//                   // Do nothing
//                 } else {
//                   color("green")
//                     trapezoid(trapezoidalCutoutWidthVertical, trapezoidalCutoutWidthVerticalBottom, cutoutThickness, trapezoidalCutoutDepth);
//                 }
//             }
//           }
//         } else if (Cutout_Style == "None") {
//           // Do nothing
//         }
//       }
      
//     }
//     binSlotBackWall();
//   }
// }

// module storageBoxFrame() {
//   union() {
//     for (c = [0:Rack_Columns - 1], r = [0:Rack_Rows - 1]) {
//       translate([c * binSlotOuterWidth, r * binSlotOuterHeight, 0])
//         binSlot(binSlotOuterWidth, binSlotOuterHeight, binSlotInnerWidth, binSlotInnerHeight, binSlotDepth, c, r);
//     }
//   }
// }

// module binDrawer() {
//   drawerOuterWidth = binSlotInnerWidth - Drawer_Tolerance;
//   drawerOuterHeight = binSlotInnerHeight - Drawer_Tolerance;
//   drawerDepth = Drawer_Depth * cellSize - Drawer_Tolerance;

//   drawerInnerWidth = drawerOuterWidth - 2 * Wall_Thickness;
//   drawerInnerHeight = drawerOuterHeight - 2 * Wall_Thickness;
//   drawerInnerDepth = drawerDepth - 2 * Wall_Thickness;
  
//   difference() {
//     cube([drawerOuterWidth, drawerOuterHeight, drawerDepth], center=false);
//     translate([Wall_Thickness, Wall_Thickness, Wall_Thickness])
//       cube([drawerInnerWidth, drawerInnerHeight * 2, drawerInnerDepth], center=false);
//     translate([drawerOuterWidth / 2, drawerOuterHeight - Drawer_Cutout_Height / 2, drawerDepth])
//       cube([Drawer_Cutout_Width, Drawer_Cutout_Height, Wall_Thickness * 10], center=true);
//   }
// }
