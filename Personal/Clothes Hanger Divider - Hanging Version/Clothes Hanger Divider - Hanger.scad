/* [Rod Parameters] */
Rod_Type = "round"; // [round:Round Rod, rectangular:Rectangular Rod]
// Diameter of the round rod (only used when Rod_Type is "round")
Rod_Diameter = 32; // [3:0.5:100]
// Width of the rectangular rod (only used when Rod_Type is "rectangular")
Rod_Width = 15; // [3:0.5:100]
// Height of the rectangular rod (only used when Rod_Type is "rectangular")
Rod_Height = 30; // [3:0.5:100]
// Extra clearance added to the rod hole for an easier fit
Rod_Tolerance = 0.2; // [0:0.05:2]


/* [Hanger Parameters] */
// Z thickness of the hanger body
Hanger_Thickness = 3; // [0.5:0.2:20]
// Rounding of the outer hanger corners
Hanger_Rounding = 5; // [0:0.5:50]
// Mirror text onto the back face of the hanger (forces all text to be debossed on both faces)
Mirror_Labels = false; // [true, false]

/* [Top Label Section] */
// Height of the label section area from the top of the hanger down to the top of the rod hole
Label_Top_Height = 50; // [5:0.5:150]
Label_Top_Text_Line_1 = "TOPS";
Label_Top_Text_Line_2 = "";
Label_Top_Text_Line_3 = "";
Label_Top_Text_Size = 10; // [1:0.5:50]
Label_Top_Text_Font = "Avenir Next Condensed"; // ["American Typewriter", "Andale Mono", "Arial", "Avenir", "Avenir Next Condensed", "Baskerville", "Copperplate", "Geneva", "Georgia", "Liberation Mono", "Menlo", "Times New Roman", "Courier New", "Comic Sans MS"]
Label_Top_Text_Style = "Bold"; // [Regular, Bold, Italic, "Bold Italic"]
Label_Top_Text_Depth = 1.2; // [0.1:0.1:5]
// If > 0, text protrudes above the label surface by this amount; if 0, text is debossed into the label. Ignored when Mirror_Labels is true (always debossed).
Label_Top_Text_Extrusion = 0; // [0:0.1:5]
// Vertical spacing factor between lines (multiplied by font size)
Label_Top_Text_Line_Spacing = 1.25; // [1:0.05:3]
// Horizontal alignment of the label text within the label
Label_Top_Text_Alignment = "edge"; // [center:Center, edge:Edge]
// Inset from the free edge of the label when Label_Top_Text_Alignment is "edge"
Label_Top_Text_Edge_Margin = 4; // [0:0.5:50]

/* [Bottom Label Section] */
// Height of the label section area from the bottom of the rod hole to the bottom of the hanger
Label_Bottom_Height = 50; // [5:0.5:150]
Label_Bottom_Text_Line_1 = "";
Label_Bottom_Text_Line_2 = "";
Label_Bottom_Text_Line_3 = "";
Label_Bottom_Text_Size = 10; // [1:0.5:50]
Label_Bottom_Text_Font = "Avenir Next Condensed"; // ["American Typewriter", "Andale Mono", "Arial", "Avenir", "Avenir Next Condensed", "Baskerville", "Copperplate", "Geneva", "Georgia", "Liberation Mono", "Menlo", "Times New Roman", "Courier New", "Comic Sans MS"]
Label_Bottom_Text_Style = "Bold"; // [Regular, Bold, Italic, "Bold Italic"]
Label_Bottom_Text_Depth = 1.2; // [0.1:0.1:5]
// If > 0, text protrudes above the label surface by this amount; if 0, text is debossed into the label. Ignored when Mirror_Labels is true (always debossed).
Label_Bottom_Text_Extrusion = 0; // [0:0.1:5]
// Vertical spacing factor between lines (multiplied by font size)
Label_Bottom_Text_Line_Spacing = 1.25; // [0.05:0.05:3]
// Horizontal alignment of the label text within the label
Label_Bottom_Text_Alignment = "edge"; // [center:Center, edge:Edge]
// Inset from the free edge of the label when Label_Bottom_Text_Alignment is "edge"
Label_Bottom_Text_Edge_Margin = 4; // [0:0.5:50]

