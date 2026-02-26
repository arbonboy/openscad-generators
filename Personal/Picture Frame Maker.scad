/* [Options] */
texture = "wood"; //[wood:Wood,lines:Lines,none:None]
dove_tails = true;

// this is a heavy script, only render 1 side if true
sample = false;

// if orient for printing is false, this shows the parts slightly spaced apart for easy dovetail inspection
explode = false;

screw_hole = 2; // [0: no screwhole, 1: 1 screwhole, 2: 2 screwholes, 3: 4 screwholes]

// if orient for printing is false, this shows the underside for easy screw hole inspection
flip = false;

// orient the parts for easy printing
orient_for_printing = true;

// Put labels on the back portions of the sections for easy assembly
label_printed_sections = true;


/* [Dimensions] */
// The height of your artwork (mm)
art_h = 180;
// The width of your artwork (mm)
art_w = 180;

// Frame width (mm)
frame_w = 20;
// Frame depth (mm)
frame_d = 15;

// Lip width (mm)
lip_w = 20;
// Lip depth (mm)
lip_d = 3;

/* [Texture Settings] */
// Magic number
tex_diameter = 40; // [0:1:250]
// Number of Woodgrains per row
tex_steps = 10; // [0:1:50]
// Likelyhood of Woodgrain
tex_threshold = 0.70; // [0.0:0.05:1.0]
// Woodgrain width (mm)
tex_size = 1; // [0.8:0.4:5]
// Woodgrain depth (mm)
tex_depth = 0.8; // [0.0:0.4:4]
//Line Texture Width
Line_Texture_Segment_Width = 20; //[1:1:100]

/* [Dovetail Settings] */
// Offset between the wall and the dovetail (mm)
dove_tail_wall_offset = 2.4;
// Margin between male and female dovetail (mm)
dove_tail_margin = 0.1; // [0.0:0.01:0.4]

/* [Screwhole Settings] */
// Diameter of screw head (mm)
screw_head_d = 8;
// height of screw head (mm)
screw_head_h = 4;
// Diameter of screw shaft (mm)
screw_shaft_d = 4.5;

// Offset between the wall and the screwhole (mm)
screw_wall_offset = 2.4;
// Margin around the screw (mm)
screw_margin = .5;

/* [Print Settings] */
// If orient for printing is active, this represents angle of the individual frame parts. depending on the dimensions of each part, you may need to increase or decrease this value to fit them on your printbed
print_rotation = 45;

// If orient for printing is active, this represents the space between each frame part. You may need to adjust it if you change the print rotation
print_margin = 10;

// A frame part will be subdevided into an odd number of segments if it's length exceeds this value
max_segment_size = 330;

/* [Hidden] */
edgeLabels = ["Top", "Right", "Bottom", "Left"];

module rounded_rectangle(width, height, radius) {
    hull() {
        translate([radius, radius, 0]) circle(r=radius, $fn=32);
        translate([width - radius, radius, 0]) circle(r=radius, $fn=32);
        translate([width - radius, height - radius, 0]) circle(r=radius, $fn=32);
        translate([radius, height - radius, 0]) circle(r=radius, $fn=32);
    }
}

tau = 0.005;

rands_range = 100000;
num_rands = 100000;
global_seed = rands(100, 500, 1)[0];
rands1 = rands(-rands_range, rands_range, num_rands);
rands2 = rands(-rands_range, rands_range, num_rands);
rands3 = rands(-rands_range, rands_range, num_rands);
rands4 = rands(-rands_range, rands_range, num_rands);
rands5 = rands(-rands_range, rands_range, num_rands);

module rounded_diamond(width, height, radius) {
    hull() {
        translate([radius, -height / 2, 0]) circle(r=radius, $fn=32);
        translate([width - height / 2, -radius, 0]) circle(r=radius, $fn=32);
        translate([width - radius, -height / 2, 0]) circle(r=radius, $fn=32);        
        translate([width - height / 2, -height + radius, 0]) circle(r=radius, $fn=32);
    }
}

