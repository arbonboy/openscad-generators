include <../lib/tb_board_nonthreaded.scad>



import("/Users/john.andersen/Downloads/Safety Glasses Holder T-Nut v2.stl");

translate([0, 26, 81])
    rotate([90, 0, 0])
        tb_ntb_board(rows=1, cols=4, center=true, thickness=4, roundedCorners=true, cornerRadius=2);