/* [Side Label Section] */
// Width of the label section area from the right edge of the rod hole to the right edge of the hanger
Label_Side_Width = 50; // [5:0.5:150]
Label_Side_Text_Line_1 = "";
Label_Side_Text_Line_2 = "";
Label_Side_Text_Line_3 = "";
Label_Side_Text_Size = 10; // [1:0.5:50]
Label_Side_Text_Font = "Avenir Next Condensed"; // ["American Typewriter", "Andale Mono", "Arial", "Avenir", "Avenir Next Condensed", "Baskerville", "Copperplate", "Geneva", "Georgia", "Liberation Mono", "Menlo", "Times New Roman", "Courier New", "Comic Sans MS"]
Label_Side_Text_Style = "Bold"; // [Regular, Bold, Italic, "Bold Italic"]
Label_Side_Text_Depth = 1.2; // [0.1:0.1:5]
// If > 0, text protrudes above the label surface by this amount; if 0, text is debossed into the label. Ignored when Mirror_Labels is true (always debossed).
Label_Side_Text_Extrusion = 0; // [0:0.1:5]
// Vertical spacing factor between lines (multiplied by font size)
Label_Side_Text_Line_Spacing = 1.25; // [0.05:0.05:3]
// Horizontal alignment of the label text within the label
Label_Side_Text_Alignment = "edge"; // [center:Center, edge:Edge]
// Inset from the free edge of the label when Label_Side_Text_Alignment is "edge"
Label_Side_Text_Edge_Margin = 4; // [0:0.5:50]


/* [Rod Clip Parameters] */
// Distance between the left edge of the hanger and the left rod hold edge
Rod_Clip_Depth = Label_Side_Width; // [1:0.5:50]
// The width of the Rod Clip opening on the front face of the hanger (should be less than rod size for snap fit)
Rod_Clip_Opening_Width = 10; // [1:0.5:50]


$fn = 64;

// =============================================================================
// Derived values
// =============================================================================

// Rod bounding box (the size of the rod hole BEFORE tolerance, used for layout).
rod_box_w = (Rod_Type == "round") ? Rod_Diameter : Rod_Width;
rod_box_h = (Rod_Type == "round") ? Rod_Diameter : Rod_Height;

// Rod hole dimensions including clearance tolerance
rod_hole_w = rod_box_w + 2 * Rod_Tolerance;
rod_hole_h = rod_box_h + 2 * Rod_Tolerance;

// Overall hanger dimensions
hanger_w = Rod_Clip_Depth + rod_box_w + Label_Side_Width;
hanger_h = Label_Top_Height + rod_box_h + Label_Bottom_Height;

// Rod hole position (lower-left corner of the rod bounding box, in hanger coords).
// The hanger is laid out with (0,0) at its lower-left corner.
rod_box_x = Rod_Clip_Depth;
rod_box_y = Label_Bottom_Height;

// Rod hole center
rod_cx = rod_box_x + rod_box_w / 2;
rod_cy = rod_box_y + rod_box_h / 2;

// Width of the snap-in slot on the left edge of the hanger that opens into the rod hole.
clip_slot_w = Rod_Clip_Opening_Width;

// Epsilon for clean boolean operations
EPS = 0.01;

// =============================================================================
// 2D outline modules
// =============================================================================

// Outer hanger outline (without the clip slot or rod hole) -- a rounded rectangle.
// Uses inflate/deflate offsetting to round only the outer corners.
module hanger_outline_2d() {
    if (Hanger_Rounding > 0) {
        offset(r = Hanger_Rounding)
            offset(r = -Hanger_Rounding)
                square([hanger_w, hanger_h], center = false);
    } else {
        square([hanger_w, hanger_h], center = false);
    }
}

