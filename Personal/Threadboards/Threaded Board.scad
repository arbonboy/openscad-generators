include <BOSL2/std.scad>;
include <BOSL2/threading.scad>;
include <BOSL2/paths.scad>;
include <lib/tb_board_threaded.scad>;


Rows = 2;
Cols = 2;
Height = 4; //[4:4mm,8:8mm]
Layers = 2; // Number of layers
Spacer_Radius = 0.6; // Radius of the spacer
//This should match your slicer's layer height
Spacer_Height = 0.75; // Height of the spacer
Cell_Length = 24; // Length of each cell
Min_Dist_Between_Spacers = 3; // Minimum distance between spacers
Reinforce_Holes = true; // Reinforce holes with a cylinder
Hole_Reinforcer_Radius = 9; // Radius of the hold reinforcer
Hole_Reinforcer_Border = 1; // Border of the hold reinforcer
Include_Reinforcements_On_Topmost_Layer = false; // Include reinforcements on the topmost layer
Hole_Reinforcers_Dash_Angle = 5;
Hole_Reinforcers_Gap_Angle = 20;
Punch_Out_Style = 0; //[0:Square,1:Circle,2:Octagon,3:Threaded,4:Complex Threaded]
Punch_Out_Size = 12; // Size of the punch out
Punch_Out_Affects_Border = true;



board();
// threadedHoleSpacer(r = TB_TB_Hole_Radius + 1, h = Spacer_Height, dashes = 40, dash_fraction = 0.5);

module punchoutBoard(){
  punchoutCols = Punch_Out_Affects_Border ? Cols + 1 : Cols - 1;
  punchoutRows = Punch_Out_Affects_Border ? Rows + 1 : Rows - 1;
  difference(){
    board();
    color("red") translate([0, 0, -Height/2]) tb_tb_punchouts(style = Punch_Out_Style, rows = punchoutRows, cols = punchoutCols, thickness = 300, cell_size = Cell_Length, hole_size = Punch_Out_Size);
  }
}


module board() {
  for (level = [0:1:Layers - 1]) {
    boardZPos = level * (Height + Spacer_Height); // Calculate the position of each layer
    spacerZPos = boardZPos + Height; // Calculate the position of each layer
    layersForSpacers = Include_Reinforcements_On_Topmost_Layer ? Layers : Layers - 1;
  
    translate([0, 0, boardZPos]) {
      tb_tb_board(rows=Rows, cols=Cols, punchout_style=Punch_Out_Style, punchout_size=Punch_Out_Size, punchout_affects_border=Punch_Out_Affects_Border, roundedCorners = false, center=false, spacers=Layers > 1 && level != Layers-1 ? true : Include_Reinforcements_On_Topmost_Layer ? true :false, spacer_height=Spacer_Height);
    }
    // if (level < layersForSpacers) {
    //   translate([Cell_Length/2, Cell_Length/2, spacerZPos]) {
    //     for (tiley = [0:1:Rows - 1]) {
    //       translate([0, Cell_Length * tiley, 0]) drawSpacers(Height / 2, Spacer_Height, Spacer_Radius); // Draw spacers at the specified height
    //       for (tilex = [0:1:Cols - 1]) {
    //         translate([Cell_Length * tilex, Cell_Length * tiley, 0]) drawSpacers(Height / 2, Spacer_Height, Spacer_Radius); // Draw spacers at the specified height
    //       }
    //     }
    //   }
    // }
  }
}

module drawSpacers(zPos, height, radius) {

  edgePadding = floor(Cell_Length / 5);
  for (row = [0:1:Rows - 1]) {
    for (col = [0:1:Cols - 1]) {
      for (relX = [1:Min_Dist_Between_Spacers:Cell_Length]) {
        for (relY = [1:Min_Dist_Between_Spacers:Cell_Length]) {
          placeSpacer = (relY <= edgePadding || relY >= Cell_Length - edgePadding) ? true : (relX <= edgePadding - 0.25 || relX >= Cell_Length - edgePadding) ? true : false;
          if (placeSpacer) {
            coordX = (relX - Cell_Length / 2) + radius / 2; // Calculate the absolute X coordinate
            coordY = (relY - Cell_Length / 2) + radius / 2; // Calculate the absolute Y coordinate
            translate([coordX, coordY, height / 2]) {
              // Adjust position to stack spacers
              cylinder(r=radius, h=height, center=true); // Draw the spacer
            }
          }
        }
      }

      translate([0, 0.5, height/2]) {
        // Adjust position to stack spacers
        if (Reinforce_Holes) {
          holeSupport();
        }
      }
    }
  }
}


