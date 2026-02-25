// Based on the excellent Gridfinity system by Zach Freedman
// Wiki: https://gridfinity.xyz/
// v1.0 7/5/2025 Initial version of GridPlates fork.
// v1.1 8/24/2025 - Fixing connectors and spacing calculators. Adding corner cutouts. 
// v1.2 9/4/2025 - Adding debug mode, bottom chamfer, solid base thickness, 848x620 spacing problems
// v1.3 8/25/2025 - Adding numbering on back of tiles for easier assembly. With tiles upside down starting top left and work left to right. For offset rows assume top of tile and left to right skipping columns as necessary. (Tricky debug dimensions 588x620)

/* [3MF Export Instructions for OpenSCAD] */
// To export each panel as a separate object for your slicer:
// 1. In OpenSCAD Menu, go to: Edit -> Preferences -> Features -> and CHECK the "lazy-union" box.
// 2. Set 'Enable_3MF_Export_Mode' advanced option to 'true'.
// 3. Render, then File -> Export -> Export as 3MF.
// 4. Your slicer will now see each panel as a separate object.

// For exact Gridfinity units, multiply by 42. eg 10 Gridfinity spaces is 10 * 42 = 420
Width_in_mm = 388;

// For exact Gridfinity units, multiply by 42. eg 10 Gridfinity spaces is 10 * 42 = 420
Depth_in_mm = 420;

// Suggest 2mm if measurements don't allow for clearance.
Clearance = 0;

Build_Plate_Size=236; //[180: Small (A1 Mini), 236: Standard (X1/P1/A1), 350: Large (350mm)]

/* [Options] */

// Type of interlocking mechanism between plates.
Interlock_Type = 1; // [0: None (Butt-Together Baseplate), 1: Standard gridPlates Tab, 2: Looser gridPlates Tab]

// Include a half-width grid in the margin(s) if there is sufficient space.
Half_Sized_Filler = true;

// Designed to fit drawers where the bottom edges are not square but rounded.
Bottom_Edge_Chamfer_in_mm = 0;

// Use with caution as this will increase warping.
Solid_Base_Thickness_in_mm = 0;

/* [Numbering Options] */

// Emboss a sequential number on the bottom of each plate's first inner grid bar for easy assembly.
Enable_Numbering = true;
// Font size of the embossed number in millimeters.
Number_Size = 2;
// How deep to cut the number into the base. Should be a multiple of your layer height.
Number_Depth = 0.2;

/* [Advanced] */

// Minimum size for generated parts in grid units. Set to 2 to ensure all corner pieces can have screw holes, or 1.5 if you are using half-fillers. 0 = no minimum.
Minimum_Part_Size_in_Grid_Units = 0;

// Offset grid right or left.
Offset_Horizontal_in_mm = 0;

// Offset grid back or forward.
Offset_Vertical_in_mm = 0;

// Mirrors the baseplate left-to-right.
Mirror_Horizontally = false;

// Mirrors the baseplate front-to-back.
Mirror_Vertically = false;

// Cuts a concave quarter-circle from the four outer corners of the complete baseplate. Great for wire racks.
Corner_Cutout_in_mm = 0;

/* [Screw Hole Options] */

// Add screw holes near the corners of the baseplate for mounting. Holes are placed at grid bar intersections for maximum structural support.
Enable_Screw_Holes = false;

// Screw hole placement pattern.
Screw_Hole_Pattern = 0; // [0: Corners Only, 1: All Intersections (Heavy Duty)]

// Diameter of the screw hole (clearance hole size). Common: M3=3.4, M4=4.5, M5=5.5
Screw_Hole_Diameter = 3.4;

// Number of grid units inward from each corner/edge to place screw holes. 1 = first grid intersection from edge.
Screw_Hole_Grid_Inset = 1;

// Enable countersink for flat-head screws.
Enable_Countersink = false;

// Diameter of the countersink (typically ~2x screw diameter). Common: M3=6.3, M4=8.4, M5=10.4
Countersink_Diameter = 6.3;

// Depth/angle of countersink (82° standard flat head creates depth ≈ (diameter-hole)/2).
Countersink_Depth = 1.5;

// Renders a single small plate for quick previews and debugging.
Debug_Mode = false;

// Amount of extra rounding to apply to the corners. This value is limited based on the size of the margins.
Extra_Corner_Rounding = 0;

// Whether to add space for magnets. Increases the height of the baseplate!
Magnets = false;

// The magnet hole radius. Slightly smaller than the magnet to hold it snug.
Magnet_Radius_in_mm = 2.95;

// The magnet hole height.
Magnet_Height_in_mm = 2.25;

/* [Export Options] */

// Set to 'true' to center all plates at the origin for multi-plate 3MF export.
// This will cause them to overlap in the preview window.
// Set to 'false' (default) for a normal grid layout preview.
Enable_3MF_Export_Mode = false;

// Standard Gridfinity is 42 mm
Base_Unit_Width_Depth = 42;