// The rod hole 2D shape, positioned at the proper location in hanger coords.
module rod_hole_2d() {
    if (Rod_Type == "round") {
        translate([rod_cx, rod_cy])
            circle(d = rod_hole_w);
    } else {
        translate([rod_box_x - Rod_Tolerance, rod_box_y - Rod_Tolerance])
            square([rod_hole_w, rod_hole_h], center = false);
    }
}

// The clip slot connecting the left edge of the hanger to the rod hole.
// It's a horizontal rectangle whose bottom edge is flush with the bottom of
// the rod hole, so the rod drops in from above and rests on the slot floor.
module clip_slot_2d() {
    slot_y = rod_box_y - Rod_Tolerance;
    // Extend past the rod center so the union with the rod hole is clean.
    slot_x_end = rod_cx + EPS;
    translate([-EPS, slot_y])
        square([slot_x_end + EPS, clip_slot_w], center = false);
}

// The complete 2D footprint of the hanger (outline minus rod hole minus clip slot).
module hanger_footprint_2d() {
    difference() {
        hanger_outline_2d();
        rod_hole_2d();
        clip_slot_2d();
    }
}

// =============================================================================
// Text modules
// =============================================================================

// Build a multi-line text 2D shape. Lines are laid out with line 1 on top.
// The block is centered vertically on (0,0). halign controls horizontal
// anchoring within the block: "center" centers on x=0, "right" right-aligns
// at x=0, "left" left-aligns at x=0.
module multi_line_text_2d(line1, line2, line3, size, font, style, line_spacing, halign) {
    // Build the font spec used by OpenSCAD text(): "Family:style=Style"
    font_spec = (style == "Regular") ? font : str(font, ":style=", style);

    // Collect non-empty lines in order so line 1 is always on top of the stack
    lines = [
        for (s = [line1, line2, line3]) if (len(s) > 0) s
    ];
    n = len(lines);

    if (n > 0) {
        line_step = size * line_spacing;
        // Center the block vertically on y=0. Top line at +((n-1)/2)*step,
        // each subsequent line at -line_step from the previous.
        for (i = [0 : n - 1]) {
            y_off = ((n - 1) / 2 - i) * line_step;
            translate([0, y_off])
                text(lines[i],
                     size = size,
                     font = font_spec,
                     halign = halign,
                     valign = "center",
                     $fn = $fn);
        }
    }
}

// Compute horizontal text anchor x and halign for a horizontal (top/bottom)
// label that uses the FRONT face's edge convention (edge = right alignment
// at the right edge of the hanger).
// Returns [x_anchor, halign].
function front_horiz_anchor(label_left, label_right, alignment, margin) =
    alignment == "center"
        ? [(label_left + label_right) / 2, "center"]
        : [label_right - margin, "right"];

// =============================================================================
// Per-label 2D text shapes (always for the FRONT face).
//
// Each shape returns a 2D geometry positioned in the hanger's XY plane that
// represents how the text should appear when viewed from the +Z (front) side
// of the hanger. The back-face version is obtained by mirroring this 2D
// shape about the hanger's vertical centerline.
// =============================================================================

// TOP label: horizontal text anchored to the top of the hanger.
// Label_Top_Text_Edge_Margin pushes the text down from the top edge
// (and also insets it from the right edge when the alignment is "edge").
module top_label_text_2d() {
    label_left_x   = 0;
    label_right_x  = hanger_w;

    anchor = front_horiz_anchor(label_left_x, label_right_x,
                                 Label_Top_Text_Alignment,
                                 Label_Top_Text_Edge_Margin);

    n       = num_text_lines(Label_Top_Text_Line_1, Label_Top_Text_Line_2, Label_Top_Text_Line_3);
    block_h = text_block_height(n, Label_Top_Text_Size, Label_Top_Text_Line_Spacing);
    cy      = hanger_h - Label_Top_Text_Edge_Margin - block_h / 2;

    translate([anchor[0], cy])
        multi_line_text_2d(Label_Top_Text_Line_1,
                            Label_Top_Text_Line_2,
                            Label_Top_Text_Line_3,
                            Label_Top_Text_Size,
                            Label_Top_Text_Font,
                            Label_Top_Text_Style,
                            Label_Top_Text_Line_Spacing,
                            anchor[1]);
}

