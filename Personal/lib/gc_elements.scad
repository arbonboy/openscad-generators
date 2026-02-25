
// ------------------------------------------------------------
// Circular Lid with Internal Thread (BOSL2 v2.x)
// Requires BOSL2:
//   https://github.com/revarbat/BOSL2
// ------------------------------------------------------------
include <BOSL2/std.scad>;
include <BOSL2/threading.scad>;

// difference(){
//     gc_container_external_thread(height= 50, wall_t=2, solid=true); 
//     translate([55,0,0])
//         cube([100, 100, 200], center=true);
// }



module gc_container_external_thread(
    inner_d     = 20,    // inner diameter of container (mm)
    wall_t      = 2,     // wall thickness (mm)
    height      = 45,    // height of container (mm)
    bottom_angle = 35,    // angle of conical bottom (degrees)
    solid = false, // if true, the container will be solid with no threads, but will require a lid clearance diameter so that this can be used to be subtracted from a solid block
    lid_clearance_d = 0, // if solid=true, this is the diameter of the clearance hole in the lid to allow the container to fit inside; if negative, then we will make it twice the diameter of the container
    lid_clearance_h = 0, // if solid=true, this is the height of the lid clearance portion; if negative, we will use the thread height

    //thread portion
    thread_tol  = 0.12,  // radial oversize for additive printer (mm)
    thread_h    = 12,    // height of threaded portion (mm)
    pitch       = 2.0,   // mm per revolution
    starts      = 1,
    left_handed = false,
    entry_chamfer_h = 0.6,   // set 0 for none - Small entry chamfer to help engagement

    // Visual smoothness
    $fn = 128
){
    outer_d = inner_d + 2*wall_t;
    nonThreadedHeight = solid ? height : height - thread_h;
    lid_clearance = lid_clearance_d < 0 ? 2*outer_d : lid_clearance_d;
    if(solid){
        assert(lid_clearance > outer_d, "lid_clearance_d must be larger than container outer diameter");
    }
    lid_clearance_height = lid_clearance_h < 0 ? thread_h : lid_clearance_h;
    if(solid){
        assert(lid_clearance_height > 0, "lid_clearance_h must be positive");
    }

    union(){
        gc_container_not_threaded(
            outer_d     = outer_d,
            wall_t      = wall_t,
            height      = nonThreadedHeight,
            bottom_angle = bottom_angle,
            solid = solid,
            $fn = $fn
        );
        if(!solid){
            difference(){
                translate([0,0,height-thread_h/2]){
                    threaded_rod(
                        d=outer_d,
                        l=thread_h,
                        pitch=pitch,
                        starts=starts,
                        left_handed=left_handed,
                    );
                }
                translate([0,0,height-thread_h]){
                    cylinder(d=outer_d - 2*wall_t, h=thread_h + 0.02, $fn=$fn);
                }
            }
        } else {
            // lid clearance block
            translate([0,0,height-thread_h])
                cylinder(d=lid_clearance, h=lid_clearance_height + 0.02, $fn=$fn);
        }
    }
}

module gc_container_internal_thread(
    thread_d = 16,     // nominal internal thread major diameter (mm)
    wall_t      = 2,     // wall thickness (mm)
    height      = 45,    // height of container (mm)
    bottom_angle = 35,    // angle of conical bottom (degrees)
    solid = false, // if true, the container will be solid with no threads, but will require a lid clearance diameter so that this can be used to be subtracted from a solid block
    lid_clearance_d = 0, // if solid=true, this is the diameter of the clearance hole in the lid to allow the container to fit inside; if negative, then we will make it twice the diameter of the container
    lid_clearance_h = 0, // if solid=true, this is the height of the lid clearance portion; if negative, we will use the thread height

    //thread portion
    thread_tol  = 0.6,  // radial oversize for additive printer (mm)
    thread_h    = 12,    // height of threaded portion (mm)
    pitch       = 2.0,   // mm per revolution
    starts      = 1,
    left_handed = false,

    // Visual smoothness
    $fn = 128
){
    inner_d = thread_d-2*thread_tol-2*wall_t;
    outer_d = thread_d + 2*thread_tol + 2*wall_t;
    nonThreadedHeight = solid ? height : height - thread_h;
    lid_clearance = lid_clearance_d < 0 ? 2*outer_d : lid_clearance_d;
    if(solid){
        assert(lid_clearance > outer_d, "lid_clearance_d must be larger than container outer diameter");
    }
    lid_clearance_height = lid_clearance_h < 0 ? thread_h : lid_clearance_h;
    if(solid){
        assert(lid_clearance_height > 0, "lid_clearance_h must be positive");
    }

    union(){
        gc_container_not_threaded(
            outer_d     = outer_d,
            wall_t      = wall_t,
            height      = nonThreadedHeight,
            bottom_angle = bottom_angle,
            solid = solid,
            $fn = $fn
        );
        if(!solid){
            difference(){
                translate([0,0,height-thread_h-0.02]){
                    cylinder(d=outer_d, h=thread_h, $fn=$fn);
                }
                translate([0,0,height-thread_h/2]){
                    threaded_rod(
                        d=thread_d+2*thread_tol,
                        l=thread_h+pitch,
                        pitch=pitch,
                        starts=starts,
                        internal=true,
                        bevel=true,
                        left_handed=left_handed,
                    );
                }
                
            }
        } else {
            // lid clearance block
            translate([0,0,height])
                cylinder(d=lid_clearance, h=lid_clearance_height + 0.02, $fn=$fn);
        }
    }
}