/* [Hidden] */

// --- Gridfinity System Dimensions ---
b_top_chamfer_height = 1.9;
b_center_height = 1.8;
b_bottom_chamfer_height = 0.8;
b_bottom_vertical_height = 0;
b_corner_center_inset = 4;
b_corner_center_radius = 1.85;

// --- Interlock Profile Data ---
standard_interlock_profile_1 = [[0.25,38.52,0.13],[0.17,38.81,0],[-0.78,40.45,-0.77],[-0.43,40.8,0],[0.44,40.29,0.58],[1.07,40.65,0]];
standard_interlock_profile_2 = [[0.9,40.65,-0.58],[0.53,40.44,0],[-0.35,40.94,0.77],[-0.92,40.37,0],[-0.28,39.26,-0.13],[-0.25,39.14,0]];
looser_interlock_profile_1 = [[0.25,38.52,0.13],[0.18,38.77,0],[-0.74,40.37,-0.77],[-0.4,40.72,0],[0.43,40.24,0.58],[1.18,40.67,0]];
looser_interlock_profile_2 = [[0.93,40.67,-0.58],[0.56,40.45,0],[-0.27,40.93,0.77],[-0.96,40.25,0],[-0.28,39.08,-0.13],[-0.25,38.96,0]];

// --- Magnet Parameters ---

magnet_strength_top = 0.5; // two layers
magnet_strength_bottom = 0.75;
magnet_center_offset = 4.8;
magnet_cutout_chamfer_radius = 10;
magnet_removal_slot_extend = 6;
magnet_removal_slot_radius = 1.5;
magnet_border = 3;