// BOTTOM label: horizontal text anchored to the bottom of the hanger.
// Label_Bottom_Text_Edge_Margin lifts the text up from the bottom edge
// (and also insets it from the right edge when the alignment is "edge").
module bottom_label_text_2d() {
    label_left_x   = 0;
    label_right_x  = hanger_w;

    anchor = front_horiz_anchor(label_left_x, label_right_x,
                                 Label_Bottom_Text_Alignment,
                                 Label_Bottom_Text_Edge_Margin);

    n       = num_text_lines(Label_Bottom_Text_Line_1, Label_Bottom_Text_Line_2, Label_Bottom_Text_Line_3);
    block_h = text_block_height(n, Label_Bottom_Text_Size, Label_Bottom_Text_Line_Spacing);
    cy      = Label_Bottom_Text_Edge_Margin + block_h / 2;

    translate([anchor[0], cy])
        multi_line_text_2d(Label_Bottom_Text_Line_1,
                            Label_Bottom_Text_Line_2,
                            Label_Bottom_Text_Line_3,
                            Label_Bottom_Text_Size,
                            Label_Bottom_Text_Font,
                            Label_Bottom_Text_Style,
                            Label_Bottom_Text_Line_Spacing,
                            anchor[1]);
}

// SIDE label: vertical text running along the right side of the hanger.
// The text is rotated -90 degrees (clockwise when looking from +Z) so the
// top of each letter points toward the +X (right edge) of the hanger, as
// required by the spec.
//
// The side region spans the full HEIGHT of the hanger horizontally to the
// right of the rod hole. After rotation, the text reads from top-to-bottom
// of the hanger.
//
// "Edge" alignment maps to right-alignment in the text's local (un-rotated)
// frame. After -90 degree rotation, the right end of each line lands at
// the BOTTOM of the hanger (this is the analog of "right-aligned" for the
// rotated text -- the trailing end of the reading direction touches the
// free / outer edge).
module side_label_text_2d() {
    label_left_x   = rod_box_x + rod_box_w;
    label_right_x  = hanger_w;
    label_top_y    = hanger_h;
    label_bot_y    = 0;

    // Center of the side region in hanger coords
    // cx = (label_left_x + label_right_x) / 2;
    cx = label_right_x - Label_Side_Text_Size - Label_Side_Text_Edge_Margin; // Anchor the rotation center to the free edge of the side region so the text is properly aligned after mirroring
    cy = (label_top_y + label_bot_y) / 2;

    // Length of the rotated text block (in pre-rotation x, which becomes
    // hanger -y after the rotation). This equals the height of the side
    // region.
    side_len = label_top_y - label_bot_y;

    halign =
        (Label_Side_Text_Alignment == "center") ? "center"
                                                : "right";

    // x_anchor positions the right edge of the pre-rotated text block.
    // For halign="right" with margin m: anchor at +side_len/2 - m so that
    //   after rotate(-90), the right edge of the text (at +x pre-rotation)
    //   maps to -y post-rotation, i.e. side_len/2 - m below the rotation
    //   center -- which becomes the bottom of the hanger plus margin.
    margin = Label_Side_Text_Edge_Margin;
    x_anchor =
        (halign == "right") ? (side_len / 2 - margin)
                            : 0;

    translate([cx, cy])
        rotate([0, 0, -90])
            translate([x_anchor, 0])
                multi_line_text_2d(Label_Side_Text_Line_1,
                                    Label_Side_Text_Line_2,
                                    Label_Side_Text_Line_3,
                                    Label_Side_Text_Size,
                                    Label_Side_Text_Font,
                                    Label_Side_Text_Style,
                                    Label_Side_Text_Line_Spacing,
                                    halign);
}