module gc_container_not_threaded(
    outer_d     = 20,    // inner diameter of container (mm)
    wall_t      = 2,     // wall thickness (mm)
    height      = 15,    // height of container (mm)
    bottom_angle = 35,    // angle of conical bottom (degrees)
    solid = false,

    // Visual smoothness
    $fn = 128
){
    inner_d = outer_d - 2*wall_t;
    inner_r = inner_d / 2;
    outer_r = outer_d / 2;

    cone_h = tan(bottom_angle)*outer_r;
    cyl_h = height - cone_h;
    

    // Guardrails (simple sanity checks)
    assert(inner_d > 0,            "wall_t too large: inner diameter <= 0");
    assert(height > 0,             str("height must be positive but was ", height));

    // ---- Solid container body: outer cylinder with open top ----
    // Z=0 at the open end; +Z goes toward the bottom.
    translate([0,0,cone_h])
        union(){
            difference() {
                cylinder(d=outer_d, h=cyl_h, $fn=$fn);
                if(!solid){
                    translate([0,0,0])
                        cylinder(d=inner_d, h=cyl_h + 0.02, $fn=$fn);
                }
            }
            translate([0,0,-cone_h+0.02])
                difference() {
                    cylinder(r2=outer_r, r1=0.1, h=cone_h, $fn=$fn);
                    if(!solid){
                        innerCyl_r = inner_r + tan(bottom_angle)/wall_t;
                        translate([0,0,wall_t])
                            cylinder(r2=innerCyl_r, r1=0.1, h=cone_h-wall_t, $fn=$fn);
                    }
                }
        }
    
}


module gc_circular_lid_external_thread(
    outer_d     = 20,    // outer radius of lid (mm)
    thread_d    = 16,     // nominal internal thread major radius (mm)
    thread_h    = 6,    // height of threaded portion (mm)
    nonthread_h = 1,     // additional smooth interior height above threads (mm)
    top_t       = 10,     // top wall thickness (mm)

    // Thread geometry (ISO-like defaults)
    pitch       = 2.0,   // mm per revolution
    starts      = 1,
    left_handed = false,

    finger_grip = false, // if true, adds a simple finger grip to the lid
    finger_grip_r = 5, // radius of finger grip (mm)

    // Visual smoothness
    $fn = 128
){
    total_h   = thread_h + nonthread_h + top_t;            // overall outer height
    thread_r    = thread_d / 2;
    outer_r = outer_d/2;
    
    // Guardrails (simple sanity checks)
    assert(outer_d > thread_d+pitch,      "outer_d is not big enough, it needs to be at least thread_d+pitch");

    basePosZ = 0;
    nonthreadPosZ = top_t+basePosZ;
    threadPosZ = nonthreadPosZ + nonthread_h + thread_h/2;
    translate([0,0,0]){
        union() {
            translate([0,0,basePosZ])
                difference(){
                    cylinder(d=outer_d, h=top_t, $fn=$fn);
                    if(finger_grip){
                        translate([-outer_r+finger_grip_r*3/2,0,0])
                            color("red") sphere(d=finger_grip_r*2);
                        translate([outer_r-finger_grip_r*3/2,0,0])
                            color("red") sphere(d=finger_grip_r*2);
                    }
                }
            translate([0,0,nonthreadPosZ])
                cylinder(d=thread_d, h=nonthread_h, $fn=$fn);
            translate([0,0,threadPosZ])
                threaded_rod(
                        d=thread_d,
                        l=thread_h,
                        pitch=pitch,
                        starts=starts,
                        left_handed=left_handed
                    );
        }
    }
    
}


