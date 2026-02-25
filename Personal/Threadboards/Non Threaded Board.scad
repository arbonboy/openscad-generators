include <lib/tb_board_nonthreaded.scad>;

Rows = 2; //[1:1:30]
Cols = 2; //[1:1:30]
Thickness = 2; //[1:12]
Corner_Rounding = 1; //[0:.1:5]

/* [Hidden] */
Hole_Radius = 8.5;
Cell_Size = 24;

tb_ntb_board(rows=Rows, cols=Cols, thickness=Thickness, roundedCorners = true, cornerRadius = Corner_Rounding, hole_radius=Hole_Radius, cell_size=Cell_Size, center=false);
