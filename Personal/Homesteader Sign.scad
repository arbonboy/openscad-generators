include <BOSL2/std.scad> 
include <lib/qr.scad> 
include <Threadboards/lib/tb_board_nonthreaded.scad>

// echo("QR Code Generator Library loaded successfully!");
/* [Sign Parameters] */
Sign_Width = 110; //[50:1:300]
Sign_Height = 225; //[50:1:300]
Sign_Thickness = 5; //[1:1:10]
Sign_Rounding = 5; //[0:1:50]
Border_Width = 10; //[0:1:50]
Border_Depth = 0.8; //[0:0.1:10]
Border_Extrusion = 0; //[0:0.1:10]
Border_Margin = 1; //[0:1:50]

/* [Header TextParameters] */
Header_Font_Size = 7; //[1:1:50]
Header_Font_Family = "Arial"; //["American Typewriter", "Andale Mono", "Arial", "Avenir", "Avenir Next Condensed", "Baskerville", "Copperplate", "Geneva", "Georgia", "Liberation Mono", "Menlo", "Times New Roman", "Courier New", "Comic Sans MS"]
Header_Font_Style = "Bold";
Header_Depth = 0.8; //[0:0.1:10]
Header_Extrusion = 0; //[0:1:10]
Header_Text_Line_1 = "Arbon Valley";
Header_Text_Line_2 = "Homestead";
Header_Text_Line_3 = "Marker";
Header_Y_Offset = 15; //[-500:1:500]

/* [Title Text Parameters] */
Title_Font_Size = 10; //[1:1:50]
Title_Font_Family = "American Typewriter"; //["American Typewriter", "Andale Mono", "Arial", "Avenir", "Avenir Next Condensed", "Baskerville", "Copperplate", "Geneva", "Georgia", "Liberation Mono", "Menlo", "Times New Roman", "Courier New", "Comic Sans MS"]
Title_Font_Style = "Bold";
Title_Depth = 0.8;//[0:1:10]
Title_Extrusion = 0; //[0:0.1:10]
Title_Text_Line_1 = "JOHN";
Title_Text_Line_2 = "CHRISTIAN";
Title_Text_Line_3 = "ANDERSEN";
Title_Y_Offset = 70; //[-500:1:500]

/* [QR Code Parameters] */
QR_Message = "https://www.homesteader.com";
QR_Error_Correction = "M"; //[L, M, Q, H]
QR_Size = 60; //[10:1:200]
QR_Thickness = 0.8; //[0:0.1:10]
QR_Extrusion = 0; //[0:0.1:10]
QR_Center = true;
QR_Y_Offset = 137; //[-500:1:500]

/* [Instruction Text Parameters] */
Instruction_Font_Size = 7; //[1:1:50]
Instruction_Font_Family = "Copperplate"; //["American Typewriter", "Andale Mono", "Arial", "Avenir", "Avenir Next Condensed", "Baskerville", "Copperplate", "Geneva", "Georgia", "Liberation Mono", "Menlo", "Times New Roman", "Courier New", "Comic Sans MS"]
Instruction_Font_Style = "Bold";
Instruction_Depth = 0.8;//[0:0.1:10]
Instruction_Extrusion = 0; //[0:0.1:10]
Instruction_Text_Line_1 = "Scan the QR code";
Instruction_Text_Line_2 = "for more";
Instruction_Text_Line_3 = "information";
Instruction_Text_Line_4 = "";
Instruction_Y_Offset = 198; //[-500:1:500]

/* [TB Hole Parameters] */
TB_Hole_1 = true; //true or false
TB_Hole_1_Y_Offset = 66; //[-500:1:500]
TB_Hole_2 = true; //true or false
TB_Hole_2_Y_Offset = -68; //[-500:1:500]


main();

module main(){
    difference(){
        sign();
        color("white"){
            union(){
                if(TB_Hole_1){
                    tb_hole(y_offset=TB_Hole_1_Y_Offset);
                }
                if(TB_Hole_2){
                    tb_hole(y_offset=TB_Hole_2_Y_Offset);
                }
            }
        }
        // if(TB_Hole_1){
        //     tb_hole(y_offset=TB_Hole_1_Y_Offset);
        // }
        // if(TB_Hole_2){
        //     tb_hole(y_offset=TB_Hole_2_Y_Offset);
        // }
    }
    
}

