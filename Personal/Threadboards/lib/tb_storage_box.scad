include <tb_board_nonthreaded.scad>;
TB_SB_DrawerBlocker_Thickness = 3;
TB_SB_DrawerBlocker_Length = 5;
TB_SB_DrawerBlocker_Height = 10;

module tbSb_StorageBoxRack(
    wallThickness = 1.5,
    drawerHeight = 2,
    drawerWidth = 2,
    drawerDepth = 3,
    cols = 2,
    rows = 2,
    addDrawerBlockers = true,
    backWallThickness = 1,
    cutoutTopWidthPercentage = 80,
    cutoutBottomWidthPercentage = 50,
    cutoutHeightPercentage = 80,
    ignoreCutoutForTopWall = false,
    ignoreCutoutForRightWall = false,
    ignoreCutoutForBottomWall = false,
    ignoreCutoutForLeftWall = false,
    backWallCellSize = 24,
    backWallHoleRadius = TB_NTB_Hole_Radius,
    cornerRounding = 0
){
    // The rack is a grid of frames, each carrying its own slice of the back board, so
    // rounding a frame's corners would bite notches out of every seam where two of them
    // meet. Rounding is applied once, to the assembled rack, which leaves the interior
    // untouched and softens only the four upright corners that are actually exposed.
    rackWidth = cols * drawerWidth * backWallCellSize;
    rackHeight = rows * drawerHeight * backWallCellSize;
    rounding = min(cornerRounding, rackWidth/2, rackHeight/2);

    intersection(){
        union() tbSb_StorageBoxRackBody(
            wallThickness = wallThickness,
            drawerHeight = drawerHeight,
            drawerWidth = drawerWidth,
            drawerDepth = drawerDepth,
            cols = cols,
            rows = rows,
            addDrawerBlockers = addDrawerBlockers,
            backWallThickness = backWallThickness,
            cutoutTopWidthPercentage = cutoutTopWidthPercentage,
            cutoutBottomWidthPercentage = cutoutBottomWidthPercentage,
            cutoutHeightPercentage = cutoutHeightPercentage,
            ignoreCutoutForTopWall = ignoreCutoutForTopWall,
            ignoreCutoutForRightWall = ignoreCutoutForRightWall,
            ignoreCutoutForBottomWall = ignoreCutoutForBottomWall,
            ignoreCutoutForLeftWall = ignoreCutoutForLeftWall,
            backWallCellSize = backWallCellSize,
            backWallHoleRadius = backWallHoleRadius
        );

        // A tall prism of the rack's own footprint: it only ever removes material at the
        // corners, so the depth it is given is irrelevant as long as it clears the rack.
        translate([rackWidth/2, rackHeight/2, 0])
            cuboid([rackWidth, rackHeight, (drawerDepth + 2) * backWallCellSize * 4],
                   rounding = rounding > 0 ? rounding : 0.001, edges = "Z");
    }
}

// The rack itself, before the corners are taken off it.
module tbSb_StorageBoxRackBody(
    wallThickness = 1.5,
    drawerHeight = 2,
    drawerWidth = 2,
    drawerDepth = 3,
    cols = 2,
    rows = 2,
    addDrawerBlockers = true,
    backWallThickness = 1,
    cutoutTopWidthPercentage = 80,
    cutoutBottomWidthPercentage = 50,
    cutoutHeightPercentage = 80,
    ignoreCutoutForTopWall = false,
    ignoreCutoutForRightWall = false,
    ignoreCutoutForBottomWall = false,
    ignoreCutoutForLeftWall = false,
    backWallCellSize = 24,
    backWallHoleRadius = TB_NTB_Hole_Radius
){
    for( col = [0:cols-1]){
        for( row = [0:rows-1]){
            translate([
                col * (drawerWidth * backWallCellSize ),
                row * (drawerHeight * backWallCellSize),
                0
            ])
            tbSb_StorageBoxFrame(
                wallThickness = wallThickness,
                drawerHeight = drawerHeight,
                drawerWidth = drawerWidth,
                drawerDepth = drawerDepth,
                addDrawerBlockers = addDrawerBlockers,
                backWallThickness = backWallThickness,
                cutoutTopWidthPercentage = cutoutTopWidthPercentage,
                cutoutBottomWidthPercentage = cutoutBottomWidthPercentage,
                cutoutHeightPercentage = cutoutHeightPercentage,
                ignoreCutoutForTopWall = ignoreCutoutForTopWall,
                ignoreCutoutForRightWall = ignoreCutoutForRightWall,
                ignoreCutoutForBottomWall = ignoreCutoutForBottomWall,
                ignoreCutoutForLeftWall = ignoreCutoutForLeftWall,
                backWallCellSize = backWallCellSize,
                backWallHoleRadius = backWallHoleRadius
            );
        }
    }
}

