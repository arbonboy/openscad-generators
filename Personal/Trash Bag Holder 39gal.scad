include </Users/john.andersen/odrive/GDrive (Personal)/Personal/3D Printing/3D Printing Queue/0001 Generators/lib/ThreadBoards/tb_board_nonthreaded.scad>;

difference(){
    union(){
        import("/Users/john.andersen/Downloads/Trash Bag Holder XL 3D Model.stl");
        color("red") translate([0, -15, 0]) cube([7, 220, 250]);
    }

    translate([-20, -0, 20])
        rotate([90, 0, 90]) 
            difference(){
                tb_ntb_countersinkPeg(rows=10, cols=9, headHeight=30, stemHeight=0);
                translate([10, -50, 0]) cube([50, 280, 70]);
                translate([108, -50, 0]) cube([70, 280, 70]);
            }
}