module create_edge(width, height) {
    linear_extrude(height = 3) {
        square(size = [width, height]);
    }
}

module create_screw_hole(width, height) {
    head_d = screw_head_d + (screw_margin * 2);
    shaft_d = screw_shaft_d + (screw_margin * 2);
    
    wall_offset = screw_wall_offset + head_d/2;
    slot_l = frame_w - (wall_offset * 2);
    
    translate([0,wall_offset,0])
    translate([0,slot_l, 0])
    translate([width/2, 0, -lip_d - 1])
    union() {
        linear_extrude(height = screw_head_h + screw_margin + screw_wall_offset + 1) {
            circle(d=head_d, $fn=100);
        }
        
        
        translate([0,0,screw_wall_offset + 1])
        linear_extrude(height = screw_head_h + screw_margin) {
            hull() {
                circle(d=head_d, $fn=100);
                translate([0,-slot_l])
                circle(d=head_d, $fn=100);
            }
        }
        
        linear_extrude(height = screw_wall_offset + 2) {
            hull() {
                circle(d=shaft_d, $fn=100);
                translate([0,-slot_l+screw_margin])
                circle(d=shaft_d, $fn=100);
            }
        }
    }
}

module create_label(width, height, index) {
    head_d = screw_head_d + (screw_margin * 2);
    shaft_d = screw_shaft_d + (screw_margin * 2);
    
    wall_offset = screw_wall_offset + head_d/2;
    slot_l = frame_w - (wall_offset * 2);
    
    translate([-head_d/2,wall_offset,0])
    translate([0,slot_l+10, 0])
    translate([width/2, 0, -lip_d - 1])
    union() {
        linear_extrude(height = 1.25) {
            text(size=3, str(index));
        }
    }
}

module create_edge2(width, height, index) {
    union() {        
        difference() {
            union() {
                // lip
                translate([0,0,-lip_d])
                linear_extrude(height = lip_d) {
                    polygon(points=[
                    [0,0],
                    [height +lip_w,height+lip_w],
                    [width - height - lip_w,height+lip_w],
                    [width, 0]], paths=[[0,1,2,3]],convexity=10);
                }
                
                // frame
                linear_extrude(height = frame_d) {
                    polygon(points=[
                    [0,0],
                    [height,height],
                    [width - height,height],
                    [width, 0]], paths=[[0,1,2,3]], convexity=10);
                }
            }
            
            if (dove_tails && (index == 1 || index == 3)) {
                create_nega_dove_tails(width, height);
            }
            
            if (screw_hole > 0 && (index == 2 || screw_hole == 3|| (screw_hole == 2 && index == 0))) {
                create_screw_hole(width, height);
            }

            // if (label_printed_sections) {
            //     create_label(width, height, index);
            // }
        }
        
        if (dove_tails && (index == 0 || index == 2)) {
            create_dove_tails(width, height);
        }
    }
}

module center_edge2(width, height) {
    translate([-width/2,-frame_w,0])
    children();
}

module create_dove_tails(width, height) {
    offset = dove_tail_wall_offset + dove_tail_margin;
    extrude = frame_w - offset * 2;
    
    translate([width - frame_w + offset,0,frame_d])
    rotate([90,0,90])
    translate([offset, -offset, 0])
    linear_extrude(height = extrude) {
        create_dove_tail(offset, 1);
    }
    
    translate([offset,0,frame_d])
    rotate([90,0,90])
    translate([offset, -offset, 0])
    linear_extrude(height = extrude) {
        create_dove_tail(offset, 1);
    }
}

module create_nega_dove_tails(width, height) {
    offset = dove_tail_wall_offset;
    extrude = frame_w - offset * 2;
    
    translate([width - frame_w + offset,0,frame_d])
    rotate([90,0,180])
    translate([-extrude, -offset, offset])
    linear_extrude(height = extrude) {
        create_dove_tail(offset, 2);
    }
    