// --- Derived Calculations ---
adjusted_width = Width_in_mm - Clearance;
adjusted_depth = Depth_in_mm - Clearance;
whole_units_wide = floor(adjusted_width / Base_Unit_Width_Depth);
whole_units_deep = floor(adjusted_depth / Base_Unit_Width_Depth);
have_vertical_half_strip = Half_Sized_Filler && (adjusted_width - whole_units_wide * Base_Unit_Width_Depth) >= Base_Unit_Width_Depth / 2;
have_horizontal_half_strip = Half_Sized_Filler && (adjusted_depth - whole_units_deep * Base_Unit_Width_Depth) >= Base_Unit_Width_Depth / 2;
units_wide = whole_units_wide + (have_vertical_half_strip ? 0.5 : 0);
units_deep = whole_units_deep + (have_horizontal_half_strip ? 0.5 : 0);
half_margin_h = (adjusted_width - units_wide * Base_Unit_Width_Depth) / 2;
half_margin_v = (adjusted_depth - units_deep * Base_Unit_Width_Depth) / 2;
margin_left = half_margin_h + Offset_Horizontal_in_mm;
margin_back = half_margin_v + Offset_Vertical_in_mm;
margin_right = half_margin_h - Offset_Horizontal_in_mm;
margin_front = half_margin_v - Offset_Vertical_in_mm;
max_margin = max(max(margin_left, margin_right), max(margin_front, margin_back)); 
base_corner_radius = 4;
max_extra_corner_radius = max(min(margin_left, margin_right), min(margin_front, margin_back));
outer_corner_radius = base_corner_radius + max(0, min(Extra_Corner_Rounding, max_extra_corner_radius));
fn_min = 20;
fn_max = 40;
function lerp(x, x0, x1, y0, y1) = y0 + (x - x0) * (y1 - y0) / (x1 - x0);
$fn = max(min(lerp(units_wide*units_deep, 300, 600, fn_max, fn_min), fn_max), fn_min);
selected_plate_size = Build_Plate_Size;
max_recursion_depth = 12;
part_spacing = 10;
cut_overshoot = 0.1;
non_gridplates_edge_clearance = 0.25;
min_corner_radius = 1;
gridplates_min_margin_for_full_tab = 2.75;
b_total_height = b_top_chamfer_height + b_center_height + b_bottom_chamfer_height + b_bottom_vertical_height + Solid_Base_Thickness_in_mm;
b_tool_top_chamfer_height = b_top_chamfer_height + cut_overshoot;
b_tool_bottom_chamfer_height = b_bottom_chamfer_height + (Solid_Base_Thickness_in_mm > 0 || b_bottom_vertical_height > 0 ? 0 : cut_overshoot);
b_tool_bottom_vertical_height = b_bottom_vertical_height > 0 ? (b_bottom_vertical_height + (Solid_Base_Thickness_in_mm > 0 ? 0 : cut_overshoot)) : 0;
b_tool_top_scale = (b_corner_center_radius + b_tool_top_chamfer_height) / b_corner_center_radius;
b_tool_bottom_scale = (b_corner_center_radius - b_tool_bottom_chamfer_height) / b_corner_center_radius;
polyline_data_1 = Interlock_Type == 2 ? looser_interlock_profile_1 : standard_interlock_profile_1;
polyline_data_2 = Interlock_Type == 2 ? looser_interlock_profile_2 : standard_interlock_profile_2;
extra_height = Magnets ? magnet_strength_top + magnet_strength_bottom + Magnet_Height_in_mm : 0;
function tessellate_arc(start, end, bulge, segments = 8) = let(chord=end-start,chord_length=norm(chord),sagitta=abs(bulge)*chord_length/2,radius=(chord_length/2)^2/(2*sagitta)+sagitta/2,center_height=radius-sagitta,center_offset=[-chord.y,chord.x]*center_height/chord_length,center=(start+end)/2+(bulge>=0?center_offset:-center_offset),start_angle=atan2(start.y-center.y,start.x-center.x),end_angle=atan2(end.y-center.y,end.x-center.x),angle_diff=(bulge>=0)?(end_angle<start_angle?end_angle-start_angle+360:end_angle-start_angle):(start_angle<end_angle?start_angle-end_angle+360:start_angle-end_angle),num_segments=max(1,round(segments*(angle_diff/360))),angle_step=angle_diff/num_segments) [for(i=[0:num_segments-1]) let(angle=start_angle+(bulge>=0?1:-1)*i*angle_step) center+radius*[cos(angle),sin(angle)]];
function tessellate_polyline(data) = let(polyline_curve_segments=8,points=[for(i=[0:len(data)-1]) let(start=[data[i][0],data[i][1]],end=[data[(i+1)%len(data)][0],data[(i+1)%len(data)][1]],bulge=data[i][2]) if(bulge==0) [start] else tessellate_arc(start,end,bulge,polyline_curve_segments)]) [for(segment=points,point=segment) point];
function reverse_polyline_data(data) = let(n=len(data),reversed=[for(i=[n-1:-1:0]) [data[i][0],data[i][1],i>0?-data[i-1][2]:0]]) reversed;
function get_min_polyline_x(data) = min([for (point = tessellate_polyline(data)) point[0]]);
function get_max_polyline_x(data) = max([for (point = tessellate_polyline(data)) point[0]]);
left_tab_extent = -min(0, min(get_min_polyline_x(polyline_data_1), get_min_polyline_x(polyline_data_2)));
right_tab_extent = max(0, max(get_max_polyline_x(polyline_data_1), get_max_polyline_x(polyline_data_2)));
reversed_polyline_data_2 = reverse_polyline_data(polyline_data_2);    
tab_min_clearance = polyline_data_1[len(polyline_data_1)-1][0] - polyline_data_2[0][0];
tab_extent_allowance = max(left_tab_extent, right_tab_extent) + cut_overshoot + min_corner_radius;
gridplates_tool_extent_allowance = tab_extent_allowance + cut_overshoot;
function reverse_points(arr) = [for (i = [len(arr)-1:-1:0]) arr[i]];
function y_mirror_points(points) = [for (point = reverse_points(points)) [point.x, -point.y]];
function y_translate_points(points, y_delta) = [for (point = points) [point.x, point.y + y_delta]];
function lower_butt_profile(direction) = let(close_clearance=tab_min_clearance/2,delta=non_gridplates_edge_clearance-close_clearance,start=[close_clearance*-direction,-gridplates_min_margin_for_full_tab],end=[start.x+delta*-direction,start.y-delta]) [end,start];
function upper_butt_profile(direction) = [[non_gridplates_edge_clearance * -direction, 0]];
function tesselate_and_adjust_gridplates_profile(polyline_data) = y_translate_points(tessellate_polyline(polyline_data), -42);
function lower_half_profile(gridplates_base_profile) = gridplates_base_profile;
function upper_half_profile(gridplates_base_profile) = y_mirror_points(gridplates_base_profile);
function full_profile(gridplates_base_profile) = [each lower_half_profile(gridplates_base_profile),each upper_half_profile(gridplates_base_profile)];
function repeat_profile(profile, repetitions, spacing, start_offset) = repetitions<=0?[]:let(repeated=[for(i=[0:repetitions-1]) [for(point=profile) [point.x,point.y+i*spacing+start_offset]]]) [for(segment=repeated,point=segment) point];
cutting_tool_height = (b_total_height + cut_overshoot) * 2;
function gridplates_left_polyline_data() = reversed_polyline_data_2;
function gridplates_right_polyline_data() = polyline_data_1;