// SIDE label: vertical text running along the right side of the hanger.
// The text is rotated -90 degrees (clockwise when looking from +Z) so the
// top of each letter points toward the +X (right edge) of the hanger, as
// required by the spec.
//
// The side region spans the full HEIGHT of the hanger horizontally to the
// right of the rod hole. After rotation, the text reads from top-to-bottom
// of the hanger.
//
// "Edge" alignment maps to right-alignment in the text's local (un-rotated)
// frame. After -90 degree rotation, the right end of each line lands at
// the BOTTOM of the hanger (this is the analog of "right-aligned" for the
// rotated text -- the trailing end of the reading direction touches the
// free / outer edge).
module side_label_back_text_2d() {
    label_left_x   = rod_box_x + rod_box_w;
    label_right_x  = hanger_w;
    label_top_y    = hanger_h;
    label_bot_y    = 0;

    // Center of the side region in hanger coords
    // cx = (label_left_x + label_right_x) / 2;
    cx = label_right_x - Label_Side_Text_Size - Label_Side_Text_Edge_Margin; // Anchor the rotation center to the free edge of the side region so the text is properly aligned after mirroring
    cy = (label_top_y + label_bot_y) / 2;
    echo("side label region: left ", label_left_x, " right ", label_right_x, " top ", label_top_y, " bot ", label_bot_y, " cx ", cx, " cy ", cy);
    
    // Length of the rotated text block (in pre-rotation x, which becomes
    // hanger -y after the rotation). This equals the height of the side
    // region.
    side_len = label_top_y - label_bot_y;

    halign =
        (Label_Side_Text_Alignment == "center") ? "center"
                                                : "right";

    // x_anchor positions the right edge of the pre-rotated text block.
    // For halign="right" with margin m: anchor at +side_len/2 - m so that
    //   after rotate(-90), the right edge of the text (at +x pre-rotation)
    //   maps to -y post-rotation, i.e. side_len/2 - m below the rotation
    //   center -- which becomes the bottom of the hanger plus margin.
    margin = Label_Side_Text_Edge_Margin;
    x_anchor =
        (halign == "right") ? (side_len / 2 - margin)
                            : 0;

    echo("hanger_w: ", hanger_w, "  side_len: ", side_len, "  x_anchor: ", x_anchor, " margin: ", margin);
    echo("hanger_h: ", hanger_h, "  label_top_y: ", label_top_y, "  label_bot_y: ", label_bot_y, "  cy: ", cy);
    //-cy/2+Label_Side_Text_Size*Label_Side_Text_Line_Spacing+hanger_w
    translate([-cx, cy])
        rotate([0, 0, 90])
            translate([x_anchor, 0]) // Compensate for the mirroring in mirror_for_back
                multi_line_text_2d(Label_Side_Text_Line_1,
                                    Label_Side_Text_Line_2,
                                    Label_Side_Text_Line_3,
                                    Label_Side_Text_Size,
                                    Label_Side_Text_Font,
                                    Label_Side_Text_Style,
                                    Label_Side_Text_Line_Spacing,
                                    halign);
}

// =============================================================================
// Helpers
// =============================================================================

// Reflect 2D children about the vertical centerline of the hanger. This is
// the generic operation that converts front-face text into the corresponding
// back-face text such that the back-face text reads correctly when the
// hanger is flipped page-style (about the Y axis). Used for the Side label
// and for center-aligned Top/Bottom labels. Top/Bottom labels with "edge"
// alignment use a dedicated construction (see top_label_back_text_2d /
// bottom_label_back_text_2d) so the back-face text ends up LEFT-aligned
// against the back face's left edge.
module mirror_for_back() {
    translate([hanger_w / 2, 0])
        mirror([1, 0, 0])
            translate([hanger_w / 2, 0])
                children();
}

