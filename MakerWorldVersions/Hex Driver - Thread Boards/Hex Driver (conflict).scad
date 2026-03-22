include <BOSL2/std.scad>

/* [General Parameters] */
ThreadBoard_Hex_Size = 0; //[0:None,15.8:Normal,8.8:Mounting Hole]
Metric_Hex_Size = "none"; //[none:None,6.7:6,9:8,11.3:10,13.5:12,15.88:14,19.2:17,21.5:19]
SAE_Hex_Size = "none"; //[none:None,0.0.28:1/4,0.0.35:5/16,0.42:3/8,0.49:7/16,0.55:1/2,0.63:9/16,0.70:5/8,0.85:3/4,0.99:7/8,1.13:1]

Hex_Length = 40; //[20:1:200]
Handle_Type = "tstyle"; //[none:None,arm:Single Arm,tstyle:T-Style]
Handle_Size = 50; //[20:Small,50:Medium,75:Large]


/* [Hidden Parameters] */



main();



module main(){
    doTB = ThreadBoard_Hex_Size == 0 ? 0 : 1;
    doMetric = Metric_Hex_Size == "none" ? 0 : 1;
    doSae = SAE_Hex_Size == "none" ? 0 : 1;
    numSizesSelected = doTB + doMetric + doSae;

    if(numSizesSelected == 0){
        errorMessage("You must choose one Hex size");
    } else if(numSizesSelected > 1){
        errorMessage("Too many Hex sizes selected.  Choose only one.");
    } else {
        hexSize = doTB ? ThreadBoard_Hex_Size : (doMetric ? Metric_Hex_Size : SAE_Hex_Size);
        

        // Render the Hex Driver
        renderHexDriver(hexSize, Handle_Type, Handle_Size);
    }
}

module renderHexDriver(hexSize, handleType, handleSize){
    // Placeholder for the actual hex driver rendering logic
    // This is where you would implement the geometry of the hex driver based on the selected parameters
    echo(str("Rendering Hex Driver with Hex Size: ", hexSize, ", Handle Type: ", handleType, ", Handle Size: ", handleSize));
    
    // Example: Render a simple hexagonal prism for demonstration
    rotate([0, 0, 0]){
        X = hexSize;          // opposite vertices
        r = X/2;         // hex circumradius
        straight1 = Hex_Length;  // before bend
        bend_r = 20;     // centerline bend radius
        straight2 = handleSize;  // after bend
        steps = 64;

        profile = zrot(60, p=hexagon(r=r));

        // straight section before bend
        translate([0,0,-straight1/2]){
            color("blue") linear_extrude(height=straight1){
                polygon(profile);
            }
        }   
        up(straight1/2)
        color("red") linear_extrude(height=straight1)
        polygon(profile);

        // curved section
        translate([straight2/2-r/2,-straight1,straight1+straight2]){
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
        
        // straight section after bend
        translate([bend_r,0,straight1+straight2+bend_r]){
            rotate([0,90,0]){
                linear_extrude(height=straight2){
                    polygon(profile);
                }
            }
        }
        
        
        // union(){
        //     cylinder(h=Hex_Length, r=hexSize/2, $fn=6, center=true);
        //     translate([0, 0, Hex_Length/2+hexSize/2]){
        //         if(Handle_Type == "arm"){
        //             // Render a single arm handle
        //             translate([handleSize/2-hexSize/2, 0, 0]) cube([handleSize, hexSize, hexSize], center=true);
        //         } else if(Handle_Type == "tstyle"){
        //             // Render a T-style handle
        //             translate([-handleSize/2, hexSize, 0]) cube([handleSize, hexSize, hexSize], center=true);
        //             translate([handleSize/2, hexSize, 0]) cube([handleSize, hexSize, hexSize], center=true);
        //         }
        //     }
            
        // }
        
    } 

}



module errorMessage(text){
    % rotate([0, 0, 90]) color("red") text(text, size=5, halign="center");
}