    translate([0 + offset,0,frame_d])
    rotate([90,0,0])
    translate([0, -offset, -height+offset])
    linear_extrude(height = extrude) {
        create_dove_tail(offset, 2);
    }
}

module create_dove_tail(offset, roundness) {
    smollest = min(frame_w, frame_d);
    largest = max(frame_w, frame_d);
    translate(frame_d > frame_w ? [0,-frame_w  / 1.3 / 4,0] : [0,0,0])
    rounded_diamond(frame_w - (offset * 2), (frame_d > frame_w ? frame_w  / 1.3 : frame_d)- (offset * 2), roundness);
}

module create_wood_texture_plates(width, height, index) {
    for ( y = [0:tex_size:frame_w]) {
        step = width / 10;
        
        translate([
            y % 2 == 1 ? 0 : step * .5,
            y, 
            0
        ])        
        for ( x = [0:1:10]) {
            seed = (y * frame_w) + x + (index * global_seed);
            if (rands(0,100,1, rands1[seed])[0] < tex_threshold * 100) {
                rotate([90,0,rands(-2,2,1,rands2[seed])[0]])
                translate([step * x, 0])
                translate([0, frame_d + (tex_diameter/2), 0])
                translate([0, -tex_depth* rands(.5,1,1, rands3[seed])[0], 0])
                create_wood_texture_plate(tex_diameter + (rands(tex_diameter,tex_diameter * 10,1, rands4[seed])[0]), tex_diameter, rands5[seed]);
            }
        }
    }    
}

module create_wood_texture_plate(width, height, seed) {
    echo("Creating wood texture plate with width:", width, "height:", height, "seed:", seed);
    linear_extrude(height = tex_depth * rands(.6,1.4,1,seed)[0]) {
        resize([width,height])circle(d=10, $fn=100);
    }
}

module create_line_texture_plates(width, height, index) {
    line_seg_width = Line_Texture_Segment_Width;
    for ( y = [0:tex_size:frame_w]) {
        // step = width / lines_per_side;
        step = line_seg_width;
        
        
        translate([
            y % 2 == 1 ? 0 : step * .5,
            y, 
            0
        ]) {       
            for ( x = [0:1:width]) {
                
                // seed = (y * frame_w) + x + (index * global_seed);
                // if (rands(0,100,1, rands1[seed])[0] < tex_threshold * 100) {
                //     rotate([90,0,rands(-2,2,1,rands2[seed])[0]])
                //     translate([step * x, 0])
                //     translate([0, frame_d + (tex_diameter/2), 0])
                //     translate([0, -tex_depth* rands(.5,1,1, rands3[seed])[0], 0])
                //     create_wood_texture_plate(tex_diameter + (rands(tex_diameter,tex_diameter * 10,1, rands4[seed])[0]), tex_diameter, rands5[seed]);
                // }

                rotate([90,0,0])
                translate([step * x, 0])
                translate([0, frame_d + (tex_diameter/2), 0])
                translate([0, -tex_depth, 0])
                rotate([0,90,0])
                    create_line_texture_plate(tex_diameter, tex_diameter, 0);
        
            }
        }
    }    
}

module create_line_texture_plate(width, height, seed) {
    // echo("Creating line texture plate with width:", width, "height:", height, "seed:", seed);
    linear_extrude(height = tex_depth) {
        resize([width,height])circle(d=10, $fn=100);
    }
}

module translate_explode() {
    translate(explode ? [0, -frame_w] : [0,0])
    children();
}