module sign(){
    color("white") cuboid([Sign_Width, Sign_Height, Sign_Thickness], rounding=Sign_Rounding, except=[TOP, BOTTOM]);
    translate([0, 0, Sign_Thickness/2-(Border_Depth-Border_Extrusion)/2]){
        color("black") border(width=Sign_Width, height=Sign_Height, thickness=Border_Depth, line_width=Border_Width, margin=Border_Margin, rounding=Sign_Rounding);
    }
    headerY = Sign_Height/2 - Header_Y_Offset;
    translate([0, headerY, Sign_Thickness/2-(Header_Depth-Header_Extrusion)]){
        color("black") header(headerText=[Header_Text_Line_1, Header_Text_Line_2, Header_Text_Line_3], headerFontSize=Header_Font_Size, headerFontFamily=Header_Font_Family, headerFontStyle=Header_Font_Style, headerDepth=Header_Depth);
    }   
    titleY = Sign_Height/2 - Title_Y_Offset;
    translate([0, titleY, Sign_Thickness/2-(Title_Depth-Title_Extrusion)]){
        color("black") title(titleText=[Title_Text_Line_1, Title_Text_Line_2, Title_Text_Line_3], titleFontSize=Title_Font_Size, titleFontFamily=Title_Font_Family, titleFontStyle=Title_Font_Style, titleDepth=Title_Depth);
    }
    qrY = Sign_Height/2 - QR_Y_Offset;
    translate([0, qrY, Sign_Thickness/2-(QR_Thickness-QR_Extrusion)]){
         color("black") qr(QR_Message, error_correction=QR_Error_Correction, width=QR_Size, height=QR_Size, thickness=QR_Thickness, center=QR_Center);
    }
    instructionY = Sign_Height/2 - Instruction_Y_Offset;
    translate([0, instructionY, Sign_Thickness/2-(Instruction_Depth-Instruction_Extrusion)]){
        color("black") instruction();
    }
    
    
}


module border(width=Sign_Width, height=Sign_Height, thickness=Border_Depth, line_width=Border_Width, margin=1, rounding=Sign_Rounding){
    difference(){
        cuboid([width-margin*2, height-margin*2, thickness], rounding=rounding, except=[TOP, BOTTOM]);
        cuboid([width-margin*2-line_width, height-margin*2-line_width, thickness*2], rounding=rounding, except=[TOP, BOTTOM]);
    }
}

module header(
    headerFontSize=Header_Font_Size,
    headerFontFamily=Header_Font_Family,
    headerFontStyle=Header_Font_Style,
    headerDepth=Header_Depth,
    headerText=[Header_Text_Line_1, Header_Text_Line_2, Header_Text_Line_3]
){
    lineSpacing = 2;
    lines = headerText;
    
    linear_extrude(height=headerDepth){
        for(i = [0:len(lines)-1]){
            translate([0, -i*(headerFontSize+lineSpacing), 0]){
                    text(lines[i], size=headerFontSize, font=str(headerFontFamily,":",headerFontStyle), halign="center");
            }
        }
    }
}


module title(
    titleFontSize=Title_Font_Size,
    titleFontFamily=Title_Font_Family,
    titleFontStyle=Title_Font_Style,
    titleDepth=Title_Depth,
    titleText=[Title_Text_Line_1, Title_Text_Line_2, Title_Text_Line_3]
){
    lineSpacing = 2;
    lines = titleText;
    
    linear_extrude(height=titleDepth){
        for(i = [0:len(lines)-1]){
            translate([0, -i*(titleFontSize+lineSpacing), 0]){
                    text(lines[i], size=titleFontSize, font=str(titleFontFamily,":",titleFontStyle), halign="center");
            }
        }
    }
}   


module instruction(
    instructionFontSize=Instruction_Font_Size,
    instructionFontFamily=Instruction_Font_Family,
    instructionFontStyle=Instruction_Font_Style,
    instructionDepth=Instruction_Depth,
    instructionText=[Instruction_Text_Line_1, Instruction_Text_Line_2, Instruction_Text_Line_3, Instruction_Text_Line_4]
){
    lineSpacing = 2;
    lines = instructionText;
    
    linear_extrude(height=instructionDepth){
        for(i = [0:len(lines)-1]){
            translate([0, -i*(instructionFontSize+lineSpacing), 0]){
                    text(lines[i], size=instructionFontSize, font=str(instructionFontFamily,":",instructionFontStyle), halign="center");
            }
        }
    }
}

module tb_hole(y_offset=0){
    translate([0, y_offset, -Sign_Thickness]){
        tb_ntb_countersinkPeg(rows=1, cols=1, stemHeight=Sign_Thickness*4);
    }
}   