module tbSb_StorageBoxFrame(
    wallThickness = 1.5,
    drawerHeight = 100,
    drawerWidth = 400,
    drawerDepth = 400,
    addDrawerBlockers = true,
    backWallThickness = 1,
    cutoutTopWidthPercentage = 80,
    cutoutBottomWidthPercentage = 50,
    cutoutHeightPercentage = 80,
    ignoreCutoutForTopWall = false,
    ignoreCutoutForRightWall = false,
    ignoreCutoutForBottomWall = false,
    ignoreCutoutForLeftWall = false,
    backWallCellSize = 24,
    backWallHoleRadius = TB_NTB_Hole_Radius
){
    widthMM = drawerWidth * backWallCellSize;
    heightMM = drawerHeight * backWallCellSize;
    depthMM = drawerDepth * backWallCellSize + backWallThickness;
    cutoutTopLeftXHorizontal = widthMM/2 - widthMM * cutoutTopWidthPercentage / 100 / 2;
    cutoutTopRightXHorizontal = widthMM/2 + widthMM * cutoutTopWidthPercentage / 100 / 2;
    cutoutBottomLeftXHorizontal = widthMM/2 - widthMM * cutoutBottomWidthPercentage / 100 / 2;
    cutoutBottomRightXHorizontal = widthMM/2 + widthMM * cutoutBottomWidthPercentage / 100 / 2;

    cutoutTopLeftXVertical = heightMM/2 - heightMM * cutoutTopWidthPercentage / 100 / 2;
    cutoutTopRightXVertical = heightMM/2 + heightMM * cutoutTopWidthPercentage / 100 / 2;
    cutoutBottomLeftXVertical = heightMM/2 - heightMM * cutoutBottomWidthPercentage / 100 / 2;
    cutoutBottomRightXVertical = heightMM/2 + heightMM * cutoutBottomWidthPercentage / 100 / 2;

    cutoutHeightYBottom = ignoreCutoutForBottomWall ? depthMM : depthMM - depthMM * cutoutHeightPercentage / 100;
    cutoutHeightYTop = ignoreCutoutForTopWall ? depthMM : depthMM - depthMM * cutoutHeightPercentage / 100;
    cutoutHeightYRight = ignoreCutoutForRightWall ? depthMM : depthMM - depthMM * cutoutHeightPercentage / 100;
    cutoutHeightYLeft = ignoreCutoutForLeftWall ? depthMM :depthMM -  depthMM * cutoutHeightPercentage / 100;

    tb_ntb_board(rows=drawerHeight, cols=drawerWidth, thickness=wallThickness, cell_size=backWallCellSize, hole_radius=backWallHoleRadius);


    // Bottom Wall
    translate([0,wallThickness,0]) rotate([90,0,0]) 
        linear_extrude(wallThickness){
            polygon(points=[
                    [0,0], 
                    [widthMM,0], 
                    [widthMM, depthMM], 
                    [cutoutTopRightXHorizontal, depthMM],
                    [cutoutBottomRightXHorizontal, cutoutHeightYBottom],
                    [cutoutBottomLeftXHorizontal, cutoutHeightYBottom],
                    [cutoutTopLeftXHorizontal, depthMM],
                    [0, depthMM]
                ]
            );
        }
    
    // Top Wall
    translate([0,heightMM,0]) rotate([90,0,0]) 
        linear_extrude(wallThickness){
            polygon(points=[
                    [0,0], 
                    [widthMM,0], 
                    [widthMM, depthMM], 
                    [cutoutTopRightXHorizontal, depthMM],
                    [cutoutBottomRightXHorizontal, cutoutHeightYTop],
                    [cutoutBottomLeftXHorizontal, cutoutHeightYTop],
                    [cutoutTopLeftXHorizontal, depthMM],
                    [0, depthMM]
                ]
            );
        }
    
    // Left Wall
    translate([0,0,0]) rotate([90,0,90]) 
        linear_extrude(wallThickness){
            polygon(points=[
                    [0,0], 
                    [heightMM,0], 
                    [heightMM, depthMM],
                    [cutoutTopRightXVertical, depthMM],
                    [cutoutBottomRightXVertical, cutoutHeightYLeft],
                    [cutoutBottomLeftXVertical, cutoutHeightYLeft],
                    [cutoutTopLeftXVertical, depthMM],
                    [0, depthMM]
                ]
            );
        }

    // Right Wall
    translate([widthMM-wallThickness,0,0]) rotate([90,0,90]) 
        linear_extrude(wallThickness){
            polygon(points=[
                    [0,0], 
                    [heightMM,0], 
                    [heightMM, depthMM],
                    [cutoutTopRightXVertical, depthMM],
                    [cutoutBottomRightXVertical, cutoutHeightYRight],
                    [cutoutBottomLeftXVertical, cutoutHeightYRight],
                    [cutoutTopLeftXVertical, depthMM],
                    [0, depthMM]
                ]
            );
        }

    if(addDrawerBlockers){
        // Left Drawer Blocker
        translate([wallThickness+TB_SB_DrawerBlocker_Length/2, heightMM/2, backWallThickness+TB_SB_DrawerBlocker_Height/2]) rotate([0,0,0])
            cuboid([TB_SB_DrawerBlocker_Length, TB_SB_DrawerBlocker_Thickness, TB_SB_DrawerBlocker_Height]);

        // Right Drawer Blocker
        translate([widthMM - wallThickness - TB_SB_DrawerBlocker_Length/2, heightMM/2, backWallThickness+TB_SB_DrawerBlocker_Height/2]) rotate([0,0,0])
            cuboid([TB_SB_DrawerBlocker_Length, TB_SB_DrawerBlocker_Thickness, TB_SB_DrawerBlocker_Height]);

        // Bottom Drawer Blocker
        translate([widthMM/2, TB_SB_DrawerBlocker_Length/2+wallThickness, backWallThickness+TB_SB_DrawerBlocker_Height/2]) rotate([0,0,90])
            cuboid([TB_SB_DrawerBlocker_Length, TB_SB_DrawerBlocker_Thickness, TB_SB_DrawerBlocker_Height]);

        // Top Drawer Blocker
        translate([widthMM/2, heightMM - wallThickness - TB_SB_DrawerBlocker_Length/2, backWallThickness+TB_SB_DrawerBlocker_Height/2]) rotate([0,0,90])
            cuboid([TB_SB_DrawerBlocker_Length, TB_SB_DrawerBlocker_Thickness, TB_SB_DrawerBlocker_Height]);
    }
}