// --- Plate Slicing Logic ---
function GetCutOffsetForward(prev_offset, margin_start, margin_end, axis_unit_length) = 
    let(
        min_part = Minimum_Part_Size_in_Grid_Units,
        // For internal cuts, we need full grid units - half-fillers can ONLY be at outer edge
        min_part_full = ceil(min_part),
        prev_carry_over = prev_offset == 0 ? margin_start : left_tab_extent,
        remaining = prev_carry_over + (axis_unit_length - prev_offset) * Base_Unit_Width_Depth + margin_end,
        raw_offset = prev_offset + floor((selected_plate_size - left_tab_extent - right_tab_extent - (prev_offset == 0 ? margin_start : 0)) / Base_Unit_Width_Depth),
        next_remaining_approx = (axis_unit_length - raw_offset) * Base_Unit_Width_Depth + margin_end,
        // Adjust for tab margin requirements
        tab_adjusted = (next_remaining_approx < Base_Unit_Width_Depth + gridplates_min_margin_for_full_tab + 0.001) ? raw_offset - 1 : raw_offset,
        // Enforce minimum size for current piece (must be full units)
        current_size = tab_adjusted - prev_offset,
        min_current_adjusted = (min_part > 0 && current_size > 0 && current_size < min_part_full) ? prev_offset + min_part_full : tab_adjusted,
        // Check if remaining piece would be too small (count full units only for internal check)
        remaining_full_units = floor(axis_unit_length) - min_current_adjusted,
        remaining_size = axis_unit_length - min_current_adjusted,
        // If remaining is too small, try to "steal" from current piece by moving cut backward
        // Ensure last piece has at least min_part_full FULL units (plus any half-filler at edge)
        steal_offset = floor(axis_unit_length) - min_part_full,  // Cut position giving last piece min_part_full full units
        steal_remaining = axis_unit_length - steal_offset,  // Total size including any half-filler
        steal_current_size = steal_offset - prev_offset,
        steal_is_valid = steal_current_size >= min_part_full && steal_remaining >= min_part,
        // Use steal offset if valid, otherwise skip cut as last resort
        final_offset = (min_part > 0 && remaining_full_units > 0 && remaining_full_units < min_part_full)
            ? (steal_is_valid ? steal_offset : -1)
            : min_current_adjusted
    )
    remaining <= selected_plate_size ? -1 : final_offset;
function GetAltEndOffset(margin_end, axis_unit_length) = let(space_for_full_units=selected_plate_size-margin_end-left_tab_extent-(axis_unit_length%1)*Base_Unit_Width_Depth,full_units=floor(space_for_full_units/Base_Unit_Width_Depth),offset=floor(axis_unit_length)-full_units) offset;
function GetUnitsPerInnerSection(axis_unit_length) = let(space_for_full_units=selected_plate_size-left_tab_extent-right_tab_extent) floor(space_for_full_units/Base_Unit_Width_Depth);
function GetAltStartOffset(margin_start, margin_end, axis_unit_length) = 
    let(
        min_part = Minimum_Part_Size_in_Grid_Units,
        // First piece must have full grid units (half-filler only at outer edge)
        min_part_full = ceil(min_part),
        end_offset = GetAltEndOffset(margin_end, axis_unit_length),
        units_per_inner_section = GetUnitsPerInnerSection(axis_unit_length),
        initial_offset = end_offset % units_per_inner_section,
        adjusted_offset = (initial_offset == 0) ? max(1, floor(units_per_inner_section / 2)) : initial_offset,
        tab_adjusted = (adjusted_offset == 1 && margin_start < (gridplates_min_margin_for_full_tab + 0.001)) ? 2 : adjusted_offset,
        // Enforce minimum part size (full units) for the first piece in alternating rows
        final_offset = (min_part > 0 && tab_adjusted < min_part_full) ? min_part_full : tab_adjusted
    )
    final_offset;
function recurse_plates_x(x_depth=0,start_offset=0) = let(end_offset=GetCutOffsetForward(start_offset,margin_left,margin_right,units_wide)) (end_offset<0||x_depth>max_recursion_depth)?recurse_plates_y(x_depth,start_offset,units_wide):concat(recurse_plates_y(x_depth,start_offset,end_offset),recurse_plates_x(x_depth+1,end_offset));
function recurse_plates_y(x_depth,x_start_offset,x_end_offset,y_depth=0,y_start_offset=0) = let(alt_cuts=x_depth%2!=0,standard_offset=GetCutOffsetForward(y_start_offset,margin_front,margin_back,units_deep),y_end_offset=alt_cuts&&y_start_offset==0&&standard_offset>=0?GetAltStartOffset(margin_front,margin_back,units_deep):standard_offset) (y_end_offset<0||y_depth>max_recursion_depth)?[[x_depth,y_depth,x_start_offset,x_end_offset,y_start_offset,units_deep]]:concat([[x_depth,y_depth,x_start_offset,x_end_offset,y_start_offset,y_end_offset]],recurse_plates_y(x_depth,x_start_offset,x_end_offset,y_depth+1,y_end_offset));
plates = Debug_Mode ? [[0,0,0,2,0,2]] : recurse_plates_x();