module gc_circular_lid_external_thread_OLD(
    outer_d     = 20,    // outer radius of lid (mm)
    thread_d    = 16,     // nominal internal thread major radius (mm)
    thread_h    = 6,    // height of threaded portion (mm)
    nonthread_h = 1,     // additional smooth interior height above threads (mm)
    top_t       = 10,     // top wall thickness (mm)

    // Thread geometry (ISO-like defaults)
    pitch       = 2.0,   // mm per revolution
    starts      = 1,
    left_handed = false,

    // Small entry chamfer to help engagement
    entry_chamfer_h = 0.6,   // set 0 for none

    // Visual smoothness
    $fn = 128
){
    total_h   = thread_h + nonthread_h + top_t;            // overall outer height
    thread_r    = thread_d / 2;
    outer_r = outer_d;
    
    // Guardrails (simple sanity checks)
    assert(outer_d > thread_d+pitch,      "outer_d is not big enough, it needs to be at least thread_d+pitch");

    basePosZ = 0;
    nonthreadPosZ = top_t+basePosZ;
    threadPosZ = nonthreadPosZ + nonthread_h + thread_h/2;
    translate([0,0,0]){
        union() {
            translate([0,0,basePosZ])
                cylinder(d=outer_d, h=top_t, $fn=$fn);
            translate([0,0,nonthreadPosZ])
                cylinder(d=thread_d, h=nonthread_h, $fn=$fn);
            translate([0,0,threadPosZ])
                threaded_rod(
                        d=thread_d,
                        l=thread_h,
                        pitch=pitch,
                        starts=starts,
                        left_handed=left_handed
                    );
        }
    }
    
}

module gc_circular_lid_internal_thread(
    outer_d     = 20,    // outer radius of lid (mm)
    thread_d    = 16,     // nominal internal thread major radius (mm)
    thread_tol  = 0.2,  // radial oversize for subtractive cutter (mm)
    thread_h    = 12,    // height of threaded portion (mm)
    nonthread_h = 3,     // additional smooth interior height above threads (mm)
    top_t       = 3,     // top wall thickness (mm)

    // Thread geometry (ISO-like defaults)
    pitch       = 2.0,   // mm per revolution
    starts      = 1,
    left_handed = false,

    // Small entry chamfer to help engagement
    entry_chamfer_h = 0.6,   // set 0 for none

    // Visual smoothness
    $fn = 128
){
    thread_r = thread_d/2;
    outer_r = outer_d/2;
    total_h   = thread_h + nonthread_h + top_t;            // overall outer height
    hole_r    = thread_r + thread_tol;                      // subtractive cutter radius
    inner_r   = hole_r-pitch;                       // nominal inner radius (skirt ID)
    hole_d    = 2*hole_r;                                   // subtractive cutter diameter
    body_d    = 2*outer_r;
    inner_d   = 2*inner_r;
    
    // Guardrails (simple sanity checks)
    assert(inner_r > 0,            "pitch too large: inner radius <= 0");
    assert(hole_r > inner_r,      "thread_r + thread_tol exceeds inner radius (reduce thread_r or increase outer_r/sidewall_t)");
    assert(thread_h > 0 && total_h > 0, "heights must be positive");

    difference() {
        // ---- Solid lid body: outer cylinder with solid top ----
        // Z=0 at the open end; +Z goes toward the top wall.
        cylinder(d=body_d, h=total_h, $fn=$fn);

        // ---- Hollow out the interior (leave top wall = top_t) ----
        translate([0,0,0])
            cylinder(d=inner_d, h=thread_h + nonthread_h + 0.02, $fn=$fn);

        // ---- Internal thread: subtract a slightly oversized external thread ----
        // We cut threads from Z=0 up to thread_h.
        translate([0,0,thread_h/2])
            _gc_thread_cutter(
                d      = hole_d,            // cutter diameter (major dia of internal thread)
                pitch  = pitch,
                len    = thread_h + 0.02,   // tiny extra to ensure a clean end
                starts = starts,
                lh     = left_handed
            );

        // ---- Optional entry chamfer at the mouth of the lid ----
        if (entry_chamfer_h > 0) {
            // Chamfer transitions from the inner bore at Z=0 up to the thread major at Z=entry_chamfer_h
            // This helps the mating thread find the start.
            translate([0,0,0])
                cylinder(h=entry_chamfer_h, d1=inner_d, d2=hole_d, $fn=96);
        }
    }
}

// Internal helper: subtractive thread cutter using BOSL2 generic_threaded_rod
module _gc_thread_cutter(d, pitch, len, starts=1, lh=false) {
    // External thread solid that we subtract to form the internal thread.
    // Bevels off to avoid truncating the start.
    threaded_rod(
        d=d,
        l=len,
        pitch=pitch,
        starts=starts,
        left_handed=lh
    );
}