// Rounds off the sharp tip of a convex corner that sits at the origin with its material
// filling the -x/-y quadrant. Meant to be subtracted from a 2D profile.
module tbSb_CornerFillet(radius){
    difference(){
        translate([-radius,-radius]) square(radius);
        translate([-radius,-radius]) circle(r=radius, $fn=64);
    }
}

// The finger opening removed from the top edge of a drawer's front wall, drawn with its
// origin at the middle of the cutout's bottom edge and extending upward past the wall.
//   "Rectangular" - straight sided slot (the original shape)
//   "Rounded"     - U shaped scoop, easier on fingers and free of stress risers
module tbSb_DrawerCutoutProfile(
    cutoutWidth,
    cutoutHeight,
    cutoutStyle = "Rounded"
){
    overshoot = cutoutHeight + 1;    // run the opening out through the top edge of the wall
    if(cutoutStyle == "Rounded"){
        // A wide, shallow cutout only has room to round its bottom corners; once the cutout
        // is at least half as deep as it is wide the bottom becomes a full half circle.
        radius = min(cutoutWidth/2, cutoutHeight);
        hull(){
            translate([-cutoutWidth/2 + radius, radius]) circle(r=radius, $fn=96);
            translate([ cutoutWidth/2 - radius, radius]) circle(r=radius, $fn=96);
        }
        translate([-cutoutWidth/2, radius]) square([cutoutWidth, overshoot]);
    } else {
        translate([-cutoutWidth/2, 0]) square([cutoutWidth, overshoot]);
    }
}

// 2D profile of a drawer's front wall: the full wall rectangle with the finger opening
// taken out of its top edge.
module tbSb_DrawerFrontProfile(
    drawerWidth,
    drawerHeight,
    cutoutWidth,
    cutoutHeight,
    cutoutStyle = "Rounded",
    cutoutCornerRadius = 2
){
    // Keep the lip fillet inside the material it has to live in: the side walls either
    // side of the opening, and the wall left below the top edge.
    filletRadius = max(0, min(cutoutCornerRadius, (drawerWidth - cutoutWidth)/2, cutoutHeight));
    difference(){
        square([drawerWidth, drawerHeight]);
        if(cutoutStyle != "None" && cutoutWidth > 0 && cutoutHeight > 0){
            translate([drawerWidth/2, drawerHeight - cutoutHeight])
                tbSb_DrawerCutoutProfile(
                    cutoutWidth = cutoutWidth,
                    cutoutHeight = cutoutHeight,
                    cutoutStyle = cutoutStyle
                );

            // Break the two sharp horns the opening leaves on the top edge.
            if(cutoutStyle == "Rounded" && filletRadius > 0){
                translate([drawerWidth/2 - cutoutWidth/2, drawerHeight])
                    tbSb_CornerFillet(filletRadius);
                translate([drawerWidth/2 + cutoutWidth/2, drawerHeight])
                    mirror([1,0,0]) tbSb_CornerFillet(filletRadius);
            }
        }
    }
}