// Back-face geometry for the TOP label.
//
// When the alignment is "center", we just mirror the front geometry about
// the hanger's centerline.
//
// When the alignment is "edge", the back-face text appears LEFT-aligned
// against the LEFT edge of the back face when viewed directly from the -Z
// direction (i.e., the modeling -X side). This places the back text on the
// PHYSICAL EDGE OPPOSITE to the front-face text. The characters are
// mirrored in modeling space so they read correctly when viewed from the
// back (-Z direction).
module top_label_back_text_2d() {
    n       = num_text_lines(Label_Top_Text_Line_1, Label_Top_Text_Line_2, Label_Top_Text_Line_3);
    block_h = text_block_height(n, Label_Top_Text_Size, Label_Top_Text_Line_Spacing);
    cy      = hanger_h - Label_Top_Text_Edge_Margin - block_h / 2;
    if (Label_Top_Text_Alignment == "edge") {
        translate([hanger_w-Label_Top_Text_Edge_Margin, cy])
            mirror([1, 0, 0])
                multi_line_text_2d(Label_Top_Text_Line_1,
                                    Label_Top_Text_Line_2,
                                    Label_Top_Text_Line_3,
                                    Label_Top_Text_Size,
                                    Label_Top_Text_Font,
                                    Label_Top_Text_Style,
                                    Label_Top_Text_Line_Spacing,
                                    "left");
    } else {
        mirror_for_back()
            top_label_text_2d();
    }
}

// Back-face geometry for the BOTTOM label. See top_label_back_text_2d.
module bottom_label_back_text_2d() {
    n       = num_text_lines(Label_Bottom_Text_Line_1, Label_Bottom_Text_Line_2, Label_Bottom_Text_Line_3);
    block_h = text_block_height(n, Label_Bottom_Text_Size, Label_Bottom_Text_Line_Spacing);
    cy      = Label_Bottom_Text_Edge_Margin + block_h / 2;

    if (Label_Bottom_Text_Alignment == "edge") {
        translate([hanger_w-Label_Bottom_Text_Edge_Margin, cy])
            mirror([1, 0, 0])
                multi_line_text_2d(Label_Bottom_Text_Line_1,
                                    Label_Bottom_Text_Line_2,
                                    Label_Bottom_Text_Line_3,
                                    Label_Bottom_Text_Size,
                                    Label_Bottom_Text_Font,
                                    Label_Bottom_Text_Style,
                                    Label_Bottom_Text_Line_Spacing,
                                    "left");
    } else {
        mirror_for_back()
            bottom_label_text_2d();
    }
}

// Returns true if a label section has any non-empty text lines.
function label_has_text(l1, l2, l3) =
    (len(l1) > 0) || (len(l2) > 0) || (len(l3) > 0);

// Number of non-empty lines among the three label slots.
function num_text_lines(l1, l2, l3) =
    ((len(l1) > 0) ? 1 : 0) + ((len(l2) > 0) ? 1 : 0) + ((len(l3) > 0) ? 1 : 0);

// Approximate height of a multi-line text block as laid out by
// multi_line_text_2d(): (n-1) line steps plus one line of cap-height (~size).
function text_block_height(n, size, line_spacing) =
    (n <= 0) ? 0 : (n - 1) * size * line_spacing + size;

has_top_text    = label_has_text(Label_Top_Text_Line_1, Label_Top_Text_Line_2, Label_Top_Text_Line_3);
has_bottom_text = label_has_text(Label_Bottom_Text_Line_1, Label_Bottom_Text_Line_2, Label_Bottom_Text_Line_3);
has_side_text   = label_has_text(Label_Side_Text_Line_1, Label_Side_Text_Line_2, Label_Side_Text_Line_3);

// =============================================================================
// 3D label assembly
// =============================================================================

// Construct a 3D solid that, when SUBTRACTED from the hanger body, debosses
// the given 2D text onto the FRONT face by the specified depth.
module deboss_front(depth) {
    translate([0, 0, Hanger_Thickness - depth])
        linear_extrude(height = depth + EPS, convexity = 4)
            children();
}

// Construct a 3D solid that, when SUBTRACTED from the hanger body, debosses
// the given 2D text onto the BACK face by the specified depth.
module deboss_back(depth) {
    translate([0, 0, -EPS])
        linear_extrude(height = depth + EPS, convexity = 4)
            children();
}

// Construct a 3D solid that, when UNIONED onto the hanger body, embosses
// (raises) the given 2D text on the FRONT face by the specified height.
module emboss_front(height) {
    translate([0, 0, Hanger_Thickness])
        linear_extrude(height = height, convexity = 4)
            children();
}

