
include <lib/ts_board_threaded.scad>;
include <BOSL2/std.scad>

/* [Board Settings] */
// Cutout Border leaves half-slots/holes open along the edges; Solid Border keeps all holes and adds a tiling border so the perimeter is solid and multiple boards tile with standard hole spacing.
Board_Frame_Type = "solid";    // [cutout:Cutout Border, solid:Solid Border]
// Horizontal.
Number_Of_Columns = 2;
// Vertical - Ideally an odd number.
Number_Of_Rows = 3;       
// (mm)
Board_Corner_Radius = 2;  

//Standard Skadis Boards are 5mm thick
Board_Thickness = 5; //[0.5:0.1:10]
TB_Hole_Type = "threaded";    // [threaded:Threaded, nonthreaded:Non-threaded, none:None]
Skadis_Elements = "hole"; //[none:None, hole:Hole, peg:Peg, tb:Threaded TB hole, ntb:Non-threaded TB hole]

/* [Lite Frame Settings] */
// Remove material between holes to save filament, keeping only a connected border frame around each hole.
Enable_Lite_Frame = false;
// Ultra Lite keeps only horizontal and vertical connectors; Lite also adds diagonal connectors for extra rigidity.
Lite_Frame_Type = "ultralite";    // [ultralite:Ultra Lite, lite:Lite]
// (mm) Width of the border kept around each hole and of the struts that connect the holes together.
Minimum_Lite_Frame_Border_Width = 1.5;    // [0.5:0.5:15]

/* [multiple boards] */
Number_of_Boards = 3;    // [1:1:10]
Spacer_Thickness = 0.28;    // [0.08:0.01:1] Thickness of the spacer between boards when multiple boards are stacked together.
Board_Spacer_Type = "multimaterial";    // [multimaterial:Multimaterial, gap:Gap]

/* [Hidden] */
frame_type = Enable_Lite_Frame ? Lite_Frame_Type : "none";


for(board_index = [0:Number_of_Boards-1]){
    translate([0, 0, board_index * (Spacer_Thickness + DEFAULT_TS_Board_Thickness)]){
        color("white"){
            ts_board_threaded_board(
                rows = Number_Of_Rows, 
                cols = Number_Of_Columns,
                thickness = Board_Thickness,
                tb_hole_type = TB_Hole_Type,
                skadis_elements = Skadis_Elements,
                tolerance=0.1, 
                rounding=Board_Corner_Radius,
                board_border_type=Board_Frame_Type,
                frame_type=frame_type,
                minimum_lite_frame_border_width=Minimum_Lite_Frame_Border_Width
            );
        }
        if(Board_Spacer_Type == "multimaterial"){
            if(board_index < Number_of_Boards-1){
                translate([0, 0, Spacer_Thickness/2 + DEFAULT_TS_Board_Thickness]){
                    color("black"){
                        intersection(){
                            translate([0, 0, 0]){
                                cuboid([3*Number_Of_Columns * TS_Board_Cell_Size_X, 3*Number_Of_Rows * TS_Board_Cell_Size_Y, Spacer_Thickness], rounding=Board_Corner_Radius, edges="Z");
                            }
                            translate([0, 0, -Spacer_Thickness*2]){
                                ts_board_threaded_board(
                                    rows = Number_Of_Rows, 
                                    cols = Number_Of_Columns,
                                    skadis_elements = Skadis_Elements,
                                    tolerance=0.1, 
                                    rounding=Board_Corner_Radius,
                                    board_border_type=Board_Frame_Type,
                                    frame_type=frame_type,
                                    minimum_lite_frame_border_width=Minimum_Lite_Frame_Border_Width
                                );
                            }
                        }
                        
                    }
                }
            
            }
        }
    }
    
}