// --- Module Definitions ---
function plate_centering_translation(plate) = let(x_start=plate[2],x_end=plate[3],y_start=plate[4],y_end=plate[5],left_amount=x_start==0?margin_left:left_tab_extent,right_amount=(x_end-x_start)*Base_Unit_Width_Depth+(x_end==units_wide?margin_right:right_tab_extent),front_amount=y_start==0?margin_front:left_tab_extent,back_amount=(y_end-y_start)*Base_Unit_Width_Depth+(y_end==units_deep?margin_back:right_tab_extent)) [(left_amount-right_amount)/2,(front_amount-back_amount)/2,0];
function overall_centering_translation(plate) = let(x_depth=plate[0],y_depth=plate[1],x_start_offset=plate[2],y_start_offset=plate[4],assembled_center=[-Base_Unit_Width_Depth*units_wide/2,-Base_Unit_Width_Depth*units_deep/2,0],exiting_plate_center=plate_centering_translation(plate),plate_offset=[x_start_offset*Base_Unit_Width_Depth+part_spacing*x_depth,y_start_offset*Base_Unit_Width_Depth+part_spacing*y_depth,0],combined=assembled_center+plate_offset-exiting_plate_center) [Mirror_Horizontally?-combined[0]:combined[0],Mirror_Vertically?-combined[1]:combined[1],combined[2]];

module four_directions(number) {
    children();
    if (number > 3) mirror([1, 0, 0]) children();
    if (number > 2) mirror([0, 1, 0]) children();
    if (number > 1) mirror([1, 0, 0]) mirror([0, 1, 0]) children();
}

