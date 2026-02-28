include <lib/tb_board_threaded.scad>;

Rows = 2; //[1:1:16]
Cols = 2; //[1:1:16]
Thickness = 6; //[1:0.5:10]
Number_of_Boards = 3; //[1:1:10]
Space_Between_Boards_MM = 0.3; //[0:0.01:1]
tb_tb_board_vX_stacked(rows=Rows, cols=Cols, thickness=Thickness,spaceMM=Space_Between_Boards_MM, boards=Number_of_Boards);