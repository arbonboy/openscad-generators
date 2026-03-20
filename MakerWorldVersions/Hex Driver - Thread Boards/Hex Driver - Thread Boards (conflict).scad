include <BOSL2/std.scad>

/* [General Parameters] */
Thread_Board_Hex_Size = "Normal"; //[Normal,Mounting Hole]
Hex_Length = 120; //[20:1:300]
Handle_Type = "tstyle"; //[none:None,arm:Single Arm,tstyle:T-Style]
Handle_Size = 50; //[20:Small,50:Medium,75:Large]


/* [Hidden] */
Metric_Hex_Size = "None"; //[6,8,10,12,14,17,19]
SAE_Hex_Size = "None"; //[1/4'',5/16'',3/8'',7/16'',1/2'',9/16'',5/8'',3/4'',7/8'',1'']


main();



module main(){
    doTB = Thread_Board_Hex_Size == "None" ? 0 : 1;
    doMetric = Metric_Hex_Size == "None" ? 0 : 1;
    doSae = SAE_Hex_Size == "None" ? 0 : 1;
    numSizesSelected = doTB + doMetric + doSae;
    hexLabel = doTB ? Thread_Board_Hex_Size : (doMetric ? Metric_Hex_Size : SAE_Hex_Size);
    hexSize = getHexSizeFromLabel(hexLabel, doTB, doMetric, doSae);
    //echo(getHexSizeFromLabel(hexLabel, doTB, doMetric, doSae)); 

    if(numSizesSelected == 0){
        errorMessage("You must choose one Hex size");
    } else if(numSizesSelected > 1){
        errorMessage("Too many Hex sizes selected.  Choose only one.");
    } else {
        renderHexDriver(hexSize, hexLabel, Handle_Type, Handle_Size);
        
    }
}

module renderHexDriver(hexSize, hexLabel, handleType, handleSize){
    // Placeholder for the actual hex driver rendering logic
    // This is where you would implement the geometry of the hex driver based on the selected parameters
    echo(str("Rendering Hex Driver with Hex Size: ", hexSize, ", Hex Label: ", hexLabel, ", Handle Type: ", handleType, ", Handle Size: ", handleSize));
    
    difference(){
        union(){
            // Example: Render a simple hexagonal prism for demonstration
            rotate([90, 0, 0]){
                X = hexSize;          // opposite vertices
                r = X/2;         // hex circumradius
                straight1 = Hex_Length;  // before bend
                bend_r = 20;     // centerline bend radius
                straight2 = handleSize;  // after bend
                steps = 64;

                profile = zrot(60, p=hexagon(r=r));
                // profile = zrot(60, p=circle(r=r));

                difference(){
                    union(){
                        // driver
                        translate([0,0,0]){
                            linear_extrude(height=straight1){
                                polygon(profile);
                            }
                        }   

                        if(handleType != "none"){
                            // curved section
                            translate([bend_r,-straight1,straight1]){
                                rotate([90, 0, 180]){
                                    translate([0,0,straight1]){
                                        profile = zrot(60, p=hexagon(r=r));
                                        path_sweep(
                                            profile,
                                            path3d(arc(r=bend_r, angle=[0,90], $fn=steps))
                                        );
                                    }
                                }
                            }
                            
                            // handle
                            translate([bend_r,0,straight1+bend_r]){
                                rotate([0,90,0]){
                                    linear_extrude(height=straight2){
                                        polygon(profile);
                                    }
                                }
                            }
                            
                        }

                        if(handleType == "tstyle"){
                            rotate([0, 0, 180]){
                                profile = zrot(60, p=hexagon(r=r));
                                // profile = zrot(60, p=circle(r=r)); 

                                // curved section
                                translate([bend_r,-straight1,straight1]){
                                    rotate([90, 0, 180]){
                                        translate([0,0,straight1]){
                                            profile = zrot(60, p=hexagon(r=r));
                                            path_sweep(
                                                profile,
                                                path3d(arc(r=bend_r, angle=[0,90], $fn=steps))
                                            );
                                        }
                                    }
                                }

                                // handle
                                translate([-bend_r,0,straight1+bend_r]){
                                    rotate([0,90,0]){
                                        linear_extrude(height=straight2){
                                            polygon(profile);
                                        }
                                        translate([0,0,-straight2]){
                                            cylinder(h=straight2*2+bend_r*2, r=hexSize/2, $fn=6, center=false);
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                    translate([0, hexSize/2-bend_r, Hex_Length/2]){ // Position the label above the driver
                        rotate([90, 90, 180]){
                            linear_extrude(height=202){
                                text(hexLabel, size=hexSize/4, halign="center", valign="center");
                            }
                        } 
                    }
                }
                
                
            }   
        }
        
    }
    
    translate([0, hexSize/2, Hex_Length/2]){ // Position the label above the driver
        rotate([90, 90, 180]){
            // linear_extrude(height=202){
                color("purple") text(hexLabel, size=hexSize/4, halign="center", valign="center");
            // }
        } 
    }
    
    
}


function getHexSizeFromLabel(hexSizeLabel, doTB, doMetric, doSae) = 
    doTB ? (
        hexSizeLabel == "Normal" ? 15.8 :
        hexSizeLabel == "Mounting Hole" ? 8.9 :
        undef
    ) : (
        doMetric ? (
            hexSizeLabel == "6" ? 6.8 :
            hexSizeLabel == "8" ? 9 :
            hexSizeLabel == "10" ? 11.4 :
            hexSizeLabel == "12" ? 13.7 :
            hexSizeLabel == "14" ? 15.93 :
            hexSizeLabel == "17" ? 19.7 :
            hexSizeLabel == "19" ? 21.8 :
            undef
        ) : (
            doSae ? (
                hexSizeLabel == "1/4''" ? 0.28 :
                hexSizeLabel == "5/16''" ? 0.35 :
                hexSizeLabel == "3/8''" ? 0.42 :
                hexSizeLabel == "7/16''" ? 0.49 :
                hexSizeLabel == "1/2''" ? 0.55 :
                hexSizeLabel == "9/16''" ? 0.63 :
                hexSizeLabel == "5/8''" ? 0.70 :
                hexSizeLabel == "3/4''" ? 0.85 :
                hexSizeLabel == "7/8''" ? 0.99 :
                hexSizeLabel == "1''" ? 1.13 :
                undef
            ) : undef
        )
    );


module errorMessage(text){
    % rotate([0, 0, 90]) color("red") text(text, size=5, halign="center");
}