// =============================================================================
// Final assembly
// =============================================================================

// Determine per-label modes:
//
//   * Mirror_Labels == false:
//     - If extrusion > 0: emboss on front face only, height = extrusion
//     - If extrusion == 0: deboss on front face only, depth = text_depth
//
//   * Mirror_Labels == true:
//     - Always deboss on BOTH faces, depth = text_depth
//     - Per-label extrusion is IGNORED (the spec requires this)
//     - For the Side label and any center-aligned Top/Bottom label, the
//       back-face geometry is the front geometry mirrored about the hanger's
//       vertical centerline so the text reads correctly when the hanger is
//       flipped.
//     - For Top/Bottom labels with "edge" alignment, the back-face text is
//       LEFT-aligned against the back face's LEFT edge (rather than mirrored
//       across the centerline). See top_label_back_text_2d /
//       bottom_label_back_text_2d.

// All FRONT-face debossed text solids unioned together
module front_deboss_all() {
    if (has_top_text && (Mirror_Labels || Label_Top_Text_Extrusion == 0)) {
        deboss_front(Label_Top_Text_Depth)
            top_label_text_2d();
    }
    if (has_bottom_text && (Mirror_Labels || Label_Bottom_Text_Extrusion == 0)) {
        deboss_front(Label_Bottom_Text_Depth)
            bottom_label_text_2d();
    }
    if (has_side_text && (Mirror_Labels || Label_Side_Text_Extrusion == 0)) {
        deboss_front(Label_Side_Text_Depth)
            side_label_text_2d();
    }
}

// All BACK-face debossed text solids unioned together (only when mirrored)
module back_deboss_all() {
    if (Mirror_Labels) {
        if (has_top_text) {
            deboss_back(Label_Top_Text_Depth)
                top_label_back_text_2d();
        }
        if (has_bottom_text) {
            deboss_back(Label_Bottom_Text_Depth)
                bottom_label_back_text_2d();
        }
        if (has_side_text) {
            deboss_back(Label_Side_Text_Depth)
                // side_label_back_text_2d();
                mirror_for_back()
                    side_label_back_text_2d();
        }
    }
}

// All FRONT-face embossed (raised) text solids unioned together
module front_emboss_all() {
    if (!Mirror_Labels) {
        if (has_top_text && Label_Top_Text_Extrusion > 0) {
            emboss_front(Label_Top_Text_Extrusion)
                top_label_text_2d();
        }
        if (has_bottom_text && Label_Bottom_Text_Extrusion > 0) {
            emboss_front(Label_Bottom_Text_Extrusion)
                bottom_label_text_2d();
        }
        if (has_side_text && Label_Side_Text_Extrusion > 0) {
            emboss_front(Label_Side_Text_Extrusion)
                side_label_text_2d();
        }
    }
}

// The base flat hanger body with rod hole and clip slot.
module hanger_body() {
    linear_extrude(height = Hanger_Thickness, convexity = 4)
        hanger_footprint_2d();
}

module hanger() {
    // Maximum embossing height across all labels (for clipping embossed text)
    max_emboss_height = max(
        Mirror_Labels ? 0 : Label_Top_Text_Extrusion,
        Mirror_Labels ? 0 : Label_Bottom_Text_Extrusion,
        Mirror_Labels ? 0 : Label_Side_Text_Extrusion
    );

    union() {
        // Body with debossed text removed from front and (if mirrored) back face
        difference() {
            hanger_body();
            front_deboss_all();
            back_deboss_all();
        }
        // Embossed text on the front face, clipped to the hanger footprint
        // so it never extends past the outer edges or into the rod hole.
        if (max_emboss_height > 0) {
            intersection() {
                front_emboss_all();
                translate([0, 0, Hanger_Thickness])
                    linear_extrude(height = max_emboss_height + EPS, convexity = 4)
                        hanger_footprint_2d();
            }
        }
    }
}

hanger();
