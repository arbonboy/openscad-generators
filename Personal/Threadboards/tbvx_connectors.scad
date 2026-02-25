include <lib/tb_board_threaded.scad>


Cols = 3;
Rows = 3;
Corners_Only = true;
Snap_Thickness = 6;
Connector_Thickness = 2;

/* [Hidden] */
Scale_Factor = 0.94; //.97 works but is tight


rotate([180,0,0]){
    for(x=[0:Cols-1]){
        for(y=[0:Rows-1]){
            if(Corners_Only){
                if( (x==0 && y==0) || (x==0 && y==Rows-1) || (x==Cols-1 && y==0) || (x==Cols-1 && y==Rows-1) ){
                    translate([x*(TB_TB_Cell_Size), y*(TB_TB_Cell_Size), 0])
                        tb_tb_cell_snapbase_vX(center=true, scale=Scale_Factor, thickness=Snap_Thickness);
                    translate([x*(TB_TB_Cell_Size), y*(TB_TB_Cell_Size), DEFAULT_TB_TB_Thickness/2+Connector_Thickness])
                        tb_tb_cell_snapbase_vX(center=true, scale=Scale_Factor, noSnap=true, thickness=Connector_Thickness);
                }
            } else {
                if(x==0 || y==0 || x==Cols-1 || y==Rows-1){
                    translate([x*(TB_TB_Cell_Size), y*(TB_TB_Cell_Size), 0])
                        tb_tb_cell_snapbase_vX(center=true, scale=Scale_Factor, thickness=Snap_Thickness);
                    translate([x*(TB_TB_Cell_Size), y*(TB_TB_Cell_Size), DEFAULT_TB_TB_Thickness/2+Connector_Thickness])
                            tb_tb_cell_snapbase_vX(center=true, scale=Scale_Factor, noSnap=true, thickness=Connector_Thickness);
                }
            }
        }
    }


    braceLengthX = Cols > 1 ? (Cols-1)*TB_TB_Cell_Size : TB_TB_VX_Brace_Width*2;
    braceLengthY = Rows > 1 ? (Rows-1)*TB_TB_Cell_Size : TB_TB_VX_Brace_Width*2;

    scale([Scale_Factor, Scale_Factor, 1]){
        translate([(Cols-1)*TB_TB_Cell_Size/2+0.7, (Rows-1)*TB_TB_Cell_Size/2+TB_TB_VX_Brace_Width/2-0.4, DEFAULT_TB_TB_Thickness/2+Connector_Thickness ]){
            if(Cols > 1 && Rows <= 1)
                color("blue") cuboid([braceLengthX+TB_TB_VX_Brace_Width*2, TB_TB_VX_Brace_Width*2-.8, Connector_Thickness]);
            if(Rows > 1 && Cols <= 1)
                color("green") cuboid([TB_TB_VX_Brace_Width*2-0.8, braceLengthY+TB_TB_VX_Brace_Width*2, Connector_Thickness]);
            if(Cols > 1 && Rows > 1){
                difference(){
                color("blue") cuboid([braceLengthX+TB_TB_VX_Brace_Width*2, braceLengthY+TB_TB_VX_Brace_Width*2, Connector_Thickness]);
                translate([0, 0, -0.1])
                    color("red") cuboid([braceLengthX-TB_TB_VX_Brace_Width, braceLengthY-TB_TB_VX_Brace_Width, Connector_Thickness*2]);
                }
            }
        }
    }
}