module holeSupport() {
  // Parameters
  r_outer = Hole_Reinforcer_Radius;
  wall_thickness = Hole_Reinforcer_Border;
  height = Spacer_Height;
  dash_angle = Hole_Reinforcers_Dash_Angle; // Angle of each dash in degrees
  gap_angle = Hole_Reinforcers_Gap_Angle; // Angle between dashes in degrees
  // Derived values
  r_inner = r_outer - wall_thickness;
  angle_step = dash_angle + gap_angle;
  num_dashes = floor(360 / angle_step);

  // Create dashed ring
  for (i = [0:num_dashes - 1]) {
    rotate([0, 0, i * angle_step])
      dashed_segment(r_inner, r_outer, height, dash_angle);
  }

  // Module to draw a wedge segment
  module dashed_segment(r1, r2, h, angle) {
    difference() {
      rotate_extrude(angle=angle)
        translate([r1, 0, 0])
          square([r2 - r1, h], center=true);
    }
  }
}

module threadedHoleSpacer(r = TB_TB_Hole_Radius + 1, h = Spacer_Height, dashes = 40, dash_fraction = 0.5) {

  dash_angle = 360 / dashes;
  path = circle_path(r = r, $fn = dashes * 2);
  for (i = [0: dashes - 1])
    if (i % 2 == 0)
      stroke(subpath(path, i * dash_angle / 360, (i + dash_fraction) * dash_angle / 360),
        width = 0.6);
}








/* 

module tileComponent(level, tilex, tiley) {
  path = str("./parts/1x1 ",height, "mm Thread Board.stl");
  echo(str("path: ", path));
  import(path, center=true);
  if (tiley < rows - 1) {
    translate([0, (cellLength / 2), 0]) cube([cellLength - 0.5, 4, height], center=true);
  }
  if (tilex < cols - 1) {
    translate([(cellLength / 2), 0, 0]) cube([4, cellLength - 0.5, height], center=true);
  }

  layersForSpacers = includeReinforcementsOnTopmostLayer ? layers : layers - 1;
  if (level < layersForSpacers) {
    drawSpacers(height / 2, spacerHeight, spacerRadius); // Draw spacers at the specified height
  }
}

module punchedTileComponent(level, tilex, tiley) {
  difference() {
    tileComponent(level, tilex, tiley);
    translate([0, 0, -1]) {
      punchOut(tilex, tiley);
    }
  }
}

module tilesAndSpacers() {
  for (level = [0:1:layers - 1]) {
    layerZPos = level * (height + spacerHeight) + height / 2; // Calculate the position of each layer
    tilex = 0;
    tiley = 0;
    translate([0, 0, layerZPos]) {
      for (tiley = [0:1:rows - 1]) {
        translate([0, cellLength * tiley, 0]) punchedTileComponent(level, tilex, tiley);
        for (tilex = [0:1:cols - 1]) {
          translate([cellLength * tilex, cellLength * tiley, 0]) punchedTileComponent(level, tilex, tiley);
        }
      }
    }
  }
}

// tilesAndSpacers();


module punchOut(tilex, tiley) {
  cornerStartX = punchOutAffectsBorder ? 0 : (tiley == 0 ? 1 : 0);
  cornerEndX = punchOutAffectsBorder ? 1 : (tiley == rows - 1 ? 0 : 1);
  cornerStartY = punchOutAffectsBorder ? 0 : (tilex == 0 ? 1 : 0);
  cornerEndY = punchOutAffectsBorder ? 1 : (tilex == cols - 1 ? 0 : 1);
  for (cornerY = [cornerStartX:cornerEndX]) {
    for (cornerX = [cornerStartY:cornerEndY]) {
      coordX = (cornerX * cellLength - cellLength / 2); // Calculate the absolute X coordinate
      coordY = (cornerY * cellLength - cellLength / 2); // Calculate the absolute Y coordinate
      translate([coordX, coordY, 0]) {

        if (punchOutStyle == 0) {
          // Square punch out
          rotate(45) {
            cube([punchOutSize, punchOutSize, 3 * height * layers + 10], center=true);
          }
        } else if (punchOutStyle == 1) {
          // Circular punch out
          cylinder(r=punchOutSize / 2, h=3 * height * layers + 10, center=true);
        } else if (punchOutStyle == 2) {
          // Hexagonal punch out
          // rotate(45){
          // polyhedron(6,6,)
          //     po(punchOutSize/2);
          // }
          rotate(20) {
            cylinder(r=punchOutSize/2, h=3 * height * layers + 10, $fn=8, center=true);
          }
        } else {
          cube([punchOutSize, punchOutSize, 3 * height * layers + 10], center=true);
        }
      }
    }
  }
}

 */