module uncut_baseplate(units_x, units_y, r_fl, r_bl, r_br, r_fr, m_l, m_b, m_r, m_f) {
    main_width = Base_Unit_Width_Depth*units_x;
    main_depth = Base_Unit_Width_Depth*units_y;
    difference() {
        translate([0, 0, -extra_height]) hull() {
            translate([r_fl-m_l, r_fl-m_f, 0]) cylinder(r=r_fl, h=b_total_height+extra_height, center=false);
            translate([r_bl-m_l, main_depth-r_bl+m_b, 0]) cylinder(r=r_bl, h=b_total_height+extra_height, center=false);
            translate([main_width-r_br+m_r, main_depth-r_br+m_b, 0]) cylinder(r=r_br, h=b_total_height+extra_height, center=false);
            translate([main_width-r_fr+m_r, r_fr-m_f, 0]) cylinder(r=r_fr, h=b_total_height+extra_height, center=false);
        }        
        for(y=[1:ceil(units_y)]) for(x=[1:ceil(units_x)]) translate([Base_Unit_Width_Depth*(x-0.5), Base_Unit_Width_Depth*(y-0.5),0]) gridfinity_cutting_tool(x > units_x, y > units_y);
    }
}
module gridfinity_cutting_tool(half_x, half_y) {
    base_offset = Base_Unit_Width_Depth/2 - b_corner_center_inset;
    if (half_x || half_y) {
        adjust_x = half_x ? Base_Unit_Width_Depth/4 : 0;
        adjust_y = half_y ? Base_Unit_Width_Depth/4 : 0;
        translate([-adjust_x, -adjust_y, 0]) gridfinity_cutting_tool_main(base_offset - adjust_x, base_offset - adjust_y, half_x == half_y ? 1 : 2);
    } else {
        gridfinity_cutting_tool_main(base_offset, base_offset, 4);
    }
}
module gridfinity_cutting_tool_main(offset_x, offset_y, number_of_magnets) {
    top_z_offset=b_total_height-b_top_chamfer_height;
    middle_z_offset=top_z_offset-b_center_height;
    bottom_z_offset=middle_z_offset-b_bottom_chamfer_height;
    union() {
        hull() for(x=[-offset_x,offset_x]) for(y=[-offset_y,offset_y]) translate([x,y,top_z_offset]) linear_extrude(height=b_tool_top_chamfer_height,scale=[b_tool_top_scale,b_tool_top_scale]) circle(r=b_corner_center_radius);
        hull() for(x=[-offset_x,offset_x]) for(y=[-offset_y,offset_y]) translate([x,y,middle_z_offset]) {
            cylinder(r=b_corner_center_radius,h=b_center_height,center=false);
            mirror([0,0,1]) linear_extrude(height=b_tool_bottom_chamfer_height,scale=[b_tool_bottom_scale,b_tool_bottom_scale]) circle(r=b_corner_center_radius);
        }
        if(b_tool_bottom_vertical_height>0) {tool_bottom_z_offset=bottom_z_offset-b_tool_bottom_vertical_height;hull() for(x=[-offset_x,offset_x]) for(y=[-offset_y,offset_y]) translate([x,y,tool_bottom_z_offset]) cylinder(r=b_corner_center_radius*b_tool_bottom_scale,h=b_tool_bottom_vertical_height,center=false);}
        if (Magnets) {
            cutout_offset_x = offset_x + b_tool_bottom_chamfer_height;
            cutout_offset_y = offset_y + b_tool_bottom_chamfer_height;
            adjust_magnet_center = magnet_center_offset - b_tool_bottom_chamfer_height;
            difference() {
                translate([-cutout_offset_x, -cutout_offset_y, -extra_height]) cube([cutout_offset_x*2, cutout_offset_y*2, extra_height]);
                four_directions(number_of_magnets) {
                    translate([-offset_x+adjust_magnet_center, -offset_y+adjust_magnet_center, -extra_height]) union() {
                        plate_radius = Magnet_Radius_in_mm + magnet_border;
                        cylinder(h=extra_height,r=plate_radius);
                        translate([-magnet_center_offset, -magnet_center_offset]) {
                            cube([magnet_center_offset, magnet_center_offset + plate_radius, extra_height]);
                            cube([magnet_center_offset + plate_radius, magnet_center_offset, extra_height]);
                        }
                    }
                }
            }
            
            four_directions(number_of_magnets) translate([0, 0, -Magnet_Height_in_mm-magnet_strength_top]) {
                rotation = offset_x == offset_y ? 45 : offset_x > offset_y ? 0 : 90;
                translate([-offset_x+adjust_magnet_center, -offset_y+adjust_magnet_center]) rotate([0, 0, rotation]) {
                    // main magnet cutout
                    hull() {
                        // main hole
                        cylinder(h=Magnet_Height_in_mm,r=Magnet_Radius_in_mm);
                        // cutout for inserting the magnet
                        translate([max(offset_x, offset_y), 0]) cylinder(h=Magnet_Height_in_mm,r=Magnet_Radius_in_mm);
                    }
                    // magnet removal slot
                    translate([0, 0, -magnet_strength_bottom]) hull() {
                        translate([-Magnet_Radius_in_mm, -magnet_removal_slot_radius]) cube([magnet_removal_slot_radius,magnet_removal_slot_radius*2,Magnet_Height_in_mm+magnet_strength_bottom]);
                        translate([-magnet_removal_slot_extend, 0]) cylinder(h=Magnet_Height_in_mm+magnet_strength_bottom,r=magnet_removal_slot_radius);
                    }
                }
            }
        }
    }
}
module interlock_cutting_tool_left(start_tab_amount, end_tab_amount, units) {
    gridplates_cutting_tool_common(start_tab_amount, end_tab_amount, units, gridplates_right_polyline_data(), -1);
}
module interlock_cutting_tool_right(start_tab_amount, end_tab_amount, units) {
    gridplates_cutting_tool_common(start_tab_amount,end_tab_amount,units,gridplates_left_polyline_data(),1);
}
module interlock_cutting_tool_back(start_tab_amount, end_tab_amount, units) { rotate([0,0,-90]) interlock_cutting_tool_left(start_tab_amount, end_tab_amount, units); }
module interlock_cutting_tool_front(start_tab_amount, end_tab_amount, units) { rotate([0,0,-90]) interlock_cutting_tool_right(start_tab_amount, end_tab_amount, units); }
module gridplates_cutting_tool_profile(start_tab_amount, end_tab_amount, units, base_polyline, direction) {
    gridplates_base_profile=tesselate_and_adjust_gridplates_profile(base_polyline);
    full_tab_profile=full_profile(gridplates_base_profile);
    start_profile=start_tab_amount==0?upper_butt_profile(direction):(start_tab_amount<1?upper_half_profile(gridplates_base_profile):full_tab_profile);
    end_profile=end_tab_amount==0?lower_butt_profile(direction):(end_tab_amount<1?lower_half_profile(gridplates_base_profile):full_tab_profile);
    translated_end_profile=y_translate_points(end_profile,Base_Unit_Width_Depth*units);
    repeated=repeat_profile(full_tab_profile,floor(units-0.5),Base_Unit_Width_Depth,Base_Unit_Width_Depth);
    x_ext=gridplates_tool_extent_allowance*direction;
    down_ext=start_profile[0]+[0,-Base_Unit_Width_Depth-max_margin];
    up_ext=translated_end_profile[len(translated_end_profile)-1]+[0,Base_Unit_Width_Depth+max_margin];
    start_ext=[x_ext,down_ext[1]];
    end_ext=[x_ext,up_ext[1]];
    polygon([start_ext,down_ext,each start_profile,each repeated,each translated_end_profile,up_ext,end_ext,[end_ext[0],start_ext[1]]]);
}
module gridplates_cutting_tool_common(start_tab_amount, end_tab_amount, units, base_polyline, direction) {
    linear_extrude(height=cutting_tool_height, center=true) gridplates_cutting_tool_profile(start_tab_amount, end_tab_amount, units, base_polyline, direction);
}
module bottom_chamfer_cutter(units) {
    total_overshoot=max_margin+cut_overshoot;side_length=Bottom_Edge_Chamfer_in_mm+cut_overshoot*2;extrude_length=units*Base_Unit_Width_Depth+total_overshoot*2;
    translate([-cut_overshoot,-total_overshoot,-cut_overshoot]) rotate([-90,0,0]) linear_extrude(height=extrude_length) polygon(points=[[0,0],[0,-side_length],[side_length,0]]);
}
module screw_hole_cutter() {
    // Use a generous fixed height centered around z=0 to ensure hole cuts through
    // regardless of any height modifications (magnets, solid base, weighted base, etc.)
    // 50mm centered means it extends from -25mm to +25mm which covers any baseplate
    screw_hole_height = 50;
    translate([0, 0, -screw_hole_height/2])
        cylinder(d = Screw_Hole_Diameter, h = screw_hole_height, $fn = 24);
    // Countersink on top for flush-mount flat-head screws
    // Cone tapers from large (top) to small (bottom) at the baseplate surface
    if (Enable_Countersink) {
        translate([0, 0, b_total_height - Countersink_Depth])
            cylinder(d1 = Screw_Hole_Diameter, d2 = Countersink_Diameter, h = Countersink_Depth + cut_overshoot, $fn = 24);
    }
}

