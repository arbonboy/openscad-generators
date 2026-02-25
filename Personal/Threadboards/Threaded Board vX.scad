include <lib/tb_board_threaded.scad>;

Rows = 2;
Cols = 2;
Thickness = 6;
Number_of_Boards = 3;
Space_Between_Boards_MM = 0.3;
tb_tb_board_vX_stacked(rows=Rows, cols=Cols, thickness=Thickness,spaceMM=Space_Between_Boards_MM, boards=Number_of_Boards);