module tbSb_StorageBoxDrawer(
    drawerCutoutHeight = 10,
    drawerCutoutWidth = 30,
    drawerCutoutStyle = "Rounded",
    drawerCutoutCornerRadius = 2,
    wallThickness = 1.5,
    drawerHeight = 100,
    drawerWidth = 400,
    drawerDepth = 400,
    drawerSectionThickness = 2,
    drawerSectionHeight = 40,
    drawerSectionsY = 1,
    drawerSectionsX = 1,
    cornerRounding = 0
){
    // Trim the assembled bin against a prism of its own footprint so the four upright
    // corners come off round. Doing it here rather than on each panel keeps the walls
    // full thickness right up to the corner and leaves the dividers alone - they sit
    // well inside the footprint, so the mask never reaches them.
    rounding = min(cornerRounding, drawerWidth/2, drawerDepth/2);
    intersection(){
        union() tbSb_StorageBoxDrawerBody(
            drawerCutoutHeight = drawerCutoutHeight,
            drawerCutoutWidth = drawerCutoutWidth,
            drawerCutoutStyle = drawerCutoutStyle,
            drawerCutoutCornerRadius = drawerCutoutCornerRadius,
            wallThickness = wallThickness,
            drawerHeight = drawerHeight,
            drawerWidth = drawerWidth,
            drawerDepth = drawerDepth,
            drawerSectionThickness = drawerSectionThickness,
            drawerSectionHeight = drawerSectionHeight,
            drawerSectionsY = drawerSectionsY,
            drawerSectionsX = drawerSectionsX
        );

        cuboid([drawerWidth, drawerDepth, (drawerHeight + wallThickness) * 4],
               rounding = rounding > 0 ? rounding : 0.001, edges = "Z");
    }
}

// The bin itself, before the corners are taken off it.
module tbSb_StorageBoxDrawerBody(
    drawerCutoutHeight = 10,
    drawerCutoutWidth = 30,
    drawerCutoutStyle = "Rounded",
    drawerCutoutCornerRadius = 2,
    wallThickness = 1.5,
    drawerHeight = 100,
    drawerWidth = 400,
    drawerDepth = 400,
    drawerSectionThickness = 2,
    drawerSectionHeight = 40,
    drawerSectionsY = 1,
    drawerSectionsX = 1
){
    //Floor
    cuboid([drawerWidth, drawerDepth, wallThickness]);

    //Back Wall
    backWallStartY = drawerDepth/2 - wallThickness/2;
    translate([0,backWallStartY,drawerHeight/2-wallThickness/2]) rotate([0,0,0])
        cuboid([drawerWidth, wallThickness, drawerHeight]);

    //Left Wall
    leftWallStartX = -drawerWidth/2 + wallThickness/2;
    translate([leftWallStartX,0,drawerHeight/2-wallThickness/2]) rotate([0,0,0])
        cuboid([wallThickness, drawerDepth, drawerHeight]);

    //Right Wall
    translate([drawerWidth/2 - wallThickness/2,0,drawerHeight/2-wallThickness/2]) rotate([0,0,0])
        cuboid([wallThickness, drawerDepth, drawerHeight]);

    //Front Wall with Cutout
    translate([-drawerWidth/2,-drawerDepth/2+wallThickness/2,-wallThickness/2]) rotate([90,0,0])
        linear_extrude(wallThickness)
            tbSb_DrawerFrontProfile(
                drawerWidth = drawerWidth,
                drawerHeight = drawerHeight,
                cutoutWidth = drawerCutoutWidth,
                cutoutHeight = drawerCutoutHeight,
                cutoutStyle = drawerCutoutStyle,
                cutoutCornerRadius = drawerCutoutCornerRadius
            );
    
    // Sections
    echo(str("drawerSectionsX: ", drawerSectionsX, " drawerSectionsY: ", drawerSectionsY));
    for (y = [1:drawerSectionsY-1]) {
        sectionWidthY = drawerWidth / drawerSectionsY;
        echo(str("y: ", y));
        translate([leftWallStartX + y * sectionWidthY - drawerSectionThickness / 2,
            0,
            drawerSectionHeight / 2])
                cuboid([drawerSectionThickness, drawerDepth, drawerSectionHeight]);
    }
    for (x = [1:drawerSectionsX-1]) {
        sectionWidthX = drawerDepth / drawerSectionsX;
        echo(str("x: ", x));
        translate([0,
            backWallStartY - x * sectionWidthX + drawerSectionThickness / 2,
            drawerSectionHeight / 2])
                cuboid([drawerWidth, drawerSectionThickness, drawerSectionHeight]);
    }
      
        
}