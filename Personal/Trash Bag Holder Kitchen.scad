include </Users/john.andersen/odrive/GDrive (Personal)/Personal/3D Printing/3D Printing Queue/0001 Generators/lib/ThreadBoards/tb_board_nonthreaded.scad>;


difference(){
    union(){
        //import("/Users/john.andersen/Downloads/Trash Bag Holder XL 3D Model.stl");
        translate([0, 18, 0])
            import("/Users/john.andersen/Downloads/Kitchen Trash Bag Holder.stl");
        color("red") translate([0, -15, 0]) cube([5, 198, 225]);
    }

    translate([-20, -0, 20])
        rotate([90, 0, 90]) 
            difference(){
                tb_ntb_countersinkPeg(rows=10, cols=9, headHeight=30, stemHeight=0, headRadius=11);
                translate([10, -50, 0]) cube([120, 280, 70]);
                translate([108, -50, 0]) cube([50, 280, 70]);
            }
}
