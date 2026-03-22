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
    backWallCellSize = 24
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
                backWallCellSize = backWallCellSize
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
    backWallCellSize = 24
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

    tb_ntb_board(rows=drawerHeight, cols=drawerWidth, thickness=wallThickness, cell_size=backWallCellSize);


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

module tbSb_StorageBoxDrawer(
    drawerCutoutHeight = 10,
    drawerCutoutWidth = 30,
    wallThickness = 1.5,
    drawerHeight = 100,
    drawerWidth = 400,
    drawerDepth = 400
){
    //Floor
    cuboid([drawerWidth, drawerDepth, wallThickness]);

    //Back Wall
    translate([0,drawerDepth/2-wallThickness/2,drawerHeight/2-wallThickness/2]) rotate([0,0,0])
        cuboid([drawerWidth, wallThickness, drawerHeight]);

    //Left Wall
    translate([-drawerWidth/2+wallThickness/2,0,drawerHeight/2-wallThickness/2]) rotate([0,0,0])
        cuboid([wallThickness, drawerDepth, drawerHeight]);

    //Right Wall
    translate([drawerWidth/2 - wallThickness/2,0,drawerHeight/2-wallThickness/2]) rotate([0,0,0])
        cuboid([wallThickness, drawerDepth, drawerHeight]);

    //Front Wall with Cutout
    translate([-drawerWidth/2,-drawerDepth/2+wallThickness/2,-wallThickness/2]) rotate([90,0,0]) 
        linear_extrude(wallThickness)
            polygon(points=[
                [0,0],
                [drawerWidth,0],
                [drawerWidth, drawerHeight],
                [drawerWidth/2+drawerCutoutWidth/2, drawerHeight],
                [drawerWidth/2+drawerCutoutWidth/2, drawerHeight- drawerCutoutHeight],
                [drawerWidth/2-drawerCutoutWidth/2, drawerHeight - drawerCutoutHeight],
                [drawerWidth/2-drawerCutoutWidth/2, drawerHeight],
                [0, drawerHeight]
            ]);
        
}