module emboss_plate_number_cutter(number, plate_width_units, plate_depth_units) {
    if (Enable_Numbering && plate_width_units > 1) {
        use_vertical = (number >= 10);
        y_center_pos = (plate_depth_units * Base_Unit_Width_Depth) / 2;
        translate([Base_Unit_Width_Depth, y_center_pos, -cut_overshoot]) {
            linear_extrude(height = Number_Depth + cut_overshoot * 2) {
                mirror([1, 0, 0]) { 
                    if (use_vertical) {
                        first_digit = floor(number / 10);
                        second_digit = number % 10;
                        translate([0, Number_Size * 0.6, 0])
                            text(str(first_digit), size=Number_Size, font="Liberation Sans:style=Bold", halign="center", valign="center");
                        translate([0, -Number_Size * 0.6, 0])
                            text(str(second_digit), size=Number_Size, font="Liberation Sans:style=Bold", halign="center", valign="center");
                    } else {
                        text(str(number), size=Number_Size, font="Liberation Sans:style=Bold", halign="center", valign="center");
                    }
                }
            }
        }
    }
}
module sub_baseplate(x_depth,y_depth,x_start_offset,x_end_offset,y_start_offset,y_end_offset, plate_number) {
    w=x_end_offset-x_start_offset;d=y_end_offset-y_start_offset;is_left=x_start_offset==0;is_right=x_end_offset==units_wide;is_front=y_start_offset==0;is_back=y_end_offset==units_deep;
    r_fl=is_left&&is_front?outer_corner_radius:min_corner_radius;r_bl=is_left&&is_back?outer_corner_radius:min_corner_radius;r_br=is_right&&is_back?outer_corner_radius:min_corner_radius;r_fr=is_right&&is_front?outer_corner_radius:min_corner_radius;
    inner_margin=Interlock_Type==0?-non_gridplates_edge_clearance:tab_extent_allowance;
    m_l=is_left?margin_left:inner_margin;m_b=is_back?margin_back:inner_margin;m_r=is_right?margin_right:inner_margin;m_f=is_front?margin_front:inner_margin;
    difference() { 
        uncut_baseplate(w,d,r_fl,r_bl,r_br,r_fr,m_l,m_b,m_r,m_f);
        if(Interlock_Type>0) {
            front_tab_amount=(is_front&&margin_front<gridplates_min_margin_for_full_tab)?0.5:1;back_tab_amount=(is_back&&margin_back<gridplates_min_margin_for_full_tab)?0.5:1;left_tab_amount=is_left?(margin_left<gridplates_min_margin_for_full_tab?0.5:1):0;right_tab_amount=is_right?(margin_right<gridplates_min_margin_for_full_tab?0.5:1):0;
            if(!is_left) interlock_cutting_tool_left(front_tab_amount,back_tab_amount,d);
            if(!is_right) translate([w*Base_Unit_Width_Depth,0,0]) interlock_cutting_tool_right(front_tab_amount,back_tab_amount,d);
            if(!is_front) interlock_cutting_tool_front(left_tab_amount,right_tab_amount,w);
            if(!is_back) translate([0,d*Base_Unit_Width_Depth,0]) interlock_cutting_tool_back(left_tab_amount,right_tab_amount,w);
        }
        if(Bottom_Edge_Chamfer_in_mm>0) {
            if(is_left) translate([-margin_left,0,0]) bottom_chamfer_cutter(d);
            if(is_right) translate([Base_Unit_Width_Depth*w+margin_right,0,0]) mirror([1,0,0]) bottom_chamfer_cutter(d);
            if(is_front) translate([0,-margin_front,0]) rotate([0,0,-90]) mirror([1,0,0]) bottom_chamfer_cutter(w);
            if(is_back) translate([0,Base_Unit_Width_Depth*d+margin_back,0]) rotate([0,0,-90]) bottom_chamfer_cutter(w);
        }
        if (Corner_Cutout_in_mm > 0) {
            cutter_height = b_total_height + 2 * cut_overshoot;
            cutter_z = -cut_overshoot;
            if (is_left && is_front) translate([-m_l, -m_f, cutter_z]) cylinder(r = Corner_Cutout_in_mm, h = cutter_height);
            if (is_left && is_back) translate([-m_l, d * Base_Unit_Width_Depth + m_b, cutter_z]) cylinder(r = Corner_Cutout_in_mm, h = cutter_height);
            if (is_right && is_back) translate([w * Base_Unit_Width_Depth + m_r, d * Base_Unit_Width_Depth + m_b, cutter_z]) cylinder(r = Corner_Cutout_in_mm, h = cutter_height);
            if (is_right && is_front) translate([w * Base_Unit_Width_Depth + m_r, -m_f, cutter_z]) cylinder(r = Corner_Cutout_in_mm, h = cutter_height);
        }
        // Screw holes at grid intersections (for mounting)
        if (Enable_Screw_Holes) {
            inset = Screw_Hole_Grid_Inset;
            // Use floor() to snap to full grid intersections (handles half-unit fillers correctly)
            full_w = floor(w);
            full_d = floor(d);

            // Detect half-fillers at outer edges (fractional dimension means half-filler present)
            has_right_half = is_right && (w > full_w);
            has_back_half = is_back && (d > full_d);

            // Calculate valid range for screw holes
            // Must stay inset from all edges to avoid dovetails on inner edges
            x_min = inset;
            y_min = inset;
            // For outer edges with half-filler, can extend to the boundary; otherwise stay inset
            x_max = has_right_half ? full_w : (full_w - inset);
            y_max = has_back_half ? full_d : (full_d - inset);

            // Check if we have valid space for any holes
            has_space = (x_max >= x_min) && (y_max >= y_min);

            if (has_space) {
                if (Screw_Hole_Pattern == 0) {
                    // Pattern 0: Corners only
                    has_left_corner = is_left && (is_front || is_back);
                    has_right_corner = is_right && (is_front || is_back);
                    has_front_corner = is_front && (is_left || is_right);
                    has_back_corner = is_back && (is_left || is_right);

                    left_x = x_min * Base_Unit_Width_Depth;
                    right_x = x_max * Base_Unit_Width_Depth;
                    front_y = y_min * Base_Unit_Width_Depth;
                    back_y = y_max * Base_Unit_Width_Depth;

                    if (is_left && is_front) translate([left_x, front_y, 0]) screw_hole_cutter();
                    if (is_left && is_back) translate([left_x, back_y, 0]) screw_hole_cutter();
                    if (is_right && is_back) translate([right_x, back_y, 0]) screw_hole_cutter();
                    if (is_right && is_front) translate([right_x, front_y, 0]) screw_hole_cutter();
                } else {
                    // Pattern 1: All valid intersections (heavy duty mounting)
                    for (xi = [x_min : 1 : x_max]) {
                        for (yi = [y_min : 1 : y_max]) {
                            translate([xi * Base_Unit_Width_Depth, yi * Base_Unit_Width_Depth, 0])
                                screw_hole_cutter();
                        }
                    }
                }
            }
        }
        emboss_plate_number_cutter(plate_number, w, d);
    }
}
module sub_baseplate_from_list(plate, plate_number) { 
    translate(plate_centering_translation(plate)) 
        sub_baseplate(plate[0],plate[1],plate[2],plate[3],plate[4],plate[5], plate_number); 
}
module v_mirrored_base_plate(plate, plate_number) { 
    if(Mirror_Vertically) mirror([0,1,0]) 
        sub_baseplate_from_list(plate, plate_number); 
    else 
        sub_baseplate_from_list(plate, plate_number); 
}
module mirrored_base_plate(plate, plate_number) { 
    if(Mirror_Horizontally) mirror([1,0,0]) 
        v_mirrored_base_plate(plate, plate_number); 
    else 
        v_mirrored_base_plate(plate, plate_number); 
}

// --- Final Assembly ---
module assemble_and_number() {
    for (plate = plates) {
        // Correct Top-to-Bottom, Right-to-Left numbering by calculating each plate's rank.
        // This logic compares each plate's physical top edge (y_end) and start position (x_start)
        // to all other plates to determine its place in the sequence.
        
        current_x_start = plate[2]; // x_start_offset in grid units
        current_y_end   = plate[5]; // y_end_offset represents the TOP edge

        // 1. Count plates whose TOP EDGE is physically *higher* than this one's.
        plates_in_rows_above = len([ for (p = plates) if (p[5] > current_y_end) 1 ]);

        // 2. Count plates in the *same visual row* (identical top edge) but further to the *right*.
        plates_to_the_right = len([ for (p = plates) if (p[5] == current_y_end && p[2] > current_x_start) 1 ]);
        
        // 3. The final number is the sum of these counts + 1 (for the plate itself).
        plate_number = plates_in_rows_above + plates_to_the_right + 1;

        if (Enable_3MF_Export_Mode) {
            mirrored_base_plate(plate, plate_number);
        } else {
            translate(overall_centering_translation(plate))
                mirrored_base_plate(plate, plate_number);
        }
    }
}

assemble_and_number();