module translate_index(index) {
    rot = flip ? 180:0;
    if (orient_for_printing) {
        tmp_y = frame_d + lip_d + print_margin;
        translate([0, tmp_y * index, 0])
        rotate([90, 0, 0])
            children();
    } else {
        if (index == 0) {
            rotate([0,rot,0])
            translate([0,0,0])
                children();
        }
        if (index == 1) {            
            rotate([0,rot,0])
            translate([-art_w / 2, art_h/2 , 0])
            rotate([0,0,-90])
                children();
        }
        if (index == 2) {
            rotate([0,rot,0])
            translate([0, art_h, 0])
            rotate([0,0,180])
                children();
        }
        if (index == 3) {
            rotate([0,rot,0])
            translate([art_w / 2, art_h/2  , 0])
            rotate([0,0,90])
                children();
        }
    }
}

module split_segments(width, height, edgeLabel) {
    total_l = width;
    tmp_num_segments = ceil(total_l / max_segment_size);
    num_segments = tmp_num_segments % 2 == 0 ? tmp_num_segments + 1 : tmp_num_segments;
    segment_l = total_l / num_segments;
    
    echo("num_segments", num_segments);
    echo("segment_l", segment_l);
    
    module my_translate_explode(index, num_segments) {
        num_seg_min_one = -frame_w * (num_segments - 1);
        if (explode || orient_for_printing) {
            translate([num_seg_min_one + frame_w * index * 2, num_seg_min_one])
            children();
        } else {
            children();
        }
    }
    
    module my_create_male_dovetail(index, num_segments) {
        offset = dove_tail_wall_offset + dove_tail_margin;
        extrude = frame_w - offset * 2;
        
        if (index != 0) {
            translate([-extrude,0,frame_d])
            rotate([90,0,90])
            translate([offset, -offset, 0])
            linear_extrude(height = extrude) {
                create_dove_tail(offset, 1);
            }
        }
    }
    
    module my_create_female_dovetail(index, num_segments, segment_l) {
        offset = dove_tail_wall_offset;
        extrude = frame_w - offset * 2;
        
        if (index != num_segments - 1) {
            translate([segment_l-extrude + tau,0,frame_d])
            rotate([90,0,90])
            translate([offset, -offset, 0])
            linear_extrude(height = extrude + tau) {
                create_dove_tail(offset, 2);
            }
        }
    }
    
    for( i = [0:num_segments - 1]) {
        my_translate_explode(i, num_segments)
        union() {
            difference() {            
                ///*
                intersection() {
                    translate([segment_l * i,0,-lip_d])
                    linear_extrude(height=frame_d + lip_d)
                    square([segment_l, frame_w + lip_w], center = false);
                    
                    children();
                }
                // */
                
                translate([segment_l * i,0,0])
                my_create_female_dovetail(i, num_segments, segment_l);

                translate([segment_l * i,0,0])
                    create_label(segment_l, segment_l, str(edgeLabel, "-", i));
                
            }
            
            
            translate([segment_l * i,0,0])
            my_create_male_dovetail(i, num_segments);
        }
    }
}

module subtract_wood_texture(width, height, index) {
    difference() {
        children();
        create_wood_texture_plates(width, height, index);
        
    }
}


module subtract_line_texture(width, height, index) {
    difference() {
        children();
        create_line_texture_plates(width, height, index);
    }
}

module create_frame_edge(index, width, height) {
    translate_index(index){
        translate_explode(){
            center_edge2(width, height){
                split_segments(width, height, str(edgeLabels[index])){
                    if(texture=="wood"){
                        subtract_wood_texture(width, height, index){
                           create_edge2(width, height, index);
                        }
                    } else if(texture=="lines"){
                        subtract_line_texture(width, height, index){
                            create_edge2(width, height, index);
                        }
                    }
                    
                }
            }
        }
    }
}

module create_frame() {
    w_length = art_w + (2 * frame_w);
    h_length = art_h + (2 * frame_w);
    
    create_frame_edge(0, w_length, frame_w);
    
    if (!sample) {
        create_frame_edge(1, h_length, frame_w);
        create_frame_edge(2, w_length, frame_w);
        create_frame_edge(3, h_length, frame_w);
    }
}

create_frame();